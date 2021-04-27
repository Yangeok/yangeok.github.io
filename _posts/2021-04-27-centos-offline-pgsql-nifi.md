---
layout: post
title: CentOS 내부망에 PostgreSQL, PostGIS, Apache NiFi 설치하기
author: Yangeok
categories: Linux
date: 2021-04-27 15:00
comments: true
tags: []
cover: https://res.cloudinary.com/yangeok/image/upload/v1619337729/logo/posts/centos-nifi-pgsql.jpg
---

## 작성 목적
도커 컨테이너조차 쓸 수 없는 환경에서 인터넷 연결조차 되지 않는 환경에서 패키지를 설치하기 위한 삽질을 하고 왔습니다. 추상화된 패키지 매니저(ubuntu의 apt<sup>Advanced Package Tool</sup>, CentOS의 yum<sup>Yellowdog Updater, Modified</sup>)가 없어도 오프라인(=내부망, 폐쇄망) 환경에서도 원하는 패키지를 뚝딱 설치할 수 있단걸 알리고 싶어 작성한 글입니다.

postgresql, postgis, apache nifi가 어떤 프로그램인지에 대한 설명은 적혀있지 않은 점 참고 부탁드립니다!

<br>

---

<br>

## 작업환경
- CentOS 7.6


<br>

---

<br>

## 개념 소개
### yum vs. rpm
`apt`나 `yum`은 인터넷이 연결되어있어야 사용할 수 있는 패키지 매니저입니다. 리눅스 초기부터 `apt`나 `yum`을 사용했던건 아니에요. `apt`는 `deb` 기반 패키지의 자동 설치/업데이트/삭제 도구이고, `yum`은 `rpm`<sup>Redhat Package Manager</sup> 기반 패키지의 자동 설치/업데이트/삭제 도구입니다.

다시 말하자면,

`rpm`은 각각의 패키지 설치파일 확장명을 말하고, 이것을 설치할 수 있는 패키지 매니저를 말합니다.
`yum`은 `rpm`을 설치하다보면 생기는 의존성들을 OS 버전에 맞게 찾아서 자동으로 설치까지 도와주는 추상화된 패키지 매니저입니다.


<br>

---

<br>

### repository
저장소하면 여러가지 저장소들이 있죠? 깃헙 저장소도 있고, 언어별 패키지 저장소도 있죠. OS에도 마찬가지로 패키지들을 제공해주는 `yum` 저장소가 있습니다. 아래와 같은 기본값으로 들어가있는 저장소가 있는가 하면, 기본 저장소에서 제공해주지 않는 패키지를 다운받기 위해서는 `yum` 저장소를 추가해줘야 하기도 합니다.

```sh
$ ls -l
-rw-r--r--. 1 root root 1664 Nov 23 15:08 CentOS-Base.repo
-rw-r--r--. 1 root root 1309 Nov 23 15:08 CentOS-CR.repo
-rw-r--r--. 1 root root  649 Nov 23 15:08 CentOS-Debuginfo.repo
-rw-r--r--. 1 root root  630 Nov 23 15:08 CentOS-Media.repo
-rw-r--r--. 1 root root 1331 Nov 23 15:08 CentOS-Sources.repo
-rw-r--r--. 1 root root 8515 Nov 23 15:08 CentOS-Vault.repo
-rw-r--r--. 1 root root  314 Nov 23 15:08 CentOS-fasttrack.repo
-rw-r--r--. 1 root root  616 Nov 23 15:08 CentOS-x86_64-kernel.repo
```

`yum`은 `rpm` 패키지를 설치할 때 생기는 의존성을 OS 버전에 맞춰 자동으로 설치해준다고 했었죠? 인터넷이 연결되지 않은 오프라인 환경에서 `rpm` 파일만 가지고도 원하는 패키지를 설치할 수 있지만, 의존성 패키지를 찾아서 직접 설치하는데 드는 공수가 너무 큽니다. 그래서 설치에 필요한 `rpm` 파일들을 로컬 저장소에 모아두고 온라인에서처럼 `yum install`을 하면 큰 공수 없이 뚝딱 패키지 설치를 할 수가 있게 됩니다. 아래서 로컬 저장소를 만들어서 사용하는 방법을 살펴볼겁니다.


