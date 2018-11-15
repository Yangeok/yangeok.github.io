---
layout: post
title:  "ES, Sequelize 오류 해결"
author: Yangeok
categories: Node.js
---

작업환경은 NodeJS v8, KoaJS, SequelizeJS(MySQL)입니다. 

우선 __첫번째__ 와 같이 코드를 작성했습니다. ```.getUserByUserId()```는 아이디 중복체크하는 메서드입니다. 여기서 이미 중복돼서 생성된 아이디가 있다면 ```if```문을 통해 ```body```에 중복된 아이디가 있다고 반환합니다. 그리고 중복이 없다면 ```.addUser()```를 통해 새로운 계정을 생성하는 프로세스입니다.

하지만 
 1. ```.addUser()```가 없고, 아이디가 중복되었을때는 ```success: false```를 반환합니다. 하지만 있으면 ```body```에는 404에러와 함께 콘솔에는 ```ValidationError```가 뜨더군요.
 2. 다시 .```addUser()```를 넣고, 아이디가 중복되지 않았을때는 ```success: true```가 잘 반환됩니다. 

__첫번째__
```js
exports.localJoin = async (ctx) => {
    let body = ctx.request.body;
    
    await userService.getUserByUserId(body.userId || '').then(exists => {
        if (exists) { 
            ctx.body = { success: false, message: `${exists.dataValues.userId} is already registered.` };
        }
    });

    let user = { 
        userId: body.userId, 
        firstName: body.firstName, 
        lastName: body.lastName, 
        password: bcrypt.hashSync(body.password, 10) 
    };

    await userService.addUser(user).then(() => {
        ctx.body = { success: true, password: user.password };
    });
};
```

이대론 안될 것 같아서 __두번째__ 와 같은 코드로 변경했습니다.

__두번째__
```js
exports.localJoin = async (ctx) => {
    let body = ctx.request.body;

    await userService.getUserByUserId(body.userId || '').then(exists => {
        if (exists || '') { 
            ctx.body = { success: false, message: `${exists.dataValues.userId} is already registered.` };
        } else {
            let user = { 
                userId: body.userId, 
                firstName: body.firstName, 
                lastName: body.lastName, 
                password: bcrypt.hashSync(body.password, 10) 
            };

            return userService.addUser(user).then(() => {
                ctx.body = { success: true };        
            });
        }
    });
};
```

잘 작동합니다. 여기서 궁금한 점이

 1. ```else``` 안쪽에서는 왜 ```return```이 ```await```으로 변경이 안되는지 알고 싶습니다.
 2. __두번째__ 와 같은 코드가 최선인가요?

 보신분 계시면 도움 좀 부탁드리겠습니다. 더 자세한 정보가 필요하시다면 아래 있는 메일이나 SNS로 메시지 남겨주시면 감사하겠습니다.