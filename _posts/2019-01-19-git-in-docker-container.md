---
layout: post
title: '도커 컨테이너에서 깃 사용하는 방법'
author: Yangeok
categories: DevOps
comments: true
tags:
  [
    'docker',
    'git',
    'github',
    'container',
    'image',
    'POSIX',
    'ubuntu',
    'locale',
    'vi',
    'vim',
    'editor',
  ]
cover: 'https://www.dropbox.com/s/yh6j6ryslvgwd1c/gitdock.jpg?dl=1'
---

바쁜 일상을 살아가고 강박적으로 깃헙에 커밋을 올리는 병에 걸린 사람이 한 명 있습니다. 항상 늦게까지 약속이 있는 날은 노트북을 챙겨 다닙니다. 하지만 그날따라 약속도 없을 것같고 커밋도 올리기 싫어 늑장부리고 싶어지는 날이었습니다. 갑자기 급약속이 생깁니다. 약속이 금방 끝날 것같아 노트북은 챙기지 않습니다. 자정이 지나서야 집에 들어올 수 있었습니다. 그날 해야할 커밋도 하지 못하고 말이죠.

이런 경험이 있었습니다. 공부하면서 왠만하면 커밋은 빼먹지 말자는 생각에 블로그까지 깃헙페이지로 운영하고 있는데 그날은 커밋을 하나도 날리지를 못했죠. 그래서 그 뒤로는 밖에서 컴퓨터 쓸 기회가 생기면 깃을 설치해서 저장소 클론해서 집어넣을 내용 입력하고 커밋해서 푸시를 했습니다. 복잡하다. 개발자인 사람 컴퓨터를 잠깐 빌려쓰면 그럴 일은 없겠네 호호. 도커를 공부하다 문득 이런 생각이 들었습니다.

> 근데 개발자는 컴퓨터에 깃이 깔려있고 자기 계정으로 설정했을텐데? 그럼 도커 컨테이너에 깃을 깔면 어떨까?

로 시작했습니다. 과연 실제로 쓸 일이 있을지는 모르겠지만 한번 실행에 옮겨봤습니다. 제 작업환경은 윈도우입니다. 그리고 도커가 이미 깔려있다는 것을 전제로 하겠습니다. 일단 컨테이너에 운영체제가 있어야겠죠. 윈도우 이미지를 쓸 일이 아직 없는 저는 우분투 이미지를 검색하고 받습니다. 그래도 윈도우 이미지가 있는지 궁금해서 검색을 해봤습니다.

```sh
$ docker search windows

NAME                                                          DESCRIPTION                                     STARS               OFFICIAL            AUTOMATED
microsoft/windowsservercore                                   The official Windows Server Core base image     643
microsoft/mssql-server-windows-developer                      Official Microsoft SQL Server Developer Edit…   289
microsoft/mssql-server-windows-express                        Official Microsoft SQL Server Express Editio…   280
stefanscherer/node-windows                                    Node.js is a JavaScript-based platform for s…   33
thewtex/cross-compiler-windows-x64                            64-bit Windows cross-compiler based on MXE/M…   32                                      [OK]
microsoft/windowsservercore-insider                           The official Windows Server Core insider bas…   30
stefanscherer/registry-windows                                Containerized docker registry for Windows Se…   18
cdrx/pyinstaller-windows                                      PyInstaller for Windows inside Docker (using…   15                                      [OK]
dockcross/windows-x64                                         64-bit Windows cross-compiler based on MXE/M…   9
thewtex/cross-compiler-windows-x86                            32-bit Windows cross-compiler based on MXE/M…   8                                       [OK]
nanori/jenkins-windows-slave                                  Dockerized Windows JNLP slave for Jenkins       5                                       [OK]
asmagin/jenkins-on-windowsservercore                          Jenkins on Windows Server Core                  3                                       [OK]
coderobin/windows-sdk-10.1                                    Windows SDK 10.1 for Windows Container (base…   3                                       [OK]
cloudfoundry/windows2016fs                                                                                    3
jonathank/jenkins-jnlp-slave-windows                          Jenkins JNLP Slaves for Windows                 3
dockcross/windows-x86                                         32-bit Windows cross-compiler based on MXE/M…   3
microsoft/service-fabric-reliableservices-windowsservercore   Windows Server Core OS image for running Ser…   2
stefanscherer/prometheus-windows                              Prometheus in a Windows container               1
cirrusci/windowsservercore                                    Windows containers that can be executed on G…   1
stefanscherer/visualizer-windows                              Docker Swarm mode visualizer for Windows        1
cloudfoundry/garden-windows-ci                                CI image for the CF Garden-Windows team         0
toktoknet/windows                                             Windows cross compilers: i686 and x86_64.       0
cloudfoundry/groot-windows-test                               Test images for groot-windows: https://githu…   0
getgauge/gocd-windows-all                                     gocd windows agent with everything needed fo…   0
mgba/windows                                                  Windows autobuilds                              0                                       [OK]
```

있네요. 신기하네요. 우분투 이미지를 검색하고 최신버전을 받습니다.

```sh
$ docker serach ubuntu
$ docker pull ubuntu:latest
```

이미지를 받아왔으면 확인을 합니다.

```sh
docker iamges

REPOSITORY          TAG                 IMAGE ID            CREATED             SIZE
ubuntu              latest              1d9c17228a9e        2 weeks ago         86.7MB
```

