---
layout: post
title: Azure Function App 배포하기
author: Yangeok
categories: Azure
date: 2022-12-25 14:00
tags: []
cover: https://res.cloudinary.com/yangeok/image/upload/v1671945843/logo/posts/azure-function-app.jpg
---

다음은 ML 파이프라인으로 구현된 모델과 모델 추론을 위한 사용자 데이터를 처리하기 위한 API를 Azure Function App으로 배포한 경험을 공유하고자 작성한 글입니다.

<br>

---

<br>

## API 엔드포인트 설계

ML 모델을 서빙할 API를 설계해야 했는데, 요청 종류에 따라 처리 시간이 천차만별이었습니다. 단건 추론은 몇 초면 끝나지만, 사용자 데이터를 배치로 돌리면 수분 이상 걸리거든요. 그래서 엔드포인트를 짧은 작업과 긴 작업으로 나눴습니다. 짧은 작업은 `POST /predict`로 즉시 응답하고, 긴 작업은 `POST /predict/batch`로 작업 ID만 반환한 뒤 `GET /predict/batch/{job_id}`로 상태를 조회하는 방식입니다.

<br>

---

<br>

## FastAPI로 API 구현

Python이니까 FastAPI를 선택했습니다. 타입 힌트 기반 자동 검증이랑 Swagger 자동 생성이 편하더라구요.

```python
# main.py
from fastapi import FastAPI, BackgroundTasks
from pydantic import BaseModel
import joblib
import uuid

app = FastAPI()
model = joblib.load('model.pkl')

class PredictRequest(BaseModel):
    features: list[float]

class BatchPredictRequest(BaseModel):
    items: list[list[float]]

@app.post('/predict')
def predict(req: PredictRequest):
    result = model.predict([req.features])
    return {'prediction': result[0].tolist()}

@app.post('/predict/batch')
async def predict_batch(req: BatchPredictRequest, background_tasks: BackgroundTasks):
    job_id = str(uuid.uuid4())
    background_tasks.add_task(run_batch, job_id, req.items)
    return {'job_id': job_id}

def run_batch(job_id: str, items: list):
    results = model.predict(items)
    save_results(job_id, results)
```

로컬에서 돌려보면 잘 동작합니다. `BackgroundTasks`가 응답 반환 후에 `run_batch`를 알아서 실행해주니까요. 문제는 이걸 Azure Function App에 올리면서 시작됐습니다.

<br>

---

<br>

## 긴 작업과 짧은 작업 분리

Function App은 HTTP 응답을 반환하면 "이 함수 실행 끝났다"고 판단합니다. Consumption Plan에서는 특히 idle 상태가 되면 인스턴스를 아예 내려버릴 수 있어서, 백그라운드에서 돌고 있던 `run_batch`가 중간에 죽어버리는 케이스가 생겼습니다. 로컬에서는 FastAPI 프로세스가 계속 살아있으니까 백그라운드 태스크가 잘 도는데, Function App은 서버리스라 그 전제가 깨지는거죠.

<br>

---

<br>

## 긴 작업의 백그라운드 처리

결국 `BackgroundTasks`를 포기하고 **Azure Queue Storage**를 도입했습니다. HTTP 트리거 함수에서는 큐에 메시지만 넣고 바로 응답을 반환하고, 별도의 Queue Trigger 함수가 메시지를 꺼내서 실제 배치 작업을 수행하는 구조입니다. 이러면 HTTP 함수는 큐에 메시지 넣고 바로 끝나니까 프로세스가 죽어도 상관없습니다.

```python
from azure.storage.queue import QueueClient
import json, os

queue_client = QueueClient.from_connection_string(
    os.environ['AzureWebJobsStorage'], 'batch-jobs'
)

@app.post('/predict/batch')
async def predict_batch(req: BatchPredictRequest):
    job_id = str(uuid.uuid4())
    message = json.dumps({'job_id': job_id, 'items': req.items})
    queue_client.send_message(message)
    return {'job_id': job_id}
```

<br>

---

<br>

## Azure Function App으로 래핑

FastAPI를 Function App에 올리는 방법은 생각보다 간단합니다. `azure-functions` 패키지의 ASGI 미들웨어가 FastAPI 앱을 HTTP Trigger로 래핑해줍니다.

