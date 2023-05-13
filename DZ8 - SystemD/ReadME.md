### 1.Написать service, который будет раз в 30 секунд мониторить лог на предмет наличия ключевого слова (файл лога и ключевое слово должны задаваться в /etc/sysconfig).
### 2.Из репозитория epel установить spawn-fcgi и переписать init-скрипт на unit-файл (имя service должно называться так же: spawn-fcgi).
### 3.Дополнить unit-файл httpd (он же apache) возможностью запустить несколько инстансов сервера с разными конфигурационными файлами.


## Задание 1
Создадим файл настроек /etc/sysconfig/monitoring...
```
touch /etc/sysconfig/monitoring
echo -e "LOGFILE=/var/log/messages\nKEYWORD=systemd" >> /etc/sysconfig/monitoring
```
Создадим скрипт поиска ключегово слова в логах:
```
touch /opt/watchlog.sh
chmod 774 /opt/watchlog.sh
cat <<'EOF1_0' >/opt/watchlog.sh
#!/bin/bash
KEYWORD=$1
LOGFILE=$2
DATE=`date`
if grep $KEYWORD $LOGFILE &> /dev/null
then
logger "$DATE: I found word, Master!"
else
exit 0
fi
EOF1_0
```

Создадим таймер
```
touch /etc/systemd/system/monitoring.timer
chmod 664 /etc/systemd/system/monitoring.timer
cat <<'EOF1_1' >/etc/systemd/system/monitoring.timer
          [Unit]
          Description=monitoring timer
          After=syslog.target

          [Timer]
          OnBootSec=0sec
          OnUnitActiveSec=30sec
          [Install]
          WantedBy=timers.target.target
EOF1_1
```

Создадим cервис
```
          touch /etc/systemd/system/monitoring.service
          chmod 664 /etc/systemd/system/monitoring.service
          cat <<'EOF1_2' >/etc/systemd/system/monitoring.service
          [Unit]
          Description=monitoring service
          After=syslog.target

          [Service]
          User=root
          Type=oneshot
          EnvironmentFile=/etc/sysconfig/monitoring
          ExecStart=/opt/watchlog.sh $KEYWORD $LOGFILE
          [Install]
          WantedBy=timers.target.target
EOF1_2
```

Запускаем таймер
```
          systemctl daemon-reload
          systemctl start monitoring.timer
```
  Проверим журнал
  ```
          tail /var/log/messages
    legasov: May 13 13:08:54 localhost systemd-logind: New session 4 of user vagrant.
    legasov: May 13 13:08:54 localhost systemd-logind: Removed session 4.
    legasov: May 13 13:08:57 localhost systemd: Reloading.
    legasov: May 13 13:08:57 localhost systemd: Started monitoring timer.
    legasov: May 13 13:08:57 localhost systemd: Starting monitoring service...
    legasov: May 13 13:08:57 localhost root: Sat May 13 13:08:57 UTC 2023: I found word, Master!
    legasov: May 13 13:08:57 localhost systemd: Started monitoring service.
    legasov: May 13 13:09:27 localhost systemd: Starting monitoring service...
    legasov: May 13 13:09:27 localhost root: Sat May 13 13:09:27 UTC 2023: I found word, Master!
    legasov: May 13 13:09:27 localhost systemd: Started monitoring service.
  ```
### Задание 1 выполнено
          

