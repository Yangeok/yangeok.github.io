---
layout: post
title: Nodejs 중첩 스트림을 활용한 I/O
author: Yangeok
categories: Nodejs
date: 2022-10-16 16:00
tags: []
cover: https://res.cloudinary.com/yangeok/image/upload/v1668925389/logo/posts/nodejs.jpg
---

비순차 병렬 처리를 통한 API 응답 파싱과 데이터 정제를 한꺼번에 하기 위해 다음과 같은 워크플로우를 구성해보았습니다.

복수 개의 API에 요청을 보내야 했고, 응답은 EUC-KR로 인코딩된 XML 형식이었습니다. 이걸 JSON으로 변환하고 정제한 다음 하나의 CSV 파일로 저장하는게 목표였는데, 응답 처리 순서는 따로 보장할 필요가 없었습니다.

각 조건을 어떻게 구현했는지 순서대로 풀어보겠습니다.

<br>

---

<br>

> 복수 개의 API 요청을 해야 한다.

정해진 개수만큼의 API 요청 처리가 필요했지만, 순서가 중요하지 않기때문에 `Promise.all` 혹은 다음과 같은 구문을 사용할 수 있습니다.

```ts
.reduce(async (prevPromise, i) => {
  await prevPromise

  doSomething(i)
}, Promise.resolve())
```

위 패턴은 이전 프로미스가 끝나야 다음 이터레이션이 시작되는 순차 처리입니다. 순서가 상관없는 경우에는 `Promise.all`로 한꺼번에 쏘는게 낫습니다.

```ts
const responses = await Promise.all(
  urls.map((url) => axios.get(url, { responseType: 'arraybuffer' }))
)
```

여기서 `responseType: 'arraybuffer'`가 중요한데, 이유는 바로 다음에서 설명하겠습니다.

<br>

---

<br>

> API 응답들은 EUC-KR로 인코딩된 XML 형식이다.

공공 API를 사용하다보면 EUC-KR 인코딩 XML을 반환하는 경우가 은근히 많습니다. axios가 기본적으로 응답을 UTF-8 문자열로 변환해버리기때문에 그냥 받으면 한글이 전부 깨져나옵니다. 처음에 `responseType: 'text'`로 받아놓고 왜 깨지지 하면서 삽질했는데, 바이너리로 받아서 `iconv-lite`로 직접 디코딩하는게 정답이었습니다.

```ts
import iconv from 'iconv-lite'

const decoded = iconv.decode(Buffer.from(response.data), 'euc-kr')
```

<br>

---

<br>

> XML로 떨어지는 응답을 JSON으로 변환해야 한다.

`xml2js`의 `parseStringPromise`를 사용했습니다. 콜백 패턴 대신 프로미스를 지원해서 async/await랑 같이 쓰기 편합니다. `explicitArray: false`는 꼭 설정해주는걸 추천하는데, 이게 없으면 `<item>값</item>`이 `{ item: ['값'] }`으로 파싱됩니다. 옵션을 넣으면 `{ item: '값' }`으로 깔끔하게 나옵니다.

```ts
import { parseStringPromise } from 'xml2js'

const json = await parseStringPromise(decoded, {
  explicitArray: false,
  trim: true,
})
```

<br>

---

<br>

> JSON 데이터를 정제해야 한다.

공공 API는 숫자도 날짜도 전부 문자열로 내려주는 경우가 많습니다. 필요한 필드만 추출하면서 타입 변환까지 같이 해줍니다.

```ts
interface Record {
  id: string
  name: string
  value: number
  date: string
}

function cleanRecord(raw: any): Record {
  return {
    id: String(raw.id),
    name: String(raw.name).trim(),
    value: parseFloat(raw.value) || 0,
    date: String(raw.date),
  }
}
```

<br>

---

<br>

> 정제한 데이터를 하나의 CSV 파일로 저장해야 한다.

`csv-stringify`로 Record 배열을 CSV 포맷으로 직렬화해서 파일에 씁니다. 데이터가 적으면 이걸로 충분하지만, 건수가 많아지면 전체 데이터를 메모리에 다 올려놓고 처리하는게 부담이 됩니다.

```ts
import { stringify } from 'csv-stringify/sync'
import { writeFileSync } from 'fs'

const rows = records.map(cleanRecord)
const csv = stringify(rows, { header: true })
writeFileSync('output.csv', csv, 'utf-8')
```

<br>

---

<br>

## Transform 스트림으로 파이프라인 구성하기

위에서 각 단계를 개별적으로 구현했는데, 이걸 Node.js `Transform` 스트림으로 엮으면 데이터가 흘러가면서 단계별로 처리되는 파이프라인을 만들 수 있습니다. `Transform`은 입력을 받아서 가공한 다음 출력으로 내보내는 Duplex 스트림으로, 각 처리 단계를 독립적인 Transform으로 만들고 `stream.pipeline`으로 연결하면 됩니다.

