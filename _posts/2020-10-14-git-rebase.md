---
layout: post
title: Git rebase로 협업 고수되기
author: Yangeok
categories: Git
date: 2020-10-24 18:05
comments: true
tags: [rebase, git, interactive, coworking, pair, 페어, 코워킹]
cover: https://res.cloudinary.com/yangeok/image/upload/v1591531187/logo/posts/git.png
---

## 목차
- [목차](#목차)
- [들어가기 앞서](#들어가기-앞서)
- [대화형 rebase 사용하기](#대화형-rebase-사용하기)
  - [pick, p](#pick-p)
  - [reword, r](#reword-r)
  - [edit, e](#edit-e)
  - [squash, s](#squash-s)
  - [fixup, f](#fixup-f)
  - [drop, d](#drop-d)
- [같은 브랜치에 여러명이 작업한 경우 Merge branch 커밋이 생긴 경우 해소하기](#같은-브랜치에-여러명이-작업한-경우-merge-branch-커밋이-생긴-경우-해소하기)
- [현재 브랜치에 다른 브랜치에 다른 브랜치 커밋 로그를 붙이고 싶은 경우](#현재-브랜치에-다른-브랜치에-다른-브랜치-커밋-로그를-붙이고-싶은-경우)

<br>

---

<br>

## 들어가기 앞서

`rebase`는 크게 두 가지 경우에 사용을 합니다. 

- 같은 브랜치에 여러명이 작업한 경우 Merge branch 커밋이 생긴 경우 해소하기
- 현재 브랜치에 다른 브랜치에 다른 브랜치 커밋 로그를 붙이고 싶은 경우

아래 나올 케이스들은 다른 테크닉도 사용 가능하겠지만, rebase를 위주로 다루는 글이니 유의하면서 읽어주세요. 두 가지 케이스를 설명하기 전에 대화형 rebase를 스크린샷과 함께 짧게 보고 가도록 하겠습니다.

<br>

---

<br>

## 대화형 rebase 사용하기

`rebase -i HEAD`에서 플래그 `-i`는 `--interactive`의 약어로 뜻과 같이 대화형으로 rebase 하겠다는 의미입니다. 아래는 대화형 rebase에서 선택할 수 있는 옵션들입니다. 

<img src="https://res.cloudinary.com/yangeok/image/upload/c_scale,w_700/v1603516954/git-rebase/01.png">

### pick, p

대화형의 기본 옵션 명령어입니다. 커밋의 순서를 바꿀 수도 있습니다. 다만 충돌이 발생할 수 있으니 조심해서 쓰는게 좋습니다. `dd`로 라인을 복사해서 `p`로 붙여넣어볼게요. 

<img src="https://res.cloudinary.com/yangeok/image/upload/c_scale,w_700/v1603519049/git-rebase/02-1.png">

에디터를 탈출하면 auto-merging을 실행합니다. 아쉽게도 충돌이 발생했어요. 

<img src="https://res.cloudinary.com/yangeok/image/upload/c_scale,w_700/v1603519051/git-rebase/02-2.png">

파일에 진입해 충돌을 해소해준 다음에 커밋을 친 다음 `git rebase --continue`까지 쳐주면 커밋 로그 위치가 바뀌게 됩니다.

### reword, r

커밋 메시지를 바로 수정할 수 있습니다.

<img src="https://res.cloudinary.com/yangeok/image/upload/c_scale,w_700/v1603520178/git-rebase/03.png">

대화 박스를 빠져나오면 아래와 같이 바로 커밋을 수정할 수 있게 vi 에디터로 진입하게 됩니다.

<img src="https://res.cloudinary.com/yangeok/image/upload/c_scale,w_700/v1603520495/git-rebase/03-2.png">

### edit, e

edit는 reword 옵션과는 약간 차이가 있는데요. 커밋 메시지 뿐만 아니라 커밋의 작업 내용도 변경할 수 있습니다.

<img src="https://res.cloudinary.com/yangeok/image/upload/c_scale,w_700/v1603520495/git-rebase/04.png">

`git commit --amend`로 커밋을 수정할 수 있습니다.

<img src="https://res.cloudinary.com/yangeok/image/upload/c_scale,w_700/v1603520495/git-rebase/04-2.png">

### squash, s

squash 옵션을 입력한 커밋과 바로 위의 커밋을 하나의 커밋으로 합칠 수 있습니다. squash 옵션을 여러 커밋에 써주면 여러개의 커밋을 하나로 합치는 것도 가능합니다.

<img src="https://res.cloudinary.com/yangeok/image/upload/c_scale,w_700/v1603521335/git-rebase/05.png">

대화 박스를 빠져나오면 squash한 커밋 로그를 적을 수 있게 vi 에디터로 진입합니다. 커밋로그 **2**와 **3**이 보입니다. 두 커밋을 한 개로 묶어서 새로운 커밋을 만들거에요. 커밋로그를 찍으면 보여질 새로운 커밋로그를 위에 적어줍니다. 저는 **Squashed commit**이라고 적어줄게요.

<img src="https://res.cloudinary.com/yangeok/image/upload/c_scale,w_700/v1603521335/git-rebase/05-2.png">

충돌 없이 성공적으로 커밋을 squash했습니다.

<img src="https://res.cloudinary.com/yangeok/image/upload/c_scale,w_700/v1603521335/git-rebase/05-3.png">

커밋로그를 찍어보면 아래와 같이 보입니다.

<img src="https://res.cloudinary.com/yangeok/image/upload/c_scale,w_700/v1603521335/git-rebase/05-4.png">

아래처럼 squash 옵션을 여러 개의 커밋에 적어주면 적어준 커밋 위의 커밋까지 합쳐서 squash를 합니다. 아래에서는 총 3개의 커밋을 squash 합니다.

<img src="https://res.cloudinary.com/yangeok/image/upload/c_scale,w_700/v1603521877/git-rebase/05-5.png">

커밋로그를 찍어보면 아래와 같이 보입니다.

<img src="https://res.cloudinary.com/yangeok/image/upload/c_scale,w_700/v1603521877/git-rebase/05-6.png">

### fixup, f

squash와 마찬가지로 해당 커밋을 이전 커밋과 합치는 기능을 하지만, 커밋 메시지는 합치지 않습니다.

<img src="https://res.cloudinary.com/yangeok/image/upload/c_scale,w_700/v1603522159/git-rebase/06.png">

### drop, d

히스토리에서 해당 커밋을 삭제하는 명령어입니다. pick에서와 마찬가지로 충돌을 조심하세요. 대화형 창에서 해당 커밋의 라인을 없애도 같은 기능을 합니다.

<img src="https://res.cloudinary.com/yangeok/image/upload/c_scale,w_700/v1603523861/git-rebase/07.png">

커밋로그를 찍어보면 아래와 같이 보입니다.

<img src="https://res.cloudinary.com/yangeok/image/upload/c_scale,w_700/v1603524254/git-rebase/07-2.png">

<br>

---

<br>

## 같은 브랜치에 여러명이 작업한 경우 Merge branch 커밋이 생긴 경우 해소하기

<img src="https://res.cloudinary.com/yangeok/image/upload/c_scale,w_700/v1603525133/git-rebase/08.png">

혼자서 작업하면 같은 브랜치에서 작업하는 경우에는 커밋로그가 한 줄로 예쁘게 쌓이지만 커미터가 늘어났는데 어떤 전략도 없이 커밋 로그를 쌓다보면 지저분해진 콜백 지옥과도 같은 커밋 로그 그래프를 볼 수 밖에 없습니다.

사용자 a가 먼저 커밋한 내용을 사용자 b가 동기화하지 않은채로 사용하다가 충돌때문에 **Merge branch** 커밋이 생긴 상황에 어떻게 한 줄로 커밋을 만드는지 보여드릴게요! 

아래와 같이 사용자 a가 **2 by user a**라는 커밋을 먼저 origin에 push했습니다.

<img src="https://res.cloudinary.com/yangeok/image/upload/c_scale,w_700/v1603525780/git-rebase/08-2.png">

사용자 b는 사용자 a가 어떤 커밋을 origin에 올렸단 사실을 모르고 같은 작업을 했습니다.

<img src="https://res.cloudinary.com/yangeok/image/upload/c_scale,w_700/v1603525588/git-rebase/08-3.png">
 
origin에 push하려고 하니 에러가 발생합니다.

<img src="https://res.cloudinary.com/yangeok/image/upload/c_scale,w_700/v1603526249/git-rebase/08-4.png">

origin에 누군가가 먼저 커밋했다는 사실을 확인하고 pull합니다.

<img src="https://res.cloudinary.com/yangeok/image/upload/c_scale,w_700/v1603526249/git-rebase/08-5.png">

merge가 필요한 상태가 됐습니다. 에디터에서 충돌을 해결하고 우선 커밋을 merge해줍니다.

<img src="https://res.cloudinary.com/yangeok/image/upload/c_scale,w_700/v1603526249/git-rebase/08-6.png">

커밋로그를 찍어보면 아래와 같이 커밋로그가 두 줄로 분기된 것을 확인할 수 있습니다. 

<img src="https://res.cloudinary.com/yangeok/image/upload/c_scale,w_700/v1603526249/git-rebase/08-7.png">

한 줄로 커밋로그를 합쳐주기 위해 리베이스를 할겁니다. `git rebase -i HEAD~1`로 **2 by user a** 커밋을 **1** 커밋에서 분기한 가지에서 떼내서 **2 by user b** 위에다 붙여주려고 합니다. 옵션은 pick으로 그대로 내버려둡니다.

<img src="https://res.cloudinary.com/yangeok/image/upload/v1603526641/git-rebase/08-8.png">

auto-merging이 된다면 아래와 같은 로그가 나타나지 않을텐데 충돌한 부분이 있었나봐요. 에디터에서 충돌난 부분을 해소합니다.

<img src="https://res.cloudinary.com/yangeok/image/upload/v1603526640/git-rebase/08-9.png">

충돌을 해결하고 stage에 올려서 커밋을 쳐줍니다. 커밋을 따로 정의하지 않고 `git commit`을 친다면 rebase할 때 선택한 커밋이 자동으로 입력됩니다.

<img src="https://res.cloudinary.com/yangeok/image/upload/v1603526641/git-rebase/08-10.png">

커밋까지 완성하고 나서 `git rebase --continue`를 치면 rebase를 빠져나오게 됩니다. 커밋로그를 보면 분기되었던 커밋로그가 한 줄로 합쳐진 것을 확인할 수 있습니다.

<img src="https://res.cloudinary.com/yangeok/image/upload/v1603526640/git-rebase/08-11.png">

혹시라도 rebase를 하기 전 상태인 **Merged branch**가 있는 상태에서 origin에 push했다면 조금 문제가 생길 수 있는데요. 아래 나올 rebase를 전부 하고 나서 origin에 push도 강제로 해야 합니다. 제가 rebase 작업을 하고 있는 중에 다른 커미터들이 origin에 올라간 커밋을 pull했다면 그들에게도 pull을 강제로 하라고 말을 해줘야 하는 점 꼭 기억하세요!

위 예제는 간단한 예제지만 상대방이 커밋을 많~이 친 경우 동기화할 때에도 마찬가지로 rebase를 사용할 수 있습니다. 복잡한 리베이스로 커밋로그 분기를 한꺼풀 한꺼풀 벗겨내다보면 금새 한 줄로 만들 수 있을거에요.

<br>

---

<br>

## 현재 브랜치에 다른 브랜치에 다른 브랜치 커밋 로그를 붙이고 싶은 경우

git flow를 사용 중이라 feature 브랜치를 따서 새로운 기능을 개발하고 있다고 가정해볼게요. feature 브랜치에서 기능개발이 끝나면 develop에 merge해줘야 합니다. 아무리 기능을 쪼개서 최소한의 커밋만 친다고 하더라도 기능의 복잡도가 높다면 커밋양이 많아질 수밖에 없습니다.

기능 개발이 끝나고 develop에 merge 시키는데 날텐데 충돌을 해결하는데 들어가는 시간이 만만치 않을 것입니다. 가능하다면 feature에서 작업을 하면서 틈 날 때마다 develop에 반영된 커밋을 동기화시키는 것이 충돌을 최소화하는 방법 중에 하나일 것입니다.

아래와 같이 feature와 develop 브랜치로 분기된 상태에서 시작해보겠습니다. feature에 있는 커밋이 아래 이미지에서는 2개지만 우린 커밋을 훨씬 많이 쳤다고 가정해볼게요.

<img src="https://res.cloudinary.com/yangeok/image/upload/c_scale,w_700/v1603529155/git-rebase/09-1.png">

feature 브랜치에는 없는 develop 브랜치의 커밋인 **2 by user b**, **3 by user b**을 feature 브랜치에 붙이려고 합니다. `git rebase -i develop`로 아래와 같이 대화 박스로 진입합니다.

<img src="https://res.cloudinary.com/yangeok/image/upload/c_scale,w_700/v1603529848/git-rebase/09-2.png">

같은 라인에서 충돌나는 코드가 있나봐요. 에디터에서 충돌을 해결합니다.

<img src="https://res.cloudinary.com/yangeok/image/upload/c_scale,w_700/v1603529848/git-rebase/09-3.png">

`git commit`으로 커밋을 치면 develop 브랜치에 있던 커밋명이 그대로 나옵니다.

<img src="https://res.cloudinary.com/yangeok/image/upload/c_scale,w_700/v1603529848/git-rebase/09-4.png">

커밋을 저장하고 에디터에서 빠져나오면 아래와 같이 develop 브랜치에 있던 커밋 위에 개발중인 feature 브랜치에 있는 커밋이 쌓이게 됩니다.

<img src="https://res.cloudinary.com/yangeok/image/upload/c_scale,w_700/v1603529848/git-rebase/09-5.png">

origin에 있는 내용을 덮어씌우기 위해 강제로 push합니다. feature 브랜치가 아래와 같이 한 줄짜리 깔끔하게 변합니다.

<img src="https://res.cloudinary.com/yangeok/image/upload/c_scale,w_700/v1603530108/git-rebase/09-6.png">

주기적으로 개발중인 브랜치를 develop 브랜치와 동기화시켜주면 나중에 merge하는 경우에 충돌이 그만큼 덜 발생하니 공수가 줄어들거에요.

물론 작은 기능이라면 굳이 develop에 있는 커밋을 동기화 시켜줄 필요까지는 없습니다. 충돌난 코드가 몇 개 되지 않는다면 merge하는 시점에 충돌을 풀어주면 되니까요. 이 경우에는 merge하는 경우에 **Merge branch** 커밋이 생길 수 있습니다.

아래는 git flow를 사용하는 경우라면 `git flow feature finish test`, 아니라면 develop 브래치에서 `git merge test`를 한 경우 나오는 커밋로그입니다.

<img src="https://res.cloudinary.com/yangeok/image/upload/c_scale,w_700/v1603530498/git-rebase/09-7.png">

(머지 전략 설명하면 좋을둡!)

`git flow feature finish` 명령어를 사용하는 경우에는 강제로 일반 merge 전략을 사용해 **Merge branch** 커밋이 생길 수밖에 없습니다. 

squash and merge 전략을 사용해서 merge하면 브랜치는 feature와 develop 브랜치 간의 분기는 생기지만 **Merge branch** 커밋이 생기지 않게 merge할 수 있죠. squash의 단어 뜻 그대로 모양이 일그러지게 쥐어짜서 커밋 하나 feature 브랜치에서 작업했던 커밋들을 모아담을 수 있습니다.

`git merge feature/test --squash`를 치고 충돌나는 부분을 해결해줍니다. 그 다음 `git commit`으로 커밋을 쳐주면 아래와 같이 커밋로그를 남길 수 있습니다.  

<img src="https://res.cloudinary.com/yangeok/image/upload/c_scale,w_700/v1603531282/git-rebase/09-8.png">

주석처리 되지 않은 라인은 모두 커밋로그에 저장되기때문에 커밋로그를 아래와 같이 수정해주도록 하겠습니다.

<img src="https://res.cloudinary.com/yangeok/image/upload/c_scale,w_700/v1603531498/git-rebase/09-9.png">

squash and merge는 github 저장소에서 pull request를 날려서 병합하는게 더 편할 수도 있습니다. 

<br>

---

<br>

이번 글은 rebase에 대한 글이라 merge에 대해서는 다른 글에서 깊이있게 다뤄보도록 하겠습니다. 글에 오탈자나 잘못된 부분에 대한 피드백 달아주시면 완전 감사합니다!