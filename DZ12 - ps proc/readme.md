## Что нужно было сделать?

### написать свою реализацию ps ax используя анализ /proc
### Результат ДЗ - рабочий скрипт который можно запустить

------

##### для начала рассмотрим вывод команды ``ps ax``.
В выводе получим несколько столбцов:
- PID - TTY - STAT - TIME - COMMAND

##### Разберемся откуда берутся данные у процессов
``strace -e openat ps ax``

часть вывода:
```
5698 pts/1    S+     0:00 sudo tail -f /var/log/Xorg.0.log
openat(AT_FDCWD, "/proc/5700/stat", O_RDONLY|O_LARGEFILE) = 6
openat(AT_FDCWD, "/proc/5700/status", O_RDONLY|O_LARGEFILE) = 6
openat(AT_FDCWD, "/proc/5700/cmdline", O_RDONLY|O_LARGEFILE) = 6
 5700 pts/1    S+     0:00 tail -f /var/log/Xorg.0.log
openat(AT_FDCWD, "/proc/5839/stat", O_RDONLY|O_LARGEFILE) = 6
openat(AT_FDCWD, "/proc/5839/status", O_RDONLY|O_LARGEFILE) = 6
openat(AT_FDCWD, "/proc/5839/cmdline", O_RDONLY|O_LARGEFILE) = 6
```
Если посмотреть содержимое файла ``/proc/5698/stat``  
Получим любопытные данные:
```
[root@host-15 ~]# cat /proc/5698/stat
5698 (sudo) S 5351 5698 5351 34817 5698 4194560 341 83 0 0 0 0 0 0 20 0 1 0 367750 8544256 1036 4294967295 4435968 4621096 3213206560 0 0 0 0 0 134969863 1 0 0 17 1 0 0 0 0 0 4748280 4755104 11816960 3213208088 3213208121 3213208121 3213209582 0
```
Man по proc вносит ясность в содержимое данного файла: ``man 5 proc``

pid (поле 1), state (поле 3), tty_nr (поле 7), utime (поле 14), stime (поле 15)  

-----

Находим **PID** используя команду ``cat /proc/5698/stat | awk '{ print $1 }'``

Находим **TTY** используя комманду ``sudo ls -l /proc/5698/fd | head -n2 | tail -n1 | sed 's%.*/dev/%%'``

Находим **STAT** используя команду ``cat /proc/5698/stat | awk '{ print $3 }'``

Находим **TIME** используя поля **UTIME** (Количество времени, которые данный процесс  провел в режиме пользователя) и **STIME** (Количество времени, которые данный процесс  провел в режиме ядра) сложив их и поделить их на значение переменной ядра **CLK_TCK**. Переменную CLK_TCK можно узнать командой ``getconf CLK_TCK``.

Находим **COMMAND** используя команду ``cat /proc/5698/cmdline | strings -n 1 | tr '\n' ' '``

Находим все пиды процессов с директории /proc используя команду ``ls -l /proc | awk '{ print $9 }' | grep -Eo '[0-9]{1,5}'| sort -n``  
Из вывода ``ls -l`` отбираем только 9 поле с наименованием и оттуда отбираем только наименования из цифр.

В результате будут такие выводы:
```
[root@host-15 ~]# cat /proc/5698/stat | awk '{ print $1 }'
5698
[root@host-15 ~]# sudo ls -l /proc/5698/fd | head -n2 | tail -n1 | sed 's%.*/dev/%%'
pts/1
[root@host-15 ~]# cat /proc/5698/stat | awk '{ print $3 }'
S
[root@host-15 ~]# UTIMEV=`cat /proc/5698/stat | awk '{ print $14 }'`
[root@host-15 ~]# STIMEV=`cat /proc/5698/stat | awk '{ print $15 }'`
[root@host-15 ~]# CLKTCK=`getconf CLK_TCK`
[root@host-15 ~]# FULLTIME=$((UTIMEV+STIMEV))
[root@host-15 ~]# CPUTIME=$((FULLTIME/CLKTCK))
[root@host-15 ~]# date -u -d @${CPUTIME} +"%T"
00:00:00
[root@host-15 ~]# cat /proc/5698/cmdline | strings -n 1 | tr '\n' ' '
sudo tail -f /var/log/Xorg.0.log 
```
Теперь наберем из данных команд башскрипт и проверим
<details>
<summary>
 вот что показывает ps ax
