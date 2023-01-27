# Домашнее задание 2 
###### - Добавить в Vagrantfile еще дисков;
###### - Сломать/починить raid;
###### - Собрать R0/R5/R10 - на выбор;
###### - Создать на рейде GPT раздел и 5 партиций.
###### В качестве проверки принимаются - измененный Vagrantfile, скрипт для создания рейда.
###### * Доп. задание - Vagrantfile, который сразу собирает систему с подключенным рейдом.

---

###### Использую Vagrantfile (без автоматической сборки RAID)
- [Vagrantfile, без автоматической сборки RAID](Vagrantfile)

###### Проверяю подключение новых дисков
```

[vagrant@otuslinux ~]$ sudo lshw -short |grep disk
/0/100/1.1/0.0.0    /dev/sda  disk        42GB VBOX HARDDISK
/0/100/d/0          /dev/sdb  disk        262MB VBOX HARDDISK
/0/100/d/1          /dev/sdc  disk        262MB VBOX HARDDISK
/0/100/d/2          /dev/sdd  disk        262MB VBOX HARDDISK
/0/100/d/3          /dev/sde  disk        262MB VBOX HARDDISK
/0/100/d/0.0.0      /dev/sdf  disk        262MB VBOX HARDDISK

[vagrant@otuslinux ~]$ sudo fdisk -l

Disk /dev/sdf: 262 MB, 262144000 bytes, 512000 sectors
Units = sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes


Disk /dev/sdd: 262 MB, 262144000 bytes, 512000 sectors
Units = sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes


Disk /dev/sdc: 262 MB, 262144000 bytes, 512000 sectors
Units = sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes


Disk /dev/sdb: 262 MB, 262144000 bytes, 512000 sectors
Units = sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes


Disk /dev/sde: 262 MB, 262144000 bytes, 512000 sectors
Units = sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes


Disk /dev/sda: 42.9 GB, 42949672960 bytes, 83886080 sectors
Units = sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disk label type: dos
Disk identifier: 0x0009ef1a

   Device Boot      Start         End      Blocks   Id  System
/dev/sda1   *        2048    83886079    41942016   83  Linux
[vagrant@otuslinux ~]$ lsblk
NAME   MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
sda      8:0    0   40G  0 disk 
`-sda1   8:1    0   40G  0 part /
sdb      8:16   0  250M  0 disk 
sdc      8:32   0  250M  0 disk 
sdd      8:48   0  250M  0 disk 
sde      8:64   0  250M  0 disk 
sdf      8:80   0  250M  0 disk 

```

###### Входим под root
```
sudo su
```

###### Зануляем суперблоки
```
[root@otuslinux ~]# mdadm --zero-superblock --force /dev/sd{b,c,d,e,f}
mdadm: Unrecognised md component device - /dev/sdb
mdadm: Unrecognised md component device - /dev/sdc
mdadm: Unrecognised md component device - /dev/sdd
mdadm: Unrecognised md component device - /dev/sde
mdadm: Unrecognised md component device - /dev/sdf
```

###### Создаем RAID
```
[root@otuslinux ~]# mdadm --create --verbose /dev/md0 -l 6 -n 5 /dev/sd{b,c,d,e,f}
mdadm: layout defaults to left-symmetric
mdadm: layout defaults to left-symmetric
mdadm: chunk size defaults to 512K
mdadm: size set to 253952K
mdadm: Defaulting to version 1.2 metadata
mdadm: array /dev/md0 started.
```

###### Проверка правильности сборки
```
[root@otuslinux ~]# cat /proc/mdstat
Personalities : [raid6] [raid5] [raid4] 
md0 : active raid6 sdf[4] sde[3] sdd[2] sdc[1] sdb[0]
      761856 blocks super 1.2 level 6, 512k chunk, algorithm 2 [5/5] [UUUUU]
      
unused devices: <none>

[root@otuslinux ~]# mdadm -D /dev/md0
/dev/md0:
           Version : 1.2
     Creation Time : Mon Jan 23 16:45:49 2023
        Raid Level : raid6
        Array Size : 761856 (744.00 MiB 780.14 MB)
     Used Dev Size : 253952 (248.00 MiB 260.05 MB)
      Raid Devices : 5
     Total Devices : 5
       Persistence : Superblock is persistent

       Update Time : Mon Jan 23 16:45:53 2023
             State : clean 
    Active Devices : 5
   Working Devices : 5
    Failed Devices : 0
     Spare Devices : 0

            Layout : left-symmetric
        Chunk Size : 512K

