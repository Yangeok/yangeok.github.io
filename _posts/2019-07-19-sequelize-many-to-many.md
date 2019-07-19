---
layout: post
title: Sequelize 다대다 관계 사용하기
author: Yangeok
categories: Node.js
comments: true
cover: https://res.cloudinary.com/yangeok/image/upload/v1552474849/logo/posts/sequelize.jpg
---

## 작업환경

- [mysql2](https://www.npmjs.com/package/mysql2): 1.6.5
- [sequelize](https://www.npmjs.com/package/sequelize): 5.8.8
- [sequelize-cli](https://www.npmjs.com/package/sequelize-cli): 5.4.0

---

## 작업순서

여기서 사용하는 용어인 모델은 테이블과 같은 의미로 사용하고 있음을 미리 알려드립니다.

sql에서는 다대다 관계가 유효하지 않습니다. 그래서 다리 역할을 하는 테이블을 따로 만들어 인덱스를 주어야합니다. 따라서 쿼리는 테이블 3개로 작동하며, 연결 테이블은 쿼리에 적지 않습니다. 우선 다대다를 구현하기 위해 `product`, `category`, `product_category` 모델을 정의해보겠습니다.

```js
// category.js
const category = sequelize.define('category', {
  category_id: {
    allowNull: false,
    autoIncrement: true,
    primaryKey: true,
    type: DataTypes.INTEGER
  },
  name: {
    type: DataTypes.STRING(100)
  }
});

// product.js
const product = sequelize.define('product', {
  product_id: {
    allowNull: false,
    autoIncrement: true,
    primaryKey: true,
    type: DataTypes.INTEGER
  }
});

// product_category.js
const product_category = sequelize.define('product_category', {
  product_id: {
    allowNull: false,
    primaryKey: true,
    type: DataTypes.INTEGER
  },
  category_id: {
    allowNull: false,
    primaryKey: true,
    type: DataTypes.INTEGER
  }
});
```

다대다 관계를 데이터베이스 단에 만들려면 단순 모델링만으로는 부족하고 association을 해주지 않으면 데이터베이스에서 인덱싱을 하지 않습니다. 각각 테이블은 `belongsToMany()`메서드를 사용하고 연결 테이블은 `belongsTo()`메서드를 사용합니다.

```js
// category.js
category.associate = function(models) {
  category.belongsToMany(models.product, {
    through: 'product_category',
    foreignKey: 'category_id'
  });
};

// product.js
product.associate = function(models) {
  product.belongsToMany(models.category, {
    through: 'product_category',
    foreignKey: 'product_id'
  });
};

// product_category.js
product_category.associate = function(models) {
  product_category.belongsTo(models.product, {
    foreignKey: 'product_id'
  });
  product_category.belongsTo(models.category, {
    foreignKey: 'category_id'
  });
};
```

참고로 각각의 테이블 모델 파일에서 설정할 수도 있고 `index.js`에 sequelize-cli가 만들어준 `db`객체 안에서 설정할 수도 있습니다. 만약 association을 `index.js` 파일에서 설정해주고 싶다면 아래와 같은 식으로 표현할 수 있습니다.

```js
// category
db.category.belongsToMany(models.product, {
  through: 'product_category',
  foreignKey: 'category_id'
});

// product
db.product.belongsToMany(models.category, {
  through: 'product_category',
  foreignKey: 'product_id'
});

// product_category
db.product_category.belongsTo(models.product, { foreignKey: 'product_id' });
db.product_category.belongsTo(models.category, { foreignKey: 'category_id' });
```

테이블 정의가 다 됐으면 테이블 및 데이터 마이그레이션을 진행한 후 아래와 같이 쿼리를 날려봅니다. 위에서 언급했다시피 연결 테이블을 쿼리문에 사용하지 않습니다. 아래와 같이 `product_id`가 1인 상품의 카테고리명을 뽑는 쿼리를 입력합니다.

```js
await product.findOne({
  where: { product_id },
  include: {
    model: category
  }
});
```

결과값이 아래와 같이 나올겁니다.

```json
{
  "category_id": 1,
  "name": "French",
  "product_category": {
    "product_id": 1,
    "category_id": 1
  }
}
```

연결 테이블이 노출되고 객체가 지저분해졌습니다. 그럴경우 쿼리에 아래와 같은 옵션을 추가합니다.

```
through: { attributes: [] }
```

전체적인 쿼리의 모습은 아래와 같습니다.

```js
await product.findOne({
  where: { product_id: id },
  include: {
    model: category,
    through: { attributes: [] }
  }
});
```

sequelize 쿼리 조작만으로 별도의 객체 가공을 거치지 않고 연결 테이블 객체를 노출시키지 않는 결과값을 반환시킬 수 있습니다.

```json
{
  "category_id": 1,
  "name": "French",
  "department_id": 1
}
```

오탈자가 있거나 틀린 정보가 있다면 댓글이나 메일로 알려주시면 감사하겠습니다.

---

## 참조

- [ORM(Object Relation Mapping)을 이용해보자!!! 1편 Sequelize.js](https://real-dongsoo7.tistory.com/63)
- [Can't exclude association's fields from select statement in sequelize](https://github.com/sequelize/sequelize/issues/3664)
