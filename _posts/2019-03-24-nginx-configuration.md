---
layout: post
title: Nginx로 프록시와 로드밸런싱 사용하기
author: Yangeok
categories: DevOps
comments: true
cover: https://res.cloudinary.com/yangeok/image/upload/v1552491150/logo/posts/nginx.jpg
---

node.js 웹서버 포트를 숨기기 위해 프록시 서버를 사용하고 프록시를 이용해 다른 인스턴스에서 작동하는 각각의 서버를 사용해 서버에 가해지는 부하를 줄이는데 로드밸런싱을 사용합니다. nginx로 로드밸런서를 설정하는 방법을 정리해보고자 합니다.

## 작업환경

- aws lightsail
- linux ubuntu 16.04
- nginx 1.10.3
- nodejs 8.11.3

## 작업순서

우분투 인스턴스를 발급받아서 쉘을 실행하고 아래와 같이 패키지 설치를 합니다.

```sh
# 패키지 업데이트 및 root 권한 실행
apt-get update
sudo su

# 패키지 설치
apt-get install -y nginx
apt-get install -y nodejs
apt-get install -y npm

# node.js 버전 업데이트
npm i -g n
n lts

# node.js 디렉토리 및 생성
cd home
mkdir node-server1 node-server2
cd node-server1 && touch app.js && npm init && npm i -s express
cd node-server2 && touch app.js && npm init && npm i -s express
npm i -g nodemon
```

vim 에디터에서 아래와 같이 서버를 돌릴 수 있는 코드를 작성합니다.

```js
// /test1/app.js
const express = require('express');
const app = express();

app.get('/test1', (req, res) => {
  res.send('PORT 3000 /test1');
});
app.get('/test3', (req, res) => {
  res.send('PORT 3000 /test3');
});
app.get('/', (req, res) => {
  res.send('PORT 3000');
});
app.listen(3000);

// /test2/app.js
const express = require('express');
const app = express();

app.get('/test1', (req, res) => {
  res.send('PORT 3001 /test1');
});
app.get('/test2', (req, res) => {
  res.send('PORT 3001 /test2');
});
app.get('/', (req, res) => {
  res.send('PORT 3001');
});
app.listen(3001);
```

아래와 같이 각각의 서버를 실행합니다.

```sh
# /node-server1
nodemon app.js
[nodemon] 1.18.10
[nodemon] to restart at any time, enter `rs`
[nodemon] watching: *.*
[nodemon] starting `node app.js`
PORT: 3000

# /node-server2
nodemon app.js
[nodemon] 1.18.10
[nodemon] to restart at any time, enter `rs`
[nodemon] watching: *.*
[nodemon] starting `node app.js`
PORT: 3001
```

node.js 웹서버 두개가 잘 돌아가고 있는지 확인하기 위해 아래와 같이 명령어를 입력합니다.

```sh
netstat -tlnp
Active Internet connections (only servers)
Proto Recv-Q Send-Q Local Address           Foreign Address         State       PID/Program name
tcp        0      0 0.0.0.0:22              0.0.0.0:*               LISTEN      1102/sshd
tcp        0      0 0.0.0.0:3306            0.0.0.0:*               LISTEN      1097/mysqld
tcp        0      0 0.0.0.0:80              0.0.0.0:*               LISTEN      2022/nginx -g daemo
tcp6       0      0 :::22                   :::*                    LISTEN      1102/sshd
tcp6       0      0 :::3000                 :::*                    LISTEN      2136/node
tcp6       0      0 :::3001                 :::*                    LISTEN      2250/node
tcp6       0      0 :::80                   :::*                    LISTEN      2022/nginx -g daemo
```

nginx 설정파일을 수정해주어야 합니다. 혹시 모르니 원본을 복사해두고 설정파일에 손을 댑니다.

```sh
cd /etc/nginx/sites-available
cp default default_
vim default

# default
server {
  listen 80;
  server_name _;
  location / {
    proxy_pass http://localhost:3000
  }
}
```

`server_name`값은 인스턴스 ip주소나 `_`를 입력할 수 있습니다.

설정파일을 저장했으면 nginx 프로세스를 아래 명령어중 하나를 입력해서 재시작해야 합니다.

```
/etc/init.d/nginx restart
/etc/init.d/nginx reload
service nginx restart
service nginx reload
systemctl restart nginx
systemctl reload nginx
```

nginx의 실행상태를 보기 위해서는 아래 명령어중 하나를 입력합니다.

```
service nginx status
systemctl status nginx
```

어떤 리눅스 배포판이건 사용할 수 있는 명령어이기 때문에 프로세스를 재시작하는 것보다 더 추천하는 방식은 아래와 같습니다.

```
nginx -s reload
/etc/nginx -s reload
```

재시작 혹은 리로드한 nginx가 잘 돌아가고 있는지 확인하기 위해서 다음과 같이 입력하면 해당 프로세스가 돌아가고 있는지 확인할 수 있습니다.

```sh
ps aux | grep nginx
root      2022  0.0  0.8 125124  4004 ?        Ss   13:02   0:00 nginx: master process /usr/sbin/nginx -g daemon on; master_process on;
www-data  2114  0.0  0.9 125484  4740 ?        S    13:10   0:00 nginx: worker process
root      2355  0.0  0.2  12944  1008 pts/3    S+   13:41   0:00 grep --color=auto nginx
```

프록시서버를 사용하기 위한 세팅이 끝났습니다. 인스턴스 `0.0.0.0:3000`로 요청을 보내지 않고 `0.0.0.0`으로만 요청을 보내도 node.js서버에 접속이 가능해졌습니다. 코드단에서 사용하는 포트를 외부에 공개할 필요가 없어졌습니다. 이제까지 포트 3000번을 쓰는 서버만 외부와 연결을 시켰습니다. 3001번을 쓰는 서버도 외부에 연결시키기 위해서는 upstream 세팅이 필요합니다.

upstream에는 이름을 부여해서 하나 이상의 upstream을 구성할 수 있습니다. proxy_pass의 값을 아래와 같이 바꿀 수 있습니다. 모듈화 시켜버리기.

```sh
# /etc/nginx/sites-available/default
upstream node_proxy {
  server localhost:3000;
  server localhost:3001;
}
server {

  (...)

  location / {
    proxy_pass http://node_proxy;
  }
}
```

upstream에는 여러가지 옵션이 있는데 아무것도 입력하지 않은 기본 옵션은 아래와 같이 응답합니다.

```sh
curl http://0.0.0.0/
PORT 3000
curl http://0.0.0.0/
PORT 3001

(...)
```

계속 번갈아가면서 요청을 분산해서 응답해줍니다. 포트 3000번 서버에는 없는 라우터를 요청한다면 아래와 같이 응답하겠죠.

```sh
curl http://0.0.0.0/test2
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="utf-8">
<title>Error</title>
</head>
<body>
<pre>Cannot GET /test2</pre>
</body>
</html>

curl http://0.0.0.0/test2
PORT 3001 /test2
```

로드밸런싱을 사용하기 위해서는 분산서버 응답이 똑같아야 오류가 나질 않을겁니다.

## 참조

- [Nginx를 사용하여 프록시 서버 만들기](https://velog.io/@jeff0720/2018-11-18-2111-%EC%9E%91%EC%84%B1%EB%90%A8-iojomvsf0n)
- [Linux: Restart Nginx WebServer](https://www.cyberciti.biz/faq/nginx-linux-restart/)
- [nginx 로드 밸런싱 설정 (load balancing)](https://www.lesstif.com/pages/viewpage.action?pageId=35357063)