Consistency Policy : resync

              Name : otuslinux:0  (local to host otuslinux)
              UUID : 95b88be9:0d157255:8ecc299c:afbb70b7
            Events : 17

    Number   Major   Minor   RaidDevice State
       0       8       16        0      active sync   /dev/sdb
       1       8       32        1      active sync   /dev/sdc
       2       8       48        2      active sync   /dev/sdd
       3       8       64        3      active sync   /dev/sde
       4       8       80        4      active sync   /dev/sdf
       
```

###### Проверяю что массив появился в устройствах
```
[root@otuslinux ~]# lsblk
NAME   MAJ:MIN RM  SIZE RO TYPE  MOUNTPOINT
sda      8:0    0   40G  0 disk  
└─sda1   8:1    0   40G  0 part  /
sdb      8:16   0  250M  0 disk  
└─md0    9:0    0  744M  0 raid6 
sdc      8:32   0  250M  0 disk  
└─md0    9:0    0  744M  0 raid6 
sdd      8:48   0  250M  0 disk  
└─md0    9:0    0  744M  0 raid6 
sde      8:64   0  250M  0 disk  
└─md0    9:0    0  744M  0 raid6 
sdf      8:80   0  250M  0 disk  
└─md0    9:0    0  744M  0 raid6
```



###### Создание конфигурационного файла mdadm.conf
```
[root@otuslinux ~]# mkdir /etc/mdadm
[root@otuslinux ~]# echo "DEVICE partitions" > /etc/mdadm/mdadm.conf
[root@otuslinux ~]# mdadm --detail --scan --verbose | awk '/ARRAY/ {print}' >> /etc/mdadm/mdadm.conf
[root@otuslinux ~]# 
[root@otuslinux ~]# cat /etc/mdadm/mdadm.conf 
DEVICE partitions
ARRAY /dev/md0 level=raid6 num-devices=5 metadata=1.2 name=otuslinux:0 UUID=95b88be9:0d157255:8ecc299c:afbb70b7
```

###### Ломаем RAID
```
[root@otuslinux ~]# mdadm /dev/md0 --fail /dev/sdc
mdadm: set /dev/sdc faulty in /dev/md0
```

###### Проверяем что натворили
```
[root@otuslinux ~]# cat /proc/mdstat 
Personalities : [raid6] [raid5] [raid4] 
md0 : active raid6 sdf[4] sde[3] sdd[2] sdc[1](F) sdb[0]
 761856 blocks super 1.2 level 6, 512k chunk, algorithm 2 [5/4] [U_UUU]
      
```

```
[root@otuslinux ~]# mdadm -D /dev/md0
/dev/md0:
           Version : 1.2
     Creation Time : Mon Jan 23 16:45:49 2023
        Raid Level : raid6
        Array Size : 761856 (744.00 MiB 780.14 MB)
     Used Dev Size : 253952 (248.00 MiB 260.05 MB)
      Raid Devices : 5
     Total Devices : 5
       Persistence : Superblock is persistent

       Update Time : Tue Jan 24 13:37:30 2023
             State : clean, degraded 
    Active Devices : 4
   Working Devices : 4
    Failed Devices : 1
     Spare Devices : 0

            Layout : left-symmetric
        Chunk Size : 512K

Consistency Policy : resync

              Name : otuslinux:0  (local to host otuslinux)
              UUID : 95b88be9:0d157255:8ecc299c:afbb70b7
            Events : 19

    Number   Major   Minor   RaidDevice State
       0       8       16        0      active sync   /dev/sdb
       -       0        0        1      removed
       2       8       48        2      active sync   /dev/sdd
       3       8       64        3      active sync   /dev/sde
       4       8       80        4      active sync   /dev/sdf

       1       8       32        -      faulty   /dev/sdc
