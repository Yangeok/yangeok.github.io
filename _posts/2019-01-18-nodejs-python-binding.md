---
layout: post
title: 'Node.js에 Python 바인딩 하는방법'
author: Yangeok
categories: Node.js
comments: true
tags: ['nodejs', 'node.js', 'python', 'binding', 'bind', 'connect']
cover: 'http://drive.google.com/uc?export=view&id=1IhRnzezzJBUVznx5zWTsbEuHKNv2F-NR'
---

데이터 관련 라이브러리를 쓰려면 역시 python이 필요합니다. python을 node.js에서 사용하려면 어떡하지 하고 `node.js python 바인딩`이란 키워드로 구글링하다보니 결국 이거더군요. `python-shell`이었습니다. 2014년에 만들어졌고 그전부터 생각을 해왔을텐데 선구자시네요.

사용방법은 아주 간단합니다. 구동환경은 **python 3.6.5**, **node.js 8.11.3** 입니다. 이 환경과 달라도 충분히 잘 돌아갈겁니다. 아래와 같이 설치를 합니다.

```sh
yarn add python-shell
```

다음과 같은 코드를 입력합니다.

```js
const { PythonShell } = require('python-shell');

PythonShell.runString('x = 1 + 1; print(x)', null, (err, results) => {
  if (err) throw err;
  console.log(`results: ${results}`);
});

// results: 2
```

여기서 상수로 입력한 `PythonShell`은 반드시 객체로 감싸줘야 합니다. 안그럼 실행했을때 타입에러가 뜨더라구요.

```sh
TypeError: PythonShell.runString is not a funtion
```

`.py`파일을 가져오지 않고 python 코드만 입력해서 바로 결과값을 콘솔로 찍을 수도 있고, api 중에 `run([스크립트], [옵션], [콜백])`메소드가 있어서 파일을 읽어올 수도 있습니다. 옵션을 보니 결과값을 json으로도 가져올 수가 있나봅니다. 아주 유용할 것같습니다. 아래는 위에 썼던 `.js`파일과 똑같은 내용을 출력하는 코드입니다.

```py
// test.py
x = 1 + 1

print(x)
```

```js
const { PythonShell } = require('python-shell');

PythonShell.run('test.py', null, (err, results) => {
  if (err) throw err;
  console.log(`results: ${results}`);
});

// results: 2
```

아직은 공식페이지에 나온 `run()`과 `runString()`밖에 모르지만 언젠간 다른 메소드들이 필요해져서 익힐 날이 오리라 생각합니다.
