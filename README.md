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