# Домашнее задание 5. Практические навыки работы с ZFS

#### Цель:
#### Отрабатываем навыки работы с созданием томов export/import и установкой параметров.
####
#### определить алгоритм с наилучшим сжатием;
#### определить настройки pool’a;
#### найти сообщение от преподавателей.
#### Результат:
#### список команд, которыми получен результат с их выводами.

### Запускаем ВМ с набором скриптов для выполнения ДЗ
```
vilotiv@vilotiv-leg:/vagrantVM/centos7$ vagrant up
Bringing machine 'zfs' up with 'virtualbox' provider...
==> zfs: Importing base box 'centos/7'...
==> zfs: Matching MAC address for NAT networking...
==> zfs: Checking if box 'centos/7' version '2004.01' is up to date...
==> zfs: Setting the name of the VM: centos7_zfs_1676312965043_88152
==> zfs: Clearing any previously set network interfaces...
==> zfs: Preparing network interfaces based on configuration...
    zfs: Adapter 1: nat
    zfs: Adapter 2: hostonly
==> zfs: Forwarding ports...
    zfs: 22 (guest) => 2222 (host) (adapter 1)
==> zfs: Running 'pre-boot' VM customizations...
==> zfs: Booting VM...
==> zfs: Waiting for machine to boot. This may take a few minutes...
    zfs: SSH address: 127.0.0.1:2222
    zfs: SSH username: vagrant
    zfs: SSH auth method: private key
    zfs: 
    zfs: Vagrant insecure key detected. Vagrant will automatically replace
    zfs: this with a newly generated keypair for better security.
    zfs: 
    zfs: Inserting generated public key within guest...
    zfs: Removing insecure key from the guest if it's present...
    zfs: Key inserted! Disconnecting and reconnecting using new SSH key...
==> zfs: Machine booted and ready!
==> zfs: Checking for guest additions in VM...
    zfs: No guest additions were detected on the base box for this VM! Guest
    zfs: additions are required for forwarded ports, shared folders, host only
    zfs: networking, and more. If SSH fails on this machine, please install
    zfs: the guest additions and repackage the box to continue.
    zfs: 
    zfs: This is not an error message; everything may continue to work properly,
    zfs: in which case you may ignore this message.
==> zfs: Setting hostname...
==> zfs: Configuring and enabling network interfaces...
==> zfs: Rsyncing folder: /vagrantVM/centos7/ => /vagrant
==> zfs: Running provisioner: shell...
    zfs: Running: inline script
```
#### первая задача определение лучшего алгоритма сжатия, спойлеры : gzip

   ```
    zfs: -----------------------------------------------
    zfs: Определение алгоритма с наилучшим сжатием
    zfs: Установим необходимые программы...(займёт некоторое время)
    zfs: 
    zfs: Создадим mirror pool из дисков sdb и sdc
    zfs: NAME     SIZE  ALLOC   FREE  CKPOINT  EXPANDSZ   FRAG    CAP  DEDUP    HEALTH  ALTROOT
    zfs: mypool  9.50G    88K  9.50G        -         -     0%     0%  1.00x    ONLINE  -
    
    ```
    
    ```
    zfs: Создадим файловые системы с разным сжатием
    zfs: NAME             PROPERTY     VALUE     SOURCE
    zfs: mypool           compression  off       default
    zfs: mypool/dir_gzip  compression  gzip      local
    zfs: mypool/dir_lzjb  compression  lzjb      local
    zfs: mypool/dir_off   compression  off       local
    zfs: mypool/dir_zle   compression  zle       local
   ```
   
   ```
    zfs: Скачаем для теста книгу А.Толстого и скопируем ее в разные файловые системы
    zfs: Скачиваем...
    zfs: --2023-02-13 18:31:45--  http://www.gutenberg.org/ebooks/2600.txt.utf-8
    zfs: Resolving www.gutenberg.org (www.gutenberg.org)... 152.19.134.47, 2610:28:3090:3000:0:bad:cafe:47
    zfs: Connecting to www.gutenberg.org (www.gutenberg.org)|152.19.134.47|:80... connected.
    zfs: HTTP request sent, awaiting response... 302 Found
    zfs: Location: https://www.gutenberg.org/ebooks/2600.txt.utf-8 [following]
    zfs: --2023-02-13 18:31:45--  https://www.gutenberg.org/ebooks/2600.txt.utf-8
    zfs: Connecting to www.gutenberg.org (www.gutenberg.org)|152.19.134.47|:443... connected.
    zfs: HTTP request sent, awaiting response... 302 Found
    zfs: Location: https://www.gutenberg.org/cache/epub/2600/pg2600.txt [following]
    zfs: --2023-02-13 18:31:52--  https://www.gutenberg.org/cache/epub/2600/pg2600.txt
    zfs: Reusing existing connection to www.gutenberg.org:443.
    zfs: HTTP request sent, awaiting response... 200 OK
    zfs: Length: 3359372 (3.2M) [text/plain]
    zfs: Saving to: ‘War_and_Peace.txt’
    zfs: 
    zfs:      0K .......... .......... .......... .......... ..........  1%  219K 15s
    zfs:   3200K .......... .......... .......... .......... .......... 99% 1.30M 0s
    zfs:   3250K .......... .......... ..........                      100% 1.71M=3.3s
    zfs: 
    zfs: 2023-02-13 18:31:56 (1003 KB/s) - ‘War_and_Peace.txt’ saved [3359372/3359372]
  ```
  ```
    zfs: Копируем в директорию без сжатия...
    zfs: Копируем в директорию со сжатием gzip..
    zfs: Копируем в директорию со сжатием lzjb..
    zfs: Копируем в директорию со сжатием zle..
    zfs: 
    zfs: Please Wait...:
    zfs: 
    zfs: Сравним используемый объем после копирования:
    zfs: NAME              USED  AVAIL     REFER  MOUNTPOINT
    zfs: mypool           10.3M  9.19G       28K  /mypool
    zfs: mypool/dir_gzip  1.24M  9.19G     1.24M  /mypool/dir_gzip
    zfs: mypool/dir_lzjb  2.41M  9.19G     2.41M  /mypool/dir_lzjb
    zfs: mypool/dir_off   3.28M  9.19G     3.28M  /mypool/dir_off
    zfs: mypool/dir_zle   3.23M  9.19G     3.23M  /mypool/dir_zle
```
```
    zfs: Сравним компрессию:
    zfs: NAME             PROPERTY       VALUE  SOURCE
    zfs: mypool           compressratio  1.29x  -
    zfs: mypool/dir_gzip  compressratio  2.67x  -
    zfs: mypool/dir_lzjb  compressratio  1.36x  -
    zfs: mypool/dir_off   compressratio  1.00x  -
    zfs: mypool/dir_zle   compressratio  1.01x  -
 ```
 
