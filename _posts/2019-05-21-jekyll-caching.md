---
layout: post
title: Jekyll 블로그 빌드속도 개선하기
author: Yangeok
categories: Blog
comments: true
cover: https://res.cloudinary.com/yangeok/image/upload/v1552474849/logo/posts/jekyll.jpg
---

마크다운으로 글을 작성하면서 VSC플러그인으로 미리보기를 할 수도 있지만 Jekyll서버를 켜놓고 브라우저에서 글을 미리보기하는게 훨씬 편하더라구요. live-reload까지 바라지도 않지만 html파일 빌드가 조금 빨라졌으면 하는 마음에 몇가지를 알아냈습니다. 효과가 적은 것부터 큰 순서로 작성했으니 참고해주세요.

---

## 작업순서

- liquid-c
- jekyll-include-cache
- google analytics 파일로 분리하기
- liquid 조건, 반복문 사용 줄이기
- 실행시 `--incremental` 플래그 붙이기
- 실행시 `--limit_posts 1` 플래그 붙이기

---

## liquid-c

liquid는 Shopify에서 만든 `{% raw %}{% include head.html%}{% endraw %}` 형식으로 html 위에 작성하는 템플릿 언어입니다. liquid를 C로 처리하면서 빌드 속도를 올려준다고 합니다. 사용방법은 아래와 같습니다.

쉘에 아래와 같이 입력합니다.

```sh
gem install liquid-c
```

혹은 Gemfile에 다음과 같이 작성후

```
gem "liquid-c"
```

Gemfile에 작성된 gem을 아래와 같은 명령어로 설치하는 방법이 있습니다.

```sh
bundle install
```

---

## jekyll-include-cache

모든 html을 다시 빌드하기 때문에 빌드 시간이 오래 걸리는 것같습니다. 그래서 liquid로 다시 빌드할 필요가 없는 부분들은 캐싱합니다. 사용방법은 아래와 같습니다.

```sh
gem jekyll-include-cache
```

설치 후 `_layouts`디렉토리에 있는 파일들을 열어봅니다. 아래의 코드를

```html
{% raw %}{% include head.html%}{% endraw %}
```

아래와 같이 고쳐줍니다.

```html
{% raw %}{% include_cached head.html%}{% endraw %}
```

저같은 경우에는 `head.html`에 타이틀이 들어있었습니다.

```html
<head>
  <title>Yangeok</title>
</head>
```

하고 `_config.yml`에 저장된 변수를 이용해 liquid로 바꾸면 나오는

```html
<head>
  {% raw %}{{ page.title }}{% endraw %}
</head>
```

는 같은 말입지요. 저 liquid문이 캐싱을 할때 같이 해버리면 문제가 생겼습니다. 루트페이지에서는 타이틀이 `Yangeok`으로 나와야 하는데 제 첫 포스팅인 `JSON.stringify() 와 JSON.parse() 의 차이`로 나옵니다. 아래와 같이 타이틀만 제외하고 캐싱하니 페이지 타이틀도 올바르게 잘나왔습니다.

```html
{% raw %}{% include_cached head.html%}{% endraw %}

<title>
  {% raw %} {% if page.title %} {{ page.title }} {% endif %} {% endraw %}
</title>
```

---

## google analytics 파일로 분리하기

head.html에 붙어있던 스크립트를 `_includes`에 파일로 따로 만들어 `include`합니다. 다음은 분리시킨 코드입니다.

```html
{% raw %}{% if site.ga_tracking_id%}{% endraw %}
<script
  async
  src="https://www.googletagmanager.com/gtag/js?id={{ site.ga_tracking_id }}"
></script>
<script>
  window.dataLayer = window.dataLayer || [];
  function gtag() {
    dataLayer.push(arguments);
  }
  gtag('js', new Date());
  gtag('config', '{% raw %}{{ site.ga_tracking_id}}{% endraw %}');
</script>
{% raw %}{% endif%}{% endraw %}
```

