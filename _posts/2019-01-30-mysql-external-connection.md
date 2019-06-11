---
layout: post
title: MySQL 외부에서 접속할 수 있게 세팅하기
author: Yangeok
categories: DevOps
comments: true
# tags: ['sql', 'mysql', 'database', 'db', 'external', 'connection', 'access']
cover: https://res.cloudinary.com/yangeok/image/upload/v1552474850/logo/posts/mylightbuntu.jpg
---

현재 Ubuntu 16.04가 설치된 AWS Lightsail에 MySQL을 설치한 상태이고 로컬에서 인스턴스에 설치된 MySQL로 접근을 하고자 합니다. 외부에서 접근을 허용하기 위해 4가지 일이 필요합니다.

1. AWS 웹페이지에서 방화벽을 열어준다.
2. 인스턴스 내 config 파일을 수정한다.
3. MySQL에 유저권한을 등록한다.
4. MySQL을 재시작한다.

첫번째부터 시작하겠습니다. 우선 인스턴스를 하나 만들고 인스턴스 설정으로 들어갑니다.

![](https://res.cloudinary.com/yangeok/image/upload/v1552474852/mysql/mysql_2.png)

상단에 네트워킹 탭이 있습니다. 네트워킹 - 방화벽으로 갑니다.

![](https://res.cloudinary.com/yangeok/image/upload/v1552474852/mysql/mysql_3.png)

다른 항목 추가를 눌러 `MySQL/Aurora`를 선택해주면 포트를 자동으로 MySQL이 쓰는 포트인 `3306`으로 만들어줍니다. 저장을 누릅니다.

![](https://res.cloudinary.com/yangeok/image/upload/v1552474852/mysql/mysql_4.png)

두번째, 인스턴스로 들어갑니다. 아직 로컬에서는 접근 못하니 AWS 웹페이지에서 브라우저를 이용한 연결을 합니다.

![](https://res.cloudinary.com/yangeok/image/upload/v1552474852/mysql/mysql_5.png)

인스턴스 쉘에 접속했으면 MySQL에서 허용할 호스트주소를 설정하는 파일을 수정해야 합니다. 내가 설치한 MySQL버전이 어떻게 되는지에 따라 설정 방법이 다릅니다.

만약 5.6 버전 이하를 사용한다면 아래와 같이 파일에 접근하세요.

```sh
$ vim /etc/mysql/my.cnf
```

그리고 5.7 버전 이상을 사용한다면 아래와 같이 파일에 접근하세요.

```sh
$ vim /etc/mysql/mysql.conf.d/mysqld.cnf
```

아마 파일이 `[New File]`이라고 뜨면 잘못 접근한게 확실하니 본인이 사용하는 MySQL버전에 맞게 디렉토리와 파일명을 입력하세요. 설정파일에 들어왔다면 다음과 같은 텍스트가 있을겁니다.

```sh
(...)

[mysqld]
#
# * Basic Settings
#
user            = mysql
pid-file        = /var/run/mysqld/mysqld.pid
socket          = /var/run/mysqld/mysqld.sock
port            = 3306
basedir         = /usr
datadir         = /var/lib/mysql
tmpdir          = /tmp
lc-messages-dir = /usr/share/mysql
skip-external-locking
#
# Instead of skip-networking the default is now to listen only on
# localhost which is more compatible and is not less secure.
bind-address            = 127.0.0.1

(...)
```

여기서 중요한 부분이 `bind-address`입니다. 이 값이 `127.0.0.1`인데 자기 자신을 가리킵니다. 로컬호스트만 MySQL에 접근할 수가 있다는 소리기도 하죠. 이걸 모든 IP에서 접근할 수 있게 바꾸려면 `0.0.0.0`으로 수정하고 저장합니다. 그리고 쉘로 나와 포트가 열려있는지 확인하기 위해 `netstat`명령어를 이용해 확인합니다. 아래와 같이 포트가 열린 것을 확인할 수 있습니다.

```sh
$ sudo netstat -tlnp | grep mysqld
Proto Recv-0 Send-0 Local Address      Foreign Address      State       PID/Program name
tcp        0      0 0.0.0.0:3306       0.0.0.0:*            LISTEN      4124/mysqld
```

세번째, MySQL 내에서 유저 권한을 생성하고 등록해주는 과정을 거쳐야 합니다. 저는 루트계정을 모든 IP에 허용할겁니다. 하지만 실제 서비스나 중요한 데이터가 들어있을 때에는 루트를 사용해선 안됨을 꼭 명심하세요.

```sql
GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY 'root의 패스워드';
```

`*.*`는 `[모든 데이터베이스].[모든 테이블]`에 접근 가능하게 만든다는 의미입니다. 이걸 이용해서 원하는 데이터베이스나 원하는 테이블만 접근 가능하게 만들 수도 있습니다. 쿼리문으로 유저와 접근가능한 호스트 주소가 잘 설정이 되었는지 확인합니다.

```sql
USE mysql;

SELECT user, host FROM user;
+------------------+-----------+
| user             | host      |
+------------------+-----------+
| root             | %         |
| mysql.infoschema | localhost |
| mysql.session    | localhost |
| mysql.sys        | localhost |
| root             | localhost |
+------------------+-----------+
```

원하는 권한이 설정이 됐음을 확인했으면 마지막으로 권한설정을 아래와 같이 저장하고 쉘로 돌아갑니다.

```sql
FLUSH PRIVILEGES;
EXIT;
```

마지막으로 MySQL을 재시작하면 로컬에서도 인스턴스에 있는 MySQL에 접근할 수 있게 됩니다.

```sh
$ sudo service mysql restart
```

이제 커맨드라인에서 원격환경 MySQL에 접속이 잘 되는지 확인을 한번 해볼까요. 다음과 같이 잘되는 모습을 확인할 수 있습니다.

![](https://res.cloudinary.com/yangeok/image/upload/v1552474852/mysql/mysql_1.png)

---

## 참조

- [Remote Connections Mysql Ubuntu](https://stackoverflow.com/questions/15663001/remote-connections-mysql-ubuntu)