호오 받아졌습니다. 이미지를 컨테이너로 만들어줍니다. 저는 바로 쉘로 입장해서 깃을 만져보고 싶으니 `-it`옵션을 추가합니다. `-i`와 `-t`옵션을 합쳐서 사용하면 `-it`가 됩니다. 이름을 정해주지 않으면 지 멋대로 `determined_mcclintock`같은 이름을 지어버려서 컨테이너를 재실행하고자 할때 여간 불편한게 아니기 떄문에 `--name [컨테이너 이름]` 옵션을 사용하는게 정신건강상 좋습니다. 다음과 같이 명령어를 입력합니다.

```sh
$ docker run -it --name ubuntu-git ubuntu:latest
root@590fc23f5bb5:/#
```

이렇게 쉘로 바로 들어가집니다. 구글에서 **우분투 깃 설치** 라고 검색하면 나오는 글을 읽습니다. 아하 이렇게 하는구나

```sh
$ apt-get install git
Reading package lists... Done
Building dependency tree
Reading state information... Done
E: Unable to locate package git
```

오잉? 에러가 납니다. [글에 따르자면](https://stackoverflow.com/questions/29929534/docker-error-unable-to-locate-package-git) apt 저장소가 아직 업데이트 되지 않았고, apt 저장소와 tmp 파일들이 이미지가 만들어지고나서 지워진건 당연한 일이라고 합니다.

이문제를 해결하려면 git을 설치하기 전에 먼저 `apt-get update`를 실행하면 됩니다. 나중에 이미지를 빌드할때도 도움이 될 수 있으니 꼭 알아둡니다. 도커파일에도 ubuntu 이미지만 땡겨오지 말고 꼭 다음과 같이 하도록 합니다.

```dockerfile
RUN apt-get update && apt-get install -y git

(...)

done.
```

done이란 메시지와 함께 깃의 설치가 끝납니다. 가장 먼저 해줘야할 것은 `git config`로 이름과 이메일을 설정하는겁니다.

```sh
$ git config --global user.name "Yangwook Jeong"
$ git config --global user.email wooky92@naver.com
```

설정을 마쳤습니다. 이제 확인을 해봅니다.

```sh
$ git config --list
user.name=Yangwook Jeong
user.email=wooky92@naver.com
```

다행이도 설정한대로 뜨네요. 저장소를 클론을 떠서 파일을 수정해야하는데 vim이 없네요. 설치합니다.

```sh
$ apt-get install -y vim
```

두근거리는 마음으로 에디터로 파일을 만지러 들어갑니다. 네, 한글이 설치되어있질 않아서 인코딩이 깨집니다.

```sh
$ apt-get install -y locales
```

언어팩을 설치하고 `locale`명령어로 언어설정이 도대체 뭘로 됐길래 이러나 확인합니다.

```sh
LANG=
LANGUAGE=
LC_CTYPE="POSIX"
LC_NUMERIC="POSIX"
LC_TIME="POSIX"
LC_COLLATE="POSIX"
LC_MONETARY="POSIX"
LC_MESSAGES="POSIX"
LC_PAPER="POSIX"
LC_NAME="POSIX"
LC_ADDRESS="POSIX"
LC_TELEPHONE="POSIX"
LC_MEASUREMENT="POSIX"
LC_IDENTIFICATION="POSIX"
LC_ALL=
```

지금 사용 가능한 locale을 확인해봅니다. `locale -a`를 하고 엔터를 누릅니다.

```sh
C
C.UTF-8
POSIX
```

`ko_KR`이 들어간게 보이지 않습니다. locale을 생성하고 등록까지 해줍니다. 필요한 언어팩을 컴파일 합니다. `-i` 옵션은 inputfile을 의미하고 `-f`는 문자셋을 뜻한다고 합니다.

```sh
$ localedef -i ko_KR -f UTF-8 ko_KR.UTF-8
$ localedef -i en_US -f UTF-8 en_US.UTF-8
$ locale -a
```

그러고 나서 `locale -a`로 확인해보면 한국어와 영어가 생겨 있습니다.

```sh
C
C.UTF-8
POSIX
en_US.utf8
ko_KR.utf8
```

맞아요 아직 끝난게 아니에요. 왜냐면 아직도 `locale`로 확인해봐도 한글이 안보이거든요. 설정을 다시 해줘야합니다.

```sh
$ dpkg-reconfigure locales
```

를 하면 언어셋들이 뜰겁니다. 각자 환경에서 보이는 `ko_KR.UTF-8`을 찾아 입력란에 입력합니다. 두가지를 묻는데 한글을 선택합니다.

```sh
Locales to be generated: 298

(...)

  1. None  2. C.UTF-8  3. ko_KR.UTF-8
Default locale for the system environment: 3
```

다왔습니다. `LANG`환경값을 아래와 같이 등록합니다.

```sh
$ export LANG=ko_KR.UTF-8
```

이제 `locale`로 확인을 해도 POSIX는 보이지않고 `ko_KR.UTF-8`이 보일것이며 vim 에디터로 파일을 만져봐도 한글이 아름답게 위치할겁니다.

- 요약:
  - 패키지:
    - apt-get update
    - apt-get install -y git
    - apt-get install -y vim
    - apt-get install -y locales
  - 언어셋 설정:
    - locale 생성 및 등록
    - locale 패키지 재설정
    - LANG 환경값 등록

뭘 위한 여정이었는지는 모르겠으나 도움되는 분들이 계시길 바랍니다.

다음과 같이 이미지를 가져와서 돌리시면 위의 과정 대부분을 생략할 수가 있습니다. 하지만 빌드중 커맨드 입력이 안되기 때문에 locale 패키지 재설정과 LANG 환경값 등록은 컨테이너 실행후 직접 하셔야합니다.

```sh
$ docker pull wooky92/ubuntu-git
```
