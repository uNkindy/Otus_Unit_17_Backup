### Домашнее задание №17 (Backup)
#### Вводные данные:
1. Vagrantfile разворачивает 2 виртуальные машины client и backup. Для ВМ backup дополнительно добавлен 1 жесткий диск sdb. Перед запуском необходимо добавить перменную окружения:
VAGRANT_EXPERIMENTAL=disks
2. Написан ansible плейбук, который разворачивает стенд с borg backup.
___
#### Описание стенда:
Стенд представляет собой 2 виртуальные машины client и backup. На ВМ client установлен borgbackup. Виртуальные машины общаются по приватной виртуальной сети:
```console
client: 192.168.56.241
backup: 192.168.56.240
```
___
#### Принцип работы:
На виртуальный машине client:
- Устанавливается репозиторий epel-release;
- Устанавливается borgbackup;
- Генерируется пара ключей ssh;
- Забирается паблик ключ для ВМ backup;
- Копируются файлы конфигурации borg-backup.service и borg-backup.timer.
На виртуальной машине backup:
- Устанавливается репозиторий epel-release;
- Устанавливается borgbackup;
- Форматируется фаловая система ext4 на sdb;
- Создается точка монтирования /var/backup;
- Sdb монтируется в /var/backup;
- Создается юзер borg;
- Модифицируются доступы к папке /var/backup;
- Удаляется папка lost+found;
- Копируется ssh ключ в autorized_keys;
В конце:
- Инициируется репозиторий с бэкапами на client;
- Зпускается borg-backup.service и borg-backup.timer.
___
#### Результаты работы стенда:
Работа таймера:
```console
[root@client vagrant]# systemctl list-timers --all
NEXT                         LEFT          LAST                         PASSED       UNIT                         ACTIVATES
Sun 2022-11-20 17:49:10 UTC  1min 31s left Sun 2022-11-20 17:44:10 UTC  3min 28s ago borg-backup.timer            borg-backup.service
Mon 2022-11-21 16:58:10 UTC  23h left      Sun 2022-11-20 16:58:10 UTC  49min ago    systemd-tmpfiles-clean.timer systemd-tmpfiles-clean.service
n/a                          n/a           n/a                          n/a          systemd-readahead-done.timer systemd-readahead-done.service
```
```console
[root@backup vagrant]# borg list /var/backup
Enter passphrase for key /var/backup: 
etc-2022-11-20_17:50:10              Sun, 2022-11-20 17:50:11 [4022c707d46dc9bb7a08d5ae09fd6589bdef23642db3d9cdabf5b135572dc4bf]
etc-2022-11-20_17:51:49              Sun, 2022-11-20 17:51:54 [9009e0bb3ebf6ac7216e2138ef00b95d36c4a83b8e41da698f5e00ecb65bd845]
```
___
#### Удаление и восстановление папки /etc из репозитория borgbackup.
- Удалены все файлы из каталога /etc на ВМ client:
```console
[root@client vagrant]# ll /etc
total 0
[root@client vagrant]# 
```
- Через расшаренную на ВМ папку /vagrant перекинул сделанный ранее бекап на клиента:
```console
[root@backup vagrant]# mkdir /vagrant/bkp
[root@backup vagrant]# cp -r /var/backup/ /vagrant/bkp/
[root@backup vagrant]# ll /vagrant/bkp/backup/
total 104
-rw-------. 1 root root   700 Nov 25 08:59 config
drwx------. 3 root root    15 Nov 25 08:59 data
-rw-------. 1 root root    59 Nov 25 08:59 hints.21
-rw-------. 1 root root 82138 Nov 25 08:59 index.21
-rw-------. 1 root root   190 Nov 25 08:59 integrity.21
-rw-------. 1 root root    16 Nov 25 08:59 nonce
-rw-------. 1 root root    73 Nov 25 08:59 README
[root@backup vagrant]# 
```
- Восстановил папку /etc локально:
```console
[root@client vagrant]# borg extract /vagrant/bkp/backup/::etc-2022-11-24_15:52:46 /etc
Enter passphrase for key /vagrant/bkp/backup/: 
[root@client vagrant]# 
```
- Проверим папку /etc:
```console
[root@client vagrant]# ll /etc
total 1056
-rw-r--r--.  1 root root       16 Apr 30  2020 adjtime
-rw-r--r--.  1 root root     1529 Apr  1  2020 aliases
-rw-r--r--.  1 root root    12288 Nov 25 06:29 aliases.db
drwxr-xr-x.  2 root root     4096 Apr 30  2020 alternatives
-rw-------.  1 root root      541 Aug  8  2019 anacrontab
drwxr-x---.  3 root root       43 Apr 30  2020 audisp
drwxr-x---.  3 root root       83 Nov 25 06:29 audit
drwxr-xr-x.  2 root root       68 Apr 30  2020 bash_completion.d
-rw-r--r--.  1 root root     2853 Apr  1  2020 bashrc
drwxr-xr-x.  2 root root        6 Apr  7  2020 binfmt.d
-rw-r--r--.  1 root root       37 Apr  7  2020 centos-release
-rw-r--r--.  1 root root       51 Apr  7  2020 centos-release-upstream
drwxr-xr-x.  2 root root        6 Aug  4  2017 chkconfig.d
-rw-r--r--.  1 root root     1108 Aug  8  2019 chrony.conf
-rw-r-----.  1 root chrony    481 Aug  8  2019 chrony.keys
drwxr-xr-x.  2 root root       26 Apr 30  2020 cifs-utils
drwxr-xr-x.  2 root root       21 Apr 30  2020 cron.d
drwxr-xr-x.  2 root root       42 Apr 30  2020 cron.daily
-rw-------.  1 root root        0 Aug  8  2019 cron.deny
drwxr-xr-x.  2 root root       22 Jun  9  2014 cron.hourly
drwxr-xr-x.  2 root root        6 Jun  9  2014 cron.monthly
-rw-r--r--.  1 root root      451 Jun  9  2014 crontab
drwxr-xr-x.  2 root root        6 Jun  9  2014 cron.weekly
-rw-------.  1 root root        0 Apr 30  2020 crypttab
-rw-r--r--.  1 root root     1620 Apr  1  2020 csh.cshrc
-rw-r--r--.  1 root root     1103 Apr  1  2020 csh.login
drwxr-xr-x.  4 root root       78 Apr 30  2020 dbus-1
drwxr-xr-x.  2 root root       44 Apr 30  2020 default
drwxr-xr-x.  2 root root       23 Apr 30  2020 depmod.d
drwxr-x---.  4 root root       53 Apr 30  2020 dhcp
-rw-r--r--.  1 root root     5090 Aug  6  2019 DIR_COLORS
-rw-r--r--.  1 root root     5725 Aug  6  2019 DIR_COLORS.256color
-rw-r--r--.  1 root root     4669 Aug  6  2019 DIR_COLORS.lightbgcolor
-rw-r--r--.  1 root root     1285 Apr  1  2020 dracut.conf
drwxr-xr-x.  2 root root       88 Apr 30  2020 dracut.conf.d
-rw-r--r--.  1 root root      112 Nov 27  2019 e2fsck.conf
-rw-r--r--.  1 root root        0 Apr  1  2020 environment
-rw-r--r--.  1 root root     1317 Apr 11  2018 ethertypes
-rw-r--r--.  1 root root        0 Jun  7  2013 exports
drwxr-xr-x.  2 root root        6 Apr  1  2020 exports.d
-rw-r--r--.  1 root root       70 Apr  1  2020 filesystems
drwxr-x---.  7 root root      133 Apr 30  2020 firewalld
-rw-r--r--.  1 root root      450 Nov 25 06:30 fstab
-rw-r--r--.  1 root root       38 Oct 30  2018 fuse.conf
drwxr-xr-x.  2 root root        6 Aug  2  2017 gcrypt
drwxr-xr-x.  2 root root        6 Jul 13  2018 gnupg
-rw-r--r--.  1 root root       94 Mar 24  2017 GREP_COLORS
drwxr-xr-x.  4 root root       40 Apr 30  2020 groff
-rw-r--r--.  1 root root      543 Apr 30  2020 group
-rw-r--r--.  1 root root      536 Apr 30  2020 group-
lrwxrwxrwx.  1 root root       22 Apr 30  2020 grub2.cfg -> ../boot/grub2/grub.cfg
drwx------.  2 root root      182 Apr 30  2020 grub.d
----------.  1 root root      433 Apr 30  2020 gshadow\
```