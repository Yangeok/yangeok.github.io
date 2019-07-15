# docker rm `docker ps -a -q`

docker run --rm --name blog -v "C:/dev/record/blog:/srv/jekyll" -p 4000:4000 -it jekyll/jekyll jekyll serve --force_polling --livereload 

# 아래 옵션은 노노~
# --watch --drafts