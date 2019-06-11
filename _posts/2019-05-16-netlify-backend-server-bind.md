---
layout: post
title: Netlify에서 api서버 정보 읽어오기
author: Yangeok
categories: DevOps
comments: true
cover: https://res.cloudinary.com/yangeok/image/upload/v1552491150/logo/posts/netlinode.jpg
---

netlify는 정적페이지를 정말 편하게 배포해주는 서비스입니다. 대신에 프론트와 백에서 설정을 하나씩 해줘야 합니다. 그렇지 않으면 오류가 날거에요.

---

## 작업환경

- netlify
- node.js

---

## 작업순서

### 프론트엔드

그냥 `create-react-app`에서는 그저 `package.json`에서 proxy설정만 해주면 알아서 api서버에 요청을 보낼때 설정값이 바인딩됩니다. 하지만 netlify에 배포된 환경에서는 그것만으로는 부족합니다.

`_redirects`과 `_headers`이 있습니다. `_redirects`를 먼저 살펴보겠습니다. 아래와 같은 예제가 있습니다.

```sh
# Redirects from what the browser requests to what we serve
/home              /
/blog/my-post.php  /blog/my-post
/news              /blog
/google            https://www.google.com
```

사용자가 netlify에 요청하는 url이 `/home`이라면 `/`로 redirect되겠죠. 이것을 이용해서 할 수 있는 것들은 간단히 문서를 읽어본 바로는 아래와 같습니다. 자세한 내용은 [공식문서](https://www.netlify.com/docs/redirects/)를 확인해보세요.

- 존재하지 않는 url을 요청한다면 404 페이지로 연결시킬 수 있다.
- api서버에서 json데이터를 가져올 수 있다.
- 헤더에서 지역정보를 가져와 해당 국가 언어로 페이지를 redirect시킬 수 있다.
- 회원가입, 로그인에 필요한 http 상태를 사용할 수 있게 해준다.

api서버에서 json데이터를 가져올 수 있도록 아주아주 간단한 세팅을 할겁니다.

```sh
/* https://api.com/:splat 301
```

`/[원래주소] /[바꿀주소] [상태코드]`의 순서로 작성합니다. 내 페이지의 모든 라우터를 `http://api.com/*`으로 redirect를 시킵니다. 여기서 `:splat`은 `*`과 같은 의미로 통합니다.

참고로 `301`은 url을 영구적으로 옮겼을 때 사용하고, 검색엔진 최적화에 좋습니다. `302` 일시적으로 옮겼을 때 사용합니다.

---

### 백엔드

api서버에서도 해줘야 할 일이 있습니다. 프레임워크 없이 서버를 구동한다면 헤더에 `{ Access-Control-Allow-Origin: * }`를 직접 추가시켜줘야겠지만 CORS 문제를 아주 간단하게 미들웨어 하나로 쉽게 해결할 수 있습니다. 다음과 같이 설치합니다.

```sh
# koa
yarn add koa2-cors

# express
yarn add cors
```

코드단에 다음과 같이 작성하고 배포한 후에 확인해보면 netlify 서버와 api서버의 통신이 잘되는 것을 확인할 수 있습니다.

```js
// koa
const Koa = require('koa');
const cors = require('koa2-cors');

const app = new Koa();
app.use(cors());

// express
const express = require('express');
const cors = require('cors');
const app = express();

app.use(cors());
```

---

## 참조

- [Redirect & Rewrite Rules](https://www.netlify.com/docs/redirects/)
- [How to Deploy a React App with API Request Proxying](https://www.snsavage.com/blog/2017/how-to-deploy-a-react-app-with-api-request-proxying.html)
