---
layout: post
title: React에서 HashRouter를 사용해 redirection 막기
author: Yangeok
categories: React
comments: true
cover: https://res.cloudinary.com/yangeok/image/upload/v1557918359/logo/posts/retlify.jpg
---

영문이 많이 들어가니 제목이 [보그체](https://namu.wiki/w/%EB%B3%B4%EA%B7%B8%EC%B2%B4)같군요..

## 작업환경

- create-react-app
- react
- react-router v4
- netlify

## 작업순서

SPA인 리액트는 라우터에 상관없이 항상 같은 `index.html`만 보여줍니다. 그래서 새로고침을 하면 404 Not Found 오류가 납니다.

netlify 위에서 돌아가는 페이지의 경우 코드 내부에서 proxy설정을 해놓았더라도 아래 `_redirects`파일을 build파일에 포함시켜주지 않으면 api서버에서 데이터를 가져오지 못합니다. `_redirects`에 관한 문서를 확인하시려면 [여기](https://www.netlify.com/docs/redirects/)를 눌러주세요.

이 설정파일이 있어서 새로고침을 해도 404가 나지 않게 됩니다.

```
/* https://api.server.com/* 301
```

하지만 새로고침을 한다면 api서버로 리디렉트되겠죠. 혹은 뒤로가기를 하더라도 같은 결과가 생기겠죠.

```
https://awesome-devblog.netlify.com/#/
```

멍청하게 계속 헤매고 있다가 [어썸 데브블로그](https://awesome-devblog.netlify.com/#/) url을 보고 아차 싶더라구요. 그래서 이것을 해결하기 위해 url에 `#`을 넣어주는 작업이 필요합니다. 모든 라우터 설정 뒤에 `#`를 붙여줘야 하냐고요? 아뇨, `App`컴포넌트를 감싸고있는 `BrowserRouter`컴포넌트만 `HashRouter`로 바꿔주면 모든게 해결됩니다.

```js
import React from 'react';
import ReactDOM from 'react-dom';
import { App } from 'components';
import { Provider } from 'react-redux';
import { HashRouter } from 'react-router-dom';
import store from 'store';

ReactDOM.render(
  <Provider store={store}>
    <HashRouter>
      <App />
    </HashRouter>
  </Provider>,
  document.getElementById('root')
);
```

에서

```js
<BrowserRouter>
  <App />
</BrowserRouter>
```

`history`객체를 사용하기 위한 컴포넌트인 `BrowserRouter`를 아래와 같이 바꾸었습니다.

```js
<HashRouter>
  <App />
</HashRouter>
```

이렇게 하면 웹페이지가 뒤로가기, 새로고침을 해도 api서버로 리디렉트 되지않고 잘 돌아가는 것을 확인할 수 있었습니다.

근데 이상하게도 어썸 데브블로그는 루트페이지만 `#`이 붙어있는데 제 프로젝트에는 모든 라우터에 `#`이 붙어있는데 이것은 좀 더 연구를 해봐야 알 것 같습니다. 혹시라도 아시는 분은 댓글 남겨주시길 바랍니다. 허접하지만 저장소 [링크](https://github.com/Yangeok/training-front)는 여기를 눌러주세요.

## 참조

- [Fixing the "cannot GET /URL" error on refresh with React Router and Reach Router (or how client side routers work)](https://tylermcginnis.com/react-router-cannot-get-url-refresh/)
- [HashRouter vs BrowserRouter](https://stackoverflow.com/questions/51974369/hashrouter-vs-browserrouter)
- [Router history with react-router 4.0.0](https://stackoverflow.com/questions/42755934/router-history-with-react-router-4-0-0)
