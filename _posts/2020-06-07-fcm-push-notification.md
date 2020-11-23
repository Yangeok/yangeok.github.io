---
layout: post
title: React Native에서 FCM 플랫폼 통합 푸시 알림 사용하기
author: Yangeok
categories: ReactNative
date: 2020-06-07 13:35
comments: true
tags: [react-native, fcm, firebase, push, notification, apns, apple, android, react-native-firebase, noti]
cover: http://res.cloudinary.com/yangeok/image/upload/v1590495586/logo/posts/react-native-firebase.jpg
---

## 목차

- [목차](#목차)
- [서론](#서론)
- [푸시 알림 흐름](#푸시-알림-흐름)
- [FCM 콘솔 설정](#fcm-콘솔-설정)
  - [iOS](#ios)
  - [안드로이드](#안드로이드)
- [메시지 핸들러와 디바이스 토큰 저장](#메시지-핸들러와-디바이스-토큰-저장)
  - [라이프 사이클](#라이프-사이클)
  - [메시지 핸들러](#메시지-핸들러)
  - [토큰 및 권한 관리](#토큰-및-권한-관리)
  - [v5와의 차이점 및 마이그레이션](#v5와의-차이점-및-마이그레이션)
- [메시지 전달 API](#메시지-전달-api)
  - [레거시 API](#레거시-api)
  - [HTTP v1 API](#http-v1-api)
- [TL;DR](#tldr)

<br> 

---
<br>

## 서론

모바일앱에서 푸시 알림 기능을 사용하는 방법을 다양합니다. 아래와 같은 방법 뿐만아니라 다른 방법들도 많이 있을겁니다.

- Expo Push Notification
- FCM<sup>Firebase Cloud Messaging</sup> + APNS<sup>Apple Push Notification Service</sup>
- 🎉FCM only🎉
- AWS Amplify

Expo 푸시 알림을 사용하면 별도의 인증작업이 필요없지만, `expo eject`를 하면 더 이상 Expo 푸시 알림 기능을 사용할 수 없습니다. 푸시 알림을 사용하기 위해서는 어쩔 수 없이 관리 포인트가 늘어나지만 위 방법들 중 하나를 선택할 수밖에 없습니다. 최대한 빨리 최대한 간단하게 구현하는 것이 가장 중요한 포인트였습니다. AWS Amplify에서 iOS, 안드로이드 푸시 알림 기능 통합 서비스를 제공하고 있기도 하고 앱 서버를 AWS로 관리하고 있어서 이 방법을 선택하려고 했습니다. 그러기에는 2018년도부터 제공하는 서비스라 그런지 레퍼런스가 부실해서 저한테 빠른 구현을 할 수 있는 선택지는 아니었던 것 같습니다.

FCM, APNS로 따로 나눠서 푸시 알림을 관리하는 것도 불편해보였습니다. FCM에서는 자체적으로 안드로이드와 iOS뿐만 아니라 웹까지도 지원하는 것을 확인했습니다. 웹 확장성까지도 갖는 FCM을 선택하는게 가장 최선이라고 생각해 FCM만으로 안드로이드, iOS 푸시 알림을 구현하게 되었습니다.

<!-- <img src="https://res.cloudinary.com/yangeok/image/upload/v1591490911/fcm-push-notification/04.png" width="500"> -->
![](https://res.cloudinary.com/yangeok/image/upload/v1591490911/fcm-push-notification/04.png)

위의 이미지에서 FCM/APNS 바깥에 Invertase의 `react-native-firebase`가 한 번 감싸져 있는 형태이며 백엔드에서 메시지 제공자로 메시지를 전달하는 과정에는 FCM HTTP v1 API를 사용해서 진행할 예정입니다.

<br> 

---
<br>

## 푸시 알림 흐름

복잡한, 하지만 알아두면 쉬운 인증과정을 거친 후에 비로소 알림을 디바이스로 보낼 수 있습니다. 아래의 FCM과 APNS를 사용한 푸시 알림을 이해하는데 가장 도움이 크게 됐던 플로우입니다.

- 디바이스<sup>Device</sup>: 우리가 앱을 설치해서 쓰는 디바이스입니다. 아래에서 디바이스 고유 식별자인 FCM 토큰에 대한 이야기를 이어서 하도록 하겠습니다.
- 백엔드<sup>Backend</sup>: FCM API에 푸시 알림을 보내고자 하는 메시지를 담아 호출하면 추상화된 인증서버로 OS별로 만들어둔 인증정보를 같이 담아 전달합니다.
- FCM/APNS: OS별 인증을 완료하면 메시지 프로바이더 서버로 메시지를 전달합니다.
- 메시지 제공자<sup>Notification Provider</sup>: 전달받은 메시지는 안드로이드에서는 FCM에서 바로, iOS는 APNS를 한 번 거쳐 사용자엑게 메시지를 전달합니다.

![](https://res.cloudinary.com/practicaldev/image/fetch/s--oZDYjw89--/c_limit%2Cf_auto%2Cfl_progressive%2Cq_auto%2Cw_880/https://dev-to-uploads.s3.amazonaws.com/i/y700xtbqzbas833uh0ms.png)

출처: [jakubkoci - React Native Push Notifications](https://dev.to/jakubkoci/react-native-push-notifications-313i)

<br> 

---
<br>

## FCM 콘솔 설정

<!-- <img src="https://res.cloudinary.com/yangeok/image/upload/v1591490805/fcm-push-notification/03.gif" width="500"> -->
![](https://res.cloudinary.com/yangeok/image/upload/v1591490805/fcm-push-notification/03.gif)

프로젝트를 생성하고 **성장 > Cloud Messaging**으로 들어가 추가하고자 하는 앱을 추가합니다. 

<br>

### iOS

<!-- <img src="https://res.cloudinary.com/yangeok/image/upload/v1591453080/fcm-push-notification/02.gif" width="500"> -->
![](https://res.cloudinary.com/yangeok/image/upload/v1591453080/fcm-push-notification/02.gif)

`app.json`에서 `expo.iOS.bundleIdentifier`를 번들 ID에 입력하고 하기 과정대로 따라하면 푸시 알림 기능을 디바이스에서 사용할 수 있습니다. FCM 콘솔에서 앱추가를 해줘야 정상적으로 알림을 수신할 수 있습니다.

`GoogleService-Info.plist`를 `/ios` 아래 집어넣어줍니다. 프로젝트, 클라이언트 정보가 담긴 설정 파일로 `xml` 포맷입니다. 다음은 `/ios/<app_name>/AppDelegate.m` 파일입니다. 콘솔 가이드에도 나오듯 아래 코드를 적절한 위치에 붙여넣어줍니다.

```c
#import <Firebase.h>

(...)
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
  if ([FIRApp defaultApp] == nil) {
    [FIRApp configure];
  }
  (...)
}
```

<!-- <img src="https://res.cloudinary.com/yangeok/image/upload/v1591507063/fcm-push-notification/07.gif" width="500"> -->
![](https://res.cloudinary.com/yangeok/image/upload/v1591507063/fcm-push-notification/07.gif)

`/ios/<app_name>/Info.plist`파일은 xcode에서 설정을 통해 수정할 수 있습니다.  **Targets > Signing & Capabilities > Capability**에 Debug, Release 모드 둘 다 Push Notification을 추가합니다. 그 전에 앱스토어 커넥트<sup>Appstore Connect</sup>에서 인증서에 푸시 알림 기능을 추가시켜줘야 합니다.

<br>

### 안드로이드

<!-- <img src="https://res.cloudinary.com/yangeok/image/upload/v1591491917/fcm-push-notification/05.gif" width="500"> -->
![](https://res.cloudinary.com/yangeok/image/upload/v1591491917/fcm-push-notification/05.gif)

iOS와 마찬가지로 `app.json`에서 `expo.android.package`를 가져와서 패키지 이름에 입력하고 Firebase 콘솔에서 시키는 과정대로 따라합니다. FCM 프로젝트, 클라이언트 정보가 담긴 `google-service.json` 파일을 `/android/app`에 넣습니다. 아래의 파일들을 적절히 수정해줍니다.

다음은 `/android/app/build.gradle` 파일입니다. 콘솔 가이드에도 나오듯 아래 코드를 적절한 위치에 붙여넣어줍니다.

```java
apply plugin: 'com.google.gms.google-services'
```

다음은 `/android/build.gradle` 파일입니다.

```java
buildescript {
  (...)
  dependencies {
    (...)
    classpath 'com.google.gms:google-services:4.2.0'      
  }
  (...)
}
```

<br> 

---
<br>


## 메시지 핸들러와 디바이스 토큰 저장

`react-native`에서 메시지를 수신하는 코드와 정해진 디바이스에서만 메시지를 수신하기 위한 고유한 식별자가 필요합니다. 이 작업을 하기 위해서는 `firebase` 혹은 `firebase`를 래핑하고 있는 써드파티<sup>Third Party</sup> 라이브러리인 `react-native-firebase`가 필요합니다. 

아래와 같이 라이브러리를 설치합니다. v6로 업데이트하면서 세부 기능들을 분리했기때문에 코어 모듈인 `@react-native-firebase/app`를 반드시 설치해야 합니다. FCM 기능을 제공하는 `@react-native-firebase/mesasging`를 추가로 설치해줍니다. `react-native-firebase`는 v5로 아직 지원하고는 있지만 **deprecated**될 예정이니 최신 버전으로 사용하는 것을 추천합니다.

```sh
# using npm
npm i -s @react-native-firebase/app @react-native-firebase/messaging

# using yarn
yarn add @react-native-firebase/app @react-native-firebase/messaging
```

XCode에서 라이브러리를 빌드하기 위해 아래와 같이 `Pods`에 `react-native-firebase`를 설치합니다. `pod-install`은 npm에 올라온 헬퍼 라이브러리로 `/ios`에 들어가지 않아도 `pod install`을 할 수 있도록 도와줍니다.

```sh
# using pod-install
npx pod-install

# using cocoapods
cd ios && pod install
```

<br>

### 라이프 사이클

여기서 잠깐 앱이 동작하는 라이프사이클을 알아보고 갈게요. 

- Foreground
- Background
- Not running
- Suspended

<img src="https://docs-assets.developer.apple.com/published/74077a8107/ec07a686-2315-4700-9415-6485cc3bcfff.png" width="500">

출처: [Working with the watchOS App Life Cycle](https://developer.apple.com/documentation/watchkit/working_with_the_watchos_app_life_cycle?language=objc)

벌써 앱의 상태만 해도 4가지나 되는데요. `react-native-firebase`에서는 아래와 같은 상태로 표현합니다. 

- Foreground: 애플리케이션이 뷰 안에 열려있을 때
- Background: 애플리케이션이 열려있지만 최소화되어있는 상태일 때
- Quit: 디바이스가 잠긴상태나 애플리케이션이 비활성상태일 때

<br>

### 메시지 핸들러

위에서 설명한 상태에 따라서 API를 아래와 같이 구별해서 써줘야 합니다. 

- Forgorund: `onMessage`
- Background/Quit: `setBackgroundMessageHandler`

`onMessage` 메서드는 리액트 컨텍스트<sup>React Context</sup>를 통해 실행되고 앱과 인터렉션<sup>Interaction</sup>이 가능하기 때문에 `App.js` 가장 바깥에 넣어줘야 합니다. 

```js
import React, { useEffect } from 'react'
import messaging from '@react-native-firebase/messaging'

const App = () => {
  const foregroundListener = useCallback(() => {
    messaging().onMessage(async message => {
      console.log(message)
    })
  }, [])
      
  useEffect(() => {
    foregroundListener()  
  }, [])
}
```

`message` 프로퍼티<sup>Property</sup>는 FCM이 디바이스로 보낸 메시지와 인터렉션하기 위해 쓸 데이터를 포함하고 있습니다. Foreground 푸시 알림은 디바이스 상에서 따로 알림을 보내지 않기때문에 상황에 맞는 전략을 세워 커스텀 인터렉션을 추가시켜줘야 합니다.

Background에서 사용하는 리스너 메서드는 아래와 같이 `App.js`를 감싸고 있는 `index.js`에서 작성해줍니다. 여기서 나오는 `expo`는 탈출하긴 했지만 `expokit`을 사용하고 있기때문에 있습니다.

```js
import { registerRootComponent } from 'expo'
import messaging from '@react-native-firebase/messaging'

import App from './App'

massaging().setBackgroundMessageHandler(async message => {
  console.log(message)
})

registerRootComponent(App)
```

<br>

### 토큰 및 권한 관리

현재 디바이스에서 FCM 토큰을 가지고 있고 로그인한 사용자의 FCM 토큰과 일치하지 않는다면, `user.fcmToken`에 토큰을 저장합니다. 원래 받은 토큰이 사라지고 새롭게 생성된 경우도 로그인한 사용자의 FCM 토큰과 일치하는지 확인합니다.

GraphQL 쿼리는 다음과 같은 아주 간단한 쿼리입니다.

```graphql
setFcmToken(token: String!): Int!
```

다음은 `App.js`의 가장 바깥 레이어에 작성해줍니다.

```js
import React, { useState, useCallback, useEffect } from 'react'
import messaging from '@react-native-firebase/messaging'

import { setFcmToken } from 'services/fcm'

const App = () => {
  const [pushToken, setPushToken] = useState(null)
  const [isAuthorized, setIsAuthorized] = useState(false)

  (...)

  const handlePushToken = useCallback(async () => {
    const enabled = await messaging().hasPermission()
    if (enabled) {
      const fcmToken = await messaging().getToken()
      if (fcmToken) setPushToken(fcmToken)
    } else {
      const authorizaed = await messaging.requestPermission()
      if (authorized) setAuthorized(true)
    }
  }, [])

  const saveTokenToDatabase = useCallback(async (token) => {
    const { error } = await setFcmToken(token)
    if (error) throw Error(error)
  }, [])
  
  const saveDeviceToken = useCallback(async () => {
    if (isAuthorized) {
      const currentFcmToken = await firebase.messaging().getToken()
      if (currentFcmToken !== pushToken) {
        return saveTokenToDatabase(currentFcmToken)
      }

      return messaging().onTokenRefresh((token) => saveTokenToDatabase(token))
    }
  }, [pushToken, isAuthorized])
  
  useEffect(() => {
    (...)

    handlePushToken()
    saveDeviceToken()
  }, [])
}
```

함수들을 차근차근 살펴볼게요.

```js
const [pushToken, setPushToken] = useState(null)
const [isAuthorized, setIsAuthorized] = useState(false)

const handlePushToken = useCallback(async () => {
  const enabled = await messaging().hasPermission()
  if (enabled) {
    const fcmToken = await messaging().getToken()
    if (fcmToken) setPushToken(fcmToken)
  } else {
    const authorizaed = await messaging.requestPermission()
    if (authorized) setAuthorized(true)
  }
}, [])
```

권한이 있는지 확인하는 함수인 `handlePushToken`은 앱이 렌더될 때 최초 한 번 실행하도록 합니다. `hasPermission` 메서드를 통해 권한을 확인한 다음 가져온 토큰을 상태에 저장합니다. 권한이 없다면 권한을 요청해서 상태를 변경하는데 권한을 어디에 쓰는지 더 확인한 후 정리하도록 하겠습니다. 

```js
const saveTokenToDatabase = useCallback(async (token) => {
  const { error } = await setFcmToken(token)
  if (error) throw Error(error)
}, [])
```

`saveTokenToDatabase`는 아래의 함수들에서 사용할 GraphQL 쿼리 래퍼입니다. 

```js
const saveDeviceToken = useCallback(async () => {
  if (isAuthorized) {
    const currentFcmToken = await messaging().getToken()
    if (currentFcmToken !== pushToken) {
      return saveTokenToDatabase(currentFcmToken)
    }

    return messaging().onTokenRefresh((token) => saveTokenToDatabase(token))
  }
}, [pushToken, isAuthorized]) 
```

`saveDeviceToken`는 `getToken()`의 결과값이 상태에 저장된 토큰값과 일치하지 않는 경우 DB에 저장합니다. `onTokenRefresh()`는 `currentToken`에 상관없이 토큰이 만료되거나 서버에 토큰을 무효화한 경우 혹은 새로운 토큰이 디바이스에서 만들어지면 실행됩니다. 이제 같은 사용자로 디바이스를 바꿔서 테스트하는 경우에도 사용자 `user.fcmToken`이 동적으로 업데이트돼서 안정적으로 푸시 알림을 테스트할 수 있게 되었습니다.

<br>

### v5와의 차이점 및 마이그레이션

`unimodules`가 v6부터는 자동으로 pod install을 해준다고 명시되어 있습니다. 때문에 iOS에서도 따로 `Podfile`을 써주거나 `react-native link`를 해줄 필요가 없어졌습니다. 

새로 버전업한 라이브러리 네이밍을 살펴보면 `@apollo/client`같이 라이브러리 이름 앞에 `@`를 붙이는게 요새 추세인 것 같더라구요. 이것은 가장 최신버전을 나타내기도 하면서 라이브러리를 모듈단위로 나눠서 불필요한 용량을 줄일 수 있는 장점이 있습니다.

마이그레이션하면서 오류를 너무 많이 겪었습니다. v5에서 v6로 마이그레이션할 예정이라면 맘편하게 `Pods`와 `node_modules` 및 메시지 핸들러를 싹다 지운 후에 처음부터 하시는 것을 추천합니다. 

<br> 

---
<br>

## 메시지 전달 API

이제 Firebase 콘솔에서 날렸던 테스트로 날릴 수 있었던 메시지를 백엔드에서 날릴 수 있습니다. 메시지를 디바이스로 날리는 방법은 아래와 같습니다. 

- Firebase Admin SDK
- FCM HTTP v1 API
- 기존 HTTP API
- XMPP<sup>Extensible Messaging and Presence Protocol</sup>

SDK와 v1 API를 제외한 아래 두가지 방법은 레거시로 분류되고 있다는 점을 참고해주시길 바랍니다. 메시지만 전달하는 용도로 Google API를 사용할 것이기 때문에 HTTP API를 사용하도록 하겠습니다. SDK 용량이 얼마나 될지는 모르겠지만 괜히 앱 용량 늘리기엔 좀 그렇잖아요. 😉

문서에서는 HTTP v1 API를 다음과 같이 표현합니다.

> 가장 최신 프로토콜로서 보다 안전한 승인과 유연한 교차 플랫폼 메시징 기능 제공(Firebase Admin SDK는 이 프로토콜을 기반으로 하며 모든 고유 이점을 제공함)

레거시 API가 v1에 비해 레퍼런스는 훨씬 많지만 점점 관련 문서가 많아질 것이기때문에 한 번만 사용법을 알아두면 앞으로 두고두고 잘 써먹을거란 생각에 v1 API를 사용하기로 맘먹었습니다.

참고로 위에 나온 XMPP는 다음과 같은 특징을 가지고 있습니다.

- XML<sup>Extensible Markup Language</sup>에 기반한 메시지 지향 미들웨어용 통신 프로토콜
- 프로토콜의 원래이름은 Jabber
- 확장가능한 메시징과 상태를 위한 규격 서버 프로토콜

레거시 API와 v1의 차이로는 요청 바디의 모양이 다른 것과 인증방식의 차이, 그리고 플랫폼 별 오버라이딩을 한 번에 한다는 점이 있습니다. FCM 푸시서버에 직접 요청을 때리는 것이기 때문에 GraphQL을 사용하건 HTTP API를 사용하건 본인에게 익숙한 방법을 사용하는 것을 추천합니다. 아래서는 레거시 API와 HTTP v1 API의 간단 비교 및 v1 사용법을 살펴보도록 하겠습니다.

<br>

### 레거시 API

이전 요청은 아래와 같은 URI로 보낼 수 있었습니다.

```sh
POST https://fcm.googleapis.com/fcm/send
```

<!-- <img src="https://res.cloudinary.com/yangeok/image/upload/v1591501485/fcm-push-notification/06.png" width="500"> -->
![](https://res.cloudinary.com/yangeok/image/upload/v1591501485/fcm-push-notification/06.png)

인증 헤더에 콘솔에서 확인할 수 있는 **서버 키**를 집어넣어주면 요청을 할 수 있습니다.

```sh
Authorization: key=server_key
```

기본형 알림 메시지 페이로드<sup>Payload</sup>는 아래와 같습니다.

```json
{
  "token": "token",
  "notification": {
    "title": "title",
    "body": "body"
  },
  "data": {
    "story_id": "story_id"
  }
}
```

<br>

### HTTP v1 API

이제 요청을 아래와 같은 URI로 보낼 수 있습니다.

```sh
POST https://fcm.googleapis.com/v1/projects/<project_name>/messages:send
```

v1 요청의 경우 이전 요청에서 사용하는 **서버 키** 대신에 **OAuth 2.0 액세스 토큰<sup>Access Token</sup>**이 필요합니다. 따라서 다른 구글 API를 사용하기 위해 거쳤던 인증과정을 거쳐 받은 토큰으로 인증 헤더에 토큰 값을 다음과 같이 집어넣어주는 인증과정을 거쳐야 합니다. 인증방법은 아래와 같은 방법들이 있습니다.

- ADC<sup>Application Default Credentials</sup>를 사용하여 사용자 인증 정보 제공
- 수동으로 사용자 인증 정보 제공
- 사용자 인증 정보를 사용하여 액세스 토큰 발급

저희는 `googleapi` 라이브러리를 사용해 아래와 같은 형태의 헤더에 넣을 수 있는 **사용자 인증 정보를 사용하여 액세스 토큰 발급**하도록 하겠습니다. 

```sh
Authorization: Bearer generated_token
```

백엔드 API는 `typeorm`과 GraphQL 쿼리를 사용해서 작성했습니다. 다음은 타입 및 인터페이스 선언입니다.

```ts
type ID = number

interface PushMessage {
  title: string
  subtitle?: string
  body: string
  data?: object
}

interface User {
  id: ID
  fcmToken: string
}
```

다음은 인증을 통해 메시지를 보내는 로직입니다. 

```ts
import { google } from 'googleapis'
import fetch from 'node-fetch'

import {ID} from '../types'
import User from '../entity/User'

const key = require('../../firebase/serviceAccountKey.json')
const getAccessToken = async () => {
  const jwtClient = new google.auth.JWT(
    key.client_email,
    null,
    key.private_key,
    key.fcm_scope,
    null
  )
  return await jwtClient.authorize()
}

function resolvePushMessageToUsers (
  root, 
  {receiverIds, pushMesasge}: {receiverIds: ID[], pushMesasge: PushMessage}, 
  {user}: {user: User}
  ) {
    const { id: senderId } = user
    return pushMessageToUsers(receiverIds, senderId, pushMesasge)
  }

async function pushMessageToUsers (
  receiverIds: ID[], 
  senderId: ID, 
  pushMesasge: PushMessage
  ) {
    const { title, subtitle, body, data } = pushMessage
    const tokens = await User.findByIds(receiverIds, {select: ['fcmToken']})
    
    const result = tokens.map(async token => {
      const message = {
        message: {
          token,
          notification: {
            title,
            body
          },
          data: {
            id: String(data.id)
          },
          android: {},
          apns: {}
        }
      }

    const { accessToken } = await getAccessToken();
    return await fetch(key.fcm_uri, {
      method: 'POST',
      headers: {
        Accept: 'application/json',
        Authorization: `Bearer ${accessToken}`
      }
      body: JSON.stringify(message),
    })
  });

  if (result) return 1;
  return 0;
  }
```

이번에도 마찬가지로 차근차근 살펴보겠습니다. `serviceAccountKey.json`은 Firebase 콘솔에서 **Settings > 서비스 계정 > 새 비공개 키 생성**에서 다운받을 수 있습니다. 아래는 OAuth 2.0 토큰을 반환하는 함수입니다.

```js
const getAccessToken = async () => {
  const jwtClient = new google.auth.JWT(
    key.client_email,
    null,
    key.private_key,
    key.fcm_scope,
    null
  )
  return await jwtClient.authorize()
}
```

다음은 `pushMessageToUsers` 함수입니다. 우선 검색을 통해 받는 사용자의 토큰을 가져옵니다.

```js
const tokens = await User.findByIds(receiverIds, {select: ['fcmToken']})
```

다음은 받을 사용자의 토큰별로 메시지를 정의합니다. HTTP v1 API에서는 메시지 멀티캐스팅<sup>Multicasting</sup>이 불가능하므로 루프를 돌려 요청을 보내는 방식을 택했습니다.

```js    
const result = tokens.map(async token => {
  const message = {
    message: {
      token,
      notification: {
        title, subtitle, body
      }
    }
  }

  const { accessToken } = await getAccessToken();
  return await fetch(key.fcm_uri, {
    method: 'POST',
    headers: {
      Accept: 'application/json',
      Authorization: `Bearer ${accessToken}`
    }
    body: JSON.stringify(message),
  })
});
```

안드로이드, iOS에 보낼 프로퍼티를 오버라이딩 할 수 있습니다. 레거시 페이로드에서는 플랫폼 별로 따로 요청을 해야 했지만 v1 API에서는 분기문이 필요없이 페이로드에 아래처럼 한 번에 넣어서 보낼 수 있습니다. iOS에 들어갈 프로퍼티는 [여기](https://developer.apple.com/documentation/usernotifications/setting_up_a_remote_notification_server/generating_a_remote_notification)에서, 안드로이드는 [여기](https://firebase.google.com/docs/reference/fcm/rest/v1/projects.messages?hl=ko#AndroidNotification)에서 확인할 수 있습니다.

`message.data`에 들어가는 내용은 Map 타입이어야 합니다. `map (key: string, value: string)`이어야 한다고 문서상에 명시되어있는데 이걸 안보는 바람에 자꾸 요청이 `400`이 뜨는 문제를 한참 삽질하다가 해결했습니다. `number` 타입이 안들어가니 반드시 `data`에 들어가는 데이터는 `string` 타입으로 바꿔주셔야 `200`을 반환합니다!

```js
message : {
  token,
  notification: {
    title, subtitle, body
  },
  data: {
    id: String(data.id)
  },
  android: {},
  apns: {}
}
```

<br> 

---
<br>

## TL;DR

푸시 알림 개발 중 가장 불편했던 것은 바로 가상 디바이스에서는 테스트가 불가능하다는 점이었습니다. 플랫폼 별로 인증서가 필요한 것이, 특히 애플은 개발자 인증을 하려면 유료정책에 가입해야 된다는 점이 푸시 알림 관련 레퍼런스가 많이 없는 이유로 보입니다. 혹시라도 수정하거나 추가해야할 내용이 있다면 댓글 부탁드립니다.