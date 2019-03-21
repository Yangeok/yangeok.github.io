---
layout: post
title: Nginx로 웹앱 포트와 실제 포트 연결시켜주기
author: Yangeok
categories: DevOps
comments: true
cover: https://res.cloudinary.com/yangeok/image/upload/v1552491150/logo/posts/nginx.jpg
---

react 서버는 localhost에서 3000번 포트로 돌린다.

실제 리눅스 서버는 000.000.000.000:80이다.

react 코드에 손대지 않고 리눅스 서버 ip를 치고 들어가면

자동으로 react 서버에 연결되도록 하려면

nginx가 필요하다

nginx에서 설정파일에 들어간다

etc/nginx/site-available/default 파일에 접근해

```nginx
http {
    server_name [linux ip address];
    listen [linux port];
    location / {
        proxy_pass [react app ip address]
    }
}
```

포트가 돌아가고 있는지 리눅스에서 확인하려면

`netstat -plnt`로 확인한다.

이렇게 하면 외부에서 바로 접속가능하다.

## 참조

- [Nginx를 사용하여 프록시 서버 만들기](https://velog.io/@jeff0720/2018-11-18-2111-%EC%9E%91%EC%84%B1%EB%90%A8-iojomvsf0n)
