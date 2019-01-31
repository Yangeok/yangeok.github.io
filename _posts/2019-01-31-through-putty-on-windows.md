---
layout: post
title: '윈도우에서 PuTTY를 통해 AWS 인스턴스 접속하는 방법'
author: Yangeok
categories: DevOps
comments: true
tags:
  ['aws', 'windows', 'putty', 'instance', 'amazon', 'web', 'service', 'access']
cover: 'https://www.dropbox.com/s/nn9v33kxuac9awc/lightsail.jpg?dl=1'
---

AWS 자체 튜토리얼에 나온대로 인증키쌍을 생성했는데 안되더라구요. 한국커뮤니티에는 관련글이 전혀 없었고 외국 커뮤니티도 겨우 뒤져 찾아낸 방법입니다. 리눅스나 맥에서는 쉘을 통해 간단한 명령어를 통해서 바로 인스턴스에 접속할 수 있지만 윈도우는 그렇지 못합니다. 그래서 우리는 아래와 같은 4단계를 거쳐 윈도우에서 인스턴스에 접근할 수 있게 되는 튜토리얼을 [AWS 튜토리얼](https://lightsail.aws.amazon.com/ls/docs/ko/articles/lightsail-how-to-set-up-putty-to-connect-using-ssh)에서 볼 수 있습니다.

1. AWS에서 SSH키를 다운받는다.
2. PuTTY를 설치한다.
3. PuTTYgen에서 `.pem`파일을 `.ppk`로 변환시킨다.
4. PuTTY에서 간단한 설정을 마친후 접속한다.

이 중에 3번째에 치명적인 문제가 있었습니다. 튜토리얼에서 지시한대로 전처리를 하고 나서 PuTTY를 실행하니까 아래와 같은 메시지를 볼 수가 있었습니다.

```sh
# 쉘
login as: ubuntu
Server refused our key

# 메시지창
DIsconnected: No supported authentication methods available (server sent: publickey)
```

튜토리얼에는 여기에 대한 실마리조차 없더라구요. 그래서 인스턴스에는 자동으로 생성되서 손댈 필요없는 `./ssh/authorized_keys`에서 공개키를 잡고 삽질하거나 비밀번호를 거치지 않고 자동로그인을 할 수 있는데도 불구하고 PuTTY로 접근할때 비밀번호를 걸어버리는 삽질까지 안해본 삽질이 없습니다. 해답은 정말 간단하더군요. 굳이 공개키, 개인키의 관계를 모르더라도 해결할 수 있는 아주 쉬운 부분이었으니까요.

PuTTYgen에서 **Conversions - Import key** 를 통해 아까 인스턴스에서 다운받은 SSH키 파일을 데려옵니다.

![](https://www.dropbox.com/s/shfqr03gngy0zv0/putty4.png?dl=1)

튜토리얼에서는 **Actions - Load an existing private key file - Load** 를 통해 `.pem`파일을 가져오라고 합니다. 그리고 이런 메시지까지 같이 뜨죠. Save private key를 통해 PuTTY 고유 포맷으로 저장하라는 소리군요.

![](https://www.dropbox.com/s/0qxqjv9nma157ap/putty7.png?dl=1)

파일을 처음 소개한 방법을 통해 가져오고 나서 키쌍을 생성하기 전에 **Parameters - Type of key to generate** 에서 타입을 **SSH-1 (RSA)** 로 꼭 설정을 바꿔준 후에 **Actions - Generate a public/private key pair - Generate** 를 합니다.

![](https://www.dropbox.com/s/9ibl0o5llp39817/putty5.png?dl=1)

생성을 누르고 난 후에는 PuTTY창 안에서 마우스를 계속해서 움직여줘야 합니다. 랜덤한 키를 생성하기 위한 행동인 것 같습니다. 저는 처음에 멍청하게도 아래와 같은 메시지를 읽지도 않고 키 생성이 왜 이렇게 느리지라고만 생각했는데 지금 생각하면 어이가 없습니다.

![](https://www.dropbox.com/s/44cjj7xz5xeqegu/putty6.png?dl=1)

생성이 다됐다면 **Action - Save the generated key - Save private key** 를 통해 `.ppk`확장자로 개인키를 저장합니다. 그리고는 PuTTY로 넘어와서 튜토리얼에 나온 간단한 세팅을 마치면 윈도우에서도 자체 SSH 클라이언트로 라이트세일에 접속할 수가 있게 됩니다. 여담으로 AWS 포럼에도 에러가 난다고 글을 올리는데 왜 AWS측에서는 튜토리얼을 업데이트하지 않는지 이해가 안되는군요.

![](https://www.dropbox.com/s/32odta3p1qej0s9/putty2.png?dl=1)

(chmod가 필요할 수도 있다는 내용을 작성할 것)

참조:

- [Login via putty - server refused our key](https://forums.aws.amazon.com/thread.jspa?threadID=76569#jive-message-280133)
- [uTTYGen 프로그램으로 비공개키와 공개키쌍 생성](https://wikidocs.net/7368)
