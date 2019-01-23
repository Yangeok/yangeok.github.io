---
layout: post
title: Sequelize.js에서 테이블 별명 사용하는법
author: Yangeok
categories: Node.js
comments: true
tags:
  [
    셀프조인 조인 레프트조인 레프트 join self left outer alias nickname as 앨리어스,
  ]
cover: 'https://t1.daumcdn.net/cfile/tistory/9962D04D5C47AEAF2B'
---

Categories 테이블을 만들었는데 셀프조인을 할 예정입니다. 왜냐면 테이블 하나만 가지고 트리구조를 만들거거든요. sequelize-cli를 사용해서 디렉토리가 `models`, `migrations`, `seeders` 이렇게 3개가 존재합니다. 아래 코드는 `models` 폴더 안에 생성된 단수 파일명으로 생성된 `category.js`입니다. `migrations/****-create-category.js` 파일도 아래와 똑같은 구조로 수정해주어야 합니다. `DataTypes`만 `Sequelize`로 수정해주면 두 파일간의 내용이 똑같아지니 다른 튜토리얼을 보고 따라하시면 됩니다. 참고로 `migrations` 하위 파일들은 테이블마다 `createdAt`, `updatedAt`을 가지고 있으니 참고하시구요.

```js
module.exports = (sequelize, DataTypes) => {
  const Category = sequelize.define('Category', {
    categoryId: {
      type: DataTypes.INTEGER,
      primaryKey: true
    },
    categoryName: {
      type: DataTypes.STRING
    },
    parent: {
      type: DataTypes.INTEGER,
      defaultValue: true
    }
  });

  return Category;
};
```

페이크 데이터를 몇개 집어넣어주고요. 왜 `categoryId: 10`에는 `parent`가 없는데 `categoryId: 11`따위에는 `parent`가 있는지에 대해 이야기해보자면 부모-자식간의 관계를 표시해주기 위해서입니다. 부모의 id가 10인 노드의 자식들의 id가 11, 12, 13, 14, 15임을 알 수 있습니다.

```js
module.exports = {
  up: (queryInterface, Sequelize) => {
    return queryInterface.bulkInsert(
      'Categories',
      [
        {
          categoryId: 10,
          categoryName: 'bottom'
        },
        {
          categoryId: 11,
          categoryName: 'bottom_leggings',
          parent: 10
        },
        {
          categoryId: 12,
          categoryName: 'bottom_longPants',
          parent: 10
        },
        {
          categoryId: 13,
          categoryName: 'bottom_denim',
          parent: 10
        },
        {
          categoryId: 14,
          categoryName: 'bottom_training',
          parent: 10
        },
        {
          categoryId: 15,
          categoryName: 'bottom_jumpSuit',
          parent: 10
        }
      ],
      {}
    );
  },

  down: (queryInterface, Sequelize) => {
    return queryInterface.bulkDelete('Categories', null, {});
  }
};
```

이제 sql문으로 간단히 우리가 쓸 쿼리를 확인해봅니다.

```sql
SELECT cat.categoryId, cat.categoryName, sub_cat.categoryId, sub_cat.categoryName
FROM Categories AS cat
LEFT JOIN Categories AS sub_cat
ON sub_cat.parent = cat.cat_id;
```

보다시피 `AS`는 같은 테이블명이 길어서 줄여쓰고 싶을때뿐만 아니라 한테이블을 두번이상 언급하는 셀프조인을 사용하기 위해 필요합니다. sql에서는 `AS`라고 하지만 sequelize에서는 `alias`라고 하더군요.

```js
const categories = models.Category.findAll({
  attributes: ['categoryId', 'categoryName'],
  include: [
    {
      model: models.Category,
      as: 'sub_cat', // 이 부분을 잘 보세요.
      attributes: ['categoryId', 'categoryName']
    }
  ]
});
```

참고로 `.find()`메소드를 사용하면 deprecated 메시지가 뜨니 한개의 데이터만을 찾을 떄에는 `.findOne()`메소드를 사용하세요.

테이블간의 관계 제약을 전혀 주지 않고 실행했더니 alias 관련 에러메시지가 나오더라구요. 관계를 설정해야죠. 1:N 관계로 설정해야 나중에 JSON데이터로 볼때 데이터가 중복없이 배열안에 쏘옥 들어가게 나오겠죠.

`.hasMany()`, `.belongsTo()`메소드를 `models/index.js`나 `models/category.js`에서 합니다. 저는 `index.js`에서 하겠습니다. `index.js`에서 관계설정을 하면 다른 테이블들의 관계까지 한꺼번에 볼 수 있어 좋지만 `db`객체를 한번 타고 들어가야해서 데이터가 많을때는 성능상 이슈가 있을 것같습니다. 나중에 자료가 많을때는 꼭 각 테이블별 파일에서 관계설정을 해야겠다고 다짐해봅니다.

```js
db.Category.hasMany(db.Category, {
  as: 'sub_cat',
  foreignKey: 'parent'
});

db.Category.belongsTo(db.Category, {
  foreignKey: 'parent'
});
```

부모 노드쪽에서 참조하는 테이블의 별명을 `as`키를 통해 `sub_cat`이라고 설정했습니다. 자식이 id가 10인 부모에게 속하려면 부모의 id를 참조해야겠죠. 때문에 외래키까지 양쪽에 설정을 합니다. 이제 아까 실행했다 오류난 코드를 실행해봅니다.

```js
const categories = models.Category.findAll({
  attributes: ['categoryId', 'categoryName'],
  include: [
    {
      model: models.Category,
      as: 'sub_cat',
      attributes: ['categoryId', 'categoryName']
    }
  ]
});
```

이제는 JSON데이터가 다음과 같이 잘 나오는것을 볼 수 있습니다.

```json
[
  {
    "categoryId": c_id,
    "categoryName": c_name,
    "sub_cat": [
      {
        "categoryId": c_id,
        "categoryName": c_name
      }
    ]
  }
]
```

다시 말하지만 sql에서는 테이블 작성할때 한꺼번에 별명, 제약을 설정할 수 있지만 sequelize는 그렇지가 않습니다. 여러군데 분산되어 있는 설정들을 하나하나 찾아서 해줘야합니다. 그럼에도 불구하고 ORM을 사용하는 이유는 설계는 좀 더 복잡하지만 나중에 유지보수가 편리해서 그런게 아닐까 생각해봅니다.
