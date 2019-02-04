---
layout: post
title: 'Javascript 배열 가공하기'
author: Yangeok
categories: Javascript
comments: true
tags:
  [
    'javascript',
    'ecmascript',
    'es6',
    'arr',
    'array',
    'obj',
    'object',
    'manufacture',
  ]
cover: 'http://drive.google.com/uc?export=view&id=1bruVEytwg8WRTy8b_st8-v-gdXzu1Fsd'
---

본 포스팅은 ES5 문법과 ES6 문법을 병용함을 참고하시길 바랍니다. 또한 의도하지 않은 객체의 변경이 생기는 것을 막기 위해 객체를 참조하는게 아니라 복사해서 불변객체를 만들어줘야 하지만 따로 객체를 복사해서 사용하진 않았음을 확인 부탁드립니다.

데이터베이스에서 나온 정보를 그대로 사용하지 않고 프론트단에서 쓰기 좋게 가공해서 보내줘야하는 경우가 있습니다. 누구보다도 정보가 멋있게 나왔다고 해도 프론트에서 원하는 형식이 아닐 수가 있죠. 다음과 같은 데이터가 있습니다.

```json
[
  {
    "pid": 1,
    "pname": "test1",
    "psize": "z",
    "pcolor": "a"
  },
  {
    "pid": 1,
    "pname": "test1",
    "psize": "y",
    "pcolor": "a"
  },
  {
    "pid": 1,
    "pname": "test1",
    "psize": "z",
    "pcolor": "b"
  },
  {
    "pid": 1,
    "pname": "test1",
    "psize": "y",
    "pcolor": "b"
  }
];
```

가만 보면 중복된 부분이 정말 많습니다. `pid"`, `pname`이 중복되고 `psize`, `pcolor`가 각각 두개씩 있죠. 집합 개념으로도 생각해볼 수가 있습니다.

