#!/bin/bash
outfile=$(mktemp -t proc.XXXXXX)
#yest=$(date -d yesterday +"%b %e")
yest='Oct 16'
# Find yesterday's query lines out of the dnsmasq file and
# ignore arpa, labellum and spotilocal domains and
# cut just the queried domain name and
# cut out queries without domains
# uniquify it

sudo grep "^$yest.*: query\[" $1 |grep -Ev in.addr.arpa\|ip6.arpa\|labellum.org\|spotilocal| \
    cut -f3 -d] |cut -f 2 -d ' ' |grep '\.'|sort |uniq >$outfile

longdom=$(mktemp  long.XXXXXX)
shortdom=$(mktemp short.XXXXXX)
grep -viE '(info|tech|xyz|it|ru|to|fr|gg|biz|gov|net|com|int|org|edu|pro|eu|be|io|im|int|at|tv|me)$' $outfile  |sed -e 's/.*\.\(.*\..*\..*\)$/\1/' |sort|uniq >$longdom
grep  -iE '(info|tech|xyz|it|ru|to|fr|gg|biz|gov|net|com|int|org|edu|pro|eu|be|io|im|int|at|tv|me)$' $outfile  |sed -e 's/.*\.\(.*\..*\)$/\1/' |sort|uniq >$shortdom

newshort=$(mktemp short.XXXXXX)
newlong=$(mktemp  long.XXXXXX)

comm -13 seen.short $shortdom >$newshort
comm -13 seen.long  $longdom  >$newlong

ipnew=$(mktemp ipnew.XXXXXX)
#find first local IP that queried new domain
for new in `cat newshort; cat newlong`; do
    ip=$(grep "$new from " $i|head -1|cut -f3 -d']'| cut -f 4 -d ' ')
    echo "$ip $new" >$ipnew
done

sort $ipnew

# Commands that created seen files which were then edited to remove
# unwanted domains
#ukndom=$(mktemp ukn.XXXXXX)
#kndom=$(mktemp  kn.XXXXXX)

#grep -viE '(info|tech|xyz|it|ru|to|fr|gg|biz|gov|net|com|int|org|edu|pro|eu|be|io|im|int|at|tv|me)$' $outfile  |sed -e 's/.*\.\(.*\..*\..*\)$/\1/' |sort|uniq >$ukndom
#grep  -iE '(wal\.co|info|tech|xyz|it|ru|to|fr|gg|biz|gov|net|com|int|org|edu|pro|eu|be|io|im|int|at|tv|me)$' $outfile  |sed -e 's/.*\.\(.*\..*\)$/\1/' |sort|uniq >$kndom



