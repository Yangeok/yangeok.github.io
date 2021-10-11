---
layout: post
title: 오라클 클라우드 평생 무료 플랜 사용하기
author: Yangeok
categories: Cloud
date: 2021-08-17 10:41
comments: true
tags: []
cover: https://res.cloudinary.com/yangeok/image/upload/v1628994789/logo/posts/oracle-cloud.jpg
--- 

### 들어가기 앞서

공짜 좋아하세요? [오라클 클라우드](https://www.oracle.com/kr/cloud) 쓰세요. 두 번 쓰세요. AWS, GCP만 경험해보다 평생 무료플랜 IaaS를 찾아 헤매다 찾은 해답이 오라클 클라우드였습니다. 2021년 7월 기준 평생 무료 플랜을 유지하고 있습니다. 심지어 무료로 서버를 2대나 사용할 수 있습니다. 물론 메모리가 500MB밖에 되지 않아 서버 성능이 많이 떨어지지만 가벼운 프로그램은 거뜬히 돌릴 수 있습니다.

참고로 PaaS<sub>Platform as a Service</sub>를 무료로 쓸 수 있는 [Heroku](https://www.heroku.com/)는 무료 러닝 타임이 720시간 미만이었던걸로 기억합니다.

서론이 길어졌죠? 다른 클라우드에서는 손대지 않아도 되는 부분까지 튜닝해줘야 하는 것들을 소개해드리려고 합니다. 콘솔에서 해야하는 세팅들을 다해줬는데도 접속이 되지 않아 삽질했던 경험을 살려 작성했습니다. 부디 다른 분들은 제가 겪었던 고통을 겪지 않으시길 바랍니다.

콘솔 인터페이스가 익숙치 않은건 대수롭지 않은 일이에요. 공짜로 사용하기 위해서는 어쩔 수 없는 부분이니깐요.

### 인스턴스 세팅

콘솔에서 **Compute > Instance > Create Instance**를 클릭해서 새로운 인스턴스를 만듭니다.  저는 이미 무료티어 인스턴스를 2개 만들어서 지우고 새로 만듭니다.

![alt](https://res.cloudinary.com/yangeok/image/upload/v1628994243/oracle-cloud/Bildschirmfoto_2021-08-01_um_8.13.29_PM_Kopie.png)

리전, OS 이미지와 CPU 모델을 무료 티어로 선택합니다. CPU 모델은 `VM.Standard.A1.Flex`만 선택할 수 있습니다.

![alt](https://res.cloudinary.com/yangeok/image/upload/v1628601395/oracle-cloud/Bildschirmfoto_2021-08-01_um_8.14.09_PM.png)

저는 **Ubuntu 20.04**로 선택합니다. 본인이 원하는 OS를 고릅니다.

![alt](https://res.cloudinary.com/yangeok/image/upload/v1628601398/oracle-cloud/Bildschirmfoto_2021-08-01_um_8.14.50_PM.png)

SSH용 공개키를 가지고 있는 경우에는 다음과 같이 복사해서 붙여넣습니다. MacOS에서는 기본 명령어 `pbcopy`를 사용합니다. Linux에서는 `xclip`을, Windows에서는 `clip`를 사용합니다. **Add SSH keys > Paste public keys**를 선택하고 인풋 박스에 복사한 공개키를 붙여넣습니다.

```sh
cat ~/.ssh/<key_name>.pub | pbcopy
```

![alt](https://res.cloudinary.com/yangeok/image/upload/v1628601397/oracle-cloud/Bildschirmfoto_2021-08-01_um_8.15.07_PM.png)

SSH용 키를 만들지 않았다면 다음과 같이 키페어를 만듭니다. RSA 방식으로 만들고, 길이는 4096비트로 하겠다는 뜻입니다.

```sh
ssh-keygen -t rsa -b 4096
```

만들어둔 키페어가 없고, 만드는 것도 귀찮다면 `Add SSH keys > Generate SSH key pair`를 통해 생성된 키파일들을 다운받습니다.

![alt](https://res.cloudinary.com/yangeok/image/upload/v1628601397/oracle-cloud/Bildschirmfoto_2021-08-01_um_8.15.04_PM.png)

**Compute > Instance > Instance Details > Attached VNICs > Create VNIC > Primary IP Information > Assign a public IPv4 address**를 선택합니다. 이제 퍼블릭 IP를 만들 준비가 끝났습니다. 가상 NIC<sub>Network Interface Controller</sub>를 만들었다는 이야기죠. 다시 말해 가상의 랜카드를 만들어 IP주소를 할당했다는 이야기이기도 합니다.

![alt](https://res.cloudinary.com/yangeok/image/upload/v1628601397/oracle-cloud/Bildschirmfoto_2021-08-01_um_8.25.23_PM.png)

**Networking > Virtual Cloud Network > vcn > Subnet Details > Security Lists > Add Security Lists**에서 인/아웃바운드 포트 규칙을 만듭니다. 나중에 필요한 포트만 빼고 다 막아놔야 하지만 테스트가 목적이기때문에 모든 호스트와 통신이 가능하고, 모든 포트와 통신이 가능한 상태로 만듭니다.

![alt](https://res.cloudinary.com/yangeok/image/upload/v1628601397/oracle-cloud/Bildschirmfoto_2021-08-01_um_8.25.23_PM.png)

IP주소 할당과 인/아웃 바운드 규칙을 설정했으면 인스턴스 상세보기로 돌아가 IP주소와 보안그룹을 연결해줍니다.

![alt](https://res.cloudinary.com/yangeok/image/upload/v1628601398/oracle-cloud/Bildschirmfoto_2021-08-01_um_8.20.36_PM.png)

저는 도메인이 있어서 클라우드플레어에 연결합니다.

![alt](https://res.cloudinary.com/yangeok/image/upload/v1628601396/oracle-cloud/Bildschirmfoto_2021-08-08_um_8.42.27_PM.png)

### 인스턴스 내부 방화벽 설정

클라우드 콘솔에서는 방화벽 규칙을 조정했지만, 클라우드 인스턴스 내부에도 방화벽 규칙이 또 있습니다. 이 규칙을 초기화시키지 않는 이상 외부 접속이 절대 되지 않으니 참고하시길 바랍니다.

방화벽 규칙을 초기화하기 위한 방법은 다음과 같은 두가지 방법이 있습니다.

```sh
# way 1
iptables -P INPUT ACCEPT
iptables -P FORWARD ACCEPT
iptables -P OUTPUT ACCEPT
iptables -t nat -F
iptables -t mangle -F
iptables -F
iptables -X

ip6tables -P INPUT ACCEPT
ip6tables -P FORWARD ACCEPT
ip6tables -P OUTPUT ACCEPT
ip6tables -t nat -F
ip6tables -t mangle -F
ip6tables -F
ip6tables -X

# way 2
iptables-save | awk '/^[*]/ { print $1 } 
                     /^:[A-Z]+ [^-]/ { print $1 " ACCEPT" ; }
                     /COMMIT/ { print $0; }' | iptables-restore
```

위 방법 중 하나를 시도하시고 아래와 같이 방화벽 정책이 초기화됐는지 확인합니다.

```sh
iptables -nvL
```

위의 `iptables` 명령어가 번거롭다면 `firewalld`를 설치해서 빠르게 방화벽 정책을 확인할 수 있습니다. 레드햇, 데비안 계열 모두 동작하는 패키지이니 편하게 사용하시면 됩니다. 다음과 같이 설치합니다.

```sh
# debian like
apt install firewalld

# reghat like
yum install firewalld
```

다음과 같이 방화벽 정책을 확인합니다.

```sh
firewall-cmd --list-all
```

외부에서 접속이 되는지 확인해보기 위해 nginx를 설치합니다. 설치하기 전에 오라클 리눅스의 yum 저장소에는 nginx가 없기때문에 아래 파일에 저장소를 추가합니다.

```sh
# /etc/yum.repo.d/nginx.repo

[nginx]
name=nginx repo
baseurl=http://nginx.org/packages/centos/7/$basearch/
gpgcheck=0
enabled=1
```

저장소가 정상적으로 추가됐는지 확인하기 위해 아래와 같이 명령어를 실행합니다.

```sh
yum clean all
yum repolist
```

이름이 nginx인 저장소가 로그에 찍힌다면 정상적으로 추가가 됐습니다. 다음과 같이 nginx를 설치합니다.

```sh
yum install -y nginx
```

아까 등록해둔 도메인으로 접속해보니 정상적으로 접속되는 것을 확인할 수 있습니다. 자, 여러분도 이제 공짜로 쓰는 오라클 클라우드에서도 쉽게 포트 개방을 할 수 있게 됐습니다!

![alt](https://res.cloudinary.com/yangeok/image/upload/v1628601392/oracle-cloud/Bildschirmfoto_2021-08-10_um_9.42.04_PM.png)