```

###### Удаляем "сломанный диск"
```
[root@otuslinux ~]# mdadm /dev/md0 --remove /dev/sdc
mdadm: hot removed /dev/sdc from /dev/md0
```
```
[root@otuslinux ~]# mdadm -D /dev/md0
/dev/md0:
           Version : 1.2
     Creation Time : Mon Jan 23 16:45:49 2023
        Raid Level : raid6
        Array Size : 761856 (744.00 MiB 780.14 MB)
     Used Dev Size : 253952 (248.00 MiB 260.05 MB)
      Raid Devices : 5
     Total Devices : 4
       Persistence : Superblock is persistent

       Update Time : Tue Jan 24 13:38:56 2023
             State : clean, degraded 
    Active Devices : 4
   Working Devices : 4
    Failed Devices : 0
     Spare Devices : 0

            Layout : left-symmetric
        Chunk Size : 512K

Consistency Policy : resync

              Name : otuslinux:0  (local to host otuslinux)
              UUID : 95b88be9:0d157255:8ecc299c:afbb70b7
            Events : 20

    Number   Major   Minor   RaidDevice State
       0       8       16        0      active sync   /dev/sdb
       -       0        0        1      removed
       2       8       48        2      active sync   /dev/sdd
       3       8       64        3      active sync   /dev/sde
       4       8       80        4      active sync   /dev/sdf
```

###### Вставляем новый диск
```
[root@otuslinux ~]# mdadm /dev/md0 --add /dev/sdc
mdadm: added /dev/sdc
```

###### Проверяем
```
[root@otuslinux ~]# cat /proc/mdstat 
Personalities : [raid6] [raid5] [raid4] 
md0 : active raid6 sdc[5] sdf[4] sde[3] sdd[2] sdb[0]
      761856 blocks super 1.2 level 6, 512k chunk, algorithm 2 [5/5] [UUUUU]
```




###### Создаем раздел GPT на RAID
```
[root@otuslinux ~]# parted -s /dev/md0 mklabel gpt
```

###### Размечаем диск
```
[root@otuslinux ~]# parted /dev/md0 mkpart primary ext4 0% 20%
Information: You may need to update /etc/fstab.
[root@otuslinux ~]# parted /dev/md0 mkpart primary ext4 20% 40%           
Information: You may need to update /etc/fstab.
[root@otuslinux ~]# parted /dev/md0 mkpart primary ext4 40% 60%       
Information: You may need to update /etc/fstab.
[root@otuslinux ~]# parted /dev/md0 mkpart primary ext4 60% 80%          
Information: You may need to update /etc/fstab.
[root@otuslinux ~]# parted /dev/md0 mkpart primary ext4 80% 100%         
Information: You may need to update /etc/fstab.
```

```

[root@otuslinux ~]# lsblk
NAME      MAJ:MIN RM   SIZE RO TYPE  MOUNTPOINT
sda         8:0    0    40G  0 disk  
└─sda1      8:1    0    40G  0 part  /
sdb         8:16   0   250M  0 disk  
└─md0       9:0    0   744M  0 raid6 
  ├─md0p1 259:0    0   147M  0 md    
  ├─md0p2 259:1    0 148.5M  0 md    
  ├─md0p3 259:2    0   150M  0 md    
  ├─md0p4 259:3    0 148.5M  0 md    
  └─md0p5 259:4    0   147M  0 md    
sdc         8:32   0   250M  0 disk  
└─md0       9:0    0   744M  0 raid6 
  ├─md0p1 259:0    0   147M  0 md    
  ├─md0p2 259:1    0 148.5M  0 md    
  ├─md0p3 259:2    0   150M  0 md    
  ├─md0p4 259:3    0 148.5M  0 md    
  └─md0p5 259:4    0   147M  0 md    
sdd         8:48   0   250M  0 disk  
└─md0       9:0    0   744M  0 raid6 
  ├─md0p1 259:0    0   147M  0 md    
  ├─md0p2 259:1    0 148.5M  0 md    
  ├─md0p3 259:2    0   150M  0 md    
  ├─md0p4 259:3    0 148.5M  0 md    
  └─md0p5 259:4    0   147M  0 md    
sde         8:64   0   250M  0 disk  
└─md0       9:0    0   744M  0 raid6 
  ├─md0p1 259:0    0   147M  0 md    
  ├─md0p2 259:1    0 148.5M  0 md    
  ├─md0p3 259:2    0   150M  0 md    
  ├─md0p4 259:3    0 148.5M  0 md    
  └─md0p5 259:4    0   147M  0 md    
