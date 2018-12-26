---
layout: post
title: 'Sequelize.js 모델 정의'
author: Yangeok
categories: Node.js
tags: [노드 노드제이에스 시퀄 시퀄라이즈 RDBM]
---

본 포스팅은 `sequelize-cli`를 사용하였습니다. 디렉토리 구조는 아래와 같습니다.

```shell
├─config
│    └─config.json
├─migrations
│      (...)
├─models
│    └─index.js
└─seeders
       (...)
```

이 글을 쓰는 목적은 sequelize가 [v4](http://docs.sequelizejs.com/manual/tutorial/upgrade-to-v4.html)로 업데이트 되면서 바뀐 사항들이 꽤나 있습니다만, 포스팅이나 튜토리얼을 보면 예전방식으로 쓰여진 곳이 많더라구요. 대부분 deprecated메시지를 띄울뿐 에러는 띄우지 않는데 `models`폴더에서 테이블 정의할때 기본키(PK), 외래키(FK) 지정에 있어서는 오류가 뜨더라구요.

아래의 코드들은 [sequelize 공식문서](http://docs.sequelizejs.com/manual/tutorial/upgrade-to-v4.html#config-options)에서 가져왔습니다.

예전 방식

```javascript
const Model = sequelize.define('Model', {
    ...
}, {
    classMethods: {
        associate: function (model) {...}
    },
    instanceMethods: {
        someMethod: function () { ...}
    }
});
```

새로운 방식

```javascript
const Model = sequelize.define('Model', {
    ...
});

// Class Method
Model.associate = function (models) {
    ...associate the models
};

// Instance Method
Model.prototype.someMethod = function () {..}
```

보시면 아시겠지만 `define`메소드안의 옵션으로 안들어가고 `Model`의 메소드로 정의됩니다. 객체에 객체를 쓰는 것보다 훨씬더 보기 편해졌군요.

그리고 굳이 정의할 `테이블이름.js`에 들어가서 관계를 작성하지 않아도 됩니다. 관계를 한 곳에서 모아서 보는게 훨씬 더 편할 수도 있습니다.

```javascript
// models/user.js
module.exports = (sequelize, DataTypes) => {
    const User = sequelize.define('User', {
        userId: {
            type: DataTypes.STRING,
            primaryKey: true
            validate: {
                (...)
            }
        },
        password: {
            type: DataTypes.STRING,
            allowNull: false
        },
        (...)
    });

    return User;
};

// models/order.js
module.exports = (sequelize, DataTypes) => {
    const Order = sequelize.define('Order', {
        (...)
        userId: {
            type: DataTypes.STRING
        },
        (...)
    });

    return Order;
};

// models/index.js
(...)
const db = {};
db.User.hasMany(db.Order, { foreignKey: 'userId' });
db.Order.belongsTo(db.User, { foreignKey: 'userId' });

(...)
```

`hasMany`와 `belongsTo`가 무엇인지 모른다면 [링크](http://docs.sequelizejs.com/manual/tutorial/associations.html)를 클릭하세요.

PK, FK관계가 위처럼 한개밖에 없다면 테이블파일마다 각각 정의해도 상관 없지만, 나중에 인덱싱이 많이 필요하다면 `index.js`에 관계를 모아두는 방법도 추천하고 싶습니다.

```javascript
// migrations/order.js
module.exports = {
    up: (queryInterface, Sequelize) => {
        return queryInterface.createTable('Orders', {
            (...)
            userId: {
                type: Sequelize.STRING,
                references: {
                    model: 'Users',
                    key: 'userId'
                }
            },
            (...)
        });
```

테스트전 `migrations`에서도 PK는 그냥 `primaryKey`만 정의해줘도 되지만 FK는 [`references`객체]()도 작성해야 하는것 잊지마세요 :)
