---
layout: post
title: '도커 빌드중 에러 메시지가 뜰때 해결 방법'
author: Yangeok
categories: DevOps
comments: true
# tags: ['docker', 'build', 'error', 'err', 'msg', 'message']
cover: 'http://drive.google.com/uc?export=view&id=1bDu_i5U5_tOEOf6BLhxy4p1H4mAZnq2A'
---

작업환경은 윈도우10, VSC를 이용했습니다. 도커 버전은 다음과 같습니다.

```sh
$ docker version
Client: Docker Engine - Community
 Version:           18.09.0
 API version:       1.39
 Go version:        go1.10.4
 Git commit:        4d60db4
 Built:             Wed Nov  7 00:47:51 2018
 OS/Arch:           windows/amd64
 Experimental:      false

Server: Docker Engine - Community
 Engine:
  Version:          18.09.0
  API version:      1.39 (minimum version 1.12)
  Go version:       go1.10.4
  Git commit:       4d60db4
  Built:            Wed Nov  7 00:55:00 2018
  OS/Arch:          linux/amd64
  Experimental:     false
```

도커 빌드를 하려는데 레이어링 도중에 빌딩이 죽은게 아니라 레이어링도 시작하지도 않았는데 작업이 종료되고 에러 메시지가 떴습니다. 뭔가 이제 단서를 찾을 시간입니다. 에러메시지를 통째로 구글에 검색을 하던가 링크가 있다면 들어가서 확인을 해봅니다.

```sh
$ docker build -t mall .
Sending build context to Docker daemon 250.7MB
Step 1/14 : FROM ubuntu:16.04
Get https://registry-1.docker.io/v2/: net/http: request canceled while waiting
for connection (Client.Timeout exceeded while awaiting headers)
```

우선 링크를 타고 들어가봅니다. 뭔가가 있을 것 같습니다.

```sh
$ curl https://registry-1.docker.io/v2/
{"errors":[{"code":"UNAUTHORIZED","message":"authentication required","detail":null}]}
```

제가 직관적으로 알 수 있었던 것은 인증이 안됐다는 것. 이것을 제외하고는 무슨말인지 이해할 수가 없습니다. 구글에 위의 객체를 넣고 검색해보면 결과가 많이 뜹니다. [깃헙 이슈](https://github.com/moby/moby/issues/32270)로 링크를 타고 들어가니 dns 서버를 `8.8.8.8`로 세팅하란 말이네요. 실행에 옮겨봅니다. 도커 세팅으로 들어갑니다.

![](http://drive.google.com/uc?export=view&id=1gfXaMhpUU8BGXHipijHuS0f0qCHypeqH)

이제 세팅창이 뜰겁니다.

![](http://drive.google.com/uc?export=view&id=1BqdRMDiXvZWtV1KEjlzP8Yu_dWNKsPcx)

네트워크 탭을 선택합니다.

![](http://drive.google.com/uc?export=view&id=1N0ENFr0INh0rHUNMaMrGEbLWL-J3Mk-M)
dns 서버에서 자동으로 설정된 것을 고정으로 바꿔줍니다.

![](http://drive.google.com/uc?export=view&id=10568bxiYktElkABHrGfByt8Lvn9-f5sA)

이렇게 설정을 마치고 나면 아래와 같이 성공적으로 빌드를 끝마칠 수 있게 됩니다.

```sh
Successfully built 951a6bbcaa2e
```

![](http://www.hkn24.com/news/photo/201103/69193_61042_320.jpg)
