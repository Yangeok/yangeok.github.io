---
layout: post
title: Sequelize.js 중첩모델 쿼리 작성하기
author: Yangeok
categories: Node.js
comments: true
# tags:
#   [
#     'nested',
#     'set',
#     'model',
#     'tree',
#     'node',
#     'parent',
#     'child',
#     'js',
#     'javascript',
#     'nodejs',
#     'node.js',
#   ]
cover: 'http://drive.google.com/uc?export=view&id=1tzqWG8SozuBI9BZkjMpkLxG-T84MbHt2'
---

부모 밑에 자식이 자식 밑에 손자가 있는 구조로 JSON데이터를 뽑아줄겁니다. 여기서 정렬을 거는 방법을 확인해볼겁니다. 먼저 모델을 정의하고 제약을 걸어줍니다.

```js
// 모델 정의
const Parent = sequelize.define('parent', {
    id: {
        Sequelize.INTEGER,
        primaryKey: true
    },
    name: Sequelize.STRING,
    parent: Sequelize.INTEGER
});
const Child = sequelize.define('parent', {
    id: {
        Sequelize.INTEGER,
        primaryKey: true
    },
    name: Sequelize.STRING,
    parent: Sequelize.INTEGER
});
const GrandChild sequelize.define('parent', {
    id: {
        Sequelize.INTEGER,
        primaryKey: true
    },
    name: Sequelize.STRING,
    parent: Sequelize.INTEGER
});

// 부모-자식간 제약
Parent.hasMany(Child, {
    foreignKey: 'id'
});
Child.belongsTo(Parent, {
    foreignKey: 'id'
});

// 자식-손자간 제약
Child.hasMany(GrandChild, {
    foreignKey: 'id'
});
GrandChild.belongsTo(Child, {
    foreignKey: 'id'
});
```

부모는 자식을 여럿가지고 있으니까 `.hasMany()`메소드를 썼습니다. 즉 1:N관계라는 말과도 같습니다. 페이크 데이터를 몇개 집어넣는 다음 쿼리를 작성합니다.

```js
Parent.findAll({
  include: [
    {
      model: Child
    }
  ]
});
```

위 코드는 아래의 sql문과 같습니다.

```sql
SELECT parent.id, parend.name, child.id, child.name
FROM parent
LEFT OUTER JOIN child
ON child..parent = parent.id;
```

이제 정렬을 넣어야죠. sql문에서는 `ON`절 뒤에 `ORDER BY`절만 넣으면 깔끔하게 끝나는데 sequelize에서는 깊이를 잘보고 작성해줘야 합니다. 정렬을 `order`객체 안에 배열을 작성해 표현합니다. `include`안에다 `order`를 집어넣으면 작동을 안하고 위와 같은 sql만 콘솔에 찍히죠. `include`밖에 다시말해 다음과 같이 가장 바깥쪽에 작성해줘야 합니다.

```js
Parent.findAll({
  include: [
    {
      model: Child
    }
  ],
  order: [Child, 'id', 'desc']
});
```

배열 안에 오는 순서는 `[자식테이블, 정렬할컬럼, 오름/내림차순]`이 옵니다. 자식테이블이 셀프조인이라 별명을 지정해야 한다면 제약에서 옵션에 `as: '별명'`을 입력해준 후에 `order`의 옵션에서 `Child`를 객체로 다시 작성합니다. 자식테이블을 `son`이라고 설정하고 쿼리를 작성해보겠습니다. 그러면 다음과 같이 표현할 수 있습니다. 옵션들은 구글링해보면 여러가지 옵션이 나오지만 이게 가장 사용하기 쉽고 이해하기도 쉬운것 같습니다.

```js
order: [{ model: Child, as: 'son' }, 'id', 'desc'];
```

부모-자식간의 쿼리는 만들었으니 부모-자식-손자간의 쿼리까지 작성해보도록 합니다. 참고로 `include`안에 `required`를 true로 하면 `INNER JOIN`이 됨을 참고하세요. 지금은 아무것도 작성하지 않았기 때문에 기본값이 `false`로 되어있어 `LEFT JOIN`이 되고 있습니다. 바뀐부분이 손자테이블을 추가하고 `order`에서 뒤에 손자테이블 이름만 추가했을 뿐입니다. 로우 sql보다 쉽다고 할 수는 없지만 들여쓰기가 있고 배열 안에서 단계적으로 정렬의 기준이 되는 행이 어느 상속관계에 위치해있는지가 직관적으로 보이는게 좋습니다.

```js
Parent.findAll({
  include: [
    {
      model: Child,
      include: [
        {
          model: GrandChild
        }
      ]
    }
  ],
  order: [Child, GrandChild, 'id', 'desc']
});
```

공식문서가 가독성이 극악이지만 github이나 stackoverflow에서 글들이 많이 올라오고 있어 공식문서를 보지 않아도 해결할 수 있는 이슈들이 많습니다. [github 이슈](https://github.com/sequelize/sequelize/issues)에 들어가봐도 확인할 수 있듯이 활동이 꽤나 왕성해보입니다. 역시 넘버원 ORM입니다.
