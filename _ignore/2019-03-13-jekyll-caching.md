---
layout: post
title: Jekyll 빌드속도 빠르게 하기
author: Yangeok
categories: Blog
comments: true
cover: https://res.cloudinary.com/yangeok/image/upload/v1552474849/logo/posts/jekyll.jpg
---

마크다운으로 글을 작성하면서 VSC플러그인으로 미리보기를 할 수도 있지만 Jekyll서버를 켜놓고 브라우저에서 글을 미리보기하는게 훨씬 편하더라구요.

footer에서

```html
{{ "{% for page in site.pages " }}%}
{{ "{% if page.title and page.main_nav != false " }}%}
<li class="nav-link"><a href="{{ "{{ page.url | prepend: site.baseurl " }}}}">{{ "{{ page.title " }}}}</a>
{{ "{% endif " }}%}
{{ "{% endfor " }}%}
```

```html
<li><a href="/about/">About</a></li>
<li><a href="/posts/">Posts</a></li>
<li><a href="/works">Works</a></li>
```

```sh
$ bundle exec jekyll build --profile
Configuration file: C:/dev/yangeok.github.io/_config.yml
            Source: C:/dev/yangeok.github.io
       Destination: C:/dev/yangeok.github.io/_site
 Incremental build: disabled. Enable with --incremental
      Generating...

Filename                    | Count |   Bytes |  Time
----------------------------+-------+---------+------
_layouts/default.html       |    49 | 939.45K | 0.862
_includes/footer.html       |    49 | 206.63K | 0.257
_includes/head.html         |    49 | 132.75K | 0.254
_layouts/post.html          |    30 | 419.22K | 0.230
_includes/header.html       |    49 |  97.71K | 0.225
sitemap.xml                 |     1 |   5.40K | 0.054
search.json                 |     1 |  45.01K | 0.020
feed.xml                    |     1 | 115.23K | 0.019
_layouts/archive.html       |     9 |   9.19K | 0.016
posts.html                  |     1 |   7.14K | 0.015
page6/index.html            |     1 |   5.03K | 0.008
page3/index.html            |     1 |   6.17K | 0.007
page5/index.html            |     1 |   6.00K | 0.007
page4/index.html            |     1 |   5.91K | 0.006
page2/index.html            |     1 |   6.12K | 0.006
index.html                  |     1 |   5.65K | 0.005
_layouts/page.html          |     3 |   9.33K | 0.002
_includes/page_divider.html |    12 |   1.08K | 0.001
robots.txt                  |     1 |   0.04K | 0.000
search.html                 |     1 |   0.78K | 0.000


                    done in 4.114 seconds.
```

로는 부족해서 플러그인을 깔았다.

`gem 'jekyll-include-cache'`

```
{{ "{% include head.html " }}%}
{{ "{% include_cached head.html " }}%}
```

```sh
$ bundle exec jekyll serve --profile
Configuration file: C:/dev/yangeok.github.io/_config.yml
            Source: C:/dev/yangeok.github.io
       Destination: C:/dev/yangeok.github.io/_site
 Incremental build: disabled. Enable with --incremental
      Generating...

Filename                    | Count |   Bytes |  Time
----------------------------+-------+---------+------
_layouts/post.html          |    30 | 419.22K | 0.161
sitemap.xml                 |     1 |   5.26K | 0.055
_layouts/default.html       |    49 | 937.90K | 0.045
feed.xml                    |     1 | 115.17K | 0.017
_layouts/archive.html       |     9 |  10.92K | 0.010
posts.html                  |     1 |   7.14K | 0.010
search.json                 |     1 |  45.01K | 0.009
page3/index.html            |     1 |   6.17K | 0.008
page5/index.html            |     1 |   6.00K | 0.007
page6/index.html            |     1 |   5.03K | 0.006
page4/index.html            |     1 |   5.91K | 0.006
page2/index.html            |     1 |   6.12K | 0.005
index.html                  |     1 |   5.65K | 0.005
_includes/header.html       |     1 |   1.99K | 0.005
_includes/footer.html       |     1 |   4.23K | 0.005
_includes/head.html         |     1 |   2.63K | 0.003
_layouts/page.html          |     3 |   9.33K | 0.001
robots.txt                  |     1 |   0.04K | 0.001
search.html                 |     1 |   0.78K | 0.000
_includes/page_divider.html |     1 |   0.09K | 0.000


                    done in 2.52 seconds.
```

## 참조

- [How to escape liquid template tags?
  ](https://stackoverflow.com/questions/3426182/how-to-escape-liquid-template-tags)
