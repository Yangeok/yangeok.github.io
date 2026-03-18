---
layout: post
title: Tableau 워크북 외부 공유 시 Trusted Auth 설정
author: Yangeok
categories: BI
date: 2022-10-16 16:00
tags: []
cover: https://res.cloudinary.com/yangeok/image/upload/v1665918855/logo/posts/tableau.jpg
---

## 본문

다음과 같은 온프레미스 환경에서 Tableau 워크북을 외부에 임베딩할 때 겪었던 이슈에 관한 이야기를 하려고 합니다.

<img src="https://res.cloudinary.com/yangeok/image/upload/v1667005852/tableau-trusted-auth/01.png">

<br>

---

<br>

## 이슈

임베딩 후 iframe을 호출하니까 로그인 프롬프트가 떡하니 나오더라구요. 계정 정보를 입력하고 로그인을 해도 또 로그인 프롬프트로 리디렉션되는거에요. 결국 iframe 안에서 Tableau 대시보드를 볼 수가 없었습니다.

원인을 찾아보니 Tableau Server가 인증되지 않은 외부 요청을 기본적으로 차단하고 있었습니다. 로그인 프롬프트를 우회하는 방법을 찾아야 했는데, 조사해보니 크게 3가지 선택지가 있었습니다. 게스트 사용자 액세스는 코어 기반 라이센스에서만 쓸 수 있어서 바로 탈락했고, SSO는 인프라 세팅부터 해야 해서 공수가 너무 컸습니다. 결국 **Trusted Authentication**으로 구현하기로 했습니다.

\* 참조: [자격 증명을 묻는 메시지를 표시하지 않도록 웹 사이트에 Tableau Server 대시보드 내장](https://kb.tableau.com/articles/howto/embedding-tableau-server-dashboards-into-a-website-without-prompting-for-credentials?lang=ko-kr)

<br>

---

<br>

## Trusted Auth가 뭔데?

간단히 말하면 Tableau Server가 "이 서버에서 오는 요청은 믿을게" 하고 인증을 건너뛰게 해주는 방식입니다. 내가 만든 API 서버가 Tableau Server에 티켓을 달라고 요청하면, 그 티켓을 iframe URL에 꽂아서 로그인 없이 워크북을 보여줄 수 있게 됩니다.

흐름을 보면, 사용자가 브라우저에서 페이지를 열면 API 서버가 Tableau Server의 `/trusted`로 POST를 보내서 일회용 티켓을 받아옵니다. 그 티켓을 URL에 삽입해서 브라우저에 돌려주면, 브라우저가 티켓 포함 URL로 Tableau Server에 접근하고, Tableau Server는 티켓을 검증한 뒤 제거한 URL로 리디렉션하면서 로그인 없이 워크북이 렌더됩니다.

![https://help.tableau.com/current/server/ko-kr/Img/trusted_auth_666x421.png](https://help.tableau.com/current/server/ko-kr/Img/trusted_auth_666x421.png)

\* 참조: [신뢰할 수 있는 인증](https://help.tableau.com/current/server/ko-kr/trusted_auth.htm)

티켓은 일회용이고 기본 3분이 지나면 만료됩니다.

<br>

---

<br>

## 구현방법

### 태블로

Tableau Server에 "이 IP에서 오는 티켓 요청은 신뢰해라"고 등록해줘야 합니다. TSM CLI에서 아래 명령어로 설정하고 변경사항을 적용하면 됩니다. 변경사항 적용 시 서버가 재시작되니까 점검 시간에 하는걸 추천합니다.

```sh
tsm configuration set -k wgserver.trusted_hosts -v "<api-server-ip>"
tsm pending-changes apply
```

\* 참조: [Tableau Server에 신뢰할 수 있는 IP 주소 또는 호스트 이름 추가](https://help.tableau.com/current/server/ko-kr/trusted_auth_trustIP.htm)

### 포탈

핵심은 API 서버가 Tableau Server의 `/trusted` 엔드포인트에 POST 요청을 보내서 티켓을 받아오는 겁니다. [Zuar 블로그](https://www.zuar.com/blog/implementing-trusted-tickets-for-tableau-server-with-nodejs/)에서 Node.js 데모 코드를 찾았는데, 외부 npm 패키지 없이 내장 모듈(`http`, `https`, `querystring`)만으로 구현할 수 있더라구요.

> 소스코드: [Yangeok/tableau-trusted-auth](https://github.com/Yangeok/tableau-trusted-auth)

```js
// index.js
const http = require('http')
const https = require('https')
const fs = require('fs')
const querystring = require('querystring')

function getTicket(res, tableauServer, username, site) {
  const url = new URL(tableauServer + '/trusted')
  const body = site ? { username, target_site: site } : { username }
  const postData = querystring.stringify(body)
  const module = url.protocol === 'https:' ? https : http

  const req = module.request(
    {
      method: 'POST',
      hostname: url.hostname,
      path: '/trusted',
      headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
    },
    (tableauRes) => {
      let ticket = ''
      tableauRes.on('data', (chunk) => (ticket += chunk))
      tableauRes.on('end', () => {
        res.writeHead(200, { 'Content-Type': 'application/json' })
        res.end(JSON.stringify({ ticket }))
      })
    }
  )
  req.write(postData)
  req.end()
}

const server = http.createServer((req, res) => {
  if (req.method === 'GET' && req.url === '/') {
    const html = fs.readFileSync('./index.html')
    res.writeHead(200, { 'Content-Type': 'text/html' })
    return res.end(html)
  }

  if (req.method === 'POST' && req.url === '/api') {
    let body = ''
    req.on('data', (chunk) => (body += chunk))
    req.on('end', () => {
      const data = JSON.parse(body)
      const shareUrl = new URL(data.share_link)

      // /t/<site> 형태면 멀티 사이트 환경
      let site
      if (shareUrl.pathname.startsWith('/t/')) {
        site = shareUrl.pathname.split('/')[2]
      }

      getTicket(
        res,
        `${shareUrl.protocol}//${shareUrl.hostname}`,
        data.username,
        site
      )
    })
    return
  }

  res.writeHead(404)
  res.end()
})

