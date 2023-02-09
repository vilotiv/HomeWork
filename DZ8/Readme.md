#### Работа с загрузчиком
#### 1. Попасть в систему без пароля несколькими способами
#### 2. Установить систему с LVM, после чего переименовать VG
#### 3. Добавить модуль в initrd
#### 4(*). Сконфигурировать систему без отдельного раздела с /boot, а только с LVM
#### PV необходимо инициализировать с параметром --bootloaderareasize 1m

---

##### Получил доступ к системе двумя способами. Первый способ - использование командной строки при загрузке в grub. Попробовал на системе Alt Server 10.
##### 1) Перезагрузил ВМ, в Grub2 при окне выбора ядра нажал "е"
##### 2) В конце строки, начинающийся с "linux /vmlinuz ...", дописал init=/bin/bash
- [bin-bash.JPG]
##### 3) Нажал ctrl+x, подгрузилась система
- [bin-bash2.JPG]
##### 4) Примонтировал корневую файловую систему с правами на запись командой "mount -rw -o remount /"
##### 5) Командой passwd поменял пароль на root
- [bin-bash3.JPG]
##### 6) Проверил после перезагрузки, пароль успешно заменен
##### Прилагаю скриншоты из окна Proxmox в тексте выше

##### 
##### Второй способ с использованием Live CD. Использовал Live CD Rescue Alt, на Alt Server 10
##### 1) Загружаемся с СиДиРома
- [Rescue0.JPG]
##### 2) Смонтировал раздел в /mnt/system1/
- [Rescue1.JPG]
##### 3) chroot /mnt/system1/
##### 4) Командой passwd сменил пароль на root
- [Rescue2.JPG]
##### 5) Проверил после перезагрузки, пароль успешно заменен
##### Прилагаю скриншоты из окна Proxmox в тексте выше


---

##### Приступаю к 2 пункту ДЗ. Использовал тестовую ВМ, с готовым LVM.
##### Смотрим какой LVM присутствует в системе
```
[root@education-tst ~]# vgs
  VG #PV #LV #SN Attr   VSize   VFree
  vg   1   2   0 wz--n- <28,97g    0
```

##### Меняем название Volume Group.
```
[root@education-tst ~]# vgrename vg vg_newname
  Volume group "vg" successfully renamed to "vg_newname"
```

##### Перезагружаемся и проверям... иии упс, не загружается, граб не пересобрал после смены имени VG
##### Загрузился с лайвСД, сделал chroot и сделал grub-mkconfig -o /boot/grub/grub.cfg
- [renameVG.JPG]

##### Перезагружаемся и проверям
``` 
[root@education-tst ~]# vgs
  VG         #PV #LV #SN Attr   VSize   VFree
  vg_newname   1   2   0 wz--n- <28,97g    0
```
---
##### Приступаю к 3 части ДЗ. Ставим необходимые пакеты. 

```
[root@education-tst ~]# apt-get install dracut
Чтение списков пакетов... Завершено
Построение дерева зависимостей... Завершено
Следующие дополнительные пакеты будут установлены:
  hardlink pigz
Следующие НОВЫЕ пакеты будут установлены:
  dracut hardlink pigz
0 будет обновлено, 3 новых установлено, 0 пакетов будет удалено и 0 не будет обновлено.
Необходимо получить 459kB архивов.
После распаковки потребуется дополнительно 1382kB дискового пространства.
Продолжить? [Y/n] y
Получено: 1 http://asu-upd-alt branch/x86_64/classic pigz 2.6-alt1:sisyphus+279071.100.1.1@1626374685 [70,6kB]
Получено: 2 http://asu-upd-alt branch/x86_64/classic hardlink 2.38.1-alt1:p10+309135.100.3.1@1667910705 [77,2kB]
Получено: 3 http://asu-upd-alt branch/x86_64/classic dracut 055-alt3:p10+287028.500.5.1@1634828676 [311kB]
Получено 459kB за 0s (11,3MB/s).
Совершаем изменения...
Подготовка...                           ################################################################################# [100%]
Обновление / установка...
1: hardlink-2.38.1-alt1                 ################################################################################# [ 33%]
2: pigz-2.6-alt1                        ################################################################################# [ 67%]
3: dracut-055-alt3                      ################################################################################# [100%]
Завершено.
```
##### Но нет, на ОС Альт использовать dracut не получилось. там необходимо использовать дргуие механизмы, но т.к. у меня что то времени вообще нету, отложу эту ситуацию на потом, а пока добавлю модуль в Centos7 с помощью dracut

##### Тогда использовую `Vagrantfile`, для удобства добавлю свойство `vb.gui = true` после строки `box.vm.provider :virtualbox do |vb|`.

##### Скрипты модулей хранятся в каталоге `/usr/lib/dracut/modules.d/`. Для того чтобы добавить свой модуль создаем там папку с именем `01test`:

```
[root@localhost ~]# mkdir /usr/lib/dracut/modules.d/01test
```

##### В нее поместим два скрипта:

