docker run --rm --name blog -v $(pwd -W):/srv/jekyll -p 49160:4000 -it jekyll/jekyll jekyll serve --force_polling --livereload

# docker run --rm --name blog -v C:/dev/record/blog:/srv/jekyll -p 49160:4000 -it jekyll/jekyll jekyll serve --force_polling --livereload