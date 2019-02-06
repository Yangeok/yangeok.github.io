---
layout: post
title: Passport.js를 사용한 구글 로그인
author: Yangeok
categories: Node.js
comments: true
# tags: ['OAuth', 'passport.js', 'passport']
cover: 'https://drive.google.com/open?id=1SHwmxE7z3-kZof0sgPMW0rHUldn3gIKk'
---

작업환경은 NodeJS, KoaJS, koa-passport, [passport-google-oauth-jwt](https://www.npmjs.com/package/passport-google-oauth-jwt)입니다.

`passport-google-oauth-jwt`모듈 가이드에 따라 작성을 했습니다. 제 개인적인 패스포트에 대한 이해는 이렇습니다.

1. 다른 사이트에서(예를 들어 구글) 로그인된 유저의 정보를 가져온다.
2. db에 유저의 회원정보가 있나 조회한다.
3. 있으면 로그인시킨다.
4. 없으면 가져온 유저의 정보로 회원 생성을 시킨다.
5. 생성시킨후 로그인시킨다.
6. 로그인할때 세션에 정보를 저장시킨다. 혹은 쿠키에 jwt를 담아 저장한다.

로컬 로그인에 jwt를 사용하고 있기 때문에 세션보다는 jwt를 사용해보고 싶어서 위 모듈을 받아 사용했습니다. 좀 더 찾아봐야 할 문제지만 그냥 `passport`모듈에 페이스북이든 구글이든 전략을 쓰고 거기다 jwt를 붙일 수 있나보더군요. 하지만 눈앞에 결과물이 금방 나타날텐데 그걸 외면하고 다른길로 돌아가기 힘들 것같아 일단은 jwt까지 같이 붙어있는 모듈을 설치해서 사용했습니다. 원리는 모릅니다 아직.

```js
// app.js
const Koa = require('koa');
const app = new Koa();

const passport = require('koa-passport');
const session = require('koa-session');

app.use(session());
app.use(passport.initialize());
app.use(passport.session());
```

여기까지가 기본설정입니다.

```js
// route.js
app.get('/auth/google', async (ctx, next) => {
  passport.authenticate('google-oauth-jwt', {
    callbackUrl: `http://localhost:${env.PORT}${env.GOOGLE_CALLBACK}`,
    scope: 'email'
  })(ctx, next);
});

app.get('/auth/google/callback', async (ctx, next) => {
  passport.authenticate('google-oauth-jwt', {
    callbackUrl: `http://localhost:${env.PORT}${env.GOOGLE_CALLBACK}`
  })(ctx, next);

  ctx.redirect('/');
});
```

라우트를 작성해줍니다. 구글계정에서는 이메일만 가져오기로 합니다.

```js
//  passport.js
const GoogleOauthJWTStrategy = require('passport-google-oauth-jwt').GoogleOauthJWTStrategy;
passport.use(new GoogleOauthJWTStrategy({
    clientId: env.GOOGLE_ID,
    clientSecret: env.GOOGLE_SECRET
}, async (accesstoken, loginInfo, refreshToken, done) => {
    done(null, {
        email: loginInfo.email
    });
```

구글ID라던지 시크릿키는 `.env`파일에 따로 담아 로드했습니다. 구글 개발자 페이지에 등록된 `clientId`와 `clientSecret`을 통해 계정 정보를 확인합니다. `/auth/google`에서 콜백된 구글 로그인 페이지가 뜰겁니다. 여기서 계정을 선택하면 아까 위에 있던 코드중 콜백 함수가 실행될 차례입니다.

```js
async (accesstoken, loginInfo, refreshToken, done) => {
    done(null, {
        email: loginInfo.email
    });
```

인자가 들어있는 순서도 다르고 이름들이 passport 모듈마다 다르더라구요. `accessToken`은 토큰 정보를 보여주는데 보통 jwt 형식으로 안되있네요. 뭔가 이상해짐을 느낍니다. jwt는 `.`를 기준으로 3부분으로 나뉘어있는데 말입니다. 다음으로 `loginInfo`는 구글 사용자 정보를 가져옵니다.

```js
{
	"iss": 'accounts.google.com',
	"azp": 'SECRET.apps.googleusercontent.com',
	"aud": 'SECRET.apps.googleusercontent.com',
	"sub": 'ID',
	"email": 'yangwookee@gmail.com',
	"email_verified": true,
	"at_hash": 'HASH_VALUE',
	"iat": 1543542243,
	"exp": 1543545843
}
```

여기서 우리가 필요한 정보는 `loginInfo.email`입니다. 기억하고 있어야합니다. `refreshToken`는 `undefined`가 뜨네요. `done`은 콜백 함수 자체를 말하는데요. 혹시 틀렸다면 댓글 바랍니다.

```js
passport.serializeUser((user, done) => {
  done(null, user);
});
passport.deserializeUser((obj, done) => {
  done(null, obj);
});
```

아까 말했던 `loginInfo.email`가 `.serializeUser()`메서드의 콜백의 인자 `user`로 들어갑니다. `.done()` 메서드를 통해 `.deserialize()`의 콜백의 인자 `obj`로 들어갑니다. 이 과정을 통해
로그인이 다되고 `ctx.redirectt('/')`을 통해 루트로 리디렉션을 시킵니다.

추후 코드작성하다가 막히거나 그것을 해결한게 있으면 추가로 작성하겠습니다.