#### вторая задача определить настройки pool’a
 ```
    zfs: -----------------------------------------------
    zfs: Определяем настройки pool’a
    zfs: 
    zfs: 
    zfs: Скачиваем архив с google drive...
    zfs: --2023-02-13 18:32:06--  https://drive.google.com/u/0/uc?id=1KRBNW33QWqbvbVHa3hLJivOAt60yukkg
    zfs: Resolving drive.google.com (drive.google.com)... 172.217.218.194, 2a00:1450:400c:c00::c2
    zfs: Connecting to drive.google.com (drive.google.com)|172.217.218.194|:443... connected.
    zfs: HTTP request sent, awaiting response... 302 Found
    zfs: Location: https://drive.google.com/uc?id=1KRBNW33QWqbvbVHa3hLJivOAt60yukkg [following]
    zfs: --2023-02-13 18:32:06--  https://drive.google.com/uc?id=1KRBNW33QWqbvbVHa3hLJivOAt60yukkg
    zfs: Reusing existing connection to drive.google.com:443.
    zfs: HTTP request sent, awaiting response... 303 See Other
    zfs: Location: https://doc-0c-bo-docs.googleusercontent.com/docs/securesc/ha0ro937gcuc7l7deffksulhg5h7mbp1/mtq5hnolc9rsr81t0tu8r0i1pj4nfv18/1676313075000/16189157874053420687/*/1KRBNW33QWqbvbVHa3hLJivOAt60yukkg?uuid=c921c848-890e-4a31-98aa-93b488371450 [following]
    zfs: Warning: wildcards not supported in HTTP.
    zfs: --2023-02-13 18:32:11--  https://doc-0c-bo-docs.googleusercontent.com/docs/securesc/ha0ro937gcuc7l7deffksulhg5h7mbp1/mtq5hnolc9rsr81t0tu8r0i1pj4nfv18/1676313075000/16189157874053420687/*/1KRBNW33QWqbvbVHa3hLJivOAt60yukkg?uuid=c921c848-890e-4a31-98aa-93b488371450
    zfs: Resolving doc-0c-bo-docs.googleusercontent.com (doc-0c-bo-docs.googleusercontent.com)... 142.251.36.1, 2a00:1450:400e:80f::2001
    zfs: Connecting to doc-0c-bo-docs.googleusercontent.com (doc-0c-bo-docs.googleusercontent.com)|142.251.36.1|:443... connected.
    zfs: HTTP request sent, awaiting response... 200 OK
    zfs: Length: 7275140 (6.9M) [application/x-gzip]
    zfs: Saving to: ‘task2.tar.gz’
    zfs: 
    zfs:      0K .......... .......... .......... .......... ..........  0%  255K 28s
    zfs:   7050K .......... .......... .......... .......... .......... 99% 15.6M 0s
    zfs:   7100K ....                                                  100% 8829G=4.1s
    zfs: 
    zfs: 2023-02-13 18:32:16 (1.71 MB/s) - ‘task2.tar.gz’ saved [7275140/7275140]
    zfs: zpoolexport/
    zfs: zpoolexport/filea
    zfs: zpoolexport/fileb
  ```
  
  ``` 
    zfs: Пробуем импортировать пул...
    zfs:    pool: otus
    zfs:      id: 6554193320433390805
    zfs:   state: ONLINE
    zfs:  action: The pool can be imported using its name or numeric identifier.
    zfs:  config:
    zfs: 
    zfs: 	otus                                 ONLINE
    zfs: 	  mirror-0                           ONLINE
    zfs: 	    /home/vagrant/zpoolexport/filea  ONLINE
    zfs: 	    /home/vagrant/zpoolexport/fileb  ONLINE
  ```
  
  ```
    zfs: Смонтируем.
    zfs: Общая информация
    zfs: -----------------------------------------------
    zfs: NAME   SIZE  ALLOC   FREE  CKPOINT  EXPANDSZ   FRAG    CAP  DEDUP    HEALTH  ALTROOT
    zfs: otus   480M  2.21M   478M        -         -     0%     0%  1.00x    ONLINE  -
    zfs: -----------------------------------------------
    zfs: NAME  PROPERTY    VALUE    SOURCE
    zfs: otus  recordsize  128K     local
    zfs: -----------------------------------------------
    zfs: NAME  PROPERTY     VALUE     SOURCE
    zfs: otus  compression  zle       local
    zfs: -----------------------------------------------
    zfs: NAME  PROPERTY  VALUE      SOURCE
    zfs: otus  checksum  sha256     local
    zfs: -----------------------------------------------
  ```
  #### Получаем характеристики pool’a
  ```
    zfs: Размер хранилища: 480M
    zfs: Тип пула: mirror
    zfs: Recordsize: 128K
    zfs: Compression: zle
    zfs: Checksum: sha256
 ```
 #### третья задача найти секретное сообщение
   ```
    zfs: -----------------------------------------------
    zfs: Найти сообщение от преподавателей
    zfs: 
    zfs: 
    zfs: Скачиваем файл..
    zfs: --2023-02-13 18:32:32--  https://drive.google.com/u/0/uc?id=1gH8gCL9y7Nd5Ti3IRmplZPF1XjzxeRAG
    zfs: Resolving drive.google.com (drive.google.com)... 172.217.218.194, 2a00:1450:400c:c00::c2
    zfs: Connecting to drive.google.com (drive.google.com)|172.217.218.194|:443... connected.
    zfs: HTTP request sent, awaiting response... 302 Found
    zfs: Location: https://drive.google.com/uc?id=1gH8gCL9y7Nd5Ti3IRmplZPF1XjzxeRAG [following]
    zfs: --2023-02-13 18:32:32--  https://drive.google.com/uc?id=1gH8gCL9y7Nd5Ti3IRmplZPF1XjzxeRAG
    zfs: Reusing existing connection to drive.google.com:443.
    zfs: HTTP request sent, awaiting response... 303 See Other
    zfs: Location: https://doc-00-bo-docs.googleusercontent.com/docs/securesc/ha0ro937gcuc7l7deffksulhg5h7mbp1/a9p6t41052buuc7ojeus5nlkmbr9papj/1676313150000/16189157874053420687/*/1gH8gCL9y7Nd5Ti3IRmplZPF1XjzxeRAG?uuid=bc20025d-e171-4c2d-bba3-28ade877c7ec [following]
    zfs: Warning: wildcards not supported in HTTP.
    zfs: --2023-02-13 18:32:36--  https://doc-00-bo-docs.googleusercontent.com/docs/securesc/ha0ro937gcuc7l7deffksulhg5h7mbp1/a9p6t41052buuc7ojeus5nlkmbr9papj/1676313150000/16189157874053420687/*/1gH8gCL9y7Nd5Ti3IRmplZPF1XjzxeRAG?uuid=bc20025d-e171-4c2d-bba3-28ade877c7ec
    zfs: Resolving doc-00-bo-docs.googleusercontent.com (doc-00-bo-docs.googleusercontent.com)... 142.250.186.65, 2a00:1450:4001:828::2001
    zfs: Connecting to doc-00-bo-docs.googleusercontent.com (doc-00-bo-docs.googleusercontent.com)|142.250.186.65|:443... connected.
    zfs: HTTP request sent, awaiting response... 200 OK
    zfs: Length: 5432736 (5.2M) [application/octet-stream]
    zfs: Saving to: ‘otus_task2.file’
    zfs: 
    zfs:      0K .......... .......... .......... .......... ..........  0%  272K 19s
    zfs:     50K .......... .......... .......... .......... ..........  1%  603K 14s
    zfs:   5250K .......... .......... .......... .......... .......... 99% 1.19M 0s
    zfs:   5300K .....                                                 100% 10312G=3.3s
    zfs: 
    zfs: 2023-02-13 18:32:40 (1.59 MB/s) - ‘otus_task2.file’ saved [5432736/5432736]
   ```      
   ```
    zfs: Восстановим полученный файл..
  cat otus_task2.file | sudo zfs recv -F mypool/task3
   ```
  
   ```
    zfs: Выведем сообщение из файла:
   cat `find /mypool/task3/ -name "secret_message"`
   ```
    
   ```
    zfs: https://github.com/sindresorhus/awesome
    zfs: < Все задания выполнены. Спасибо за проверку! >
    zfs:  -------------------
    zfs:    ''
    zfs:     ''
    zfs:         .--.
    zfs:        |o_o |
    zfs:        |:_/ |
    zfs:       //   ' '
    zfs:      (|     | )
    zfs: '    /'_   _/' '
    zfs: '    ''___)=(___/'
   ```
