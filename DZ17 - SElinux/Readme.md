SELinux - когда все запрещено 
### SELINUX

```
1. Запустить nginx на нестандартном порту 3-мя разными способами:
   * переключатели setsebool;
   * добавление нестандартного порта в имеющийся тип;
   * формирование и установка модуля SELinux.
К сдаче:
   * README с описанием каждого решения (скриншоты и демонстрация приветствуются).
2. Обеспечить работоспособность приложения при включенном selinux.
   * развернуть приложенный стенд https://github.com/mbfx/otus-linux-adm/tree/master/selinux_dns_problems;
   * выяснить причину неработоспособности механизма обновления зоны (см. README);
   * предложить решение (или решения) для данной проблемы;
   * выбрать одно из решений для реализации, предварительно обосновав выбор;
   * реализовать выбранное решение и продемонстрировать его работоспособность.
К сдаче:
   * README с анализом причины неработоспособности, возможными способами решения и обоснованием выбора одного из них;
   * исправленный стенд или демонстрация работоспособной системы скриншотами и описанием.
```

## Запуск nginx на нестандартном порту 3-мя разными способами

Итак, для демонстрации имеется готовый [Vagrantfile](Vagrantfile). 

<details>
<summary>
Запускаем ВМ: vagrant up.
</summary>
  
