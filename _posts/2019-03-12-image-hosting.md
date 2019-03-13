---
layout: post
title: Jekyll 블로그 이미지 호스팅하기
author: Yangeok
categories: Blog
comments: true
cover: http://drive.google.com/uc?export=view&id=1MFCb4w0Ws1VCZahiCPLAYMbQHO01omYu
---

블로그에 코드만 올리다 점점 스크린샷을 찍어 올려야 할 일이 점점 많아집니다. 처음에는 [티스토리 블로그](https://yangwookee.tistory.com/)에 호스팅을 해서 이미지를 가져와서 사용했습니다. 물론 현재도 사용하고 있는 블로그에 비공개로 해서 올려놓기 때문에 3자가 본다면 아무것도 안보이겠죠. 제 눈에는 너무 지저분해보이고 티스토리가 날아간다면 이 블로그에 있는 이미지들도 다 날아가겠죠. 그래서 생각해냈던 방법이 다음과 같습니다.

1. [드롭박스](#드롭박스)
2. [AWS S3](#aws-s3)
3. [소스파일](#소스파일)
4. [구글 드라이브](#구글-드라이브)

## 드롭박스

드롭박스 메인페이지에서 이미지 호스팅용 저장소로 쓸 폴더를 하나 새로 만듭니다.

![](https://res.cloudinary.com/yangeok/image/upload/v1552475432/image-hosting/hosting_1.jpg)

드래그앤 드롭으로 이미지를 올린 후에 **팀원 - 본인만** 에 마우스를 올리면 그 우측에 **공유** 버튼이 떠오르면 클릭합니다.

![](https://res.cloudinary.com/yangeok/image/upload/v1552475432/image-hosting/hosting_2.jpg)

공유설정 창에 들어가면 하단에 있는 **링크만들기** 를 누릅니다.

![](https://res.cloudinary.com/yangeok/image/upload/v1552475432/image-hosting/hosting_3.jpg)

링크가 만들어졌다는 메시지가 뜹니다.

![](https://res.cloudinary.com/yangeok/image/upload/v1552475433/image-hosting/hosting_4.jpg)

다시 공유설정 창에 들어가 **링크 복사** 를 하고 메모장에 붙여넣기합니다.

`https://www.dropbox.com/이미지주소?dl=0`

위 주소를 타고 들어가면 이미지 공유 페이지가 뜹니다.

![](https://res.cloudinary.com/yangeok/image/upload/v1552475433/image-hosting/hosting_5.jpg)

바로 파일이 다운로드 되게 설정을 바꿉니다. `dl=0`를 `dl=1`로 변경합니다. 이미지 파일이 바로 다운로드 되는 것을 이용해 `<img src="링크주소">`를 입력하면 이미지를 사용할 수 있습니다.

주소 뒤에 정수 하나만 바꿔주면 됐기에 무지 편하다고 생각하고 포스트에 들어있는 이미지들을 싹 다 드롭박스도 교체했습니다. 웹환경에서는 이미지가 로딩이 잘되는데 모바일환경(iOS용 사파리)에서는 싹 다 깨져버리더군요. 그래서 다음 방법으로 넘어갑니다.

## AWS S3

**버킷만들기** 를 눌러 새로운 저장소를 만듭니다.

![](https://res.cloudinary.com/yangeok/image/upload/v1552475432/image-hosting/hosting_6.jpg)

버킷 이름을 [DNS형식](https://docs.aws.amazon.com/ko_kr/AmazonS3/latest/dev/BucketRestrictions.html)으로 지정하고 리전을 거주지나 방문자들이 가장 많이 접속할 곳으로 골라줍니다. 저는 아시아 태평양(서울)을 선택했습니다.

![](https://res.cloudinary.com/yangeok/image/upload/v1552475432/image-hosting/hosting_7.jpg)

2단계는 아무것도 체크하지 않고 넘어가고 외부접근 설정을 합니다. 4개의 체크박스를 전부 체크해제합니다. 오로지 이미지만을 쓰기 위해서 체크를 권장하는 박스의 체크를 해제한겁니다. 다른 중요한 파일이 있는 버킷설정을 아래와 같이 하시면 안됩니다.

![](https://res.cloudinary.com/yangeok/image/upload/v1552475432/image-hosting/hosting_8.jpg)

버킷에 드래그앤 드롭으로 이미지를 올린 후에 사용하고자 하는 이미지 파일명을 클릭합니다.

![](https://res.cloudinary.com/yangeok/image/upload/v1552475432/image-hosting/hosting_9.jpg)

가장 아래 **객체 URL** 에 있는 주소가 우리가 `<img src="링크주소">`태그에 넣어 사용할 수 있는 주소입니다.

![](https://res.cloudinary.com/yangeok/image/upload/v1552475432/image-hosting/hosting_10.jpg)

이미지서버로 예전부터 쓸 생각을 했습니다. 1년간 무료로 쓸 수 있지만 1년이 지나면 돈이 나가서 망설였던 방법입니다. 자세히는 모르지만 S3가 이미지를 일정량 이상 GET요청을 하면 과금이 되는 구조더군요. 그렇지 않을지 몰라도 누군가 악의적으로 이미지를 무한로딩한다면 요금폭탄을 맞을 가능성도 있겠구나 싶어 사용하다 포기했습니다.

## 소스파일

이 블로그는 Jekyll로 작성했고 [Centrarium](http://bencentra.com/centrarium/)테마를 사용하고 있습니다. 디렉토리 구조는 다음과 같습니다. `_posts` 디렉토리에 포스팅을 작성하고 `assets`에 있는 이미지파일을 이용해 페이지를 생성합니다. `_site` 디렉토리에 페이지가 생성되고 그걸 배포하는 구조입니다.

```
├─.sass-cache
├─assets
├─css
├─js
├─_includes
├─_layouts
├─_posts
├─_sass
└─_site
```

`/assets` 디렉토리에 있는 이미지파일을 `/_posts/yyyy-mm-dd-post.md`에서 가져다 쓸때 아래와 같이 포스팅 서두에 `cover`에는 `assets` 디렉토리에서 이미지를 읽어올 수 있습니다.

```yml
---
layout: post
title: 블로그 이미지 호스팅하기
author: Yangeok
categories: Blog
comments: true
cover: assets/cover-image.png
---

```

하지만 본문 내용에서 `![](../assets/cover-image.jpg)`와 같이하면 마크다운 파일 작성시에는 읽을 수 있지만 HTML로 생성된 파일에서는 읽을 수가 없습니다.

맞아요. 소스파일에 이미지를 포함시켜 저장소에 올리면 편합니다. Jekyll이 HTML로 빌드할때 마크다운에서 작성하는 이미지 주소와 실제 빌드파일에서 사용하는 이미지 주소가 일치하지 않아 빌드 중에 오류를 뿜어대더라구요.

```
[2019-03-12 19:07:49] ERROR `/blog/assets/cover-image.png' not found.
```

이미지 주소 문제만 없었다면 가장 편한 방법이 됐을텐데 아쉽게 됐습니다.

## 구글 드라이브

이미지 호스팅을 포기하지 못한 저는 결국 구글 드라이브까지 들어가게 됐습니다. 공식적으로 다운로드용 이미지 링크가 없어 어떤 분이 올려주신 에디터를 가져다 사용해서 이미지 호스팅에 결국 성공했습니다. 약간의 가공을 통해 마크다운 이미지 문법에 맞게 url을 가공하도록 했습니다. [링크](https://google-drive-path-modifier.herokuapp.com/)를 타고 들어가시면 사용할 수 있습니다.

```html
<html>

<head>
  <!-- Latest compiled and minified CSS -->
  <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css" integrity="sha384-BVYiiSIFeK1dGmJRAkycuHAHRg32OmUcww7on3RYdg4Va+PmSTsz/K68vbdEjh4u"
    crossorigin="anonymous" />
  <style>
    #converter {
      padding: 20px 20px;
      border-radius: 5px;
      background-color: #f8f8f8;
      width: 100%;
      padding: 15px 15px;
    }

    #converter textarea {
      display: block;
      white-space: wrap;
      border: 1px solid #888;
      border-radius: 5px;
      margin-bottom: 10px;
      padding: 5px 5px;
      width: 100%;
      height: 60px;
    }

    #converter label {
      font-weight: bold;
      color: #333;
    }

    #converter button {
      font-weight: bold;
    }

    #btn-convert {
      width: 100%;
    }

    #convert-result {
      margin-top: 20px;
    }
  </style>
</head>

<body>
  <div id="converter">
    <label>Google Drive path</label>
    <textarea id="gd-url" placeholder="Input Google Drive Url"></textarea>
    <button id="btn-convert" class="btn btn-primary">
      Make Google Drive Path Linkable
    </button>
    <div id="convert-result">
      <label for="result">Linkable Image path</label>
      <textarea id="result" name="result" readonly></textarea>
      <button id="btn-save-result-cb" class="btn btn-success pull-right" data-clipboard-target="#result">
        <span class="glyphicon glyphicon-copy" aria-hidden="true"></span>
        Save to Clipboard
      </button>
      <br /><br />

      <label for="result-img-tag">Markdown Image Tag</label>
      <textarea id="result-img-tag" name="result" readonly></textarea>
      <button id="btn-save-result-img-tag-cb" class="btn btn-success pull-right" data-clipboard-target="#result-img-tag">
        <span class="glyphicon glyphicon-copy" aria-hidden="true"></span>
        Save to Clipboard
      </button>
    </div>
    <br /><br />

    <label for="result-html-tag">HTML Image Tag</label>
    <textarea id="result-html-tag" name="result" readonly></textarea>
    <button id="btn-save-result-html-tag-cb" class="btn btn-success pull-right" data-clipboard-target="#result-html-tag">
      <span class="glyphicon glyphicon-copy" aria-hidden="true"></span>
      Save to Clipboard
    </button>
  </div>
  <br /><br /><br />
  <p align="center">
    <b>Preview image</b>
  </p>
  <p align="center">
    <img id="preview" alt="image preview" src="https://www.google.com/drive/static/images/drive/logo-drive.png" class="img-thumbnail"
      style="max-width: 200px" /><br />
  </p>
  </div>

  <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.2.1/jquery.min.js"></script>
  <script src="https://cdnjs.cloudflare.com/ajax/libs/clipboard.js/1.7.1/clipboard.min.js"></script>
  <script>
    var gdUrl = $('#gd-url');
    $('#btn-convert').on('click', function (event) {
      if (!isValidUrl(gdUrl.val())) {
        alert('You have input invalid path.');
        gdUrl.val('');
        return;
      }

      var gdId = getParameterByName('id', gdUrl.val());
      var prefix = 'http://drive.google.com/uc?export=view&id=';
      $('#result').val(prefix + gdId);
      $('#result-img-tag').val(`![](${prefix}${gdId})`);
      $('#result-html-tag').val(`<img src="${prefix}${gdId}"/><br>`)
      $('#preview').attr('src', prefix + gdId);
    });

    var clipboard = new Clipboard('.btn');

    clipboard.on('success', function (e) {
      console.info('Action:', e.action);
      console.info('Text:', e.text);
      console.info('Trigger:', e.trigger);

      e.clearSelection();
    });

    clipboard.on('error', function (e) {
      console.error('Action:', e.action);
      console.error('Trigger:', e.trigger);
    });

    // validity check. ref: https://gist.github.com/jlong/2428561
    function isValidUrl(url) {
      // to be impl...
      var parser = document.createElement('a');
      parser.href = url;

      if (
        url === '' ||
        parser.hostname !== 'drive.google.com' ||
        !parser.search.includes('?id=')
      )
        return false;

      return true;
    }

    function getParameterByName(name, url) {
      if (!url) url = window.location.href;
      name = name.replace(/[\[\]]/g, '\\$&');
      var regex = new RegExp('[?&]' + name + '(=([^&#]*)|&|#|$)'),
        results = regex.exec(url);
      if (!results) return null;
      if (!results[2]) return '';
      return decodeURIComponent(results[2].replace(/\+/g, ' '));
    }
  </script>
</body>

</html>
```

더 좋은 방법이 있다면 알려주세요.

## 참조

- [드롭박스 깨알팁 - 자동 다운로드,이미지 외부링크](https://www.clien.net/service/board/lecture/9145738)
- [구글 드라이브를 외부 이미지 링크 저장소로 사용하기](http://www.somanet.xyz/2017/06/blog-post_21.html)
