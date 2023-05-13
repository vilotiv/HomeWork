#!/bin/bash

IFS=$' '
PIDF=/vagrantVM/bash/weblog.pid
LOGD=/vagrantVM/bash/log
FROMv="vilotiv@localhost"
XCOUNT=10
YCOUNT=10

# настройка даты и периода формирования отчета
dataNOW="`date +"%d/%b/%Y %H:%M:%S"`"
DataStart="`sed -n '1'p $LOGD/access*.log | cut -d ' ' -f 4 | cut -d '[' -f 2`"
DataEnd="`sed -n '$'p $LOGD/access*.log | cut -d ' ' -f 4 | cut -d '[' -f 2`"



# функция отправки письма
send_email()
{
        (
cat - <<END
Subject: Отчет веб-сервера
From: no-reply@localhost
To: $FROMv
Content-Type: text/plain
From the last hour there is some stats from web server
Отчет за преиод времени с $DataStart по $DataEnd.
Следующие IP-адреса были зафикированы:
count ip-address
${IP_L[@]}
наиболее популярные страницы посещаемые:
count url
${IP_Adr[@]}
http codes зафикисированы:
count code
${HTTP_STAT[@]}
Зафиксированные ошибки:
${ERRORS[@]}
END
) | /usr/sbin/sendmail $1
}

# Начало скрипта

if [ -e $PIDF ]
then
    echo "$dataNOW --> Скрипт уже запущен!"
    exit 1
else
        echo "$$" > $PIDF
        trap 'rm -f $PIDF; exit $?' INT TERM EXIT
        echo "Отчет за преиод времени с $DataStart по $DataEnd."
        IP_L+=(`cat $LOGD/access*.log  | awk '{print $1}' | sort | uniq -c | sort -nr | head -$XCOUNT`)
        IP_Adr+=(`cat $LOGD/access*.log  | awk '{print $7}' | sort | uniq -c | sort -nr | head -$YCOUNT`)
        HTTP_STAT+=(`cat $LOGD/access*.log  | awk '{print $9}' | sort | uniq -c | sort -nr`)
        ERRORS+=(`cat $LOGD/error.log`)
        send_email $FROMv
        rm -r $PIDF
        trap - INT TERM EXIT
        echo "Следующие IP-адреса были зафикированы:"
        echo ${IP_L[@]}
        echo "=========================================="
        echo "Наиболее популярные страницы посещаемые:"
        echo ${IP_Adr[@]}
        echo "=========================================="
        echo "http codes зафикисированы:"
        echo ${HTTP_STAT[@]}
        echo "=========================================="
        echo "Зафиксированные ошибки:"
        echo ${ERRORS[@]}
fi