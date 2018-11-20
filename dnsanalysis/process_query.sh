#!/bin/bash
#Checks for new domains and OpenDNS blocks. Writes to output if seen.

#logfile=$1
logfile=/var/log/dnsmasq.log

cd /var/lib/dnsanalysis

yestfile=$(mktemp yest.XXXXXX)
yest=$(date -d yesterday +"%b %e")
#yest='Oct 30'
# Find yesterday's query lines out of the dnsmasq file and
# ignore arpa, labellum and spotilocal domains and
# cut just the queried domain name and
# cut out queries without domains
# uniquify it

sudo grep "^$yest.*: query\[" $logfile |grep -Ev in.addr.arpa\|ip6.arpa\|labellum.org\|spotilocal >$yestfile
outfile=$(mktemp proc.XXXXXX)
    cut -f3 -d] $yestfile|cut -f 2 -d ' ' |grep '\.'|sort |uniq >$outfile

longdom=$(mktemp  long.XXXXXX)
shortdom=$(mktemp short.XXXXXX)
grep -viE '(info|tech|xyz|it|ru|to|fr|gg|biz|gov|net|com|int|org|edu|pro|eu|be|io|im|int|at|tv|me)$' $outfile  |sed -e 's/.*\.\(.*\..*\..*\)$/\1/' |sort -u >$longdom
grep  -iE '(info|tech|xyz|it|ru|to|fr|gg|biz|gov|net|com|int|org|edu|pro|eu|be|io|im|int|at|tv|me)$' $outfile  |sed -e 's/.*\.\(.*\..*\)$/\1/' |sort -u >$shortdom

resfile=$(mktemp resfile.XXXXXX)
comm -13 seen.short $shortdom >$resfile 
comm -13 seen.long  $longdom >>$resfile

ipnew=$(mktemp ipnew.XXXXXX)
#find first local IP that queried new domain
for new in `cat $resfile`; do
    ip=$(grep "$new from " $yestfile|head -1|cut -f3 -d']'| cut -f 4 -d ' ')
    echo "$ip $new" >>$ipnew
done

sort $ipnew >$resfile

if [ -s $resfile ]; then
   echo "New Domains queried:"
   cat $resfile
fi

#cleanup and add seen domains to lists
cat $shortdom seen.short |sort -u >seen.new
mv seen.new seen.short
rm $shortdom

cat $longdom seen.long |sort -u >seen.new
mv seen.new seen.long
rm $longdom

#Check for OpenDNS blocks

grep id.opendns.com $outfile | sed -e 's/\.x\..*from //' >$resfile
if [ -s $resfile ]; then
   echo "OpenDNS Blocks seen:"
   cat $resfile
fi

rm $yestfile $outfile $resfile $ipnew

# Commands that created seen files which were then edited to remove
# unwanted domains
#ukndom=$(mktemp ukn.XXXXXX)
#kndom=$(mktemp  kn.XXXXXX)

#grep -viE '(info|tech|xyz|it|ru|to|fr|gg|biz|gov|net|com|int|org|edu|pro|eu|be|io|im|int|at|tv|me)$' $outfile  |sed -e 's/.*\.\(.*\..*\..*\)$/\1/' |sort|uniq >$ukndom
#grep  -iE '(wal\.co|info|tech|xyz|it|ru|to|fr|gg|biz|gov|net|com|int|org|edu|pro|eu|be|io|im|int|at|tv|me)$' $outfile  |sed -e 's/.*\.\(.*\..*\)$/\1/' |sort|uniq >$kndom