</summary>

  ```bash
[root@host-15 ~]# ps ax
  PID TTY      STAT   TIME COMMAND
    1 ?        Ss     0:04 /sbin/init splash
    2 ?        S      0:00 [kthreadd]
    3 ?        I<     0:00 [rcu_gp]
    4 ?        I<     0:00 [rcu_par_gp]
    6 ?        I<     0:00 [kworker/0:0H-events_highpri]
    8 ?        I<     0:00 [mm_percpu_wq]
    9 ?        S      0:00 [rcu_tasks_kthre]
   10 ?        S      0:00 [rcu_tasks_rude_]
   11 ?        S      0:00 [rcu_tasks_trace]
   12 ?        S      0:00 [ksoftirqd/0]
   13 ?        I      0:01 [rcu_sched]
   14 ?        S      0:00 [migration/0]
   16 ?        S      0:00 [cpuhp/0]
   17 ?        S      0:00 [cpuhp/1]
   18 ?        S      0:00 [migration/1]
   19 ?        S      0:00 [ksoftirqd/1]
   21 ?        I<     0:00 [kworker/1:0H-events_highpri]
   22 ?        S      0:00 [kdevtmpfs]
   23 ?        I<     0:00 [netns]
   24 ?        S      0:00 [kauditd]
   25 ?        S      0:00 [khungtaskd]
   26 ?        S      0:00 [oom_reaper]
   27 ?        I<     0:00 [writeback]
   28 ?        S      0:00 [kcompactd0]
   29 ?        SN     0:00 [ksmd]
   30 ?        SN     0:00 [khugepaged]
   74 ?        I<     0:00 [kintegrityd]
   75 ?        I<     0:00 [kblockd]
   76 ?        I<     0:00 [blkcg_punt_bio]
   77 ?        I<     0:00 [tpm_dev_wq]
   78 ?        I<     0:00 [md]
   79 ?        I<     0:00 [edac-poller]
   80 ?        I<     0:00 [devfreq_wq]
   81 ?        S      0:00 [watchdogd]
   83 ?        I<     0:02 [kworker/1:1H-kblockd]
   84 ?        S      0:00 [kswapd0]
   86 ?        I<     0:00 [kthrotld]
   87 ?        I<     0:00 [nvme-wq]
   88 ?        I<     0:00 [nvme-reset-wq]
   89 ?        I<     0:00 [nvme-delete-wq]
   90 ?        I<     0:00 [ipv6_addrconf]
   91 ?        I<     0:00 [kstrp]
   94 ?        I<     0:00 [zswap-shrink]
   95 ?        I<     0:00 [kworker/u5:0]
  101 ?        I<     0:00 [charger_manager]
  299 ?        I<     0:03 [kworker/0:1H-kblockd]
  348 ?        I<     0:00 [ata_sff]
  375 ?        S      0:00 [scsi_eh_0]
  378 ?        I<     0:00 [scsi_tmf_0]
  719 ?        S      0:00 [irq/18-vmwgfx]
  727 ?        I<     0:00 [ttm_swap]
  732 ?        S      0:00 [card0-crtc0]
  741 ?        S      0:00 [card0-crtc1]
  749 ?        S      0:00 [card0-crtc2]
  757 ?        S      0:00 [card0-crtc3]
  764 ?        S      0:00 [card0-crtc4]
  769 ?        S      0:00 [card0-crtc5]
  777 ?        S      0:00 [card0-crtc6]
  781 ?        S      0:00 [card0-crtc7]
 1862 ?        S      0:00 [jbd2/sda2-8]
 1863 ?        I<     0:00 [ext4-rsv-conver]
 2244 ?        Ss     0:01 /lib/systemd/systemd-journald
 2271 ?        Ss     0:00 /lib/systemd/systemd-udevd
 2274 ?        Ss     0:00 /lib/systemd/systemd-userdbd
 2297 ?        S      0:00 [scsi_eh_1]
 2298 ?        I<     0:00 [scsi_tmf_1]
 2299 ?        S      0:00 [scsi_eh_2]
 2300 ?        I<     0:00 [scsi_tmf_2]
 2303 ?        I<     0:00 [cryptd]
 2353 ?        Ssl    0:00 /usr/libexec/accounts-daemon
 2355 ?        Ss     0:00 avahi-daemon: running [host-15.local]
 2358 ?        Ss     0:00 /bin/dbus-daemon --system --address=systemd: --nofork --nopidfile --systemd-activation --syslog-only
 2360 ?        Ssl    0:00 /usr/libexec/polkit-1/polkitd --no-debug
 2361 ?        Ss     0:00 /lib/systemd/systemd-logind
 2362 ?        Ssl    0:00 /usr/libexec/udisks2/udisksd
 2367 ?        Ssl    0:00 /usr/libexec/upower/upowerd
 2373 ?        S      0:00 avahi-daemon: chroot helper
 2419 ?        S      0:00 /usr/sbin/chronyd
 2452 ?        Ssl    0:00 /usr/sbin/NetworkManager --no-daemon
 2455 ?        Ssl    0:00 /usr/sbin/ModemManager
 2460 ?        Ss     0:00 /usr/sbin/cupsd -l
 2463 ?        Ss     0:00 /usr/sbin/crond -n
 2466 ?        SLsl   0:00 /usr/sbin/lightdm
 2487 tty1     Ssl+   0:51 X -nolisten tcp :0 -seat seat0 -auth /run/lightdm/root/:0 -nolisten tcp vt1 -novtswitch
 2490 ?        Ssl    0:00 /usr/libexec/colord
 2719 ?        Ssl    0:00 /usr/sbin/cups-browsed
 2798 ?        S      0:00 /usr/sbin/nmbd --no-process-group
 2803 ?        S      0:00 /usr/sbin/smbd --no-process-group
 2805 ?        S      0:00 /usr/sbin/smbd --no-process-group
 2806 ?        S      0:00 /usr/sbin/smbd --no-process-group
 2846 ?        Sl     0:00 lightdm --session-child 12 19
 3141 ?        Ss     0:00 /lib/systemd/systemd --user
 3143 ?        S      0:00 (sd-pam)
 3150 ?        Ssl    0:00 /usr/bin/pulseaudio --daemonize=no --log-target=journal
 3152 ?        Ssl    0:00 xfce4-session
 3153 ?        Ss     0:01 /bin/dbus-daemon --session --address=systemd: --nofork --nopidfile --systemd-activation --syslog-only
 3200 ?        Ss     0:00 ssh-agent -u
 3220 ?        S      0:00 /usr/bin/VBoxClient --clipboard
 3221 ?        Sl     0:00 /usr/bin/VBoxClient --clipboard
 3233 ?        S      0:00 /usr/bin/VBoxClient --seamless
 3234 ?        Sl     0:00 /usr/bin/VBoxClient --seamless
 3243 ?        S      0:00 /usr/bin/VBoxClient --draganddrop
 3244 ?        Sl     0:25 /usr/bin/VBoxClient --draganddrop
 3249 ?        S      0:00 /usr/bin/VBoxClient --vmsvga
 3297 ?        Sl     0:00 /usr/lib/xfce4/xfconf/xfconfd
 3304 ?        Ssl    0:00 /usr/libexec/gvfs/gvfsd
 3309 ?        Sl     0:00 /usr/libexec/gvfs/gvfsd-fuse /run/user/500/gvfs -f
 3311 ?        Ssl    0:00 /usr/libexec/at-spi-bus-launcher
 3317 ?        S      0:00 /bin/dbus-daemon --config-file=/usr/share/defaults/at-spi2/accessibility.conf --nofork --print-address 3
 3325 ?        Sl     0:00 /usr/libexec/at-spi2-registryd --use-gnome-session
 3327 ?        Sl     0:00 /usr/bin/xfce4-screensaver
 3338 ?        SLs    0:00 /usr/bin/gpg-agent --supervised
 3340 ?        Sl     0:01 xfwm4
 3346 ?        Sl     0:00 xfsettingsd
 3349 ?        Sl     0:00 xfce4-panel
 3353 ?        Sl     0:00 Thunar --daemon
 3358 ?        Sl     0:01 xfdesktop
 3359 ?        Sl     0:01 /usr/lib/xfce4/panel/wrapper-2.0 /usr/lib/xfce4/panel/plugins/libwhiskermenu.so 13 25165831 whiskermenu Меню Whiske
 3364 ?        Sl     0:00 /usr/lib/xfce4/panel/wrapper-2.0 /usr/lib/xfce4/panel/plugins/libxkb.so 1 25165833 xkb Раскладки клавиатуры Настрой
 3365 ?        Sl     0:00 /usr/lib/xfce4/panel/wrapper-2.0 /usr/lib/xfce4/panel/plugins/libsystray.so 9 25165834 systray Модуль статусного тр
 3366 ?        Sl     0:03 /usr/lib/xfce4/panel/wrapper-2.0 /usr/lib/xfce4/panel/plugins/libpulseaudio-plugin.so 11 25165835 pulseaudio Модуль
 3367 ?        Sl     0:00 /usr/lib/xfce4/panel/wrapper-2.0 /usr/lib/xfce4/panel/plugins/libdatetime.so 8 25165836 datetime Дата и время Отобр
 3368 ?        Sl     0:00 /usr/lib/xfce4/panel/wrapper-2.0 /usr/lib/xfce4/panel/plugins/libplaces.so 16 25165837 places Переход Предоставляет
 3369 ?        Sl     0:00 /usr/lib/xfce4/panel/wrapper-2.0 /usr/lib/xfce4/panel/plugins/libactions.so 14 25165838 actions Системные действия 
 3387 ?        Ssl    0:00 /usr/lib/xfce4/notifyd/xfce4-notifyd
 3395 ?        Ssl    0:00 /usr/libexec/gvfs/gvfs-udisks2-volume-monitor
 3400 ?        Sl     0:00 /usr/libexec/polkit-1/polkit-gnome-authentication-agent-1
 3403 ?        Sl     0:00 blueberry-obex-agent
 3405 ?        Ssl    0:00 /usr/libexec/gvfs/gvfs-afc-volume-monitor
 3412 ?        S      0:00 /usr/bin/python3 /usr/share/system-config-printer/applet.py
 3419 ?        Ssl    0:00 /usr/libexec/gvfs/gvfs-goa-volume-monitor
 3423 ?        Sl     0:00 /usr/libexec/goa-daemon
 3424 ?        Sl     0:00 xfce4-power-manager
 3434 ?        Sl     0:00 nm-applet
 3437 ?        Sl     0:00 apt-indicator --autostarted
 3448 ?        Sl     0:00 /usr/libexec/goa-identity-service
 3454 ?        Ssl    0:00 /usr/libexec/gvfs/gvfs-gphoto2-volume-monitor
 3463 ?        Ssl    0:00 /usr/libexec/gvfs/gvfs-mtp-volume-monitor
 3506 ?        Sl     0:00 /usr/libexec/gvfs/gvfsd-trash --spawner :1.7 /org/gtk/gvfs/exec_spaw/0
 3535 ?        Ss     0:00 /usr/libexec/bluetooth/obexd
 3646 ?        Sl     0:31 /usr/bin/xfce4-terminal
 3685 pts/0    Ss     0:00 bash
 3700 pts/0    S      0:00 sudo -i
 3709 pts/0    S+     0:00 -bash
 5062 ?        I      0:00 [kworker/1:0-events]
 5351 pts/1    Ss     0:00 bash
 5482 pts/2    Ss     0:00 bash
 5486 pts/2    S      0:00 sudo -i
 5492 pts/2    S      0:00 -bash
 5698 pts/1    S+     0:00 sudo tail -f /var/log/Xorg.0.log
 5700 pts/1    S+     0:00 tail -f /var/log/Xorg.0.log
 5839 pts/3    Ss     0:00 bash
 5843 pts/3    S      0:00 sudo -i
 5845 pts/3    S+     0:00 -bash
 6287 ?        I      0:00 [kworker/1:1]
 6310 ?        I      0:01 [kworker/0:1-events]
10843 ?        I      0:00 [kworker/u4:2-events_unbound]
20311 ?        I      0:00 [kworker/0:0-ata_sff]
20331 ?        I      0:00 [kworker/u4:3-events_unbound]
20460 ?        I      0:00 [kworker/0:2-ata_sff]
20485 ?        I      0:00 [kworker/u4:0-flush-8:0]
24535 ?        S      0:00 systemd-userwork: waiting...
24636 ?        S      0:00 systemd-userwork: waiting...
24749 ?        S      0:00 systemd-userwork: waiting...
24851 pts/2    R+     0:00 ps ax

```
  