sdf         8:80   0   250M  0 disk  
└─md0       9:0    0   744M  0 raid6 
  ├─md0p1 259:0    0   147M  0 md    
  ├─md0p2 259:1    0 148.5M  0 md    
  ├─md0p3 259:2    0   150M  0 md    
  ├─md0p4 259:3    0 148.5M  0 md    
  └─md0p5 259:4    0   147M  0 md   
```

###### Создаем файловую систему в разделах
```
[root@otuslinux ~]# for i in $(seq 1 5); do mkfs.ext4 /dev/md0p$i; done
mke2fs 1.42.9 (28-Dec-2013)
Filesystem label=
OS type: Linux
Block size=1024 (log=0)
Fragment size=1024 (log=0)
Stride=512 blocks, Stripe width=1536 blocks
37696 inodes, 150528 blocks
7526 blocks (5.00%) reserved for the super user
First data block=1
Maximum filesystem blocks=33816576
19 block groups
8192 blocks per group, 8192 fragments per group
1984 inodes per group
Superblock backups stored on blocks: 
	8193, 24577, 40961, 57345, 73729

Allocating group tables: done                            
Writing inode tables: done                            
Creating journal (4096 blocks): done
Writing superblocks and filesystem accounting information: done 

mke2fs 1.42.9 (28-Dec-2013)
Filesystem label=
OS type: Linux
Block size=1024 (log=0)
Fragment size=1024 (log=0)
Stride=512 blocks, Stripe width=1536 blocks
38152 inodes, 152064 blocks
7603 blocks (5.00%) reserved for the super user
First data block=1
Maximum filesystem blocks=33816576
19 block groups
8192 blocks per group, 8192 fragments per group
2008 inodes per group
Superblock backups stored on blocks: 
	8193, 24577, 40961, 57345, 73729

Allocating group tables: done                            
Writing inode tables: done                            
Creating journal (4096 blocks): done
Writing superblocks and filesystem accounting information: done 

mke2fs 1.42.9 (28-Dec-2013)
Filesystem label=
OS type: Linux
Block size=1024 (log=0)
Fragment size=1024 (log=0)
Stride=512 blocks, Stripe width=1536 blocks
38456 inodes, 153600 blocks
7680 blocks (5.00%) reserved for the super user
First data block=1
Maximum filesystem blocks=33816576
19 block groups
8192 blocks per group, 8192 fragments per group
2024 inodes per group
Superblock backups stored on blocks: 
	8193, 24577, 40961, 57345, 73729

Allocating group tables: done                            
Writing inode tables: done                            
Creating journal (4096 blocks): done
Writing superblocks and filesystem accounting information: done 

mke2fs 1.42.9 (28-Dec-2013)
Filesystem label=
OS type: Linux
Block size=1024 (log=0)
Fragment size=1024 (log=0)
Stride=512 blocks, Stripe width=1536 blocks
38152 inodes, 152064 blocks
7603 blocks (5.00%) reserved for the super user
First data block=1
Maximum filesystem blocks=33816576
19 block groups
8192 blocks per group, 8192 fragments per group
2008 inodes per group
Superblock backups stored on blocks: 
	8193, 24577, 40961, 57345, 73729

Allocating group tables: done                            
Writing inode tables: done                            
Creating journal (4096 blocks): done
Writing superblocks and filesystem accounting information: done 

mke2fs 1.42.9 (28-Dec-2013)
Filesystem label=
OS type: Linux
Block size=1024 (log=0)
Fragment size=1024 (log=0)
Stride=512 blocks, Stripe width=1536 blocks
37696 inodes, 150528 blocks
7526 blocks (5.00%) reserved for the super user
First data block=1
Maximum filesystem blocks=33816576
19 block groups
8192 blocks per group, 8192 fragments per group
1984 inodes per group
Superblock backups stored on blocks: 
	8193, 24577, 40961, 57345, 73729