<br>

---

<br>

## rpm 파일 다운받기
온라인 환경과 오프라인 환경에서 모두 사용할 수 있게 설치되지 않은 `rpm` 파일을 원하는 위치에 미리 다운을 받아놔야 합니다. 패키지를 설치하지 않고 다운받기 위해서는 아래와 같은 두 가지 방법이 있습니다.

- `yum-utils`에서 나온 `yumdownloader` 명령어
- `yum-downloadonly`에서 나온 `yum --downloadonly` 확장 플래그

이 중에서 저는 첫 번째 방법인 `yumdownloader`를 사용해서 진행할 예정이에요. 두 패키지간의 큰 차이는 없어서 본인에게 익숙하거나 편해보이는 방법을 사용하시면 될 것 같아요. `yumdownloader`은 다음과 같은 옵션들이 있습니다.

- `--downloadonly`: 패키지를 설치하지 않고 다운만 받겠다
- `--resolve`: 패키지에 붙은 의존성을 모두 다운받겠다
- `--dist`: 다운받을 디렉토리를 다음과 같이 정하겠다


<br>

---

<br>

## 로컬 저장소 만들기
인터넷이 되는 서버에서 원하는 폴더에 `createrepo`를 다운받습니다. 저같은 경우 `/home/opc/createrepo`에 다운받았습니다. 인터넷이 연결된 서버는 앞으로 온라인 서버라고 부르겠습니다.

```sh
# /home/opc/createrepo
yumdownloader --downloadonly --resolve createrepo # way 1
yum --downloadonly createrepo --downloaddir=. # way 2
```

패키지 설치에 `rpm` 명령어를 치지 않고 오프라인 서버 2대에 createrepo를 초기화할거라서 재사용 목적의 쉘스크립트 파일을 작성합니다.

```sh
# /home/opc/createrepo/install.sh
rpm -ivh deltarpm-3.6-3.el7.x86_64.rpm
rpm -ivh python-deltarpm-3.6-3.el7.x86_64.rpm
rpm -ivh createrepo-0.9.9-28.el7.noarch.rpm
```

온라인  서버에 패키지를 설치합니다. 온라인 서버에서는 굳이 이렇게 설치 안하셔도 돼요 ㅎㅎ

```sh
# /home/opc/createrepo
sh install.sh
```

`/home/opc/local`에 로컬 저장소를 아래와 같이 선언합니다.

```sh
createrepo /home/opc/local
```

이제 `/home/opc/local`에는 `repodata`라는 디렉토리가 생겼고, 그 안에는 로컬 저장소를 관리하는 파일인 `repomd.xml`이 만들어졌습니다. 아직 끝난게 아니에요. `yum`에 로컬 저장소를 연결하기 위해서는 `/etc/yum.repo.d` 디렉토리 안에 아래와 같은 파일을 써줘야 합니다. 주의할 점으로는 line 2에 있는 `[]`는 저장소 이름으로 공백이 들어가서는 안됩니다.

```sh
# /etc/yum.repo.d/local.repo
[local-repo] # Not allowed empty space!
name=local repository
baseurl=file:///home/opc/local/
enabled=1
gpgcheck=0
```

저장소가 제대로 올라갔나 테스트해봅니다. 앞서 작성한 `local-repo`라는 이름이 저장소 목록에 찍히면 성공입니다.

```sh
yum repolist
```

실제로 로컬 저장소에서 제공하는 패키지 파일로 설치가 되는지 테스트해볼 필요가 있습니다. 외부 저장소는 모두 백업해둡니다. 다른 방법으로는 `yum --enablerepo=<local_repo_name> -y install <package_name>`을 사용할 수 있습니다.

```sh
# /etc/yum.repo.d
mkdir backup custom
mv local.repo custom/
mv *.repo backup/
mv custom/local.repo .
```

다시 저장소가 제대로 올라갔나 테스트합니다. 아래와 같이 저장소가 한 개만 찍히면 성공입니다.