##### 1. /module-setup.sh - который устанавливает модуль и вызывает скрипт `test.sh`
```#!/bin/bash

check() {
    return 0
}

depends() {
    return 0
}

install() {
    inst_hook cleanup 00 "${moddir}/test.sh"
}
```
##### 2. [test.sh](/test.sh) - собственно сам вызываемый скрипт, в нём рисуется пингвинчик
```#!/bin/bash

exec 0<>/dev/console 1<>/dev/console 2<>/dev/console
cat <<'msgend'
Hello! You are in dracut module!
 ___________________
< I'm dracut module >
 -------------------
   \
    \
        .--.
       |o_o |
       |:_/ |
      //   \ \
     (|     | )
    /'\_   _/`\
    \___)=(___/
msgend
sleep 10
echo " continuing...."
```
##### Переходим в каталог и выставляем флаг для запуска `x`:

```bash
[root@localhost ~]# cd /usr/lib/dracut/modules.d/01test
[root@localhost 01test]# chmod a+x *
[root@localhost 01test]# ls -al
total 12
drwxr-xr-x.  2 root root   44 Sep 15 23:03 .
drwxr-xr-x. 52 root root 4096 Sep 15 22:58 ..
-rwxr-xr-x.  1 root root  111 Sep 15 23:03 module-setup.sh
-rwxr-xr-x.  1 root root  316 Sep 15 23:03 test.sh
```

##### Пересобираем образ `initrd`

```
[root@localhost 01test]# mkinitrd -f -v /boot/initramfs-$(uname -r).img $(uname -r)
Executing: /sbin/dracut -f -v /boot/initramfs-3.10.0-862.2.3.el7.x86_64.img 3.10.0-862.2.3.el7.x86_64
dracut module 'busybox' will not be installed, because command 'busybox' could not be found!
dracut module 'crypt' will not be installed, because command 'cryptsetup' could not be found!
dracut module 'dmraid' will not be installed, because command 'dmraid' could not be found!
dracut module 'dmsquash-live-ntfs' will not be installed, because command 'ntfs-3g' could not be found!
dracut module 'mdraid' will not be installed, because command 'mdadm' could not be found!
dracut module 'multipath' will not be installed, because command 'multipath' could not be found!
dracut module 'busybox' will not be installed, because command 'busybox' could not be found!
dracut module 'crypt' will not be installed, because command 'cryptsetup' could not be found!
dracut module 'dmraid' will not be installed, because command 'dmraid' could not be found!
dracut module 'dmsquash-live-ntfs' will not be installed, because command 'ntfs-3g' could not be found!
dracut module 'mdraid' will not be installed, because command 'mdadm' could not be found!
dracut module 'multipath' will not be installed, because command 'multipath' could not be found!
*** Including module: bash ***
*** Including module: test ***
*** Including module: nss-softokn ***
*** Including module: i18n ***
*** Including module: drm ***
*** Including module: plymouth ***
*** Including module: dm ***
Skipping udev rule: 64-device-mapper.rules
Skipping udev rule: 60-persistent-storage-dm.rules
Skipping udev rule: 55-dm.rules
*** Including module: kernel-modules ***
Omitting driver floppy
*** Including module: lvm ***
Skipping udev rule: 64-device-mapper.rules
Skipping udev rule: 56-lvm.rules
Skipping udev rule: 60-persistent-storage-lvm.rules
*** Including module: qemu ***
*** Including module: resume ***
*** Including module: rootfs-block ***
*** Including module: terminfo ***
*** Including module: udev-rules ***
Skipping udev rule: 40-redhat-cpu-hotplug.rules
Skipping udev rule: 91-permissions.rules
*** Including module: biosdevname ***
*** Including module: systemd ***
*** Including module: usrmount ***
*** Including module: base ***
*** Including module: fs-lib ***
*** Including module: shutdown ***
*** Including modules done ***
*** Installing kernel module dependencies and firmware ***
*** Installing kernel module dependencies and firmware done ***
*** Resolving executable dependencies ***
*** Resolving executable dependencies done***
*** Hardlinking files ***
*** Hardlinking files done ***
*** Stripping files ***
*** Stripping files done ***
*** Generating early-microcode cpio image contents ***
*** No early-microcode cpio image needed ***
*** Store current command line parameters ***
*** Creating image file ***
*** Creating image file done ***
*** Creating initramfs image file '/boot/initramfs-3.10.0-862.2.3.el7.x86_64.img' done ***
```

##### или

```[root@localhost 01test]# dracut -f```

##### Можно проверить/посмотреть какие модули загружены в образ:

```
[root@localhost 01test]# lsinitrd -m /boot/initramfs-$(uname -r).img | grep test
test
```

##### После чего можно пойти двумя путями для проверки:
	* Перезагрузиться и руками выключить опции `rghb` и `quiet` и увидеть вывод
	* Либо отредактировать `grub.cfg` убрав эти опции

##### В итоге при загрузке будет пауза на 10 секунд и вы увидите пингвина в выводе терминала

- [ScreenshotSracut]

---

##### Приступаю к заданию со звездой (Переустановил VM, в Vagrantfile добавил HDD).

##### Смотрим какие разделы у нас есть
```
[root@localhost vagrant]# lsblk
NAME                    MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
sda                       8:0    0   40G  0 disk
├─sda1                    8:1    0    1M  0 part
├─sda2                    8:2    0    1G  0 part /boot
└─sda3                    8:3    0   39G  0 part
  ├─vg-LogVol00 253:0    0 37.5G  0 lvm  /
  └─vg-LogVol01 253:1    0  1.5G  0 lvm  [SWAP]
sdb                       8:16   0   10G  0 disk
```
##### Видим что boot находится на отдельном разделе sda2, корень и swap на VG.

##### Далее планировал установить пропатченный граб https://yum.rumyantsev.com/centos/7/x86_64/ ... но нет, ссылка битая... как быть?