Allocating group tables: done                            
Writing inode tables: done                            
Creating journal (4096 blocks): done
Writing superblocks and filesystem accounting information: done 
```

###### Монитруем
```
[root@otuslinux ~]# mkdir -p /raid/part{1,2,3,4,5}
[root@otuslinux ~]# for i in $(seq 1 5); do mount /dev/md0p$i /raid/part$i; done
```

```
[root@otuslinux ~]# lsblk
NAME      MAJ:MIN RM   SIZE RO TYPE  MOUNTPOINT
sda         8:0    0    40G  0 disk  
└─sda1      8:1    0    40G  0 part  /
sdb         8:16   0   250M  0 disk  
└─md0       9:0    0   744M  0 raid6 
  ├─md0p1 259:0    0   147M  0 md    /raid/part1
  ├─md0p2 259:1    0 148.5M  0 md    /raid/part2
  ├─md0p3 259:2    0   150M  0 md    /raid/part3
  ├─md0p4 259:3    0 148.5M  0 md    /raid/part4
  └─md0p5 259:4    0   147M  0 md    /raid/part5
sdc         8:32   0   250M  0 disk  
└─md0       9:0    0   744M  0 raid6 
  ├─md0p1 259:0    0   147M  0 md    /raid/part1
  ├─md0p2 259:1    0 148.5M  0 md    /raid/part2
  ├─md0p3 259:2    0   150M  0 md    /raid/part3
  ├─md0p4 259:3    0 148.5M  0 md    /raid/part4
  └─md0p5 259:4    0   147M  0 md    /raid/part5
sdd         8:48   0   250M  0 disk  
└─md0       9:0    0   744M  0 raid6 
  ├─md0p1 259:0    0   147M  0 md    /raid/part1
  ├─md0p2 259:1    0 148.5M  0 md    /raid/part2
  ├─md0p3 259:2    0   150M  0 md    /raid/part3
  ├─md0p4 259:3    0 148.5M  0 md    /raid/part4
  └─md0p5 259:4    0   147M  0 md    /raid/part5
sde         8:64   0   250M  0 disk  
└─md0       9:0    0   744M  0 raid6 
  ├─md0p1 259:0    0   147M  0 md    /raid/part1
  ├─md0p2 259:1    0 148.5M  0 md    /raid/part2
  ├─md0p3 259:2    0   150M  0 md    /raid/part3
  ├─md0p4 259:3    0 148.5M  0 md    /raid/part4
  └─md0p5 259:4    0   147M  0 md    /raid/part5
sdf         8:80   0   250M  0 disk  
└─md0       9:0    0   744M  0 raid6 
  ├─md0p1 259:0    0   147M  0 md    /raid/part1
  ├─md0p2 259:1    0 148.5M  0 md    /raid/part2
  ├─md0p3 259:2    0   150M  0 md    /raid/part3
  ├─md0p4 259:3    0 148.5M  0 md    /raid/part4
  └─md0p5 259:4    0   147M  0 md    /raid/part5
```

###### Заполняем fstab
```
[root@otuslinux ~]# cat /etc/fstab