캐싱해도 이상없기떄문에 `_cached` 옵션을 추가해서 include합니다.

```html
{% raw %}{% include_cached google_analytics.html %}{% endraw %}
```

google analytics뿐만 아니라 다른 플러그인 코드가 있다면 똑같이 코드를 쪼갤 수 있습니다.

---

## liquid 조건, 반복문 사용 줄이기

템플릿에 있는 liquid로 작성된 조건, 반복문을 줄이는 방법도 빌드 속도를 개선하는 방법 중에 하나입니다. 아래 코드를

```html
{% raw %}{% for page in site.pages %}{% if page.title and page.main_nav!=false
%}
<li class="nav-link">
  <a href="{{ '{{ page.url | prepend: site.baseurl'}}}}"> {{ page.title }} </a
  >{% endif %}{% endfor %}{% endraw %}
</li>
```

다음과 같은 형식으로 순수 html로 수정합니다.

```html
<li><a href="/about/">About</a></li>
<li><a href="/posts/">Posts</a></li>
<li><a href="/works">Works</a></li>
```

---

## 실행시 --incremental 플래그 붙이기

리액트 컴포넌트처럼 포스트나 페이지가 바뀔때 바뀐 부분만 빌드를 하기때문에 빌드 속도가 올라가는 방법입니다.

```
bundle exec jekyll serve --incremental
```

혹은

```
bundle exec jekyll serve -I
```

혹은
`_config.yml`에서 `incremental: true`옵션을 만들어줍니다.

---

## 실행시 --limit_posts 1 플래그 붙이기

마지막으로 포스팅 작성할때 쓰면 좋은 옵션입니다. 단점도 있겠지만 빌드 속도를 올리기 위해 다른 파일은 감시하지 않고 (보통 현재) 작성 중인 포스팅만 리-빌드할 수 있게 해줍니다.

```sh
bundle exec jekyll serve --limit_posts <작동시킬 포스팅 수>
```

만약 포스팅 1개만 watch할 수 있게 하려면

```sh
bundle exec jekyll serve --limit_posts 1
```

이라고 하면 됩니다.

---

## 정리

서버를 껐다가 다음과 같은 명령어로 속도를 측정할 수 있습니다. 기존 빌드 속도아 플래그를 사용한 속도 개선방법을 제외한 방법들을 모두 사용한 빌드 속도를 비교해봤습니다. 우선 기존 빌드 속도입니다.

```
Filename                            | Count |   Bytes |  Time
------------------------------------+-------+---------+------
_layouts/default.html               |    49 | 939.45K | 0.862
_includes/footer.html               |    49 | 206.63K | 0.257
_includes/head.html                 |    49 | 132.75K | 0.254
_layouts/post.html                  |    30 | 419.22K | 0.230
_includes/header.html               |    49 |  97.71K | 0.225
sitemap.xml                         |     1 |   5.40K | 0.054
search.json                         |     1 |  45.01K | 0.020
feed.xml                            |     1 | 115.23K | 0.019
_layouts/archive.html               |     9 |   9.19K | 0.016
posts.html                          |     1 |   7.14K | 0.015
page6/index.html                    |     1 |   5.03K | 0.008
page3/index.html                    |     1 |   6.17K | 0.007
page5/index.html                    |     1 |   6.00K | 0.007
page4/index.html                    |     1 |   5.91K | 0.006
page2/index.html                    |     1 |   6.12K | 0.006
index.html                          |     1 |   5.65K | 0.005
_layouts/page.html                  |     3 |   9.33K | 0.002
_includes/page_divider.html         |    12 |   1.08K | 0.001
_includes/tawk_to.html              |     1 |   0.40K | 0.001
_includes/google_analytics.html     |     1 |   0.26K | 0.000
robots.txt                          |     1 |   0.04K | 0.000
search.html                         |     1 |   0.78K | 0.000

                    done in 4.114 seconds.
```