```
vilotiv@vilotiv-leg:~$ cd /vagrantVM/selinux/
vilotiv@vilotiv-leg:/vagrantVM/selinux$ ls
Vagrantfile
vilotiv@vilotiv-leg:/vagrantVM/selinux$ vagrant up
Bringing machine 'selinux' up with 'virtualbox' provider...
==> selinux: Importing base box 'centos/7'...
==> selinux: Matching MAC address for NAT networking...
==> selinux: Checking if box 'centos/7' version '2004.01' is up to date...
==> selinux: There was a problem while downloading the metadata for your box
==> selinux: to check for updates. This is not an error, since it is usually due
==> selinux: to temporary network problems. This is just a warning. The problem
==> selinux: encountered was:
==> selinux: 
==> selinux: The requested URL returned error: 404
==> selinux: 
==> selinux: If you want to check for box updates, verify your network connection
==> selinux: is valid and try again.
==> selinux: Setting the name of the VM: selinux_selinux_1678373272529_80438
==> selinux: Clearing any previously set network interfaces...
==> selinux: Preparing network interfaces based on configuration...
    selinux: Adapter 1: nat
==> selinux: Forwarding ports...
    selinux: 4881 (guest) => 4881 (host) (adapter 1)
    selinux: 22 (guest) => 2222 (host) (adapter 1)
==> selinux: Running 'pre-boot' VM customizations...
==> selinux: Booting VM...
==> selinux: Waiting for machine to boot. This may take a few minutes...
    selinux: SSH address: 127.0.0.1:2222
    selinux: SSH username: vagrant
    selinux: SSH auth method: private key
    selinux: 
    selinux: Vagrant insecure key detected. Vagrant will automatically replace
    selinux: this with a newly generated keypair for better security.
    selinux: 
    selinux: Inserting generated public key within guest...
    selinux: Removing insecure key from the guest if it's present...
    selinux: Key inserted! Disconnecting and reconnecting using new SSH key...
==> selinux: Machine booted and ready!
==> selinux: Checking for guest additions in VM...
    selinux: No guest additions were detected on the base box for this VM! Guest
    selinux: additions are required for forwarded ports, shared folders, host only
    selinux: networking, and more. If SSH fails on this machine, please install
    selinux: the guest additions and repackage the box to continue.
    selinux: 
    selinux: This is not an error message; everything may continue to work properly,
    selinux: in which case you may ignore this message.
==> selinux: Setting hostname...
==> selinux: Rsyncing folder: /vagrantVM/selinux/ => /vagrant
==> selinux: Running provisioner: shell...
    selinux: Running: inline script
    selinux: Loaded plugins: fastestmirror
    selinux: Determining fastest mirrors
    selinux:  * base: mirror.yandex.ru
    selinux:  * extras: mirror.yandex.ru
    selinux:  * updates: mirror.axelname.ru
    selinux: Resolving Dependencies
    selinux: --> Running transaction check
    selinux: ---> Package epel-release.noarch 0:7-11 will be installed
    selinux: --> Finished Dependency Resolution
    selinux: 
    selinux: Dependencies Resolved
    selinux: 
    selinux: ================================================================================
    selinux:  Package                Arch             Version         Repository        Size
    selinux: ================================================================================
    selinux: Installing:
    selinux:  epel-release           noarch           7-11            extras            15 k
    selinux: 
    selinux: Transaction Summary
    selinux: ================================================================================
    selinux: Install  1 Package
    selinux: 
    selinux: Total download size: 15 k
    selinux: Installed size: 24 k
    selinux: Downloading packages:
    selinux: Public key for epel-release-7-11.noarch.rpm is not installed
    selinux: warning: /var/cache/yum/x86_64/7/extras/packages/epel-release-7-11.noarch.rpm: Header V3 RSA/SHA256 Signature, key ID f4a80eb5: NOKEY
    selinux: Retrieving key from file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7
    selinux: Importing GPG key 0xF4A80EB5:
    selinux:  Userid     : "CentOS-7 Key (CentOS 7 Official Signing Key) <security@centos.org>"
    selinux:  Fingerprint: 6341 ab27 53d7 8a78 a7c2 7bb1 24c6 a8a7 f4a8 0eb5
    selinux:  Package    : centos-release-7-8.2003.0.el7.centos.x86_64 (@anaconda)
    selinux:  From       : /etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7
    selinux: Running transaction check
    selinux: Running transaction test
    selinux: Transaction test succeeded
    selinux: Running transaction
    selinux:   Installing : epel-release-7-11.noarch                                     1/1
    selinux:   Verifying  : epel-release-7-11.noarch                                     1/1
    selinux: 
    selinux: Installed:
    selinux:   epel-release.noarch 0:7-11
    selinux: 
    selinux: Complete!
    selinux: Loaded plugins: fastestmirror
    selinux: Loading mirror speeds from cached hostfile
    selinux:  * base: mirror.yandex.ru
    selinux:  * epel: mirror.logol.ru
    selinux:  * extras: mirror.yandex.ru
    selinux:  * updates: mirror.axelname.ru
    selinux: Resolving Dependencies
    selinux: --> Running transaction check
    selinux: ---> Package nginx.x86_64 1:1.20.1-10.el7 will be installed
    selinux: --> Processing Dependency: nginx-filesystem = 1:1.20.1-10.el7 for package: 1:nginx-1.20.1-10.el7.x86_64
    selinux: --> Processing Dependency: libcrypto.so.1.1(OPENSSL_1_1_0)(64bit) for package: 1:nginx-1.20.1-10.el7.x86_64
    selinux: --> Processing Dependency: libssl.so.1.1(OPENSSL_1_1_0)(64bit) for package: 1:nginx-1.20.1-10.el7.x86_64
    selinux: --> Processing Dependency: libssl.so.1.1(OPENSSL_1_1_1)(64bit) for package: 1:nginx-1.20.1-10.el7.x86_64
    selinux: --> Processing Dependency: nginx-filesystem for package: 1:nginx-1.20.1-10.el7.x86_64
    selinux: --> Processing Dependency: redhat-indexhtml for package: 1:nginx-1.20.1-10.el7.x86_64
    selinux: --> Processing Dependency: system-logos for package: 1:nginx-1.20.1-10.el7.x86_64
    selinux: --> Processing Dependency: libcrypto.so.1.1()(64bit) for package: 1:nginx-1.20.1-10.el7.x86_64
    selinux: --> Processing Dependency: libprofiler.so.0()(64bit) for package: 1:nginx-1.20.1-10.el7.x86_64
    selinux: --> Processing Dependency: libssl.so.1.1()(64bit) for package: 1:nginx-1.20.1-10.el7.x86_64
    selinux: --> Running transaction check
    selinux: ---> Package centos-indexhtml.noarch 0:7-9.el7.centos will be installed
    selinux: ---> Package centos-logos.noarch 0:70.0.6-3.el7.centos will be installed
    selinux: ---> Package gperftools-libs.x86_64 0:2.6.1-1.el7 will be installed
    selinux: ---> Package nginx-filesystem.noarch 1:1.20.1-10.el7 will be installed
    selinux: ---> Package openssl11-libs.x86_64 1:1.1.1k-5.el7 will be installed
    selinux: --> Finished Dependency Resolution
    selinux: 
    selinux: Dependencies Resolved
    selinux: 
    selinux: ================================================================================
    selinux:  Package                Arch         Version                   Repository  Size
    selinux: ================================================================================
    selinux: Installing:
    selinux:  nginx                  x86_64       1:1.20.1-10.el7           epel       588 k
    selinux: Installing for dependencies:
    selinux:  centos-indexhtml       noarch       7-9.el7.centos            base        92 k
    selinux:  centos-logos           noarch       70.0.6-3.el7.centos       base        21 M
    selinux:  gperftools-libs        x86_64       2.6.1-1.el7               base       272 k
    selinux:  nginx-filesystem       noarch       1:1.20.1-10.el7           epel        24 k
    selinux:  openssl11-libs         x86_64       1:1.1.1k-5.el7            epel       1.5 M
    selinux: 
    selinux: Transaction Summary
    selinux: ================================================================================
    selinux: Install  1 Package (+5 Dependent packages)
    selinux: 
    selinux: Total download size: 24 M
    selinux: Installed size: 28 M
    selinux: Downloading packages:
    selinux: Public key for nginx-filesystem-1.20.1-10.el7.noarch.rpm is not installed
    selinux: warning: /var/cache/yum/x86_64/7/epel/packages/nginx-filesystem-1.20.1-10.el7.noarch.rpm: Header V4 RSA/SHA256 Signature, key ID 352c64e5: NOKEY
    selinux: --------------------------------------------------------------------------------
    selinux: Total                                              1.0 MB/s |  24 MB  00:23
    selinux: Retrieving key from file:///etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-7
    selinux: Importing GPG key 0x352C64E5:
    selinux:  Userid     : "Fedora EPEL (7) <epel@fedoraproject.org>"
    selinux:  Fingerprint: 91e9 7d7c 4a5e 96f1 7f3e 888f 6a2f aea2 352c 64e5
    selinux:  Package    : epel-release-7-11.noarch (@extras)
    selinux:  From       : /etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-7
    selinux: Running transaction check
    selinux: Running transaction test
    selinux: Transaction test succeeded
    selinux: Running transaction
    selinux:   Installing : centos-logos-70.0.6-3.el7.centos.noarch                      1/6
    selinux:   Installing : 1:openssl11-libs-1.1.1k-5.el7.x86_64                         2/6
    selinux:   Installing : centos-indexhtml-7-9.el7.centos.noarch                       3/6
    selinux:   Installing : gperftools-libs-2.6.1-1.el7.x86_64                           4/6
    selinux:   Installing : 1:nginx-filesystem-1.20.1-10.el7.noarch                      5/6
    selinux:   Installing : 1:nginx-1.20.1-10.el7.x86_64                                 6/6
    selinux:   Verifying  : 1:nginx-filesystem-1.20.1-10.el7.noarch                      1/6
    selinux:   Verifying  : gperftools-libs-2.6.1-1.el7.x86_64                           2/6
    selinux:   Verifying  : 1:nginx-1.20.1-10.el7.x86_64                                 3/6
    selinux:   Verifying  : centos-indexhtml-7-9.el7.centos.noarch                       4/6
    selinux:   Verifying  : 1:openssl11-libs-1.1.1k-5.el7.x86_64                         5/6
    selinux:   Verifying  : centos-logos-70.0.6-3.el7.centos.noarch                      6/6
    selinux: 
    selinux: Installed:
    selinux:   nginx.x86_64 1:1.20.1-10.el7
    selinux: 
    selinux: Dependency Installed:
    selinux:   centos-indexhtml.noarch 0:7-9.el7.centos
    selinux:   centos-logos.noarch 0:70.0.6-3.el7.centos
    selinux:   gperftools-libs.x86_64 0:2.6.1-1.el7
    selinux:   nginx-filesystem.noarch 1:1.20.1-10.el7
    selinux:   openssl11-libs.x86_64 1:1.1.1k-5.el7
    selinux: 
    selinux: Complete!
    selinux: Job for nginx.service failed because the control process exited with error code. See "systemctl status nginx.service" and "journalctl -xe" for details.
    selinux: ● nginx.service - The nginx HTTP and reverse proxy server
    selinux:    Loaded: loaded (/usr/lib/systemd/system/nginx.service; disabled; vendor preset: disabled)
    selinux:    Active: failed (Result: exit-code) since Thu 2023-03-09 14:50:18 UTC; 15ms ago
    selinux:   Process: 2758 ExecStartPre=/usr/sbin/nginx -t (code=exited, status=1/FAILURE)
    selinux:   Process: 2757 ExecStartPre=/usr/bin/rm -f /run/nginx.pid (code=exited, status=0/SUCCESS)
    selinux: 
    selinux: Mar 09 14:50:18 selinux systemd[1]: Starting The nginx HTTP and reverse proxy server...
    selinux: Mar 09 14:50:18 selinux nginx[2758]: nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
    selinux: Mar 09 14:50:18 selinux nginx[2758]: nginx: [emerg] bind() to 0.0.0.0:4881 failed (13: Permission denied)
    selinux: Mar 09 14:50:18 selinux nginx[2758]: nginx: configuration file /etc/nginx/nginx.conf test failed
    selinux: Mar 09 14:50:18 selinux systemd[1]: nginx.service: control process exited, code=exited status=1
    selinux: Mar 09 14:50:18 selinux systemd[1]: Failed to start The nginx HTTP and reverse proxy server.
    selinux: Mar 09 14:50:18 selinux systemd[1]: Unit nginx.service entered failed state.
    selinux: Mar 09 14:50:18 selinux systemd[1]: nginx.service failed.
The SSH command responded with a non-zero exit status. Vagrant
assumes that this means the command failed. The output for this command
should be in the log above. Please read the output to determine what
went wrong.
```
</details>
  
