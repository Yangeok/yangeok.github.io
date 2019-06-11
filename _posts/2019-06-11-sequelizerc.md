---
layout: post
title: Sequelize 환경변수 관리 및 CLI명령어 관리하기
author: Yangeok
categories: Java
comments: true
cover: https://res.cloudinary.com/yangeok/image/upload/v1552474849/logo/posts/sequelize.jpg
---

## 서론

`sequelize-cli`를 사용할 때에도 `.env`로 환경변수를 관리할 수 있게 하는 방법과 `src/db`디렉토리까지 올라가서 `sequelize`명령어를 입력하지 않고 루트에서 바로 명령을 실행할 수 있게 하는 방법을 설명하려고 합니다.

우선 ORM을 통해 개발하는건 SQL별로 쿼리가 약간씩 다른 부분을 해결해 주는데 큰 도움이 되었습니다. 이 ORM을 더 편하게 CLI환경에서 사용할 수 있게 해주는 `sequelize-cli`는 generating, migrating, seeding까지 할 수 있게 해줍니다. db에서 직접 데이터를 주입하지 않고 개발환경에서 직접 할 수 있게 되어 정말 편했습니다.

하지만 `sequelize init`을 하면 아래와 같이 생성되는 디렉토리 구조때문에 `config.json`파일로 db관련 데이터를 따로 관리해야하는 불편함이 생겼습니다.

```
└─src
    └─db
      ├─config
      │      config.json
      ├─migrations
      ├─models
      │      index.js
      └─seeders
```

아래는 `config.json`입니다. `init`을 하면 기본을 설정되는 언어가 mysql이군요.

```json
{
  "development": {
    "username": "root",
    "password": null,
    "database": "database_development",
    "host": "127.0.0.1",
    "dialect": "mysql"
  },
  "test": {
    "username": "root",
    "password": null,
    "database": "database_test",
    "host": "127.0.0.1",
    "dialect": "mysql"
  },
  "production": {
    "username": "root",
    "password": null,
    "database": "database_production",
    "host": "127.0.0.1",
    "dialect": "mysql"
  }
}
```

`.json`파일에서는 아시다시피 다른 파일을 불러올 수가 없습니다. 그래서 값은 참조타입은 사용할 수 없고 무조건 원시타입만 사용할 수가 있죠. 서버 모드 별로 일일이 호스트가 바뀔 때마다 재작성해야 한다면 같은 내용을 반복 작성해야하기 떄문에 프로그래머로서의 수치일겁니다.

보통 중요한 데이터들은 `.env`파일에 작성해서 환경변수로 관리합니다. 민감한 데이터를 `.env`와 `config.json` 두 군데에서 관리할 수밖에 없게 됩니다.

`.env`로 모든 민감한 데이터를 옮겨적고 불러오기 위해서는 두 가지 방법이 있습니다.

---

## 작업환경

