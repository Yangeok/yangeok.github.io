---
layout: post
title: Koa.js JWT 두가지 방법으로 전송하기
author: Yangeok
categories: Node.js
comments: true
# tags: ['jwt', 'token', 'json', 'web', 'transfer']
cover: https://res.cloudinary.com/yangeok/image/upload/v1552474849/logo/posts/jwt.jpg
---

## 헤더에 실어서 보내는 방법

```js
ctx.set(name, value);
```

- `name`: 헤더 이름
- `value`: 토큰 값을 여기에 작성한다.

응답헤더에 토큰을 넣어 보내게 되면 브라우저에서 헤더에 있는 토큰을 가져다 브라우저의 localStorage로 집어넣어 토큰을 유지시킵니다. 이후 토큰의 유효기한이 되기 전에 요청헤더에 토큰을 넣어 서버에 보내면 디코딩후 유효성 검증을 거친 후 토큰을 새로 발급해 앞선 방법과 똑같은 방식으로 브라우저로 토큰을 전달합니다.

## 쿠키에 넣어 보내는 방법

```js
ctx.cookies.set(name, value, [options]);
```

- `name`: 쿠키 이름
- `value`: 토큰 값을 여기에 작성한다.
- `options`:
  - `httpOnly`: `true`를 작성한다면 브라우저에서 `document`객체에 접근할 수 없게 된다.
  - `maxAge`: 토큰의 유효기간을 `d`, `h`, `m`, `s`등을 사용해서 작성할 수 있다. npm 패키지 `moment`에 의존해서 파싱한다.

브라우저에서 토큰을 사용할 수 없기 떄문에 쿠키를 사용하는 로직은 서버에서 마련해야 합니다.
