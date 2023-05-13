### Написать скрипт для CRON, который раз в час будет формировать письмо и отправлять на заданную почту.
#### Необходимая информация в письме:
#### Список IP адресов (с наибольшим кол-вом запросов) с указанием кол-ва запросов c момента последнего запуска скрипта;
#### Список запрашиваемых URL (с наибольшим кол-вом запросов) с указанием кол-ва запросов c момента последнего запуска скрипта;
#### Ошибки веб-сервера/приложения c момента последнего запуска;
#### Список всех кодов HTTP ответа с указанием их кол-ва с момента последнего запуска скрипта.
#### Скрипт должен предотвращать одновременный запуск нескольких копий, до его завершения.
#### В письме должен быть прописан обрабатываемый временной диапазон.

Полный листинг скрипта [тут](https://github.com/vilotiv/HomeWork/blob/main/DZ9%20-%20Bash/script.sh).

Получим ТОП-10 список всех IP адресов
```
cat log/access*.log  | awk '{print $1}' | sort | uniq -c | sort -nr | head -10
     45 93.158.167.130
     39 109.236.252.130
     37 212.57.117.19
     33 188.43.241.106
     31 87.250.233.68
     24 62.75.198.172
     22 148.251.223.21
     20 185.6.8.9
     17 217.118.66.161
     16 95.165.18.146
 ```
 
 Список ТОП-10 ссылок
 ```
 cat log/access*.log  | awk '{print $7}' | sort | uniq -c | sort -nr | head -10
    157 /
    120 /wp-login.php
     57 /xmlrpc.php
     26 /robots.txt
     12 /favicon.ico
     11 400
      9 /wp-includes/js/wp-embed.min.js?ver=5.0.4
      7 /wp-admin/admin-post.php?page=301bulkoptions
      7 /1
      6 /wp-content/uploads/2016/10/robo5.jpg
 ```
Список ТОП-10  всех кодов HTTP ответа с указанием их кол-ва
```
cat log/access*.log  | awk '{print $9}' | sort | uniq -c | sort -nr | head -10
    498 200
     95 301
     51 404
     11 "-"
      7 400
      3 500
      2 499
      1 405
      1 403
      1 304
```


Добавим скрипт в cron с условием запуска раз в час:
```
* */1 * * *  root /bin/sh /script.sh
```
```
И получаем ежечасный отчет
vilotiv@vilotiv-leg:/vagrantVM/bash$ mail
"/var/mail/vilotiv": 19 messages 19 new
>N   1 no-reply@localhost Сб мая 13 2  65/2781  Отчет веб-серве
 N   2 no-reply@localhost Сб мая 13 2  65/2781  Отчет веб-серве
 N   3 no-reply@localhost Сб мая 13 2  65/2781  Отчет веб-серве
 N   4 no-reply@localhost Сб мая 13 2  65/2781  Отчет веб-серве
 N   5 no-reply@localhost Сб мая 13 2  65/2781  Отчет веб-серве
 N   6 no-reply@localhost Сб мая 13 2  65/2781  Отчет веб-серве
 N   7 no-reply@localhost Сб мая 13 2  65/2781  Отчет веб-серве
 ```
``` 
 Return-Path: <vilotiv@vilotiv-leg>
X-Original-To: vilotiv@localhost
Delivered-To: vilotiv@localhost
Received: by vilotiv-leg (Postfix, from userid 1000)
	id 3D2F12E0067; Sat, 13 May 2023 21:42:50 +0500 (+05)
Subject: Отчет веб-сервера
From: no-reply@localhost
To: vilotiv@localhost
Content-Type: text/plain
Message-Id: <20230513164250.3D2F12E0067@vilotiv-leg>
Date: Sat, 13 May 2023 21:42:50 +0500 (+05)

From the last hour there is some stats from web server
Отчет за преиод времени с 14/Apr/2023:04:12:10 по 15/Apr/2023:00:25:46.
Следующие IP-адреса были зафикированы:
count ip-address
45 93.158.167.130
 39 109.236.252.130
 37 212.57.117.19
 33 188.43.241.106
 31 87.250.233.68
 24 62.75.198.172
 22 148.251.223.21
 20 185.6.8.9
 17 217.118.66.161
 16 95.165.18.146
наиболее популярные страницы посещаемые:
count url
157 /
 120 /wp-login.php
 57 /xmlrpc.php
 26 /robots.txt
 12 /favicon.ico
 11 400
 9 /wp-includes/js/wp-embed.min.js?ver=5.0.4
 7 /wp-admin/admin-post.php?page=301bulkoptions
 7 /1
 6 /wp-content/uploads/2016/10/robo5.jpg
http codes зафикисированы:
count code
498 200
 95 301
 51 404
 11 "-"
 7 400
 3 500
 2 499
 1 405
 1 403
 1 304
Зафиксированные ошибки:
2023/03/15 15:39:22 [error] 3882#3882: *5 open() "/usr/share/nginx/html/favicon.ico
" failed (2: No such file or directory), client: 192.168.56.1, server: default_serv
er, request: "GET /favicon.ico HTTP/1.1", host: "192.168.56.150:8080", referrer: "h
ttp://192.168.56.150:8080/"
2023/03/15 15:39:32 [error] 3882#3882: *5 open() "/usr/share/nginx/html/index.php" 
failed (2: No such file or directory), client: 192.168.56.1, server: default_server
, request: "GET /index.php HTTP/1.1", host: "192.168.56.150:8080"
```
Спасибо за проверку.