</details>

<details>
<summary>
Вот результат свеженаписанного скрипта
</summary>
  
 ```bash
 [root@host-15 ~]# ./psax.sh
PID     TTY     STAT     TIME     COMMAND
1     ?     S     00:00:04     /sbin/init splash 
2     ?     S     00:00:00     (kthreadd)
3     ?     I     00:00:00     (rcu_gp)
4     ?     I     00:00:00     (rcu_par_gp)
6     ?     I     00:00:00     (kworker/0:0H-events_highpri)
8     ?     I     00:00:00     (mm_percpu_wq)
9     ?     S     00:00:00     (rcu_tasks_kthre)
10     ?     S     00:00:00     (rcu_tasks_rude_)
11     ?     S     00:00:00     (rcu_tasks_trace)
12     ?     S     00:00:00     (ksoftirqd/0)
13     ?     I     00:00:01     (rcu_sched)
14     ?     S     00:00:00     (migration/0)
16     ?     S     00:00:00     (cpuhp/0)
17     ?     S     00:00:00     (cpuhp/1)
18     ?     S     00:00:00     (migration/1)
19     ?     S     00:00:00     (ksoftirqd/1)
21     ?     I     00:00:00     (kworker/1:0H-events_highpri)
22     ?     S     00:00:00     (kdevtmpfs)
23     ?     I     00:00:00     (netns)
24     ?     S     00:00:00     (kauditd)
25     ?     S     00:00:00     (khungtaskd)
26     ?     S     00:00:00     (oom_reaper)
27     ?     I     00:00:00     (writeback)
28     ?     S     00:00:00     (kcompactd0)
29     ?     S     00:00:00     (ksmd)
30     ?     S     00:00:00     (khugepaged)
74     ?     I     00:00:00     (kintegrityd)
75     ?     I     00:00:00     (kblockd)
76     ?     I     00:00:00     (blkcg_punt_bio)
77     ?     I     00:00:00     (tpm_dev_wq)
78     ?     I     00:00:00     (md)
79     ?     I     00:00:00     (edac-poller)
80     ?     I     00:00:00     (devfreq_wq)
81     ?     S     00:00:00     (watchdogd)
83     ?     I     00:00:02     (kworker/1:1H-kblockd)
84     ?     S     00:00:00     (kswapd0)
86     ?     I     00:00:00     (kthrotld)
87     ?     I     00:00:00     (nvme-wq)
88     ?     I     00:00:00     (nvme-reset-wq)
89     ?     I     00:00:00     (nvme-delete-wq)
90     ?     I     00:00:00     (ipv6_addrconf)
91     ?     I     00:00:00     (kstrp)
94     ?     I     00:00:00     (zswap-shrink)
95     ?     I     00:00:00     (kworker/u5:0)
101     ?     I     00:00:00     (charger_manager)
299     ?     I     00:00:03     (kworker/0:1H-kblockd)
348     ?     I     00:00:00     (ata_sff)
375     ?     S     00:00:00     (scsi_eh_0)
378     ?     I     00:00:00     (scsi_tmf_0)
719     ?     S     00:00:00     (irq/18-vmwgfx)
727     ?     I     00:00:00     (ttm_swap)
732     ?     S     00:00:00     (card0-crtc0)
741     ?     S     00:00:00     (card0-crtc1)
749     ?     S     00:00:00     (card0-crtc2)
757     ?     S     00:00:00     (card0-crtc3)
764     ?     S     00:00:00     (card0-crtc4)
769     ?     S     00:00:00     (card0-crtc5)
777     ?     S     00:00:00     (card0-crtc6)
781     ?     S     00:00:00     (card0-crtc7)
1862     ?     S     00:00:00     (jbd2/sda2-8)
1863     ?     I     00:00:00     (ext4-rsv-conver)
2244     ?     S     00:00:01     /lib/systemd/systemd-journald 
2271     ?     S     00:00:00     /lib/systemd/systemd-udevd 
2274     ?     S     00:00:00     /lib/systemd/systemd-userdbd 
2297     ?     S     00:00:00     (scsi_eh_1)
2298     ?     I     00:00:00     (scsi_tmf_1)
2299     ?     S     00:00:00     (scsi_eh_2)
2300     ?     I     00:00:00     (scsi_tmf_2)
2303     ?     I     00:00:00     (cryptd)
2353     ?     S     00:00:00     /usr/libexec/accounts-daemon 
2355     ?     S     00:00:00     avahi-daemon: running [host-15.local] 
2358     ?     S     00:00:00     /bin/dbus-daemon --system --address=systemd: --nofork --nopidfile --systemd-activation --syslog-only 
2360     ?     S     00:00:00     /usr/libexec/polkit-1/polkitd --no-debug 
2361     ?     S     00:00:00     /lib/systemd/systemd-logind 
2362     ?     S     00:00:00     /usr/libexec/udisks2/udisksd 
2367     ?     S     00:00:00     /usr/libexec/upower/upowerd 
2373     ?     S     00:00:00     avahi-daemon: chroot helper 
2419     ?     S     00:00:00     /usr/sbin/chronyd 
2452     ?     S     00:00:00     /usr/sbin/NetworkManager --no-daemon 
2455     ?     S     00:00:00     /usr/sbin/ModemManager 
2460     ?     S     00:00:00     /usr/sbin/cupsd -l 
2463     ?     S     00:00:00     /usr/sbin/crond -n 
2466     ?     S     00:00:00     /usr/sbin/lightdm 
2487     ?     S     00:00:51     X -nolisten tcp :0 -seat seat0 -auth /run/lightdm/root/:0 -nolisten tcp vt1 -novtswitch 
2490     ?     S     00:00:00     /usr/libexec/colord 
2719     ?     S     00:00:00     /usr/sbin/cups-browsed 
2798     ?     S     00:00:00     /usr/sbin/nmbd --no-process-group 
2803     ?     S     00:00:00     /usr/sbin/smbd --no-process-group 
2805     ?     S     00:00:00     /usr/sbin/smbd --no-process-group 
2806     ?     S     00:00:00     /usr/sbin/smbd --no-process-group 
2846     ?     S     00:00:00     lightdm --session-child 12 19 
3141     ?     S     00:00:00     /lib/systemd/systemd --user 
3143     ?     S     00:00:00     (sd-pam) 
3150     ?     S     00:00:00     /usr/bin/pulseaudio --daemonize=no --log-target=journal 
3152     ?     S     00:00:00     xfce4-session 
3153     ?     S     00:00:01     /bin/dbus-daemon --session --address=systemd: --nofork --nopidfile --systemd-activation --syslog-only 
3200     ?     S     00:00:00     ssh-agent -u 
3220     ?     S     00:00:00     /usr/bin/VBoxClient --clipboard 
3221     ?     S     00:00:00     /usr/bin/VBoxClient --clipboard 
3233     ?     S     00:00:00     /usr/bin/VBoxClient --seamless 
3234     ?     S     00:00:00     /usr/bin/VBoxClient --seamless 
3243     ?     S     00:00:00     /usr/bin/VBoxClient --draganddrop 
3244     ?     S     00:00:25     /usr/bin/VBoxClient --draganddrop 
3249     ?     S     00:00:00     /usr/bin/VBoxClient --vmsvga 
3297     ?     S     00:00:00     /usr/lib/xfce4/xfconf/xfconfd 
3304     ?     S     00:00:00     /usr/libexec/gvfs/gvfsd 
3309     ?     S     00:00:00     /usr/libexec/gvfs/gvfsd-fuse /run/user/500/gvfs -f 
3311     ?     S     00:00:00     /usr/libexec/at-spi-bus-launcher 
3317     ?     S     00:00:00     /bin/dbus-daemon --config-file=/usr/share/defaults/at-spi2/accessibility.conf --nofork --print-address 3 
3325     ?     S     00:00:00     /usr/libexec/at-spi2-registryd --use-gnome-session 
3327     ?     S     00:00:00     /usr/bin/xfce4-screensaver 
3338     ?     S     00:00:00     /usr/bin/gpg-agent --supervised 
3340     ?     S     00:00:01     xfwm4 
3346     ?     S     00:00:00     xfsettingsd 
3349     ?     S     00:00:00     xfce4-panel 
3353     ?     S     00:00:00     Thunar --daemon 
3358     ?     S     00:00:01     xfdesktop 
3359     ?     S     00:00:01     /usr/lib/xfce4/panel/wrapper-2.0 /usr/lib/xfce4/panel/plugins/libwhiskermenu.so 13 25165831 whiskermenu  Whisker               
3364     ?     S     00:00:00     /usr/lib/xfce4/panel/wrapper-2.0 /usr/lib/xfce4/panel/plugins/libxkb.so 1 25165833 xkb           
3365     ?     S     00:00:00     /usr/lib/xfce4/panel/wrapper-2.0 /usr/lib/xfce4/panel/plugins/libsystray.so 9 25165834 systray              (   )          
3366     ?     S     00:00:03     /usr/lib/xfce4/panel/wrapper-2.0 /usr/lib/xfce4/panel/plugins/libpulseaudio-plugin.so 11 25165835 pulseaudio  PulseAudio        PulseAudio 
3367     ?     S     00:00:00     /usr/lib/xfce4/panel/wrapper-2.0 /usr/lib/xfce4/panel/plugins/libdatetime.so 8 25165836 datetime               ,      
3368     ?     S     00:00:00     /usr/lib/xfce4/panel/wrapper-2.0 /usr/lib/xfce4/panel/plugins/libplaces.so 16 25165837 places         ,        
3369     ?     S     00:00:00     /usr/lib/xfce4/panel/wrapper-2.0 /usr/lib/xfce4/panel/plugins/libactions.so 14 25165838 actions     ,            
3387     ?     S     00:00:00     /usr/lib/xfce4/notifyd/xfce4-notifyd 
3395     ?     S     00:00:00     /usr/libexec/gvfs/gvfs-udisks2-volume-monitor 
3400     ?     S     00:00:00     /usr/libexec/polkit-1/polkit-gnome-authentication-agent-1 
3403     ?     S     00:00:00     blueberry-obex-agent 
3405     ?     S     00:00:00     /usr/libexec/gvfs/gvfs-afc-volume-monitor 
3412     ?     S     00:00:00     /usr/bin/python3 /usr/share/system-config-printer/applet.py 
3419     ?     S     00:00:00     /usr/libexec/gvfs/gvfs-goa-volume-monitor 
3423     ?     S     00:00:00     /usr/libexec/goa-daemon 
3424     ?     S     00:00:00     xfce4-power-manager 
3434     ?     S     00:00:00     nm-applet 
3437     ?     S     00:00:00     apt-indicator --autostarted 
3448     ?     S     00:00:00     /usr/libexec/goa-identity-service 
3454     ?     S     00:00:00     /usr/libexec/gvfs/gvfs-gphoto2-volume-monitor 
3463     ?     S     00:00:00     /usr/libexec/gvfs/gvfs-mtp-volume-monitor 
3506     ?     S     00:00:00     /usr/libexec/gvfs/gvfsd-trash --spawner :1.7 /org/gtk/gvfs/exec_spaw/0 
3535     ?     S     00:00:00     /usr/libexec/bluetooth/obexd 
3646     ?     S     00:00:31     /usr/bin/xfce4-terminal 
3685     pts/0     S     00:00:00     bash 
3700     pts/0     S     00:00:00     sudo -i 
3709     pts/0     S     00:00:00     -bash 
5062     ?     I     00:00:00     (kworker/1:0-events)
5351     pts/1     S     00:00:00     bash 
5482     pts/2     S     00:00:00     bash 
5486     pts/2     S     00:00:00     sudo -i 
5492     pts/2     S     00:00:00     -bash 
5698     pts/1     S     00:00:00     sudo tail -f /var/log/Xorg.0.log 
5700     pts/1     S     00:00:00     tail -f /var/log/Xorg.0.log 
5839     pts/3     S     00:00:00     bash 
5843     pts/3     S     00:00:00     sudo -i 
5845     pts/3     S     00:00:00     -bash 
6287     ?     I     00:00:00     (kworker/1:1)
6310     ?     I     00:00:01     (kworker/0:1-events)
10843     ?     I     00:00:00     (kworker/u4:2-events_unbound)
20311     ?     I     00:00:00     (kworker/0:0-ata_sff)
20331     ?     I     00:00:00     (kworker/u4:3-events_unbound)
20460     ?     I     00:00:00     (kworker/0:2-events)
20485     ?     I     00:00:00     (kworker/u4:0-flush-8:0)
20532     pts/2     S     00:00:00     /bin/bash ./psax.sh 
```
</details>

<details>
<summary>
Тело скрипта
</summary>  
  
 ```
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
 ```
 </details>



----
### Спасибо за проверку!