* Выполним вход: `vagrant ssh`, выполним вход `sudo -i`.

* Проверим состояние сервиса `nginx`: `systemctl status nginx`

```bash
[vagrant@selinux ~]$ sudo -i
[root@selinux ~]# systemctl status nginx.service 
● nginx.service - The nginx HTTP and reverse proxy server
   Loaded: loaded (/usr/lib/systemd/system/nginx.service; disabled; vendor preset: disabled)
   Active: failed (Result: exit-code) since Mon 2022-12-26 17:29:50 UTC; 28min ago
  Process: 2830 ExecStartPre=/usr/sbin/nginx -t (code=exited, status=1/FAILURE)
  Process: 2829 ExecStartPre=/usr/bin/rm -f /run/nginx.pid (code=exited, status=0/SUCCESS)
Dec 26 17:29:50 selinux systemd[1]: Starting The nginx HTTP and reverse proxy server...
Dec 26 17:29:50 selinux nginx[2830]: nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
Dec 26 17:29:50 selinux nginx[2830]: nginx: [emerg] bind() to [::]:4881 failed (13: Permission denied)
Dec 26 17:29:50 selinux nginx[2830]: nginx: configuration file /etc/nginx/nginx.conf test failed
Dec 26 17:29:50 selinux systemd[1]: nginx.service: control process exited, code=exited status=1
Dec 26 17:29:50 selinux systemd[1]: Failed to start The nginx HTTP and reverse proxy server.
Dec 26 17:29:50 selinux systemd[1]: Unit nginx.service entered failed state.
Dec 26 17:29:50 selinux systemd[1]: nginx.service failed.
```

