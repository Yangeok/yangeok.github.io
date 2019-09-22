# Home
docker run --rm --name blog -v "C:/dev/record/blog:/srv/jekyll" -p 49160:4000 -it jekyll/jekyll jekyll serve --force_polling --livereload

# Company
# docker run --rm --name blog -v "C:/Users/Administrator/Desktop/Y/blog:/srv/jekyll" -p 4000:4000 -it jekyll/jekyll jekyll serve --force_polling --livereload