```ts
import { Transform, PassThrough } from 'stream'
import { pipeline } from 'stream/promises'
import { createWriteStream } from 'fs'
import { stringify } from 'csv-stringify'
```

XML 파싱 Transform에서 `objectMode: true`가 포인트입니다. 이걸 설정해야 Buffer/string 대신 JavaScript 객체를 스트림으로 흘릴 수 있습니다. XML 문자열을 넣으면 파싱된 JSON 객체가 나오는 형태가 됩니다.

```ts
const xmlParseTransform = new Transform({
  objectMode: true,
  async transform(chunk, _encoding, callback) {
    try {
      const json = await parseStringPromise(chunk.toString(), {
        explicitArray: false,
        trim: true,
      })
      callback(null, json)
    } catch (err) {
      callback(err as Error)
    }
  },
})
```

데이터 정제 Transform에서는 하나의 XML에 `<item>`이 여러 개 있을 수 있으니까 `this.push()`를 반복 호출해서 각 레코드를 개별적으로 내보냅니다. `callback`의 인자로 넘기면 하나만 보낼 수 있지만, `this.push()`는 1:N 변환이 가능합니다.

```ts
const cleanTransform = new Transform({
  objectMode: true,
  transform(json, _encoding, callback) {
    const items = json?.response?.body?.items?.item ?? []
    const arr = Array.isArray(items) ? items : [items]
    arr.forEach((item) => this.push(cleanRecord(item)))
    callback()
  },
})
```

여기가 "중첩 스트림"의 핵심입니다. `Promise.all`로 여러 API를 동시에 쏘고, 각 응답을 EUC-KR 디코딩한 뒤 `PassThrough` 스트림에 write합니다. `PassThrough`는 들어온 데이터를 그대로 통과시키는 스트림인데, 여러 소스의 데이터를 하나의 스트림으로 모을 때 씁니다. EUC-KR 디코딩은 스트림에 넣기 전에 미리 해줍니다. 멀티바이트 문자가 chunk 경계에서 잘리면 디코딩이 깨질 수 있거든요.

```ts
async function run(urls: string[]) {
  const merge = new PassThrough({ objectMode: true })
  let pending = urls.length

  Promise.all(
    urls.map(async (url) => {
      const response = await axios.get(url, { responseType: 'arraybuffer' })
      const decoded = iconv.decode(Buffer.from(response.data), 'euc-kr')
      merge.write(decoded)
      if (--pending === 0) merge.end()
    })
  )

  await pipeline(
    merge,
    xmlParseTransform,
    cleanTransform,
    stringify({ header: true }),
    createWriteStream('output.csv')
  )
}
```

전체 흐름을 그려보면 이렇습니다.

```
Promise.all (병렬 API 요청)
  ↓ iconv.decode (EUC-KR 디코딩)
  ↓ PassThrough (여러 응답을 하나로 병합)
  ↓ xmlParseTransform (XML → JSON)
  ↓ cleanTransform (JSON → Record)
  ↓ csv-stringify (Record → CSV row)
  ↓ fs.createWriteStream (파일 저장)
```

`stream/promises`의 `pipeline`을 쓰면 스트림 체인 중간에 에러가 나도 자동으로 모든 스트림을 정리해줍니다. 예전 `.pipe()` 방식은 에러가 나면 스트림이 좀비처럼 남아서 메모리 누수가 생기기 쉬웠는데, `pipeline`이 이 문제를 깔끔하게 해결해줍니다.

<br>

---

<br>

## 마치며

처음에는 응답 전체를 메모리에 올린 다음에 디코딩 → 파싱 → 정제 → 저장 순서로 순차적으로 처리했습니다. API 건수가 적을 때는 문제없었는데, 요청 수가 늘어나면서 메모리 사용량이 선형으로 증가하는게 눈에 보이기 시작했습니다.

Transform 스트림으로 바꾸고 나서 달라진 건 크게 두 가지입니다. 하나는 데이터가 청크 단위로 흘러가면서 처리되기때문에 전체를 메모리에 올릴 필요가 없어졌다는 것, 다른 하나는 각 처리 단계가 독립적인 스트림으로 분리되니까 코드가 훨씬 읽기 쉬워졌다는 겁니다. 새로운 처리 단계가 생겨도 Transform 하나 더 만들어서 `pipeline`에 끼워넣으면 되니까 확장도 편합니다.

`.pipe()` 대신 `stream/promises`의 `pipeline`을 쓴 것도 나중에 잘한 선택이었다고 느꼈습니다. 예전에 `.pipe()`로 체인을 엮으면 중간에 에러가 나도 상위 스트림이 닫히지 않아서 메모리 누수가 생기곤 했는데, `pipeline`은 어느 단계에서 에러가 나든 모든 스트림을 알아서 정리해줍니다.

```sh
npm install axios iconv-lite xml2js csv-stringify
npm install -D @types/node @types/xml2js
```
