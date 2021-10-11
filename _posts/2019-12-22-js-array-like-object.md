---
layout: post
title: Javascript 유사배열을 배열로 바꾸기
author: Yangeok
categories: Javascript
date: 2019-12-22 11:17
comments: true
cover: /assets/header_image.jpg
---

리스트로 된 html 요소를 추출하고자 할때, 특히 웹크롤을 하고자할때 분명 배열로 추출된 것 같은데 배열 메서드를 쓰려고만 하면 에러가 발생할 때가 있습니다. 그 에러를 겪다가 삽질 후 다음번에는 시행착오를 겪지 않기 위해 이 글을 작성합니다.

아래와 같은 html이 있다고 가정하겠습니다.

```html
<ul id="list">
  <li class="item">1</li>
  <li class="item">2</li>
  <li class="item">3</li>
  <li class="item">4</li>
  <li class="item">5</li>
  <li class="item">6</li>
  <li class="item">7</li>
  <li class="item">8</li>
  <li class="item">9</li>
  <li class="item">10</li>
</ul>
```

<br>

---

<br>

document 객체나 jquery 둘 중 아무거나 써도 상관 없습니다. 어차피 같은 javascript잖아요? 성능은 좋지 않아도 빠르게 데이터를 뽑아내야 할 경우엔 jquery를 사용하는 것을 더 선호한답니다. 두 가지 경우 모두 예시를 보도록 하겠습니다.

### DOM을 사용하는 방법

유사배열인 `NodeList`가 콘솔에 찍히는 것을 확인할 수 있습니다.

```js
document.querySelectorAll('#list > .item') 

// NodeList(10) [li.item, li.item, li.item, li.item, li.item, li.item, li.item, li.item, li.item, li.item]
```

### jquery를 사용하는 방법

유사배열인 `HTMLCollection`이 콘솔이 찍히는 것을 확인할 수 있습니다.

```js
$('#list').children

// HTMLCollection(10) [li.item, li.item, li.item, li.item, li.item, li.item, li.item, li.item, li.item, li.item]
```

<br>

---

<br>

둘 다 배열이 아니라서 배열 메서드를 사용하려고 하면 에러가 발생하거나 자식 요소를 볼 수 없게 됩니다.

### DOM을 사용하는 경우

```js
document.querySelectorAll('#list > .item').map(el => el)
```

> Uncaught TypeError: document.querySelectorAll(...).map is not a function
> at <anonymous>:1:46

### jquery를 사용하는 경우

```js
$('#list > .item').children().map(el => el)
```

> C.fn.init [prevObject: C.fn.init(0)]

<br>

---

<br>

때문에 유사배열인 `HTMLCollection`과 `NodeList`를 진짜 배열로 바꿔줘야 다음 작업이 진행가능합니다. 물론 jquery에서는 다음과 같은 경우라면 `toArray()` 메서드만 사용하면 바로 배열로 변경도 가능합니다. 아래와 같은 경우들을 제외하고 말하는거에요.

### `toArray()`를 사용하는 경우

```js
$('#list > .item')

// C.fn.init(10) [li.item, li.item, li.item, li.item, li.item, li.item, li.item, li.item, li.item, li.item, prevObject: C.fn.init(1)]

$('#list > .item').toArray()

// (10) [li.item, li.item, li.item, li.item, li.item, li.item, li.item, li.item, li.item, li.item]
```

### double dollar sign을 사용하는 경우

```js
$$('.item')

// (10) [li.item, li.item, li.item, li.item, li.item, li.item, li.item, li.item, li.item, li.item]
```

<br>

---

<br>

이제부터 배열 메서드나 트릭을 사용해서 간단하게 유사배열을 배열로 바꿔볼겁니다.

### `Array.from()`를 사용하는 방법

유사 배열 객체나 반복 가능한 객체를 얕게 복사해 새로운 `Array`객체를 만드는 방법입니다.

```js
Array.from(document.querySelectorAll('#list > .item'))

// (10) [li.item, li.item, li.item, li.item, li.item, li.item, li.item, li.item, li.item, li.item]
```

### `Array.slice()`를 사용하는 방법

참고로 인자로는 `start`, `end`값이 들어가는데, `end`는 생략 가능합니다.

```js
Array.slice(document.querySelectorAll('#list > .item'))

// (10) [li.item, li.item, li.item, li.item, li.item, li.item, li.item, li.item, li.item, li.item]
```

### 스프레드 연산자를 사용하는 방법

```js
[...document.querySelectorAll('#list > .item')]

// (10) [li.item, li.item, li.item, li.item, li.item, li.item, li.item, li.item, li.item, li.item]
```

<br>

---

<br>
ES6 이전이었다면 다음과 같은 구문을 사용했을테지만 매번 배열로 변경할때마다 아래와 같은 방법을 사용하지 않아도 된다는 것은 정말 ECMA재단에 정말 감사할 일입니다. 특히 마지막에 함수를 한 번 돌리는 구문은 눈물납니다 ㅠㅠ

```js
Array.prototype.slice.call(document.querySelectorAll('#list > .item'))
// (10) [li.item, li.item, li.item, li.item, li.item, li.item, li.item, li.item, li.item, li.item]

[].slice.call(document.querySelectorAll('#list > .item'))
// (10) [li.item, li.item, li.item, li.item, li.item, li.item, li.item, li.item, li.item, li.item]

function toArray(x) {
    for(var i = 0, a = []; i < x.length; i++)
        a.push(x[i]);
    return a
}
toArray(document.querySelectorAll('#list > .item'))
// (10) [li.item, li.item, li.item, li.item, li.item, li.item, li.item, li.item, li.item, li.item]
```

다른 궁금하신 점이나 수정해야할 부분이 있다면 댓글 달아주시면 감사하겠습니다 :)
