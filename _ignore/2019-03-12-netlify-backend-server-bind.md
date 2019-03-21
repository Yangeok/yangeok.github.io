---
layout: post
title: Netlify에서 api서버 읽어오기
author: Yangeok
categories: DevOps
comments: true
cover: https://res.cloudinary.com/yangeok/image/upload/v1552491150/logo/posts/retlinode.jpg
---

백엔드 api를 불러와야 하는데 proxy가 잘 안됐나 `프론트/백 api`로 불러오더라구요.

https://www.netlify.com/docs/redirects/

를 참조했더니

https://www.snsavage.com/blog/2017/how-to-deploy-a-react-app-with-api-request-proxying.html

와 같이

/public/\_redirect 파일을 만들어 배포하면 된다더군요.

- netlify back-end server 바인딩 방법

  - config/webpack.config.js 수정
  - \_redirects 수정
    - build/\_redirects 가 아닌 static/\_redirects로 작성해야한다.
      - build폴더는 파일 빌드하면 자동으로 삭제된다.
    - `/[원래주소] /[바꿀주소] [상태코드]`: 상태코드를 반드시 작성해야한다.
    - `/[바꿀주소]/:splat`:
      - hashcode 답변 기다리기

- cors:

  - 백엔드 서버에 cors정책을 설치해줘야 한다. Access-Control-Allow-Origin

- redirect:
  - 301: 영구적으로 옮겼을 때 사용한다. 검색엔진 최적화에 좋다.
  - 302: 일시적으로 옮겼을 때 사용한다.
