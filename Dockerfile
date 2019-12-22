FROM jekyll/jekyll

EXPOSE 4000 49160
WORKDIR /src/jekyll

CMD ["jekyll", "serve", "--force_polling", "--livereload"]