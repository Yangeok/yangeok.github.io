---
layout: post
title: Selenium, Puppeteer 비교하기
author: Yangeok
categories: Node.js
comments: true
cover: https://res.cloudinary.com/yangeok/image/upload/v1567054556/logo/posts/seleteer.jpg
---

## 서두

nodejs의 [cheerio](https://cheerio.js.org), python의 [beautiful soup](https://www.crummy.com/software/BeautifulSoup/bs4/doc/#)은 둘 다 스스로 웹사이트를 크롤링 할 수 없습니다. request 라이브러리를 사용해서 html 소스를 가져온 다음에야 크롤이 가능합니다. 또한 웹사이트에서 javascript가 사용된 부분에는 접근하는데 한계가 있습니다. 그래서 이벤트가 일어나야 html이 렌더되는 부분의 데이터를 얻기 위해서는 [puppeteer](https://www.npmjs.com/package/puppeteer)나 [selenium](https://www.npmjs.com/package/selenium-webdriver)같은 라이브러리가 필요합니다.

브라우저를 조작할 수 있는 기능들이 있기때문에 css, javascript, 뷰포트, 이미지 로딩까지 (심지어 더 넓지만 제가 모르는 부분까지도) 관여할 수 있습니다. 또한 크롤 혹은 테스트 하는 과정을 브라우저를 띄워놓고 눈으로 직접 볼 수가 있죠. 물론 쌩 html로딩만 하는게 가장 속도 면에서는 빠르겠지만 파싱이 안되는 경우가 있어 옵션으로 장난을 쳐줘야 최적화를 할 수 있습니다.

둘의 공통점으로는 물론 `document`객체에 접근하거나, 함수를 이용하는 방법이 있지만, `$`기호에 익숙한 분들이라면 jquery나 cheerio를 붙여서 `$`객체에 html을 담아서 사용할 수 있습니다.

---

## Puppeteer

- 장점

  - 상대적으로 빠른 속도를 자랑합니다. 체감상 selenium으로 똑같은 조건에서 브라우저를 띄우고 한 게시글 하나를 긁어올때 두배는 더 빠른 느낌이었습니다.
  - 상대적으로 업데이트 주기가 빠릅니다.

    <img src="https://res.cloudinary.com/yangeok/image/upload/v1567227825/selenium-puppeteer/puppeteer.jpg" width="500">

- 단점
  - nodejs 위에서만 작동합니다.
  - 크롬에서만 사용 가능합니다.

## Selenium

- 장점

  - 속도가 느린 대신 [selenium grid](https://github.com/SeleniumHQ/selenium/wiki/Grid2)로 허브를 구축해 사용할 수 있습니다.

    - 대신 java로만 할 수 있는 것같고, 구축 조건이 까다로운 것같습니다.
    - 한대의 메인 서버에 여러대의 selenium 서버를 연결해 각각 다른 환경에서 테스트하기 위해 생겨났습니다.
    - 만약 허브에 selenium 서버가 4대 연결되어 있다면 4배는 빠르게 크롤해 puppeteer를 상회하는 성능을 뽑아낼 수도 있겠죠.
    - 허브의 구조는 아래와 같습니다.

    <img src="https://www.guru99.com/images/hub_and_nodes.jpg" width="500">

  - 크롬뿐만 아니라 다른 브라우저도 사용 가능합니다.
  - 때문에 크롬에서 크롤이 되지 않는 웹사이트는 다른 브라우저를 사용해서 크롤할 수 있는 선택지가 생깁니다.
  - 다른 언어에서도 사용가능합니다.
  - java, python이 지원이 좋은 것 같습니다.

- 단점

  - 상대적으로 느린 속도를 자랑(?)합니다.
  - nodejs에서는 지원이 좋지 않아 python에서 실험기능으로 들어가있는 이미지로딩 끄기가 작동하지 않습니다.
  - [여기](https://stackoverflow.com/questions/57389778/javascript-want-to-disable-image-loading-in-selenium)는 작동하지 않아 커뮤니티에 올린 질문글입니다. 엮인글로 연결해서 확인해봐도 끝내 해결하지 못한 부분입니다. 이 옵션에 관해 아시는 분이 계시다면 메일 혹은 댓글 부탁드리겠습니다.
  - 상대적으로 업데이트가 느립니다.

    <img src="https://res.cloudinary.com/yangeok/image/upload/v1567227825/selenium-puppeteer/selenium.jpg" width="500">

---

## 참조

- [Puppeteer vs. Selenium](https://rayleighko.github.io/blog/2019-04-12-puppeteer_vs_selenium)
- [Selenium Grid를 이용한 appium 멀티 실행](https://dejavuqa.tistory.com/129)
- [Selenium Grid Tutorial: Hub & Node (with Example)](https://www.guru99.com/introduction-to-selenium-grid.html)
