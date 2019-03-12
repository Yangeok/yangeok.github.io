start_limit="bundle exec jekyll serve --limit_posts 1"
start="bundle exec jekyll serve"

# 인자가 0이면 start를 실행하고 아니면 start_limit을 실행한다.

if [ -z "$1" ]; then
    echo $start
    $start
else
    echo $start_limit
    $start_limit
fi