- [mysql2](https://www.npmjs.com/package/mysql2): 1.6.5
- [sequelize](https://www.npmjs.com/package/sequelize): 5.1.0
- [sequelize-cli](https://www.npmjs.com/package/sequelize-cli): 5.4.0

---

## 작업순서

### `config.json`을 `.js`로 바꾸기

`.env`에 민감한 정보들을 작성한 후 아래의 `config.json`파일을

```json
{
  "development": {
    "username": "root",
    "password": null,
    "database": "database_development",
    "host": "127.0.0.1",
    "dialect": "mysql"
  },
  "test": {
    "username": "root",
    "password": null,
    "database": "database_test",
    "host": "127.0.0.1",
    "dialect": "mysql"
  },
  "production": {
    "username": "root",
    "password": null,
    "database": "database_production",
    "host": "127.0.0.1",
    "dialect": "mysql"
  }
}
```

아래와 같이 `index.js`로 바꿔 export합니다. 참고로 dotenv 사용법은 [여기](https://www.npmjs.com/package/dotenv)를 클릭해주세요.

```js
require('dotenv').config();
const env = process.env;

const development = {
  username: env.MYSQL_USERNAME,
  password: env.MYSQL_PASSWORD,
  database: env.MYSQL_DATABASE,
  host: env.MYSQL_HOST,
  dialect: env.MYSQL_DIALECT,
  port: env.MYSQL_PORT
};

const production = {
  username: env.MYSQL_USERNAME,
  password: env.MYSQL_PASSWORD,
  database: env.MYSQL_DATABASE,
  host: env.MYSQL_HOST,
  dialect: env.MYSQL_DIALECT,
  port: env.MYSQL_PORT
};

const test = {
  username: env.MYSQL_USERNAME,
  password: env.MYSQL_PASSWORD,
  database: env.MYSQL_DATABASE_TEST,
  host: env.MYSQL_HOST,
  dialect: env.MYSQL_DIALECT,
  port: env.MYSQL_PORT
};

module.exports = { development, production, test };
```

그리고 `models/index.js`를 수정합니다.

```js
// before
const config = require(__dirname + '/../config/config.json')[env];

// after
const config = require(__dirname + '/../config')[env];
```

코드가 지저분해보여 약간의 커스텀을 아래와 같이 했으나 코드 동작에는 이상이 없습니다.

```js
// before
const env = process.env.NODE_ENV || 'development';
const config = require(__dirname + '/../config')[env];
const db = {};

let sequelize;
if (config.use_env_variable) {
  sequelize = new Sequelize(process.env[config.use_env_variable], config);
} else {
  sequelize = new Sequelize(
    config.database,
    config.username,
    config.password,
    config
  );
}

// after
const config = require('../config')[process.env.NODE_ENV];
const db = {};

let sequelize;
sequelize = new Sequelize(
  config.database,
  config.username,
  config.password,
  config
);
```

`config.use_env_variable`은 `sequelize`에서 자동으로 개발환경을 인식해주는 부분같은데 npm script에서 명시해줄 것이기 때문에 삭제했습니다.

위와 같이 수정을 마친상태에서 서버를 돌리면 db에 성공적으로 접근할 수 있습니다. 간혹 가다

> Dialect needs to be explicitly supplied as of v4.0.0

에러가 발생한다면 `.env`파일과 `package.json`에서 문자열을 잘못 입력하지 않았나 확인해보시면 해결할 수 있습니다.

---

### `/db`에서 뿐만 아니라 루트에서도 migrating, seeding하기

`sequelize db:migrate`, `sequelize db:seed`같이 데이터나 테이블 마이그레이션을 할때 가장 불편했던 점은 `/db` 디렉토리까지 가서 명령을 실행해야 한다는 점이었습니다. 참고로 `sequelize-cli` 명령어는 콘솔에 `sequelize --help`를 입력하면 확인할 수 있습니다.

그렇게 생각해낸 대안이 아래와 같았습니다만 좋지 않은 방법이었습니다.

```json
"scripts": {
  "db:gen:migrate": "cd src/db && sequelize db:migrate",
  "db:gen:seed": "cd src/db && sequelize db:seed:all",
  "db:migrate": "yarn db:gen:migrate",
  "db:seed": "yarn db:gen:seed"
}
```

npm script가 많아서 나중에 보면 뭐가 뭔지 헷갈릴 지경이더군요. 이에 대한 대안이 두가지 있습니다. 첫 번째 방법이 훨씬 깔끔한 방법임을 참고하시길 바랍니다.

---

### `.sequelizerc` 작성하기

이제`.sequelizerc`를 작성할 차례입니다. 루트 디렉토리에서 작성해야 합니다.

```js
const path = require('path');

module.exports = {
  config: path.join(__dirname + '/src/db/config'),
  'migrations-path': path.join(__dirname, '/src/db/migrations'),
  'seeders-path': path.join(__dirname, '/src/db/seeders'),
  'models-path': path.join(__dirname, '/src/db/models')
};
```

이제 프로젝트 내 어떤 디렉토리에서건 `seqeulize-cli` 명령어를 사용할 수 있게 되었습니다.

---

### npm scripts에서 sequelize 옵션 사용하기

`.sequelizerc`를 작성하지 않고 바로 사용하기 위해서는 `package.json`에서 npm script 수정이 필요합니다.

```json
"scripts": {
  "sequelize": "sequelize --options-path=src/db/config/options.js"
}
```

`.sequelizerc`를 대신할 `options.js` 파일이 필요합니다. 사실은 파일명은 맘대로 바꿀 수 있습니다. 파일 내용은 `.sequelizerc`와 동일한 내용으로 작성합니다.

```js
const path = require('path');

module.exports = {
  config: path.join(__dirname + '/db/config'),
  'migrations-path': path.join(__dirname, '/src/db/migrations'),
  'seeders-path': path.join(__dirname, '/src/db/seeders'),
  'models-path': path.join(__dirname, '/src/db/models')
};
```

포스팅을 읽으시다 혹시 궁금하신 점이나 고쳐야 할 부분이 있다면 댓글 혹은 메일 주시면 감사하겠습니다.

---

## 참조

- [Primitive Type(원시 타입) vs Reference Type (참조 타입)](https://weicomes.tistory.com/133)
- [Config via environment variables?](https://github.com/sequelize/cli/issues/91)
- [Unable to run migration in sequelize due to config file](https://github.com/sequelize/cli/issues/641)