В логе видим что сервис `nginx` не запустился. Ошибка возникает из-за того, что `SELinux` блокирует запуск сервиса `nginx` на нестандартном порту. Выполним проверку конфигурации `nginx` и режим работы `SELinux`:
Для начала проверим, что в ОС отключен файервол, а так же корреткна ли конфигурация nginx и режим работы  SElinux
```bash
[root@selinux ~]# systemctl status firewalld
● firewalld.service - firewalld - dynamic firewall daemon
   Loaded: loaded (/usr/lib/systemd/system/firewalld.service; disabled; vendor preset: enabled)
   Active: inactive (dead)
     Docs: man:firewalld(1)
[root@selinux ~]#
[root@selinux ~]# nginx -t
nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
nginx: configuration file /etc/nginx/nginx.conf test is successful
[root@selinux ~]# getenforce 
Enforcing
```
  Отображается режим Enforcing. 
  Данный режим означает, что SELinux будет блокировать запрещенную активность.
  
## Разрешим в SELinux работу nginx на порту TCP 4881 c помощью переключателей setsebool

  Находим в логах (/var/log/audit/audit.log) информацию о блокировании порта
```
type=SYSCALL msg=audit(1678377902.073:883): arch=c000003e syscall=49 success=no exit=-13 a0=6 a1=55f2045b47a8 a2=10 a3=7ffdbb38f920 items=0 ppid=1 pid=22152 auid=4294967295 uid=0 gid=0 euid=0 suid=0 fsuid=0 egid=0 sgid=0 fsgid=0 tty=(none) ses=4294967295 comm="nginx" exe="/usr/sbin/nginx" subj=system_u:system_r:httpd_t:s0 key=(null)
type=SERVICE_START msg=audit(1678377902.086:884): pid=1 uid=0 auid=4294967295 ses=4294967295 subj=system_u:system_r:init_t:s0 msg='unit=nginx comm="systemd" exe="/usr/lib/systemd/systemd" hostname=? addr=? terminal=? res=failed'
```
  Копируем время, в которое был записан этот лог, и, с помощью утилиты audit2why смотрим
  ```
  grep 1678377902.073:883 /var/log/audit/audit.log | audit2why
type=AVC msg=audit(1678377902.073:883): avc:  denied  { name_bind } for  pid=22152 comm="nginx" src=4881 scontext=system_u:system_r:httpd_t:s0 tcontext=system_u:object_r:unreserved_port_t:s0 tclass=tcp_socket permissive=0

	Was caused by:
	The boolean nis_enabled was set incorrectly. 
	Description:
	Allow nis to enabled

	Allow access by executing:
	# setsebool -P nis_enabled 1
  ```
  Утилита audit2why показывает почему трафик блокируется. 
  Исходя из вывода утилиты, видно, что нам нужно поменять параметр nis_enabled. 
Включим параметр nis_enabled и перезапустим nginx
```
[root@selinux ~]# setsebool -P nis_enabled 1
[root@selinux ~]# 
[root@selinux ~]# 
[root@selinux ~]# systemctl restart nginx
[root@selinux ~]# systemctl status nginx
● nginx.service - The nginx HTTP and reverse proxy server
   Loaded: loaded (/usr/lib/systemd/system/nginx.service; disabled; vendor preset: disabled)
   Active: active (running) since Thu 2023-03-09 16:06:49 UTC; 10s ago
  Process: 22190 ExecStart=/usr/sbin/nginx (code=exited, status=0/SUCCESS)
  Process: 22188 ExecStartPre=/usr/sbin/nginx -t (code=exited, status=0/SUCCESS)
  Process: 22187 ExecStartPre=/usr/bin/rm -f /run/nginx.pid (code=exited, status=0/SUCCESS)
 Main PID: 22192 (nginx)
   CGroup: /system.slice/nginx.service
           ├─22192 nginx: master process /usr/sbin/nginx
           └─22193 nginx: worker process

Mar 09 16:06:49 selinux systemd[1]: Starting The nginx HTTP and reverse proxy .....
Mar 09 16:06:49 selinux nginx[22188]: nginx: the configuration file /etc/nginx...ok
Mar 09 16:06:49 selinux nginx[22188]: nginx: configuration file /etc/nginx/ngi...ul
Mar 09 16:06:49 selinux systemd[1]: Started The nginx HTTP and reverse proxy s...r.
Hint: Some lines were ellipsized, use -l to show in full.
```
  Проверить статус параметра можно с помощью команды: getsebool -a | grep nis_enabled

  ```
  [root@selinux ~]# getsebool -a | grep nis_enabled
nis_enabled --> on
  ```
  Вернём запрет работы nginx на порту 4881 обратно. Для этого отключим nis_enabled: setsebool -P nis_enabled off
После отключения nis_enabled служба nginx снова не запустится.

  ```
  [root@selinux ~]# setsebool -P nis_enabled 0
[root@selinux ~]# getsebool -a | grep nis_enabled
nis_enabled --> off
[root@selinux ~]# systemctl restart nginx
Job for nginx.service failed because the control process exited with error code. See "systemctl status nginx.service" and "journalctl -xe" for details.

  ```
  
  ##Теперь разрешим в SELinux работу nginx на порту TCP 4881 c помощью добавления нестандартного порта в имеющийся тип
  
