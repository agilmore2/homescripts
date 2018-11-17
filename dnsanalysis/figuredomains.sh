grep -vE '(info|tech|xyz|it|ru|to|biz|gov|net|com|int|org|edu|pro|eu|be|io|im|int|at|tv|me)$' processed  |sed -e 's/.*\.\(.*\..*\)/\1/' |sort|uniq -c |cut -f2 -d'.' |sort |uniq -c |sort -rn |less
