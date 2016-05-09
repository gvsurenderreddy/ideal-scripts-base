#!/bin/bash

echo $#
if [[ $# -ne  1 ]]
then
  echo "USAGE: $0 [seconds]"
  exit 1
fi

time=$1
UPPER=1500
LOWER=1000
EXLOWER=100

CMD="sar -n DEV 1 $time"

CURDIR=`dirname $(readlink -f $0)`
LOGFILE=$CURDIR/sar.log

if [ -f $LOGFILE ]
then
  rm $LOGFILE
fi

echo "begin collecting..., pls wait $time seconds"
$CMD >> $LOGFILE
echo "collecting finished, begain analizing... "

cat $LOGFILE|egrep "\ eth0"|sed '$d'| \
awk  'BEGIN{x=0;y=0;z=0;t=0}{a[$6]++}END{for(i in a){
  if(i+0<100+0){x=x+a[i]}
  else if(i+0>1000+0 && i+0<=2000+0){y=y+a[i]}
  else if(i+0>2000+0 && i+0 <=3000){z=z+a[i]}
  else if(i+0>3000+0){t=t+a[i]}};
  print "txkB<100 counts:"x,"\ntxkB between 1000 and 2000 counts: "y,"\ntxkB between 2000 and 3000 counts: "z,"\ntxkB above 3000 counts: "t}'
