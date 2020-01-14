---
layout: page
title: Works
permalink: /works/
---

## Data Pipeline

- 크롤러로 시작해서 데이터 축적의 필요성을 느껴 잡 스케쥴링을 통해 추출한 데이터를 ElasticSearch로 보내는 파이프라인을 구축했습니다.
- 깃허브 저장소는 아래와 같습니다.

  - [pipeline-crawler](https://github.com/Yangeok/nodejs-crawler): 크롤엔진 코드와 사용법에 관한 문서 저장소입니다.
  - [pipeline-lambdas](https://github.com/Yangeok/nodejs-lambdas): Serverless 프레임워크로 레이어된 Lambda 함수와 사용법에 관한 문서 저장소입니다.
  - [pipeline-elk](https://github.com/Yangeok/nodejs-elk): ELK스택으로 데이터를 넣고 빼는 기능과 사용법에 관한 문서 저장소입니다.
  - [pipeline-pipeline-detail](https://github.com/Yangeok/nodejs-pipeline-detail): Lambda 함수부터 크롤엔진을 거쳐 ElasticSearch로 흐르는 워크플로우에 관한 문서 저장소입니다.

- 기술스택은 아래와 같습니다.

  - pipeline-crawler: [aws-sdk](https://aws.amazon.com/ko/developer/language/javascript/), [express](https://expressjs.com/ko/), [moment](https://momentjs.com/), [puppeteer](https://pptr.dev/), [pug](https://pugjs.org/api/getting-started.html), [socket.io](https://socket.io/), [react](https://ko.reactjs.org/)
  - pipeline-lambdas: [aws lambda](https://aws.amazon.com/ko/lambda/), [aws sqs](https://aws.amazon.com/ko/sqs/), [aws-sdk](https://aws.amazon.com/ko/developer/language/javascript/), [typescript](https://www.typescriptlang.org/), [serverless](https://serverless.com/)

  - 프로젝트 구조는 아래와 같습니다.

    ![](/assets/images/pl-01.jpg)

  - 크롤러 데모페이지는 아래와 같습니다.

    ![](/assets/images/pl-02.jpg)

## [Training Log](https://training-front.netlify.com/)

- 운동 관련 블로그, 유튜브를 수집해서 포스팅, 영상을 수집해 보기좋게 제공하고 있습니다. 데이터베이스가 날아가더라도 재수집을 통해 수 분 안에 복구됩니다. 아래 이미지는 서비스의 전체적인 구조입니다.
- 모바일 버전으로도 볼 수 있습니다.
- 깃허브 저장소는 아래와 같습니다.
  - [training-front](https://github.com/Yangeok/training-front): 프론트엔드 코드 저장소입니다.
  - [training-back](https://github.com/Yangeok/training-back): 백엔드 API서버 코드 저장소입니다.
  - [training-rss-feed](https://github.com/Yangeok/training-rss-feed): 백엔드 피드컬렉터 코드 저장소입니다.
  - [training-list](https://github.com/Yangeok/training-list): 유튜브, 블로그 목록을 yml파일로 수집하는 저장소입니다.
- 기술스택은 아래와 같습니다.
  - front-end: [react](https://reactjs.org/), [redux](https://redux.js.org/), [redux-saga](https://redux-saga.js.org/), [jss](https://cssinjs.org/?v=v10.0.0-alpha.16)
  - back-end: [node.js](https://nodejs.org/en/), [koa](https://koajs.com/), [mongodb](https://www.mongodb.com/), [mongoose](https://mongoosejs.com/)
  - devops: [lightsail](https://aws.amazon.com/lightsail/), [ubuntu](https://www.ubuntu.com/), [nginx](https://www.nginx.com/),[heroku](https://dashboard.heroku.com/), [netlify](https://www.netlify.com/)
- 프로젝트 구조는 아래와 같습니다.

  ![](/assets/images/tr-01.jpg)

- 데모페이지는 아래와 같습니다.

  ![](/assets/images/tr-02.jpg)

## [Turing Backend API Server](https://turing-back.herokuapp.com/)

- 프리랜서 에이전트 서비스인 [turing.com](https://turing.com/)에서 테스트 문제로 내주는 백엔드 웹서버입니다.
- 다음은 [깃허브 저장소](https://github.com/Yangeok/turing-back)입니다.
- 기술스택은 아래와 같습니다.
  - back-end: [node.js](https://nodejs.org/en/), [koa](https://koajs.com/), [mysql](https://www.mysql.com/), [sequelize](http://docs.sequelizejs.com/), [passport](http://www.passportjs.org/), [nodemailer](https://nodemailer.com/about/), [faker](https://www.npmjs.com/package/faker), [stripe](https://stripe.com/), [jwt](https://jwt.io/)
  - devops: [lightsail](https://aws.amazon.com/lightsail/), [ubuntu](https://www.ubuntu.com/), [nginx](https://www.nginx.com/), [heroku](https://dashboard.heroku.com/), [travis ci](https://travis-ci.org/)

## [Github Pages 개발블로그](https://yangeok.github.io/)

- Jekyll 테마 [Centrarium](https://github.com/bencentra/centrarium)을 이용해서 만들었습니다. 시작한지는 얼마 안됐고 막힌부분을 풀어나가면서 잊어먹을 것같은 내용이나 한글로 포스팅이 올라오지 않은 내용을 주로 포스팅하고 있습니다. 또한 [TIL](https://github.com/Yangeok/Today-I-learned/tree/master/diary)에 정리한 내용 중 포스팅할만큼 내용이 정리가 된 경우에도 글을 쓰고 있습니다.
- 다음은 [깃허브 저장소](https://github.com/Yangeok/yangeok.github.io)입니다.
- 설치 플러그인은 다음과 같습니다.
  - [utterences](https://utteranc.es/), [tawk.to](https://www.tawk.to/)

## [Shopping Mall](https://mall-front.netlify.com)

- 첫 팀프로젝트입니다. 천천히 같이 공부하며 진행한 프로젝트라 기능구현하는데 시간이 많이 지체되었고 현재 중단된 프로젝트입니다.
- 깃허브 저장소는 아래와 같습니다.
  - [mall-front](https://github.com/Yangeok/mall-front/settings): 프론트엔드 코드 저장소입니다.
  - [mall-back](https://github.com/Yangeok/mall-back): 백엔드 코드 저장소입니다.
- 기술스택은 다음과 같습니다.

  - front-end: [react](https://reactjs.org/), [redux](https://redux.js.org/), [redux-saga](https://redux-saga.js.org/), [typescript](https://www.typescriptlang.org/), [scss](https://sass-lang.com/)
  - back-end: [node.js](https://nodejs.org/en/), [koa](https://koajs.com/), [mysql](https://www.mysql.com/), [sequelize](http://docs.sequelizejs.com/), [passport](http://www.passportjs.org/), [jwt](https://jwt.io/), [mocha](https://mochajs.org/), [chai](https://www.chaijs.com/)
  - devops: [lightsail](https://aws.amazon.com/lightsail/), [ubuntu](https://www.ubuntu.com/), [nginx](https://www.nginx.com/), [heroku](https://dashboard.heroku.com/), [netlify](https://www.netlify.com/), [travis ci](https://travis-ci.org/)

  - 프로젝트 구조는 아래와 같습니다.

    ![](/assets/images/sm-01.jpg)

  - 데이터베이스 구조는 아래와 같습니다.

    ![](/assets/images/sm-02.jpg)

  - 데모페이지는 아래와 같습니다.

    ![](/assets/images/sm-03.jpg)

## [GitHub Repository](https://github.com/yangeok/)

![](/assets/images/repo-01.jpg)

- 쓸데 있는 꾸준한 커밋으로 잔디밭을 만드는 것을 목표로 하고 있습니다.
- [Github TIL](https://github.com/Yangeok/Today-I-learned/tree/master/diary)을 아래에서 연월 별로 확인할 수 있습니다.
  - 2020
    - [Jan. 2020](https://github.com/Yangeok/Today-I-learned/blob/master/diary/2020_01.md)
  - 2019
    - [Dec. 2019](https://github.com/Yangeok/Today-I-learned/blob/master/diary/2019_12.md)
    - [Nov. 2019](https://github.com/Yangeok/Today-I-learned/blob/master/diary/2019_11.md)
    - [Oct. 2019](https://github.com/Yangeok/Today-I-learned/blob/master/diary/2019_10.md)
    - [Sep. 2019](https://github.com/Yangeok/Today-I-learned/blob/master/diary/2019_09.md)
    - [Aug. 2019](https://github.com/Yangeok/Today-I-learned/blob/master/diary/2019_08.md)
    - [Jul. 2019](https://github.com/Yangeok/Today-I-learned/blob/master/diary/2019_07.md)
    - [Jun. 2019](https://github.com/Yangeok/Today-I-learned/blob/master/diary/2019_06.md)
    - [May. 2019](https://github.com/Yangeok/Today-I-learned/blob/master/diary/2019_05.md)
    - [Apr. 2019](https://github.com/Yangeok/Today-I-learned/blob/master/diary/2019_04.md)
    - [Mar. 2019](https://github.com/Yangeok/Today-I-learned/blob/master/diary/2019_03.md)
    - [Feb. 2019](https://github.com/Yangeok/Today-I-learned/blob/master/diary/2019_02.md)
    - [Jan. 2019](https://github.com/Yangeok/Today-I-learned/blob/master/diary/2019_01.md)
  - 2018
    - [Dec. 2018](https://github.com/Yangeok/Today-I-learned/blob/master/diary/2018_12.md)
    - [Nov. 2018](https://github.com/Yangeok/Today-I-learned/blob/master/diary/2018_11.md)
    - [Oct. 2018](https://github.com/Yangeok/Today-I-learned/blob/master/diary/2018_10.md)
    - [Sep. 2018](https://github.com/Yangeok/Today-I-learned/blob/master/diary/2018_09.md)