server.listen(8080, () => console.log('listening on :8080'))
```

`getTicket` 함수에서 Tableau Server의 `/trusted`에 `username`을 POST로 보내면 티켓 문자열이 응답으로 옵니다. 멀티 사이트 환경이면 `target_site`도 같이 보내야 하는데, 공유 링크에 `/t/`가 있으면 멀티 사이트로 보고 사이트명을 추출하도록 했습니다.

프론트엔드에서는 받은 티켓을 워크북 URL 경로에 끼워넣으면 됩니다. URL 변환 방식은 간단합니다.

```
변환 전: https://tableau.example.com/views/Dashboard/Sheet1
변환 후: https://tableau.example.com/trusted/{ticket}/views/Dashboard/Sheet1
```

```js
window.onload = async () => {
  const body = new URLSearchParams({ username, share_link: sharedLink })
  const res = await fetch('/api', { method: 'POST', body })
  const { ticket } = await res.json()

  if (ticket === '-1') {
    console.error('티켓 발급 실패')
    return
  }

  const url = new URL(sharedLink)
  url.pathname = `/trusted/${ticket}${url.pathname}`

  const iframe = document.createElement('iframe')
  iframe.src = url.href
  iframe.width = '100%'
  iframe.height = '600px'
  document.getElementById('containerDiv').appendChild(iframe)
}
```

로컬 테스트는 `node index.js`로 띄우고, 운영에서는 pm2로 프로세스 관리하면 됩니다.

```sh
pm2 start index.js
pm2 save
pm2 startup
```

\* 참조: [Trusted Ticket Authentication With Tableau Server](https://www.zuar.com/blog/trusted-ticket-authentication-with-tableau-server/), [Implementing Trusted Tickets for Tableau Server with NodeJS](https://www.zuar.com/blog/implementing-trusted-tickets-for-tableau-server-with-nodejs/), [Tableau Server에서 티켓 가져오기](https://help.tableau.com/current/server/ko-kr/trusted_auth_webrequ.htm), [zuarbase/trusted_auth_demo](https://github.com/zuarbase/trusted_auth_demo)

<br>

---

<br>

## 삽질했던 부분들

구현 자체는 코드양이 적어서 금방 했는데, 삽질은 따로 있었습니다.

티켓 요청 시 계속 `-1`이 반환되는 문제가 있었는데, Tableau Server에 신뢰할 수 있는 호스트를 등록한 후에 서버 재시작을 제대로 안 해서 생긴 문제였습니다. `tsm pending-changes apply` 하면 재시작이 되긴 하는데, 이것만으로 적용이 안 되는 경우가 있어서 `tsm restart`까지 해줘야 확실했습니다. `-1`이 나오면 응답에 에러 메시지가 전혀 없어서 원인 파악이 어렵습니다. 이런 경우에는 Tableau Server 로그를 직접 뒤져봐야 하는데, 기본 경로는 아래와 같습니다.

```sh
# 로그 위치 확인
tsm configuration get -k basefilepath.log_server

# 실시간 로그 확인
tail -f /var/opt/tableau/tableau_server/logs/vizqlserver/vizql-*.txt
```

`-1`을 반환하는 원인은 생각보다 여러 가지입니다. 신뢰할 수 있는 호스트 미등록이나 재시작 누락이 가장 흔하지만, `username`이 Tableau Server에 존재하지 않는 사용자이거나 멀티 사이트 환경에서 `target_site`를 잘못 전달했을 때도 똑같이 `-1`이 나옵니다. 에러 구분이 안 되니까 하나씩 체크해보는 수밖에 없습니다.

그리고 이 방식은 **Tableau Server(온프레미스)에서만** 동작합니다. Tableau Cloud(SaaS)에서는 Trusted Auth 자체를 지원하지 않아서, 클라우드 환경이라면 처음부터 Connected Apps나 SSO 방식으로 가야 합니다.

마지막으로 보안 관련해서 한 가지 더. 데모 코드에서는 클라이언트가 `username`을 직접 POST로 전달하고 있는데, 실서비스에서 이대로 쓰면 누구든 원하는 username으로 티켓을 발급받을 수 있어서 위험합니다. 실제로는 서버 세션에서 로그인한 사용자 정보를 가져와서 Tableau 사용자와 매핑하는 로직이 API 서버 쪽에 있어야 합니다.
