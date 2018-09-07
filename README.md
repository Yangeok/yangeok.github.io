Github page + Jekyll
====

# Scripts
* (bundle exec) jekyll serve (execution) 

# Layout
```jekyll
---
layout: post
title:  "TEST"
author: Yangeok
categories: React
---
```

# Cover Images
```cover: "___dirname/__filename"```

OR

```html
<a href="__dirname/__filename" data-lightbox="description" data-title="description">
  <img src="__dirname/__filename" >
</a>
```

# Highlighting
```html
<code> 

  (...)

</code>
```

OR

```html
{% hightlight language %}

(...)

{% endhighlight %}
```