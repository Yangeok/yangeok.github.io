---
layout: post
title: '테이블 컬럼 추가시 에러 해결하기'
author: Yangeok
categories: Node.js
comments: true
cover: ''
---

## 작업환경

- sequelize
- sequelize-cli
- mysql

## 테이블 정의

cli로 `model:create` 명령어를 사용하면 `/migrations`, `/models`, `/seeders` 폴더에 각각 파일이 하나씩 생성됩니다. 우선 우리가 다룰 파일은 `/migrations`, `/models`에 있는 파일들입니다.

우선 테이블 생성을 위해 다음과 같이 입력합니다. 테이블명은 단수로 입력하면 자동으로 복수로 저장됩니다.

`sequelize model:create --name ProductColor --attributes productId:integer,productColor:string && seqeulize init:seeders && sequelize seed:create`

그럼 `/migration`, `/models`과 `/seeders`디렉토리에 테이블명을 가진 파일들이 생성될겁니다.

```js
// migrations/20190000000000-create-produt-color.js
up: (queryInterface, Sequelize) => {
  return queryInterface.createTable('ProductColors', {
    id: {
      allowNull: false,
      autoIncrement: true,
      primaryKey: true,
      type: Sequelize.INTEGER
    },
    productId: {
      type: Sequelize.INTEGER
    },
    productColor: {
      type: Sequelize.STRING
    },
    createdAt: {
      allowNull: false,
      type: Sequelize.DATE
    },
    updatedAt: {
      allowNull: false,
      type: Sequelize.DATE
    }
  });
};

// models/productcolor.js
const ProductColors = sequelize.define(
  'ProductColor',
  {
    productId: {
      type: DataTypes.INTEGER
    },
    productColor: {
      type: DataTypes.STRING
    }
  },
  {}
);
return ProductColors;

// seeders/20190000000000-product-color.js
up: (queryInterface, Sequelize) => {
  return queryInterface.bulkInsert('ProductColors', [{}]);
};
```

위 파일에 정의된 테이블의 컬럼들이 다릅니다. 저는 이 테이블을 상품의 하위 카테고리로 만들기 위해 생성날짜, 기본값이 필요하지 않아서 `/migrations`에 있는 파일을 아래와 같이 수정했습니다.

```js
// migrations/20190000000000-create-produt-color.js
up: (queryInterface, Sequelize) => {
  return queryInterface.createTable('ProductColors', {
    productId: {
      type: Sequelize.INTEGER,
      references: {
        model: 'Products',
        key: 'productId'
      }
    },
    productColor: {
      type: Sequelize.STRING
    }
  });
};
```

하위 항목인 상품 색상의 `productId`는 상품 테이블의 `productId`를 참조하기 때문에 `references`객체를 썼고 `createdAt`, `updatedAt`컬럼은 필요가 없어서 삭제했습니다. 이제 두 파일을 마이그레이션합니다.

`sequelize db:migrate`

## 데이터 삽입

콘솔에 작업이 완료됐다는 메시지가 뜨면 데이터를 추가할 차례입니다. `/seeders`에 있는 파일을 열어 삽입하고자 하는 데이터를 컬럼형식에 맞게 입력합니다.

```js
// seeders/20190000000000-product-color.js
up: (queryInterface, Sequelize) => {
  return queryInterface.bulkInsert('ProductColors', [
    {
      productId: '1',
      productColor: 'black'
    },
    {
      productId: '1',
      productColor: 'white'
    },
    {
      productId: '1',
      productColor: 'gray'
    }
  ]);
};
```

입력을 다했으면 실제 데이터베이스에 데이터를 삽입할 차례입니다.

`sequelize db:seed`

를 입력하면 마이그레이션할 때와 마찬가지로 작업이 완료됐다는 메시지가 떠야하는데 아래와 같은 오류를 뱉어냅니다. 아까 `createdAt`, `updatedAt`은 분명히 지웠는데

```sh
SequelizeDatabaseError: Unknown column 'createdAt' in
'field list'
```

라고 난다면 모델 정의 파일에서 객체에 `timestamp: false`를 하면 `createdAt`, `updatedAt`에 대한 오류가 나타나지 않고 성공적으로 데이터 삽입이 끝납니다.

```js
// models/productcolor.js
const ProductColors = sequelize.define(
  'ProductColor',
  {
    productId: {
      type: DataTypes.INTEGER,
      references: {
        model: 'Products',
        key: 'productId'
      }
    },
    productColor: {
      type: DataTypes.STRING
    }
  },
  { timestamps: false }
);
return ProductColors;
```

## 참조

- https://stackoverflow.com/questions/29652538/sequelize-js-timestamp-not-datetime
- https://stackoverflow.com/questions/50456128/unknown-column-in-field-list-sequelize