빌드 속도 개선을 한 후의 속도입니다.

```
Filename                            | Count |   Bytes |  Time
------------------------------------+-------+---------+------
_layouts/post.html                  |    30 | 419.22K | 0.161
sitemap.xml                         |     1 |   5.26K | 0.055
_layouts/default.html               |    49 | 937.90K | 0.045
feed.xml                            |     1 | 115.17K | 0.017
_layouts/archive.html               |     9 |  10.92K | 0.010
posts.html                          |     1 |   7.14K | 0.010
search.json                         |     1 |  45.01K | 0.009
page3/index.html                    |     1 |   6.17K | 0.008
page5/index.html                    |     1 |   6.00K | 0.007
page6/index.html                    |     1 |   5.03K | 0.006
page4/index.html                    |     1 |   5.91K | 0.006
page2/index.html                    |     1 |   6.12K | 0.005
index.html                          |     1 |   5.65K | 0.005
_includes/header.html               |     1 |   1.99K | 0.005
_includes/footer.html               |     1 |   4.23K | 0.005
_includes/head.html                 |     1 |   2.63K | 0.003
_layouts/page.html                  |     3 |   9.33K | 0.001
robots.txt                          |     1 |   0.04K | 0.001
_includes/tawk_to.html              |     1 |   0.40K | 0.001
_includes/google_analytics.html     |     1 |   0.26K | 0.000
search.html                         |     1 |   0.78K | 0.000
_includes/page_divider.html         |     1 |   0.09K | 0.000

                    done in 2.52 seconds.
```

**2.52 / 4.114** 로 계산기를 두드려보니 **61.25%** 가 빨라졌다고 하네요. 이게 다시 빌드할 때마다 속도 편차가 상당히 크더군요. 그래서 개선 전에는 가장 늦은 빌드타임으로, 개선 후에는 가장 빠른 빌드타임으로 계산해봤습니다. 아마 포스팅 수도 많고 페이지 사이즈도 크다면 더 확실하게 알 수 있었을 것입니다.

뭐니뭐니해도 가장 드라마틱했던 것들은 플래그를 붙이는 옵션들이었습니다. 아래와 같이 3가지 옵션을 만들어 빌드 속도를 측정해본 결과 `--limit_posts`옵션이 `--incremental`옵션의 상위 호환판인 것으로 보입니다.

```
bundle exec serve --incremental

(...)

Regenerating: 1 file(s) changed at 2019-05-21 23:42:19
                  _posts/2019-05-21-jekyll-caching.md
                  ...done in 1.209487 seconds.
```

```
bundle exec serve --limit_posts 1

(...)

Regenerating: 1 file(s) changed at 2019-05-21 23:45:15
                  _posts/2019-05-21-jekyll-caching.md
                  ...done in 0.949982 seconds.
```

```
bundle exec serve --incremental --limit_posts 1

(...)

Regenerating: 1 file(s) changed at 2019-05-21 23:42:03
                  _posts/2019-05-21-jekyll-caching.md
                  ...done in 0.9535 seconds.
```

아까 나왔던 2.52초보다는 **0.94 / 2.52** 를 해보니 **37.65%** 가 빨라졌습니다. 결론은 빌드될 파일을 최대한 줄여야한다가 되겠습니다.

---

## 참조

- [How to escape liquid template tags?](https://stackoverflow.com/questions/3426182/how-to-escape-liquid-template-tags)
- [Improving Jekyll build time](https://carlosbecker.com/posts/jekyll-build-time/)
- [How I reduced my Jekyll build time by 61%](https://forestry.io/blog/how-i-reduced-my-jekyll-build-time-by-61/)
- [Improving Jekyll Build Time](http://www.cagrimmett.com/til/2018/04/02/improving-jekyll-build-time.html)
- [Optimizing Jekyll build time](https://boris.schapira.dev/2018/11/jekyll-build-optimization/)