```python
# function_app.py
import azure.functions as func
from main import app

function_app = func.AsgiFunctionApp(
    app=app,
    http_auth_level=func.AuthLevel.ANONYMOUS
)
```

`host.json`은 이정도면 됩니다.

```json
{
  "version": "2.0",
  "extensionBundle": {
    "id": "Microsoft.Azure.Functions.ExtensionBundle",
    "version": "[4.*, 5.0.0)"
  }
}
```

<br>

---

<br>

## 백그라운드 처리 불가능한 부분 FastAPI에서 별도 함수 분리

Queue Trigger 함수를 같은 Function App 프로젝트 안에 추가합니다. 큐에 메시지가 들어오면 자동으로 실행되는 방식이라 별도로 트리거를 걸 필요가 없습니다. 큐에 메시지가 남아있는 한 Function App 인스턴스가 내려갔다 올라와도 메시지를 다시 처리하기때문에 작업 유실이 없습니다.

```python
@function_app.queue_trigger(
    arg_name='msg',
    queue_name='batch-jobs',
    connection='AzureWebJobsStorage'
)
def process_batch(msg: func.QueueMessage):
    data = json.loads(msg.get_body().decode('utf-8'))
    job_id = data['job_id']
    items = data['items']

    results = model.predict(items)
    save_results(job_id, results)
```

<br>

---

<br>

## 도커라이징 및 Azure Container Registry를 통한 배포 (Premium Plan)

ML 모델을 포함한 커스텀 런타임을 사용하려면 Docker 이미지를 직접 빌드해서 올려야 했습니다. 커스텀 컨테이너 이미지를 쓰려면 **Premium Plan(EP1 이상)** 이 필요합니다. Consumption Plan에서는 지원하지 않습니다.

Dockerfile은 Azure Functions 공식 베이스 이미지를 써야 합니다. 일반 Python 이미지를 쓰면 Function App 런타임이 없어서 동작하지 않거든요.

```dockerfile
FROM mcr.microsoft.com/azure-functions/python:4-python3.10

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . /home/site/wwwroot
```

빌드한 이미지를 ACR에 올리고 Function App에 연결하는 흐름입니다.

```sh
az acr login --name <registry-name>
docker build -t <registry-name>.azurecr.io/<image-name>:latest .
docker push <registry-name>.azurecr.io/<image-name>:latest

az functionapp config container set \
  --name <function-app-name> \
  --resource-group <resource-group> \
  --docker-custom-image-name <registry-name>.azurecr.io/<image-name>:latest \
  --docker-registry-server-url https://<registry-name>.azurecr.io
```

ACR에 새 이미지를 푸시하면 Function App이 자동으로 Pull해서 배포됩니다. GitHub Actions에서 ACR 푸시까지만 해주면 나머지는 Azure가 알아서 처리해줍니다.

<br>

---

<br>

## 한계점 및 대안

### GPU를 사용하는 경우는 AKS로 GPU 클러스터 생성

Azure Function App은 GPU 인스턴스를 지원하지 않습니다. 처음에는 Function App 하나로 다 해결하고 싶었는데, GPU 모델이 들어오면서 포기했습니다. CPU로 추론 가능한 모델은 Function App으로, GPU가 필요한 딥러닝 모델은 **AKS<sup>Azure Kubernetes Service</sup>** GPU 노드풀이나 **Azure Machine Learning Online Endpoint**로 나눠서 운영하는 구조로 갔습니다.

### 긴 작업을 더 작은 단위의 함수로 분리

배치 추론을 하나의 함수에서 다 처리하면 Premium Plan 기본 타임아웃인 30분에 걸릴 수 있습니다. 데이터가 많아지면 아이템 단위로 쪼개서 큐 메시지로 처리하거나, **Azure Durable Functions**의 Fan-out/Fan-in 패턴을 쓰는게 안정적입니다. 각 아이템을 개별 Activity 함수로 분리하면 병렬로 처리되면서 타임아웃 없이 대규모 배치도 돌릴 수 있고, Orchestrator가 진행상황을 관리해줘서 중간에 실패해도 재시도가 됩니다.

```python
# Durable Functions Fan-out/Fan-in 예시
import azure.durable_functions as df

@df.orchestrator
def orchestrator(context: df.DurableOrchestrationContext):
    items = context.get_input()
    tasks = [context.call_activity('predict_single', item) for item in items]
    results = yield context.task_all(tasks)
    return results
```