```sh
yum repolist
# repo id  repo name  status
# local-repo  local repository  0
```

오프라인 서버 2대에 각기 다른 프로그램을 설치할 예정이기때문에 아래처럼 저장소 파일을 2개를 준비합니다. `local-dm`은 postgresql12, postgis2.5를, `local-nifi`는 java8, nifi1.12를 가지고 있는 저장소가 될 예정입니다.

```sh
# /etc/yum.repo.d/local-dm.repo
[local-dm]
name=dm local repository
baseurl=file:///home/opc/local-dm/
enabled=1
gpgcheck=0

# /etc/yum.repo.d/local-nifi.repo
[local-nifi]
name=nifi local repository
baseurl=file:///home/opc/local-nifi/
enabled=1
gpgcheck=0
```

우선 각각 저장소를 따로 분리하기 위해 폴더로 분리해서 만들어두도록 하겠습니다. `/home/opc`에서 작업할거에요.

```sh
# /home/opc
mkdir local-dm local-nifi
mv local/createrepo local-dm/
mv local/createrepo local-nifi/

# /home/opc/local-dm
cd local-dm
mkdir postgresql12 postgis25_12

# /home/opc/local-nifi
cd ../local-nifi
mkdir nifi openjdk1.8
```

외부에서 `rpm` 파일을 다운받아야 하니깐 `/etc/yum.repo.d/backup` 폴더에 백업해뒀던 저장소를 살려줍니다.

```sh
mv *.repo custom
mv backup/*.repo .
```


<br>

---

<br>

## PostgreSQL
`postgresql`을 다운받기 위한 저장소를 추가합니다. `yum repolist`를 찍어보면 `pgdg*`라는 저장소가 추가된 것을 확인할 수 있습니다.

```sh
yum install https://download.postgresql.org/pub/repos/yum/reporpms/EL-7-x86_64/pgdg-redhat-repo-latest.noarch.rpm
```

`postgresql12`를 설치하지 않고, 설치에 필요한 `rpm` 파일과 의존성 패키지들을 `/home/opc/local-dm/postgresql12` 폴더에 다운받습니다. 

```sh
yumdownloader --downloadonly --resolve postgresql12 postgresql12-server postgresql12-contrib
```

모든 의존성 파일들을 받았으면 오프라인 서버로 옮겨서 저장소를 등록한 다음 아래와 같이 설치합니다. 폐쇄망의 경우 오프라인 서버와 같은 네트워크에 접속해서 `scp`나 ftp 클라이언트를 이용해서 파일을 옮길 수 있습니다. 

```sh
# install local rpm files
yum install postgresql12
yum install postgresql12-server
yum install postgresql12-contrib

# initialize db
/usr/pgsql-12/bin/postgresql-12-setup initdb

# register, execute service
systemctl enable postgresql-12.service
systemctl start postgresql-12.service

# test db
su - postgres
createdb test
psql -c 'craete extension postgis' -d test

# or do
psql -u postgres psql
postgres=# CREATE DATABASE test;
postgres=# \c test;
```

이전 버전이 설치된 경우 재설치하기 위해서는 아래와 같은 방법으로 삭제할 수 있습니다.

```sh
# remove from service
systemctl stop postgresql-1*
systemctl disable postgresql-1*

# remove pgsql home directory
rm -rf /var/lib/pgsql

# remove pgsql account 
userdel postgres
groupdel postgres

# remove packages
yum list installed *postgres*
yum remove *postgres*
yum list installed *postgres*
```


<br>

---

<br>

## PostGIS
`postgis`를 설치하지 않고, 설치에 필요한 `rpm` 파일과 의존성 패키지들을 `/home/opc/local-dm/postgis25_12` 폴더에 다운받습니다. `/home/opc/local-dm/postgresql12`에 있는 `rpm`이 똑같이 들어오는 것을 확인할 수 있습니다. `postgis`의 의존성이 `postgresql`이라서 같은 파일을 다운받게 되는거죠. 만일의 사태를 대비해 중복된 파일을 받도록 의도했습니다.

```sh
yumdownloader --downloadonly --resolve postgis25_12
```