## Задание 2. Из репозитория epel установить spawn-fcgi и переписать init-скрипт на unit-файл"
Установим необходимый софт..."
```
          yum install -y -q epel-release > /dev/null 2>&1
          yum install -y -q spawn-fcgi php-cli httpd > /dev/null 2>&1
```
Добавим Настройки spawn-fcgi.
```
          echo "OPTIONS=-u apache -g apache -s /var/run/spawn-fcgi/php-fcgi.sock -S -M 0600 -C 32 -F 1 -P /var/run/spawn-fcgi/spawn-fcgi.pid -- /usr/bin/php-cgi" >> /etc/sysconfig/spawn-fcgi
```
Создаем unit-файл для spawn-fcgi..."
```
touch /etc/systemd/system/spawn-fcgi.service
chmod 664 /etc/systemd/system/spawn-fcgi.service
          cat <<'EOF2' >/etc/systemd/system/spawn-fcgi.service
          [Unit]
          Description=spawn-fcgi
          After=syslog.target

          [Service]
          Type=forking
          User=apache
          Group=apache
          EnvironmentFile=/etc/sysconfig/spawn-fcgi
          PIDFile=/var/run/spawn-fcgi/spawn-fcgi.pid
          RuntimeDirectory=spawn-fcgi
          ExecStart=/usr/bin/spawn-fcgi $OPTIONS
          ExecStop=

          [Install]
          WantedBy=multi-user.target
EOF2
```
          systemctl daemon-reload
          systemctl enable --now spawn-fcgi.service > /dev/null 2>&1
Проверим статус сервиса spawn-fcgi
```
          systemctl status spawn-fcgi.service
```
### Задание 2 выполнено
          
## Задание 3. Дополнить unit-файл httpd (он же apache) возможностью запустить несколько инстансов сервера с разными конфигурационными файлами"
Установим необходимый софт и настроим selinux
```
          yum install -y -q policycoreutils-python
          semanage port -m -t http_port_t -p tcp 8081
          semanage port -m -t http_port_t -p tcp 8082
```
Скопируем и изменим файл сервиса httpd.service в шаблон
```
cp /usr/lib/systemd/system/httpd.service /etc/systemd/system/httpd@.service
sed -i 's*EnvironmentFile=/etc/sysconfig/httpd*EnvironmentFile=/etc/sysconfig/%i*' /etc/systemd/system/httpd@.service
```

Скопируем и изменим файлы настройки сервиса httpd.service
```
          cp /etc/sysconfig/httpd /etc/sysconfig/conf1
          cp /etc/sysconfig/httpd /etc/sysconfig/conf2
          sed -i 's*#OPTIONS=*OPTIONS=-f /etc/httpd/conf/httpd1.conf*' /etc/sysconfig/conf1
          sed -i 's*#OPTIONS=*OPTIONS=-f /etc/httpd/conf/httpd2.conf*' /etc/sysconfig/conf2
```
Скопируем и изменим файлы настройки демона httpd, запустим сервисы
```
          cp /etc/httpd/conf/httpd.conf /etc/httpd/conf/httpd1.conf
          cp /etc/httpd/conf/httpd.conf /etc/httpd/conf/httpd2.conf
          sed -i 's/Listen 80/Listen 8081/' /etc/httpd/conf/httpd1.conf
          sed -i 's/Listen 80/Listen 8082/' /etc/httpd/conf/httpd2.conf
          echo "PidFile /var/run/httpd/httpd1.pid" >> /etc/httpd/conf/httpd1.conf
          echo "PidFile /var/run/httpd/httpd2.pid" >> /etc/httpd/conf/httpd2.conf

          systemctl daemon-reload
          systemctl enable --now httpd@conf1.service > /dev/null 2>&1
          systemctl enable --now httpd@conf2.service > /dev/null 2>&1
 ```
 Проверим статусы сервисов
 ```
          systemctl status httpd@conf1.service
          systemctl status httpd@conf2.service
 ```   
Проверим порты
```
          ss -tunlp | grep httpd
legasov: tcp    LISTEN     0      128    [::]:8081               [::]:*                   users:(("httpd",pid=3736,fd=4),("httpd",pid=3735,fd=4),("httpd",pid=3734,fd=4),("httpd",pid=3733,fd=4),("httpd",pid=3732,fd=4),("httpd",pid=3730,fd=4))
legasov: tcp    LISTEN     0      128    [::]:8082               [::]:*                   users:(("httpd",pid=3755,fd=4),("httpd",pid=3754,fd=4),("httpd",pid=3753,fd=4),("httpd",pid=3752,fd=4),("httpd",pid=3751,fd=4),("httpd",pid=3749,fd=4))

```
### Задание 3 выполнено
### Спасибо за проверку!