#
# /etc/fstab
# Created by anaconda on Thu Apr 30 22:04:55 2020
#
# Accessible filesystems, by reference, are maintained under '/dev/disk'
# See man pages fstab(5), findfs(8), mount(8) and/or blkid(8) for more info
#
UUID=1c419d6c-5064-4a2b-953c-05b2c67edb15 /                       xfs     defaults        0 0
/swapfile none swap defaults 0 0
#VAGRANT-BEGIN
# The contents below are automatically generated by Vagrant. Do not modify.
#VAGRANT-EN
UUID=dad1d164-21c1-4fa5-8027-9f72a3056da7 /raid/part1	ext4	defaults 0 0 
UUID=a0198b27-3916-4c6b-af59-440dab1d8389 /raid/part2   ext4    defaults 0 0
UUID=bc7ac6f1-56db-4ba0-9a56-a069a46361b7 /raid/part3   ext4    defaults 0 0
UUID=baebdad9-8077-47cf-b921-0971ba44197a /raid/part4   ext4    defaults 0 0
UUID=63268fbf-2d54-4bde-8e9f-fc2372cee6cd /raid/part5   ext4    defaults 0 0
```

###### Создаем файлы в разделах
```
[root@otuslinux ~]# for i in $(seq 1 5); do touch /raid/part$i/file$i.txt; done
```



###### Перезагружаемся и проверяем всё ли работает
```
[root@otuslinux ~]# reboot
Connection to 127.0.0.1 closed by remote host.
vilotiv@vilotiv-leg:/vagrantVM/centos7$ vagrant ssh
Last login: Mon Jan 23 16:32:08 2023 from 10.0.2.2
[vagrant@otuslinux ~]$ lsblk
NAME      MAJ:MIN RM   SIZE RO TYPE  MOUNTPOINT
sda         8:0    0    40G  0 disk  
`-sda1      8:1    0    40G  0 part  /
sdb         8:16   0   250M  0 disk  
`-md0       9:0    0   744M  0 raid6 
  |-md0p1 259:0    0   147M  0 md    /raid/part1
  |-md0p2 259:1    0 148.5M  0 md    /raid/part2
  |-md0p3 259:2    0   150M  0 md    /raid/part3
  |-md0p4 259:3    0 148.5M  0 md    /raid/part4
  `-md0p5 259:4    0   147M  0 md    /raid/part5
sdc         8:32   0   250M  0 disk  
`-md0       9:0    0   744M  0 raid6 
  |-md0p1 259:0    0   147M  0 md    /raid/part1
  |-md0p2 259:1    0 148.5M  0 md    /raid/part2
  |-md0p3 259:2    0   150M  0 md    /raid/part3
  |-md0p4 259:3    0 148.5M  0 md    /raid/part4
  `-md0p5 259:4    0   147M  0 md    /raid/part5
sdd         8:48   0   250M  0 disk  
`-md0       9:0    0   744M  0 raid6 
  |-md0p1 259:0    0   147M  0 md    /raid/part1
  |-md0p2 259:1    0 148.5M  0 md    /raid/part2
  |-md0p3 259:2    0   150M  0 md    /raid/part3
  |-md0p4 259:3    0 148.5M  0 md    /raid/part4
  `-md0p5 259:4    0   147M  0 md    /raid/part5
sde         8:64   0   250M  0 disk  
`-md0       9:0    0   744M  0 raid6 
  |-md0p1 259:0    0   147M  0 md    /raid/part1
  |-md0p2 259:1    0 148.5M  0 md    /raid/part2
  |-md0p3 259:2    0   150M  0 md    /raid/part3
  |-md0p4 259:3    0 148.5M  0 md    /raid/part4
  `-md0p5 259:4    0   147M  0 md    /raid/part5
sdf         8:80   0   250M  0 disk  
`-md0       9:0    0   744M  0 raid6 
  |-md0p1 259:0    0   147M  0 md    /raid/part1
  |-md0p2 259:1    0 148.5M  0 md    /raid/part2
  |-md0p3 259:2    0   150M  0 md    /raid/part3
  |-md0p4 259:3    0 148.5M  0 md    /raid/part4
  `-md0p5 259:4    0   147M  0 md    /raid/part5
[vagrant@otuslinux ~]$ ls /raid/part
part1/ part2/ part3/ part4/ part5/ 
[vagrant@otuslinux ~]$ ls /raid/part2/
file2.txt  lost+found
```

### Файлы на месте. Данную часть ДЗ2 считаю выполненой. Был собран RAID, прописан mdadm.conf, сломан\починен RAID, созданы партиции, настроен /etc/fstab

---

# Использую Vagrantfile_autoRaid (с автоматической сборкой RAID1)
- [Vagrantfile, автоматическая сборка RAID1](Vagrantfile_autoRaid)

###### Проверяем ВМ после запуска
```
vagrant ssh
[vagrant@otuslinux ~]$ lsblk
NAME   MAJ:MIN RM  SIZE RO TYPE  MOUNTPOINT
sda      8:0    0   40G  0 disk  
`-sda1   8:1    0   40G  0 part  /
sdb      8:16   0  250M  0 disk  
`-md1    9:1    0  250M  0 raid1 
sdc      8:32   0  250M  0 disk  
`-md1    9:1    0  250M  0 raid1 
[vagrant@otuslinux ~]$ cat /proc/mdstat
Personalities : [raid1] 
md1 : active raid1 sdc[1] sdb[0]
      255936 blocks [2/2] [UU]
```

### В результате выполнения [Raid.sh](Raid.sh) при запуске [Vagrantfile](Vagrantfile_AutoRaid) был автоматически собран RAID1