Поиск имеющегося типа, для http трафика
  ```
  [root@selinux ~]# semanage port -l | grep http
http_cache_port_t              tcp      8080, 8118, 8123, 10001-10010
http_cache_port_t              udp      3130
http_port_t                    tcp      80, 81, 443, 488, 8008, 8009, 8443, 9000
pegasus_http_port_t            tcp      5988
pegasus_https_port_t           tcp      5989
  ```
  Добавим порт в тип http_port_t
  ```
  [root@selinux ~]# semanage port -a -t http_port_t -p tcp 4881
[root@selinux ~]# 
[root@selinux ~]# semanage port -l | grep http
http_cache_port_t              tcp      8080, 8118, 8123, 10001-10010
http_cache_port_t              udp      3130
http_port_t                    tcp      4881, 80, 81, 443, 488, 8008, 8009, 8443, 9000
pegasus_http_port_t            tcp      5988
pegasus_https_port_t           tcp      5989
  ```
Теперь перезапустим службу nginx и проверим её работу:
  ```
  [root@selinux ~]# systemctl restart nginx
[root@selinux ~]# systemctl status nginx
● nginx.service - The nginx HTTP and reverse proxy server
   Loaded: loaded (/usr/lib/systemd/system/nginx.service; disabled; vendor preset: disabled)
   Active: active (running) since Thu 2023-03-09 15:41:19 UTC; 18min ago
  Process: 22054 ExecStart=/usr/sbin/nginx (code=exited, status=0/SUCCESS)
  Process: 22052 ExecStartPre=/usr/sbin/nginx -t (code=exited, status=0/SUCCESS)
  Process: 22051 ExecStartPre=/usr/bin/rm -f /run/nginx.pid (code=exited, status=0/SUCCESS)
 Main PID: 22056 (nginx)
   CGroup: /system.slice/nginx.service
           ├─22056 nginx: master process /usr/sbin/nginx
           └─22058 nginx: worker process

Mar 09 15:41:19 selinux systemd[1]: Starting The nginx HTTP and reverse proxy .....
Mar 09 15:41:19 selinux nginx[22052]: nginx: the configuration file /etc/nginx...ok
Mar 09 15:41:19 selinux nginx[22052]: nginx: configuration file /etc/nginx/ngi...ul
Mar 09 15:41:19 selinux systemd[1]: Started The nginx HTTP and reverse proxy s...r.
Hint: Some lines were ellipsized, use -l to show in full.
  ```
  Удалить нестандартный порт из имеющегося типа можно с помощью команды: semanage port -d -t http_port_t -p tcp 4881. После чего веб-служба снова перестанет запускаться.

  ```
[root@selinux ~]# semanage port -d -t http_port_t -p tcp 4881
[root@selinux ~]# systemctl restart nginx
Job for nginx.service failed because the control process exited with error code. See "systemctl status nginx.service" and "journalctl -xe" for details.
  ```
  
  ##Разрешим в SELinux работу nginx на порту TCP 4881 c помощью формирования и установки модуля SELinux:
  
  
  Воспользуемся утилитой audit2allow для того, чтобы на основе логов SELinux сделать модуль, разрешающий работу nginx на нестандартном порту: 
grep nginx /var/log/audit/audit.log | audit2allow -M nginx
  ```
[root@selinux ~]# grep nginx /var/log/audit/audit.log | audit2allow -M nginx
******************** IMPORTANT ***********************
To make this policy package active, execute:

semodule -i nginx.pp

  ```


Audit2allow сформировал модуль, и сообщил нам команду, с помощью которой можно применить данный модуль: semodule -i nginx.pp

 ```
[root@selinux ~]# semodule -i nginx.pp
[root@selinux ~]#
 ```
