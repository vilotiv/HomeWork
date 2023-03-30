#!/bin/bash
echo "PID     TTY     STAT     TIME     COMMAND" # заголовок
for I in `ls -l /proc | awk '{ print $9 }' | grep -Eo '[0-9]{1,5}'| sort -n | uniq` #найдем все ПИД процессы
do
if [ -d /proc/$I/ ]; then  # допусловие проверки существования процесса
  PIDV=`cat /proc/$I/stat | awk '{ print $1 }'` #вычисляем ПИД процесса
  TTYC=`sudo ls -l /proc/$I/fd | head -n2 | tail -n1 | sed 's%.*/dev/%%'` #вычисляем ТТУ процесса
    if [[ $TTYC == "итого 0" ]] || [[ $TTYC == "null" ]] || [[ $TTYC == *"socket"* ]]; then
      TTYN="?"
    else
      TTYN=$TTYC
    fi

  STATV=`cat /proc/$I/stat | awk '{ print $3 }'`
  UTIMEV=`cat /proc/$I/stat | awk '{ print $14 }'`
  STIMEV=`cat /proc/$I/stat | awk '{ print $15 }'`
  CLKTCK=`getconf CLK_TCK`
  FULLTIME=$((UTIMEV+STIMEV))
  CPUTIME=$((FULLTIME/CLKTCK))
  TIMEV=`date -u -d @${CPUTIME} +"%T"`

  COMMANDV=`cat /proc/$I/cmdline | strings -n 1 | tr '\n' ' '`
  if [[ -z $COMMANDV ]]; then COMMANDV=`cat /proc/$I/stat | awk '{ print $2 }'`; fi

  echo "$PIDV     $TTYN     $STATV     $TIMEV     $COMMANDV"
fi
done
