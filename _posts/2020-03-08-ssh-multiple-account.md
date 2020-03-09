---
layout: post
title: 머신 한 대에서 GIT 계정 여러개 사용하기
author: Yangeok
categories: Network
date: 2020-03-08 16:08
comments: true
tags: [ssh, github, multiple account]
cover:
---

## 작업환경

- macos 10.15
- github

<br>

---

<br>

## 목차
- [목표](#목표)
- [ssh key란](#ssh-key란)
- [ssh key 생성하기](#ssh-key-생성하기)
- [ssh key 복사하기](#ssh-key-복사하기)
- [ssh key daemon 추가 및 권한 확인](#ssh-key-daemon-추가-및-권한-확인)
- [ssh config 작성하기](#ssh-config-작성하기)
- [gitconfig, gitconfig-* 작성하기](#gitconfig,-gitconfig-*-작성하기)
- [참조](#참조)

<br>

---

<br>

## 목표

경우에 따라 다르겠지만 회사 정책으로 저는 코드관리를 개인계정, 회사계정 따로 해야하는 상황입니다. 예전에는 회사코드도 개인계정으로 관리를 했기때문에 아래와 같은 폴더구조로 폴더관리만으로도 충분했습니다.

```sh
├── CREDENTIAL # 계정정보
├── JOB # 회사 코드
├── TEST # 테스트용 코드
└── Y # 개인 코드
```

로컬머신에서 원래 사용하던 계정이 회사계정이라고 가정하고 이야기하겠습니다. 개인계정으로 `test-for-posting`이란 private 저장소를 만든 후에 clone해보겠습니다. 

```
$ git clone https://github.com/Yangeok/test-for-posting.git
Cloning into 'test-for-posting'...  
remote: Repository not found.  
fatal: repository 'https://github.com/Yangeok/test-for-posting.git/' not found
```

계정 두 개를 동시에 한 대의 머신에서 사용할 수 있으면 private 저장소때문에 머리아플 일도 없겠군요. 거기다 미리 정해둔 폴더마다 원하는 계정으로 커밋을 찍어내 push할 수도 있습니다. 그러기 위해서는 ssh key를 만들어서 github 계정에 등록해주는 작업이 필요합니다. 작업에 앞서 ssh key가 뭔지 간단하게 알아보고 넘어가자구요.

<br>

---

<br>

## ssh key란

ssh 통신을 하기 위해 client와 server가 서로를 식별하기 위해 가지고 있는 public, private key 쌍입니다. 

아래의 이미지처럼 ssh key로 인증하는 과정은 다음과 같은 흐름을 갖습니다.

<img src="https://wiki.cdot.senecacollege.ca/w/imgs/thumb/Ssh_connection_explained.png/1200px-Ssh_connection_explained.png" width="500">  
출처: [The Seneca Centre for Development of Open Technology - OPS335 Lab 1](https://wiki.cdot.senecacollege.ca/wiki/OPS335_Lab_1#SSH_Key_Concepts)

1. 우선 client는 둘 다, server는 public key만 가지고 있는다.
2. client가 server에 ssh 연결을 요청한다.
3. server는 임의의 메시지를 client에게 보낸다.
4. client는 server로부터 받은 메시지를 자신이 가지고 있는 private key로 암호화해서 암호화된 메시지를 server로 보낸다.
5. server는 client에서 받은 암호화된 메시지를 public key로 검증한다.
6. 2에서 자신이 client에게 보낸 임의의 메시지와 일치하는지 확인하고 일치한다면, client는 인증된다.

<br>

---

<br>

## ssh key 생성하기

우선 github 계정 두 개가 준비된 상태에서 터미널로 갑니다. `~/.ssh`로 이동해서 아래와 같이 입력합니다.

```sh
$ ssh-keygen -t rsa -b 4096 -C "yangwookee@gmail.com"
```

아래와 같이 대화형으로 key 쌍을 만들도록 도와줍니다. 먼저 key 파일명을 입력합니다. 먼저 저는 개인 계정용 key 파일을 먼저 만들거라 `id_rsa_personal`이라고 입력하겠습니다.

```
Enter file in which to save the key (~/.ssh/id_rsa): id_rsa_personal
```

보안 목적으로 passphrase를 입력하라고 하지만 굳이 할 필요성을 느끼지 못해 넘어가겠습니다. 

```
Enter passphrase (empty for no passphrase):
Enter same passphrase again:
```

자, key 쌍이 하나 생성되었습니다. 

```
Your identification has been saved in ~/.ssh/id_rsa_personal.
Your public key has been saved in ~/.ssh/id_rsa_personal.pub.
The key fingerprint is:
SHA256:7guBGmNZUorbRfiwhpePtkcawmO1TjAVikzCl5EXAA8 foo@example.com
The key's randomart image is:
+---[RSA 4096]----+
|oE.=O..          |
|=o*O .           |
|o+=*+            |
|.==*..           |
|ooXoo . S        |
|.=+*o  o         |
|.o==  . .        |
|  o..  o         |
|   .    o.       |
+----[SHA256]-----+
```

같은 방법으로 `id_rsa_work`이란 이름으로 key 쌍을 만들어주고 생성된 파일을 확인해보겠습니다.

```sh
id_rsa_personal
id_rsa_personal.pub 
id_rsa_work         
id_rsa_work.pub
```

<br>

---

<br>

## ssh key 복사하기

[Adding a new SSH key to your GitHub account](https://help.github.com/en/enterprise/2.15/user/articles/adding-a-new-ssh-key-to-your-github-account)에 설명이 너무 자세히 나와있으므로 링크로 대체하겠습니다. 각 운영체제 별로 설명이 있습니다.

public key를 복사해 github에서 붙여넣어주는 과정입니다만, 아래의 명령어를 사용하면 파일을 콘솔에 찍어보거나 직접 열어서 복사할 필요가 없어집니다. 

맥을 사용한다면, 
```sh
$ cat id_rsa_personal.pub | pbcopy
```

혹은 
```sh
$ pbcoby < id_rsa_personal.pub
```

윈도우를 사용한다면 아래와 같이 복사할 수 있습니다.
```sh
$ clip < id_rsa_personal.pub
```

<br>

---

<br>

## ssh key daemon 추가 및 권한 확인

터미널로 다시 돌아와서 생성한 key를 daemon에 등록합니다. 

```sh
$ eval "$(ssh-agent -s)" &&\
	ssh-add -K id_rsa_personal		 
```

daemon에 추가된 ssh키는 다음과 같이 확인합니다.

```sh
$ ssh-add -l
```

생성한 private key는 시스템 내의, 그룹 내의 다른 사용자가 봐서는 안됩니다. 즉, 소유자만 `rw-`를 가져야하므로, 권한 번호는 `600`이 되겠군요. key 쌍의 권한이 파일들의 권한이 `600`인지 확인합니다.

```
$ ls -l
-rw------- 1 wookee staff 3381 Mar 8 15:08 id_rsa_personal
-rw------- 1 wookee staff  743 Mar 8 15:08 id_rsa_personal.pub
-rw------- 1 wookee staff 1823 Mar 8 15:08 id_rsa_work
-rw------- 1 wookee staff  397 Mar 8 15:08 id_rsa_work.pub
```

<br>

---

<br>

## ssh config 작성하기

ssh profile을 관리해주는 `~/.ssh`에서 `config`파일을 생성합니다. 다른 key 쌍들과 같이 권한은 `600`입니다.

```sh
# 개인용 계정
Host personal
	HostName github.com
	User git
	IdentityFile ~/.ssh/id_rsa_personal

# 회사용 계정
Host work
	HostName github.com
	User git
	IdentityFile ~/.ssh/id_rsa_work
```

위의 것 외의 옵션은 [여기](https://www.ssh.com/ssh/config)에서 확인하실 수 있습니다.

- `Host`: profile별 식별자명을 입력한다.
- `HostName`: 실제 호스트명을 로그로 입력한다. 이것은 호스트에 닉네임이나 약어로 사용될 수 있으며, ip주소도 사용할 수 있다. 
- `User`: 사용자명을 입력한다.
- `IdentityFile`: private key 파일의 위치를 입력한다.

`config` 파일 작성을 마쳤으면 아래와 같이 테스트해봅니다.

```
$ ssh -T git@personal
Hi Yangeok! You've successfully authenticated, but GitHub 
does not provide shell access.

$ ssh -T git@work
Hi Yangeok! You've successfully authenticated, but GitHub 
does not provide shell access.
```

`ssh -T git@{Host}`로 테스트해볼 수 있습니다. 


git remote url을 설정할때 저장소 소유자의 유저명을 다음과 같이 입력해야 함을 주의해야 합니다. 저장소가 `{User}`의 소유가 아닌 John의 소유라면 `{User}` 부분은 John이 들어가줘야 하는 점 주의해주세요.

```sh
git@{Host}:{User}/{Repository}.git
```

지금까지 온 상태에서는 git에 push, pull까지는 가능하지만, 로컬머신에서 맨 처음 로그인한 계정으로 push, pull이 될거에요. 이제 거의 다 왔어요.

<br>

---

<br>

## gitconfig, gitconfig-* 작성하기

폴더 별로 다른 git 계정을 사용할 수 있게 설정할 차례입니다. 제 폴더 구조에서 `JOB`은 profile을 `work`로, `TEST`, `Y`는 `personal`로 자동으로 매핑해줄 수 있도록 할겁니다.

```sh
├── CREDENTIAL # 계정정보
├── JOB # 회사 코드
├── TEST # 테스트용 코드
└── Y # 개인 코드
```

`.gitconfig` 파일에 아래와 같은 형태의 구문을 추가합니다.

```sh
[includeIf "gitdir:{폴더명}/"]
	path = .gitconfig-{프로파일명}
```

우리는 `personal`, `work`이란 이름의 profile을 만들었고, `JOB`은 profile을 `work`로, `TEST`, `Y`는 `personal`로 연결시키기로 했으니, 다음과 같이 쓸 수 있겠네요.

```sh
[includeIf "gitdir:~/JOB/"]
	path = .gitconfig-work
[includeIf "gitdir:~/TEST/"]
	path = .gitconfig-personal
[includeIf "gitdir:~/Y/"]
	path = .gitconfig-personal
```

자 이제 변수 `path`에 들어간 `.gitconfig-*`를 만들어줄 차례입니다. 빈 파일에 다음과 같은 형태의 구문을 추가합니다. `.gitconfig-work`에는 회사계정 정보를, `.gitconfig-personal`에는 개인계정 정보를 넣습니다. github profile에 표시되는 이름을 유저명에 넣어줘야하는 점 주의해주세요.

```sh
[user]
	email = {이메일 주소}
	name = {이름}
[github]	
	user = {유저명}
```

자, 모든 여정을 다 왔습니다. 이제 여러분은 한 대의 머신에서 두 개의 계정을 자유롭게 왔다갔다하면서 커밋 로그를 남길 수 있게 되었습니다. 혹시라도 push, pull을 하는데 문제가 생긴다면 안된다면 `~/.ssh`의 권한이 `700`이 맞나 확인해봅니다. 잘못된 내용이 있다면 댓글이나 메일 주시면 감사하겠습니다 :)

<br>

---

<br>

## 참조

- [ssh 사용시 암호 대신 SSH key로 인증하기](https://arsviator.blogspot.com/2015/04/ssh-ssh-key.html) 
- [SSH Config File](https://www.ssh.com/ssh/config)