Попробуем снова запустить nginx: systemctl start nginx
  ![image](https://user-images.githubusercontent.com/122198710/224111978-d6ab22f8-5505-41b3-8ed4-849a40284ddd.png)

  ```
[root@selinux ~]# systemctl start nginx
[root@selinux ~]# systemctl status nginx
● nginx.service - The nginx HTTP and reverse proxy server
   Loaded: loaded (/usr/lib/systemd/system/nginx.service; disabled; vendor preset: disabled)
   Active: active (running) since Thu 2023-03-09 15:41:19 UTC; 5s ago
  Process: 22054 ExecStart=/usr/sbin/nginx (code=exited, status=0/SUCCESS)
  Process: 22052 ExecStartPre=/usr/sbin/nginx -t (code=exited, status=0/SUCCESS)
  Process: 22051 ExecStartPre=/usr/bin/rm -f /run/nginx.pid (code=exited, status=0/SUCCESS)
 Main PID: 22056 (nginx)
   CGroup: /system.slice/nginx.service
           ├─22056 nginx: master process /usr/sbin/nginx
           └─22058 nginx: worker process

Mar 09 15:41:19 selinux systemd[1]: Starting The nginx HTTP and reverse proxy .....
Mar 09 15:41:19 selinux nginx[22052]: nginx: the configuration file /etc/nginx...ok
Mar 09 15:41:19 selinux nginx[22052]: nginx: configuration file /etc/nginx/ngi...ul
Mar 09 15:41:19 selinux systemd[1]: Started The nginx HTTP and reverse proxy s...r.
Hint: Some lines were ellipsized, use -l to show in full.
  ```
После добавления модуля nginx запустился без ошибок. При использовании модуля изменения сохранятся после перезагрузки. 
Просмотр всех установленных модулей: semodule -l
Для удаления модуля воспользуемся командой: semodule -r nginx
  
  ```

[root@selinux ~]# semodule -r nginx
libsemanage.semanage_direct_remove_key: Removing last nginx module (no other nginx module exists at another priority).
[root@selinux ~]# 
[root@selinux ~]# semodule -l | grep nginx
[root@selinux ~]# 
  ```
  
  
  #Обеспечение работоспособности приложения при включенном SELinux
   
<details>
<summary>
Скачиваем данные из репозитория git otus-linux-adm.git
</summary>

```

vilotiv@vilotiv-leg:/vagrantVM$ git clone https://github.com/mbfx/otus-linux-adm.git
Клонирование в «otus-linux-adm»...
remote: Enumerating objects: 558, done.
remote: Counting objects: 100% (456/456), done.
remote: Compressing objects: 100% (303/303), done.
remote: Total 558 (delta 125), reused 396 (delta 74), pack-reused 102
Получение объектов: 100% (558/558), 1.38 МиБ | 51.00 КиБ/с, готово.
Определение изменений: 100% (140/140), готово.
vilotiv@vilotiv-leg:/vagrantVM$ cd otus-linux-adm/
vilotiv@vilotiv-leg:/vagrantVM/otus-linux-adm$ ls
dhcp_dns_demo         dynamic_routing_guideline  terraform-proxmox
drbd_stand_demo       pacemaker_vbox_stand_demo  vpn_tunnels_demo
dynamic_routing_demo  selinux_dns_problems       vpn_tunnels_demo_2
vilotiv@vilotiv-leg:/vagrantVM/otus-linux-adm$ cd selinux_dns_problems/

vilotiv@vilotiv-leg:/vagrantVM/otus-linux-adm/selinux_dns_problems$ vagrant up
Bringing machine 'ns01' up with 'virtualbox' provider...
Bringing machine client up with virtualbox provider...
==> ns01: Importing base box centos/7...
==> ns01: Matching MAC address for NAT networking...
==> ns01: Checking if box centos/7 version 2004.01 is up to date...
==> ns01: There was a problem while downloading the metadata for your box
==> ns01: to check for updates. This is not an error, since it is usually due
==> ns01: to temporary network problems. This is just a warning. The problem
==> ns01: encountered was:
==> ns01: 
==> ns01: The requested URL returned error: 404
==> ns01: 
==> ns01: If you want to check for box updates, verify your network connection
==> ns01: is valid and try again.
==> ns01: Setting the name of the VM: selinux_dns_problems_ns01_1678379598948_49883
==> ns01: Fixed port collision for 22 => 2222. Now on port 2200.
==> ns01: Clearing any previously set network interfaces...
==> ns01: Preparing network interfaces based on configuration...
    ns01: Adapter 1: nat
    ns01: Adapter 2: intnet
==> ns01: Forwarding ports...
    ns01: 22 (guest) => 2200 (host) (adapter 1)
==> ns01: Running pre-boot VM customizations...
==> ns01: Booting VM...
==> ns01: Waiting for machine to boot. This may take a few minutes...
    ns01: SSH address: 127.0.0.1:2200
    ns01: SSH username: vagrant
    ns01: SSH auth method: private key
    ns01: Warning: Connection reset. Retrying...
    ns01: Warning: Remote connection disconnect. Retrying...
    ns01: Warning: Connection reset. Retrying...
    ns01: Warning: Remote connection disconnect. Retrying...
    ns01: Warning: Connection reset. Retrying...
    ns01: 
    ns01: Vagrant insecure key detected. Vagrant will automatically replace
    ns01: this with a newly generated keypair for better security.
    ns01: 
    ns01: Inserting generated public key within guest...
    ns01: Removing insecure key from the guest if it's present...
    ns01: Key inserted! Disconnecting and reconnecting using new SSH key...
==> ns01: Machine booted and ready!
==> ns01: Checking for guest additions in VM...
    ns01: No guest additions were detected on the base box for this VM! Guest
    ns01: additions are required for forwarded ports, shared folders, host only
    ns01: networking, and more. If SSH fails on this machine, please install
    ns01: the guest additions and repackage the box to continue.
    ns01: 
    ns01: This is not an error message; everything may continue to work properly,
    ns01: in which case you may ignore this message.
==> ns01: Setting hostname...
==> ns01: Configuring and enabling network interfaces...
==> ns01: Rsyncing folder: /vagrantVM/otus-linux-adm/selinux_dns_problems/ => /vagrant
==> ns01: Running provisioner: ansible...
    ns01: Running ansible-playbook...

PLAY [all] *********************************************************************

TASK [Gathering Facts] *********************************************************
ok: [ns01]

TASK [install packages] ********************************************************
changed: [ns01]

PLAY [ns01] ********************************************************************

TASK [Gathering Facts] *********************************************************
ok: [ns01]

TASK [copy named.conf] *********************************************************
changed: [ns01]

TASK [copy master zone dns.lab] ************************************************
changed: [ns01] => (item=/vagrantVM/otus-linux-adm/selinux_dns_problems/provisioning/files/ns01/named.dns.lab)
changed: [ns01] => (item=/vagrantVM/otus-linux-adm/selinux_dns_problems/provisioning/files/ns01/named.dns.lab.view1)

TASK [copy dynamic zone ddns.lab] **********************************************
changed: [ns01]

TASK [copy dynamic zone ddns.lab.view1] ****************************************
changed: [ns01]

TASK [copy master zone newdns.lab] *********************************************
changed: [ns01]

TASK [copy rev zones] **********************************************************
changed: [ns01]

TASK [copy resolv.conf to server] **********************************************
changed: [ns01]

TASK [copy transferkey to server] **********************************************
changed: [ns01]

TASK [set /etc/named permissions] **********************************************
changed: [ns01]

TASK [set /etc/named/dynamic permissions] **************************************
changed: [ns01]

TASK [ensure named is running and enabled] *************************************
changed: [ns01]
[WARNING]: Could not match supplied host pattern, ignoring: client

PLAY [client] ******************************************************************
skipping: no hosts matched

PLAY RECAP *********************************************************************
ns01                       : ok=14   changed=12   unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   

==> client: Importing base box centos/7...
==> client: Matching MAC address for NAT networking...
==> client: Checking if box centos/7 version 2004.01 is up to date...
==> client: Setting the name of the VM: selinux_dns_problems_client_1678379791241_97309
==> client: Fixed port collision for 22 => 2222. Now on port 2201.
==> client: Clearing any previously set network interfaces...
==> client: Preparing network interfaces based on configuration...
    client: Adapter 1: nat
    client: Adapter 2: intnet
==> client: Forwarding ports...
    client: 22 (guest) => 2201 (host) (adapter 1)
==> client: Running pre-boot VM customizations...
==> client: Booting VM...
==> client: Waiting for machine to boot. This may take a few minutes...
    client: SSH address: 127.0.0.1:2201
    client: SSH username: vagrant
    client: SSH auth method: private key
    client: 
    client: Vagrant insecure key detected. Vagrant will automatically replace
    client: this with a newly generated keypair for better security.
    client: 
    client: Inserting generated public key within guest...
    client: Removing insecure key from the guest if it's present...
    client: Key inserted! Disconnecting and reconnecting using new SSH key...
==> client: Machine booted and ready!
==> client: Checking for guest additions in VM...
    client: No guest additions were detected on the base box for this VM! Guest
    client: additions are required for forwarded ports, shared folders, host only
    client: networking, and more. If SSH fails on this machine, please install
    client: the guest additions and repackage the box to continue.
    client: 
    client: This is not an error message; everything may continue to work properly,
    client: in which case you may ignore this message.
==> client: Setting hostname...
==> client: Configuring and enabling network interfaces...
==> client: Rsyncing folder: /vagrantVM/otus-linux-adm/selinux_dns_problems/ => /vagrant
==> client: Running provisioner: ansible...
    client: Running ansible-playbook...

PLAY [all] *********************************************************************

TASK [Gathering Facts] *********************************************************
ok: [client]

TASK [install packages] ********************************************************
changed: [client]

PLAY [ns01] ********************************************************************
skipping: no hosts matched

PLAY [client] ******************************************************************

TASK [Gathering Facts] *********************************************************
ok: [client]

TASK [copy resolv.conf to the client] ******************************************
changed: [client]

TASK [copy rndc conf file] *****************************************************
changed: [client]

TASK [copy motd to the client] *************************************************
changed: [client]

TASK [copy transferkey to client] **********************************************
changed: [client]

PLAY RECAP *********************************************************************
client                     : ok=7    changed=5    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   

vilotiv@vilotiv-leg:/vagrantVM/otus-linux-adm/selinux_dns_problems$ 
vilotiv@vilotiv-leg:/vagrantVM/otus-linux-adm/selinux_dns_problems$ 
vilotiv@vilotiv-leg:/vagrantVM/otus-linux-adm/selinux_dns_problems$ vagrant status
Current machine states:

ns01                      running (virtualbox)
client                    running (virtualbox)

This environment represents multiple VMs. The VMs are all listed
above with their current state. For more information about a specific
VM, run vagrant status NAME.

```

</details> 
  
Запускаем наши виртуальные машины, подключаемся к клиентской машине и пробуем внести изменения в зону. 
Изменить не получается
В логах selinux с помощью утилиты audit2why на клиенте ошибок не находим:
  ```
  vilotiv@vilotiv-leg:/vagrantVM/otus-linux-adm/selinux_dns_problems$ vagrant ssh client
Last login: Thu Mar  9 16:39:10 2023 from 10.0.2.2
###############################
### Welcome to the DNS lab! ###
###############################

- Use this client to test the enviroment
- with dig or nslookup. Ex:
    dig @192.168.50.10 ns01.dns.lab

- nsupdate is available in the ddns.lab zone. Ex:
    nsupdate -k /etc/named.zonetransfer.key
    server 192.168.50.10
    zone ddns.lab 
    update add www.ddns.lab. 60 A 192.168.50.15
    send

- rndc is also available to manage the servers
    rndc -c ~/rndc.conf reload

###############################
### Enjoy! ####################
###############################
[vagrant@client ~]$ nsupdate -k /etc/named.zonetransfer.key
> server 192.168.50.10
> zone ddns.lab
> update add www.ddns.lab 60 A 192.168.50.15
> send
update failed: SERVFAIL
> quit
  [vagrant@client ~]$ sudo -i                      
[root@client ~]# cat /var/log/audit/audit.log | audi
audispd      audit2allow  audit2why    auditctl     auditd       
[root@client ~]# cat /var/log/audit/audit.log | audit2why
  ```
  
  Не закрывая сессии в клиенте переходим к серверу ns01: vagrant ssh ns01 и проверим логи SELinux

  ```
  vagrant ssh ns01
Last login: Thu Mar  9 16:36:19 2023 from 10.0.2.2
[vagrant@ns01 ~]$ 
[vagrant@ns01 ~]$ 
[vagrant@ns01 ~]$ sudo -i
[root@ns01 ~]# cat /var/log/audit/audit.log | audit2why 
type=AVC msg=audit(1678380244.332:1873): avc:  denied  { create } for  pid=5065 comm="isc-worker0000" name="named.ddns.lab.view1.jnl" scontext=system_u:system_r:named_t:s0 tcontext=system_u:object_r:etc_t:s0 tclass=file permissive=0

	Was caused by:
		Missing type enforcement (TE) allow rule.

		You can use audit2allow to generate a loadable module to allow this access.
  ```
  В логах мы видим, что ошибка в контексте безопасности. Вместо типа named_t используется тип etc_t. Проверим данную проблему в каталоге /etc/named:
  ```
  [root@ns01 ~]# ls -laZ /etc/named
drw-rwx---. root named system_u:object_r:etc_t:s0       .
drwxr-xr-x. root root  system_u:object_r:etc_t:s0       ..
drw-rwx---. root named unconfined_u:object_r:etc_t:s0   dynamic
-rw-rw----. root named system_u:object_r:etc_t:s0       named.50.168.192.rev
-rw-rw----. root named system_u:object_r:etc_t:s0       named.dns.lab
-rw-rw----. root named system_u:object_r:etc_t:s0       named.dns.lab.view1
-rw-rw----. root named system_u:object_r:etc_t:s0       named.newdns.lab
  ```
  
  Тут мы также видим, что контекст безопасности неправильный. Проблема заключается в том, что конфигурационные файлы лежат в другом каталоге. Посмотреть в каком каталоге должны лежать файлы, чтобы на них распространялись правильные политики SELinux можно с помощью команды: sudo semanage fcontext -l | grep named_zone_t
  ```
  [root@ns01 ~]# semanage fcontext -l | grep named_zone_t
/var/named(/.*)?                                   all files          system_u:object_r:named_zone_t:s0 
/var/named/chroot/var/named(/.*)?                  all files          system_u:object_r:named_zone_t:s0 
  ```
Изменим тип контекста безопасности для каталога /etc/named и проверяем его:
  ```
[root@ns01 ~]# chcon -R -t named_zone_t /etc/named
[root@ns01 ~]# ls -laZ /etc/named
drw-rwx---. root named system_u:object_r:named_zone_t:s0 .
drwxr-xr-x. root root  system_u:object_r:etc_t:s0       ..
drw-rwx---. root named unconfined_u:object_r:named_zone_t:s0 dynamic
-rw-rw----. root named system_u:object_r:named_zone_t:s0 named.50.168.192.rev
-rw-rw----. root named system_u:object_r:named_zone_t:s0 named.dns.lab
-rw-rw----. root named system_u:object_r:named_zone_t:s0 named.dns.lab.view1
-rw-rw----. root named system_u:object_r:named_zone_t:s0 named.newdns.lab
  ```
  Так же можно перенести файлы зон в каталог /var/named/ и изменить в конфигурации /etc/named.conf их расположение, но уже сделали изменение типа контекста безопасности для каталога
  
  Опять заходим на клиента и пробуем снова внести изменения. Видим, что на этот раз получилось:
  ```
  [root@client ~]# nsupdate -k /etc/named.zonetransfer.key
> server 192.168.50.10
> zone ddns.lab
> update add www.ddns.lab 60 A 192.168.50.15
> send
> quit
  ```
  проверяем утилитой dig корректность работы
  
  ```
  [root@client ~]# dig www.ddns.lab

; <<>> DiG 9.11.4-P2-RedHat-9.11.4-26.P2.el7_9.13 <<>> www.ddns.lab
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 35174
;; flags: qr aa rd ra; QUERY: 1, ANSWER: 1, AUTHORITY: 1, ADDITIONAL: 2

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 4096
;; QUESTION SECTION:
;www.ddns.lab.			IN	A

;; ANSWER SECTION:
www.ddns.lab.		60	IN	A	192.168.50.15

;; AUTHORITY SECTION:
ddns.lab.		3600	IN	NS	ns01.dns.lab.

;; ADDITIONAL SECTION:
ns01.dns.lab.		3600	IN	A	192.168.50.10

;; Query time: 3 msec
;; SERVER: 192.168.50.10#53(192.168.50.10)
;; WHEN: Thu Mar 09 16:52:38 UTC 2023
;; MSG SIZE  rcvd: 96
  ```
  
  Видим, что изменения применились. После перезагрузки так же все работает.
  Спасибо за проверку.