![](https://upload.wikimedia.org/wikipedia/commons/thumb/4/4e/Cartesian_Product_qtl1.svg/440px-Cartesian_Product_qtl1.svg.png)
출처: 위키백과

위 이미지처럼 각각 집합에 해당하는 원소들을 곱해서 나올 수 있는 경우의 수를 눈으로 보기 쉽게 보여주죠. 배열 안에 들어있는 객체들이 두 집합 `pcolor`와 `pcolor`의 [곱집합](https://ko.wikipedia.org/wiki/%EA%B3%B1%EC%A7%91%ED%95%A9)이라고도 할 수 있겠네요.

데이터를 저는 아래와 같이 만들고 싶습니다.

```json
[
  {
    "pid": "1",
    "pname": "test1",
    "psize": ["z", "y"],
    "pcolor": ["a", "b"]
  }
]
```

그러려면 여섯 단계의 과정을 거쳐야 합니다.

1. JSON데이터를 변수에 할당한다.
2. 할당된 변수에서 `psize`, `pcolor`값을 **배열** 로 추출한다.
3. 추출한 배열에서 중복된 요소를 제거한다.
4. 원래 있던 데이터의 첫번째 객체의 `psize`, `pcolor` 요소를 제거한다.
5. 첫번째 객체에 중복이 제거된 배열을 삽입한다.
6. 첫번째 객체를 제외한 나머지 객체를 제거한다.

일단 데이터를 복사해서 변수에 할당을 합니다.

```js
let products = [
    (...)
];
```

두번째, 할당된 변수에서 `psize`, `pcolor`를 추출하는데 세 가지 방법을 써봤습니다.

1. for문을 이용한다.
2. `forEach()`메서드를 이용한다.
3. `map()`메서드를 이용한다.

우선 for문을 사용한 방법은 다음과 같습니다.

```js
let emptySizeArr = [];
let emptyColorArr = [];
for (i = 0; i < products.length; i++) {
  emptySizeArr.push(products[i].psize);
  emptyColorArr.push(products[i].pcolor);
}

console.log(emptySizeArr); // [ 'z', 'y', 'z', 'y' ]
console.log(emptyColorArr); // [ 'a', 'a', 'b', 'b' ]
```

두번째 방법인 `forEach()`를 사용한 방법은 for문을 이용하면 변수 i가 가독성을 해치는데 비해 직관적으로 코드를 볼 수가 있습니다. 매개변수는 다음과 같습니다.

`forEach(callback(currentValue[, index, array])[, thisArg])`

- currentValue: 처리할 현재 요소값
- index: 처리할 현재 요소의 인덱스값
- array: forEach를 호출한 배열 자체
- thisArg: 콜백을 실행할 때 `this`로 사용하는 값

아래와 같이 코드를 작성할 수 있습니다.

```js
let emptySizeArr = [];
let emptyColorArr = [];
products.forEach(product => {
  emptySizeArr.push(product.psize);
  emptyColorArr.push(product.pcolor);
});

console.log(emptySizeArr); // [ 'z', 'y', 'z', 'y' ]
console.log(emptyColorArr); // [ 'a', 'a', 'b', 'b' ]
```

세번째 방법인 `map()`을 사용하면 보다 더 직관적으로 코드를 읽을 수 있습니다. 이 메서드는 배열의 요소를 일괄적으로 변경하는데 효과적입니다. 매개변수는 다음과 같습니다.

`map(callback(currentValue[, index[, array]])[, thisArg])`

- currentValue: 처리할 현재 요소값
- index: 처리할 현재 요소의 인덱스값
- array: forEach를 호출한 배열 자체
- thisArg: 콜백을 실행할 때 `this`로 사용하는 값

아래와 같이 코드를 작성할 수 있습니다.

```js
let emptySizeArr = products.map(product => {
  return product.psize;
});
let emptyColorArr = products.map(product => {
  return product.pcolor;
});

console.log(emptySizeArr); // [ 'z', 'y', 'z', 'y' ]
console.log(emptyColorArr); // [ 'a', 'a', 'b', 'b' ]
```

`(product => product.psize)`와 같이도 `return`과 중괄호를 생략해서도 사용할 수 있습니다.

세번째, 추출한 배열에 중복된 요소들이 있었습니다. 객체 메서드를 이용해서 중복된 요소를 추출할겁니다.

1. `filter()`메서드를 이용해서 추출한다.
2. `reduce()`메서드를 이용해서 추출한다.

우선 `filter()`를 이용해서 중복 요소를 추출해봅시다. 이 메서드는 배열의 요소들을 걸러내는 것이 목적입니다. 매개변수는 다음과 같습니다.

`filter(callback(element[, index[, array]])[, thisArg])`

- element: 처리할 현재 요소값
- index: 처리할 현재 요소의 인덱스값
- array: filter를 호출한 배열 자체
- thisArg: 콜백을 실행할 때 `this`로 사용하는 값

아래와 같이 코드를 작성할 수 있습니다.

```js
let deleteSizeDup = emptySizeArr.filter((item, idx, arr) => {
  return arr.indexOf(item) === idx;
});
let deleteColorDup = emptyColorArr.filter((item, idx, arr) => {
  return arr.indexOf(item) === idx;

console.log(deleteSizeDup); // [ 'z', 'y' ]
console.log(deleteColorDup); // [ 'a', 'b' ]
```

`filter()`안에 들어간 `indexOf()`메서드의 매개변수는 다음과 같습니다. 대소문자를 구별하고 찾으려는 문자열이 없으면 -1을 반환하니 참고 바랍니다.

`indexOf(searchValue[, fromIndex])`

- searchValue: 필수요소이며 찾으려는 문자열을 넣는다.
- fromIndex: 선택요소이며 검색을 시작할 인덱스값이다. 입력하지 않으면 처음부터 검색한다.

다음 방법으로는 `reduce()`를 이용한 방법입니다. `reduce()`메서드는 `map()`, `filter()`, `find()`를 대체할 수 있는 유연한 메서드이고 여러모로 알아두면 좋은 메서드입니다. 매개변수는 다음과 같습니다.

`reduce(callbackFunction(accumulator, currentValue[, currentIndex, array]){...}[, initialValue])`

- accumulator: 직전의 콜백이 리턴한 계산값
- currentValue: 현재 콜백, 배열의 요소값
- currentIndex: 현재 콜백이 진행되고 있는 시점의 배열의 인덱스값
- array: 작업을 수행하는 배열 자체
- initialValue: 콜백의 첫번째 호출에서 첫번쨰 인수로 사용되는 값

아래와 같이 코드를 작성할 수 있습니다.

```js
let deleteSizeDup = emptySizeArr.reduce((a, b) => {
  if (a.indexOf(b) < 0) a.push(b);
  return a;
}, []);
let deleteColorDup = emptyColorArr.reduce((a, b) => {
  if (a.indexOf(b) < 0) a.push(b);
  return a;
}, []);

console.log(deleteSizeDup); // [ 'z', 'y' ]
console.log(deleteColorDup); // [ 'a', 'b' ]
```

`delteSizeDup`변수에서 `reduce()`의 작동방법을 확인하기 위해 콘솔에 로그를 찍어보겠습니다. 우선 첫번째 인자는 `a`가 아니라 빈 객체 `[]`가 오는 것과 `indexOf()`로 검색한 값이 0보다 작다는 것은 찾고자 하는 문자열이 없다는 뜻과 같음을 알고 넘어갑시다.

```js
let deleteSizeDup = emptySizeArr.reduce((a, b) => {
  console.log(a);
  console.log(b);

  if (a.indexOf(b) < 0) a.push(b);
  return a;
}, []);

// []
// z
// [ 'z' ]
// y
// [ 'z', 'y' ]
// z
// [ 'z', 'y' ]
// y
```

빈 배열 안에 `b`가 없으면 들어가고 있으면 안들어가는 식으로 배열 마지막 값까지 확인을 하면 중복이 제거된 배열을 얻을 수 있습니다.

네번째, 새로 들어갈 배열의 중복을 제거했으면 이 배열이 들어갈 자리를 비워줘야 합니다. 아까 우리가 변수로 선언한 JSON데이터는 배열 값이 객체인 형태입니다.

```js
products = [
  {
    'pid': '1',
    'pname': 'test1',
    'psize': 'z',
    'pcolor': 'a'
  },

  (...)
];
```

객체의 속성을 제거하기 위한 유일한 방법인 `delete`연산자를 사용합니다.

```js
delete products[0].psize;
delete products[0].pcolor;
```

네, 끝입니다.

다섯째, 아까 중복제거를 했던 배열을 초기에 선언한 배열에 삽입합니다.

```js
products[0].psize = deleteSizeDup;
products[0].pcolor = deleteColorDup;
```

여섯째, 배열의 첫번째 값을 제외한 나머지 값(나머지 객체)은 `splice()`메서드를 이용해서 제거합니다. `splice()`는 배열의 기존요소를 삭제, 교체하거나 새 요소를 추가할 수 있는 메서드입니다. 매개변수는 다음과 같습니다.

`splice(start[, deleteCount[, item1[, item2[, ...]]]])`

- start: 배열의 변경을 시작할 인덱스 값
- deleteCount: 배열에서 제거할 요소의 수
- item: 배열에 추가될 요소

```js
let insertedArr = products.splice(1, products.length - 1);
```

저는 두번째 객체부터 3만큼의 배열 요소를 삭제했습니다. 그 다음 콘솔에 찍어보겠습니다.

```js
console.log(products);

// [ { pid: '1',
//    pname: 'test1',
//    psize: [ 'z', 'y' ],
//    pcolor: [ 'a', 'b' ] } ]
```

배열에 있는 값을 검색하고, 추가하고, 삭제하고 하는 과정이 우리가 한 일의 전부였습니다.
