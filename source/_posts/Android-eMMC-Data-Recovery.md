---
title: Android eMMC Data Recovery
date: 2018-12-19 18:32:41
password:
abstract:
message:
tags:
  - Android
  - eMMC
  - Data Recovery
---

最近升级了硬件工作台的工具，可以完成 BGA 的拆焊的工作了。把家里几年前进水的一只安卓手机，拿出来恢复一下里面的数据。
其实就是取下手机主板上的 eMMC 芯片再焊接到空的 U盘主控 PCB 板子上，读取里面的数据。这个方法只适合未全盘加密的设备使用，对于 iPhone 和全盘加密的 Android 只能修复主板或者拆下 ROM, CPU, Baseband 芯片，再焊接到完好的同型号主板上开机输入密码才能查看数据了。
<!--more-->
![](//files.hakr.xyz/images/2018-12-19_01-0001.png)

## 硬件拆焊

这里我使用的是安国的 U盘主控 PCB 板子，具体买的时候根据手机 eMMC 芯片型号查询对应的 BGA 封装的类型选择对应的 U盘主控板。当然也可以使用 eMMC 转 SD 卡座，或者使用 SD 卡套直接焊接飞线来连接。

## 读取 eMMC

我这里使用的是把 eMMC 焊接到 U盘主控板上来读取数据的方法。

#### 备份数据

首先对焊接完成的 USB 设备进行数据的镜像备份，恢复数据是操作镜像文件，避免直接操作设备而损坏数据。
备份前为了确保 BGA 焊接是好的，需要看一下系统能否识别设备的分区表，Windows 系统直接在「磁盘管理」里查看，Linux 使用命令 `fdisk -l` 查看。
设备镜像备份工具在 Windows 上可使用 [Win32 Disk Imager](https://sourceforge.net/projects/win32diskimager/) 或 git-bash 里的 `dd` 命令备份，Linux 上也是使用 `dd` 命令备份。

```bash
dd if=/dev/sda of=dump_0.img bs=1024
```

#### 查看镜像文件的分区表

```bash
$ fdisk -l dump_0.img
Ignoring extra data in partition table 5.
Ignoring extra data in partition table 5.
Disk dump_0.img: 3.6 GiB, 3875536896 bytes, 7569408 sectors
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disklabel type: dos
Disk identifier: 0xa91b46f7

Device      Boot   Start        End    Sectors  Size Id Type
dump_0.img1         1024 4294968318 4294967295    2T  5 Extended
dump_0.img2        26624      47103      20480   10M 83 Linux
dump_0.img3        47104      67583      20480   10M 83 Linux
dump_0.img4       101376     113663      12288    6M 83 Linux
dump_0.img5       144384    1981439    1837056  897M 83 Linux
dump_0.img6      4336640 4294968318 4290631679    2T 83 Linux
```

#### 计算要挂载分区的位置

更具需要挂载分区的 Start 值乘以 Units 值得出挂载值

```bash
$ echo $((4336640*512))
2220359680
```

#### 创建挂载目录

```bash
mkdir /mnt/emmc
```

#### 挂载指定分区

```bash
mount -o loop,offset=2220359680 dump_0.img /mnt/emmc/
```

#### 打包备份分区内的文件

打包所有数据后可以复制到 Windows 上去解包查看具体的文件

```bash
tar cvzf ~/dump_0_img6.tar.gz /mnt/emmc/
```

## 照片恢复

正常来说之前存储的照片如果没手动删除，那肯定是还在 DCIM 目录里的。但不幸的是我并没有在 DCIM 目录找到拍摄的照片，不过倒是存在一个 .thumbnails 文件夹。
.thumbnails 文件夹里有些缩略图和 .thumbdata5 的缓存文件。

#### 从 `.thumbdata` 恢复照片

这里使用 Python 脚本对 .thumbdata 文件的内照片进行读取并保存，另外你也可以使用 [HTML5 Thumbdata3 Viewer](https://x0a.github.io/thumbdata3-viewer/) 这个 Web 版的程序来读取。[thumbdata.py](https://files.iternull.com/script/python/thumbdata.py) 是我更改后的脚本，原始版本来自 [Stack Exchange](https://android.stackexchange.com/questions/58087/read-content-of-thumbdata-file) 。

```bash
$ cd /mnt/emmc/
$ find ./ -name *thumbdata*
./DCIM/.thumbnails/.thumbdata5-1763508120_0
$ mkdir ~/thumbnails
$ cp DCIM/.thumbnails/.thumbdata5-1763508120_0 ~/thumbnails/
$ cd ~/thumbnails/
$ wget https://files.iternull.com/script/python/thumbdata.py
$ chmod 755 thumbdata.py
$ ./thumbdata.py .thumbdata5-1763508120_0
```

## 联系人恢复

联系人保存在 `data/data/com.android.providers.contacts/databases/` 目录下的 `contacts2.db` 数据库文件中的 `contacts`, `view_contacts` 表里。
通话记录保存在 `data/data/com.android.providers.contacts/databases/` 目录下的 `calllog.db` 数据库文件中的 `calls` 表里。
使用 [DB Browser for SQLite](https://sqlitebrowser.org/) 打开数据库文件即可读取出原始数据。

```bash
$ cd /mnt/emmc/
$ find ./ -name contacts2.db
./data/data/com.android.providers.contacts/databases/contacts2.db
$ find ./ -name calllog.db
./data/data/com.android.providers.contacts/databases/calllog.db
```

## 短信恢复

短信保存在 `data/data/com.android.providers.telephony/databases/` 目录下的 `mmssms.db` 数据库文件中的 `sms` 表里。
使用 [DB Browser for SQLite](https://sqlitebrowser.org/) 打开数据库文件即可读取出原始数据。

```bash
$ cd /mnt/emmc/
$ find ./ -name mmssms.db
./data/data/com.android.providers.telephony/databases/mmssms.db
```
