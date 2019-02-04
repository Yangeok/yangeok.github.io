---
layout: post
title: 'Koa.js로 가독성 좋게 재작성하기'
author: Yangeok
categories: Node.js
tags: ['RDBM', 'sequelize', 'orm', 'sequelize.js']
cover: 'http://drive.google.com/uc?export=view&id=1tzqWG8SozuBI9BZkjMpkLxG-T84MbHt2'
---

작업환경은 Node.js v8, Koa.js, Sequelize.js(MySQL)입니다. API 작성전 모듈을 작성합니다.

```js
// services/user.js
const Users = require('../db/models').User;
```

먼저 sequelize 폴더에서 `Users`테이블을 가져옵니다. cli를 사용해서 작성했기 때문에 파일명이 자동생성되어 **단수** 로 생성됨을 참고 바랍니다. 테이블이름은 **복수** 입니다.

```js
// services/user.js
const addUser = user => Users.create(user);
const getUserByUserId = userId => Users.findOne({ where: { userId } });
```

간단한 함수를 작성합니다. `addUser`는 `INSERT`문이고, `getUserByUserId`는 `WHERE`조건으로 컬럼 1개만 찾는 sequelize 쿼리입니다. 자세한 문법은 [공식문서](http://docs.sequelizejs.com/)를 참고하세요.

[Express로 하는 HTTP API구현 튜토리얼](https://dev.to/vitaliikulyk/how-to-initialize-multilayer-nodejs-restful-api-with-jwt-auth-and-postgresql-in-3-steps--c8c)을 참고해서 Koa에 맞춰 작성한 API 코드입니다. 코드는 다음과 같습니다:

```js
// routes/auth/auth.controller.js
const userService = require('../services/user');

exports.localJoin = async (ctx) => {
 (...)
};
```

Koa 기본 라우팅에 대한 세팅을 해줍니다. 링크는 참고한 [디렉토리 디자인](https://github.com/vlpt-playground/heurm/tree/master/heurm-server/src/api)입니다.

```js
return userService.getUserByUserId(body.userId || '').then(exists => {
  if (exists) {
    ctx.body = {
      success: false,
      message: `${exists.dataValues.userId} is already registered.`
    };
  }
});
```

아이디가 있는지 없는지 검사한 후에 아이디가 존재하면 `body`에 메시지를 반환하도록 했습니다.

```js
let user = {
  userId: body.userId,
  firstName: body.firstName,
  lastName: body.lastName,
  password: bcrypt.hashSync(body.password, 10)
};

return userService.addUser(user).then(() => {
  ctx.body = {
    success: true,
    password: user.password
  };
});
```

`user`객체를 선언하고, 아까 정의한 `.addUser()`를 사용해 sequelize를 통해 mysql에 데이터를 삽입하는 과정입니다. 성공하면 `body`를 통해 메시지를 반환하죠. 그러니까 아이디 중복 혹은 아이디 생성의 과정입니다. 하지만 위 코드로는 아이디가 중복되면 `body`에 메시지가 떠야하는데, 콘솔에만 `Validation Error`만 뱉어내더라구요. [상태코드](https://ko.wikipedia.org/wiki/HTTP_%EC%83%81%ED%83%9C_%EC%BD%94%EB%93%9C)는 500번이었구요.

뭔가 잘못됨을 알고 혼자 코드를 고쳐본 결과가 다음과 같습니다:

```js
// Previous code 1
exports.localJoin = async ctx => {
  return userService.getUserByUserId(body.userId || '').then(exists => {
    // returns dataValues
    if (exists || '') {
      ctx.body = {
        success: false,
        message: `${exists.dataValues.userId} is already registered.`
      };
    } else {
      let user = {
        userId: body.userId,
        firstName: body.firstName,
        lastName: body.lastName,
        password: bcrypt.hashSync(body.password, 10)
      };

      return userService.addUser(user).then(() => {
        ctx.body = {
          success: true
        };
      });
    }
  });
};
```

만약 아이디가 중복됐다면 `body`를 통해 `"success": false`를 반환하고 아니라면 유저를 생성한 후 `body`에 `"success": true`를 보여주라고 했습니다.

좀만 생각해봐도 처음 코드는 조건문을 제대로 넣지 않은게 보이는군요. 게다가 다시 작성한 코드는 들여쓰기가 많아 보기 지저분합니다. 물론 작동은 합니다만.

그래서 [해시코드](https://hashcode.co.kr/)에서 [digda](https://hashcode.co.kr/users/58611/digda)님의 도움을 받아 아래와 같은 깔끔한 코드를 얻어냈습니다.

```js
// Current code
exports.localJoin = async ctx => {
  let body = ctx.request.body;

  const exists = await userService.getUserByUserId(body.userId || '');

  if (exists) {
    ctx.body = {
      success: false,
      message: `${exists.dataValues.userId} is already registered.`
    };
  } else {
    let user = {
      userId: body.userId,
      firstName: body.firstName,
      lastName: body.lastName,
      password: bcrypt.hashSync(body.password, 10)
    };

    const isAdded = await userService.addUser(user);

    if (isAdded) {
      ctx.body = {
        success: true,
        userId: user.userId,
        firstName: user.firstName,
        lastName: user.lastName
      };
    }
  }
};
```

제가 생각해낸 프로세스와 같지만, sequelize에서 제공하는 `Promise`를 제거해버려서 보기 훨씬 쉬운 코드가 됐습니다.

결론:

1.  `Promise`와 동기식 코드인 `async/await`을 동시에 남발할 필요가 없다. 그러면 들여쓰기가 많아지고 콜백지옥처럼 보기 힘들어질 것이다.
2.  API 알고리즘을 코드 작성하기 전에 다시 한번 생각해보고 작성하자.
