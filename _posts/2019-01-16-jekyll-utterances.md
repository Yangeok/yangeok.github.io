---
layout: post
title: '깃헙 저장소 이슈 페이지를 댓글로 쓰는 방법'
author: Yangeok
categories: Blog
comments: true
tags: ['github', 'page', 'blog', 'jekyll', 'utterances', 'comments', 'comment']
cover: 'http://drive.google.com/uc?export=view&id=1W8G0IEL970Xe3pNQL-OR8NOq3S9_XkGa'
---

작업환경은 Github Page Blog, Jekyll, [Centrarium Theme](http://bencentra.com/centrarium)입니다.

정적페이지에서는 db를 사용할 수 없기때문에 일반적인 방법으로는 댓글을 구현하지 못합니다. 그래서 대다수 깃헙페이지 블로거들이 사용하는 서비스가 [disqus](https://disqus.com/)인데요. 깔끔하지 못한 ui와 마크다운을 사용하지 못한다는 단점이 있음에도 가장 유명하고 한글문서가 많다는 이유로 저도 사용하게 됐습니다. 아직까진 블로그에 댓글이 없긴 하지만 그래도 깔끔한게 좋잖아요^^ 구글링 중에 블로그를 돌아다니다 댓글창이 네모지고 어디서 많이 본 레이아웃이더라구요. 그래서 좀 찾아보니 [utterances](https://utteranc.es/)란 프로젝트가 있더군요.

- Open source. 🙌
- No tracking, no ads, always free. 📡🚫
- No lock-in. All data stored in GitHub issues. 🔓
- Styled with Primer, the css toolkit that powers GitHub. 💅
- Dark theme. 🌘
- Lightweight. Vanilla TypeScript. No font downloads, JavaScript frameworks or polyfills for evergreen browsers.

위와 같이 스스로를 소개하고 있습니다. [깃헙 저장소](https://github.com/utterance/utterances)에 소스까지 전부 공개되어있더군요.

utterances은 깃헙 이슈 검색 [api](https://developer.github.com/v3/search/#search-issues)를 사용해서 해당 포스트와 매칭되는 이슈가 없으면 새로 생성하고 이미 존재하면 원래 있던 이슈를 사용합니다. 이슈에 달리는 댓글을 [primer](https://primer.style/)로 스타일을 깃헙식으로 보여줍니다.

블로그에 utterances 추가 방법을 알아봅시다.

1. 깃헙 저장소를 새로 만듭니다. 저같은 경우는 [blog-comments](https://github.com/Yangeok/blog-comments)라는 이름으로 만들었습니다.

2. utterances 웹페이지에서 [configuration](https://utteranc.es/#configuration)탭으로 갑니다. `repo`에 힌트가 나온 것처럼 `사용자명/저장소명`을 입력합니다. 저는 `Yangeok/blog-comments`라고 입력했습니다.

![](https://www.dropbox.com/s/nr95s7th6dgiibj/utterence2.png?dl=1)

3. 포스트와 깃헙저장소 이슈를 이제 연결을 시켜줘야 합니다. 옵션이 6개 있는데 위의 4개는 utterances가 `pathname`, `url`이나 `title`을 자동추적해서 블로그 댓글과 이슈를 생성해주지만, 밑에 2개는 사용자가 직접 세팅을 해줘야 생성이 되니 참고바랍니다. 저는 `pathname`을 선택했습니다.

![](https://www.dropbox.com/s/zbq9hrxo1fbkq6w/utterence3.png?dl=1)

4. 댓글창 테마를 고릅니다.

![](https://www.dropbox.com/s/ndxf83laa0ofq7e/utterence4.png?dl=1)

5. 소스를 복붙합니다. disqus를 사용할때와 마찬가지로 포스팅 댓글 부분 레이아웃 소스에 붙여줍니다.

![](https://www.dropbox.com/s/st1o6d0wkoigm68/utterence1.png?dl=1)

```js
<script
  src="https://utteranc.es/client.js"
  repo="Yangeok/blog-comments"
  issue-term="pathname"
  theme="github-light"
  crossorigin="anonymous"
  async
/>
```

이제 로컬에서 블로그를 `bundle exec jekyll serve`로 실행시켜봅니다. 댓글창이 안떠서 바로 구글에 검색해봤더니 아까 댓글용으로 만들었던 저장소에 `.json`파일을 하나 추가해줘야 한다더군요. 파일명은 `utterances.json`으로 아래와 같이 작성한 후 깃헙에 푸쉬합니다. 물론 url은 본인이 댓글을 쓰고자 하는 웹페이지 주소로 바꾸셔야합니다.

```json
{
  "origins": ["https://yangeok.github.io"]
}
```

잘되는군요. 댓글이 보기에 훨씬 disqus보다 깔끔하고 댓글들을 [깃헙저장소 이슈페이지](https://github.com/Yangeok/blog-comments/issues)에서 한번에 모아서 볼 수 있으니 훨씬 좋을 것 같습니다. 참고로 utterances는 작년 3월에 시작된 프로젝트더라구요. 어서 이름을 떨쳤으면 하는 바램입니다.

![](https://www.dropbox.com/s/paf0vcjqt520phh/utterence5.png?dl=1)

이렇게 뜨던 댓글이

![](https://www.dropbox.com/s/mumfe9199aluwkz/utterence6.png?dl=1)

이렇게 바뀝니다.