온라인 서버에서 모든 의존성 파일들을 받았으면 폐쇄망 서버로 옮겨서 저장소를 등록한 다음 아래와 같이 설치합니다.

```sh
# install local rpm files
yum install postgis25_12

# install additional rpm file
rpm -ivh postgis25_12-client-2.5.5-4.rhel7.x86_64.rpm

# test
psql -u postgres psql
postgres=# \c test;
test=# CREATE EXTENSION postgis;
test=# CREATE EXTENSION postgis_topology;
test=# CREATE EXTENSION postgis_sfcgal;
test=# CREATE EXTENSION fuzzystrmatch;
test=# CREATE EXTENSION address_standardizer;
test=# CREATE EXTENSION address_standardizer_data_us;
test=# CREATE EXTENSION postgis_tiger_geocoder;
test=# SELECT PostGIS_version();
```


<br>

---

<br>

## Java
`java8`을 설치하지 않고, 설치에 필요한 `rpm` 파일과 의존성 패키지들을 `/home/opc/local-nifi/openjdk1.8` 폴더에 다운받습니다. 

```sh
yumdownloader --downloadonly --resovljava-1.8.0-openjdk-devel.x86_64
```

모든 의존성 파일들을 받았으면 폐쇄망 서버로 옮겨서 저장소를 등록한 다음 아래와 같이 설치합니다.

```sh
yum install java-1.8.0-openjdk-devel.x86_64
```

설치가 끝났으면 java 컴파일러 버전을 확인합니다.

```sh
javac --version
# javac 1.8.0_292
```

java를 삭제하기 위해서는 아래와 같이 패키지 이름에 java, jdk가 들어간 설치현황을 확인합니다.

```sh
rpm -qa | grep java
rpm -qa | grep jdk
```

java와 관련된 모든 패키지를 삭제합니다.

```sh
yum remove java
yum remove copy-jdk-configs.noarch
yum remove tzdata-java.noarch
yum remove python-javapackages.noarch
```

java가 제대로 삭제됐는지 확인합니다.

```sh
rpm -qa | grep java
rpm -qa | grep jdk
```


<br>

---

<br>

## Apache NiFi
nifi는 yum에서 제공하지 않고 있어서 `/home/opc/local-nifi/nifi` 폴더에서 바이너리를 다운받습니다. [여기](https://nifi.apache.org/download.html)에서 최신 버전을 다운받으실 수 있습니다.

```sh
wget https://archive.apache.org/dist/nifi/1.12.0/nifi-1.12.0-bin.tar.gz
```

gzip 압축을 풀어줍니다.

```sh
tar xvfx nifi-1.12.0-bin.tar.gz
```

javac의 원본파일 위치를 확인합니다.

```sh
readlink -f /usr/bin/javac
# /usr/lib/jvm/java-1.8.0-openjdk-1.8.0.292.b10-1.el7_9.x86_64/bin/javac
```

압축을 풀었으면 설정파일 ./bin/nifi-env.sh에서 환경변수를 수정합니다. 

```sh
# /home/opc/local-nifi/nifi-1.12.0/bin/nifi-env.sh
export JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk-1.8.0.292.b10-1.el7_9.x86_64/
```

nifi가 정상적으로 동작하는지 실행해봅니다.

```sh
./bin/nifi.sh start
```

로그를 확인하기 위해서는 아래와 같이 할 수 있습니다.

```sh
tail -f logs/nifi-app.log # 전체 로그
tail -f logs/nifi-bootstrap.log # 부팅 로그
tail -f logs/nifi-user.log # 사용자 로그
```

nifi 명령어로 systemctl이나 service처럼 사용할 수 있습니다.

```sh
./bin/nifi.sh start # 시작
./bin/nifi.sh stop # 종료
./bin/nifi.sh restart # 재시작
./bin/nifi.sh status # 상태
```

service 등록은 아래와 같이 할 수 있습니다.

```sh
./bin/nifi.sh install nifi # nifi는 데몬 이름
systemctl enable nifi
systemctl restart nifi
```

내용에 비약이 심해서 이해되지 않는 부분이 있다면 댓글 부탁드립니다 :)