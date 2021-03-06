---
layout: post
title: JSON.stringify() 와 JSON.parse() 의 차이
author: Yangeok
categories: Javascript
comments: true
cover: /assets/header_image.jpg
---

## JSON.parse()

```javascript
'{ "name":"John", "age":30, "city":"New York"}';
```

웹서버에서 이런 텍스트를 전달 받았습니다.

```javascript
let obj = JSON.parse('{ "name":"John", "age":30, "city":"New York"}');
document.getElementById('demo').innerHTML = obj.name + ', ' + obj.age;
```

객체가 아니고 텍스트입니다. `JSON.parse()`는 **텍스트**를 자바스크립트 **객체**로 바꿀 때 사용하죠.

## JSON.stringify()

```javascript
let obj = { name: 'John', age: 30, city: 'New York' };
```

이런 객체가 있습니다.

```javascript
let _JSON = JSON.stringify(obj);
document.getElementById('demo').innerHTML = _JSON;
```

`_JSON`은 이제 문자열입니다. 이걸 통해 서버(여기서는 html)로 보내는거죠. `JSON.stringify()`는 **객체**를 **문자열**로 바꿀 때 사용하죠.

```javascript
let arr = [ "John", "Peter", "Sally", "Jane" ];
let obj = { name: "John", today: new Date(), city; "New York" }
```

문자열 뿐만 아니라 위같은 배열이나 날짜도 문자열로 바꿀 수 있습니다.

```javascript
obj.toString() == JSON.stringify(obj);
```
