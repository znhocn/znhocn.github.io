---
title: Hacking IP Camera (和慧眼-C08)
date: 2017-12-26 02:12:27
password: 
abstract:
message: 2018/01/30 后公开内容
tags:
  - Hacking
  - Reverse Engineering
  - Hardware
  - IPCamera
---

[和慧眼](http://www.hehuiyan.com/)是中国移动推出的一个摄像网络监控服务平台，旗下有多款智能摄像头设备。这里我们研究使用的是 C08 型号的。
IPCamera 与 WebCam 的其中一个区别是 IPCamera 不带有 Web 控制台，你只能使用厂商提供的 APP 控制设备，无法在局域网内通过网页控制设备。
并且 IPCamera 基本上都要连接互联网使用厂商的云平台，这意味着你的数据都会传输到云端，还可能需要再付费租用它的云端平台功能使用权。
<!-- more -->
## 1 拆解硬件

![](//files.hakr.xyz/images/2017-12-26_01-0001.jpg)
![](//files.hakr.xyz/images/2017-12-26_01-0002.jpg)

## 2 串口调试

我们这里使用 CP2012 USB to TTL 工具连接到设备上焊接了跳线的 UART 接口

![](//files.hakr.xyz/images/2017-12-26_01-0003.jpg)

使用 PuTTY 客户端连接 COM 端口开始上电调试

```bash
U-Boot 2010.06-svn2464 (Jan 21 2015 - 09:06:53)
DRAM:  256 MiB
gBootLogPtr:80b80008.
Check spi flash controller v350... Found
Spi(cs1) ID: 0xEF 0x40 0x18 0x00 0x00 0x00
reset/hold pin now is RESET
Spi(cs1): Block:64KB Chip:16MB Name:"W25Q128B"
boot from spi
boot from spi
partition file version 2
rootfstype squashfs root /dev/mtdblock4
In:    serial
Out:   serial
Err:   serial
TEXT_BASE:81000000
state:ff,err_count:00
support SD update
MMC:   Card did not respond to voltage select!
No EMMC device found!!!
Hisilicon ETH net controler
No such device: 0:1
No such device: 0:1
No such device: 0:2
No such device: 0:2
Try again use backup_serverip
Hisilicon ETH net controler
No such device: 0:1
No such device: 0:1
No such device: 0:2
No such device: 0:2
Failed to get info.txt
Fail to get info file!
Init error!
Hisilicon ETH net controler
No such device: 0:1
No such device: 0:1
No such device: 0:2
No such device: 0:2
## Booting kernel from Legacy Image at 82000000 ...
   Image Name:   Linux-3.0.8
   Image Type:   ARM Linux Kernel Image (uncompressed)
   Data Size:    1042164 Bytes = 1017.7 KiB
   Load Address: 80008000
   Entry Point:  80008000
   Loading Kernel Image ...OK
OK
boot from spi
partition file version 2
rootfstype squashfs root /dev/mtdblock4
cmdLine mem=44M console=ttyS0,115200 root=/dev/mtdblock4 rootfstype=squashfs

Starting kernel ...
Uncompressing Linux... done, booting the kernel.
```

尝试了多次，调试信息都是一直卡在 booting the kernel. 这，没弹出 Shell ，也没弹出登陆认证的请求。尝使用串口登陆 Shell 只能暂时放弃。

## 3 网络调试

### 3.1 端口扫描

使用 Nmap 扫描设备开放端口

```bash
$ nmap -A 192.168.8.236
Nmap scan report for 192.168.8.236
Host is up (0.0080s latency).
Not shown: 997 closed ports
PORT     STATE SERVICE VERSION
23/tcp   open  telnet  security DVR telnetd (many brands)
554/tcp  open  rtsp
| fingerprint-strings:
|   SIPOptions:
|     RTSP/1.0 401 Unauthorized
|     CSeq: 42
|_    WWW-Authenticate: Basic realm="MediaServer3.0"
|_rtsp-methods: ERROR: Script execution failed (use -d to debug)
5000/tcp open  upnp?
1 service unrecognized despite returning data. If you know the service/version, please submit the following fingerprint at https://nmap.org/cgi-bin/submit.cgi?new-service :
SF-Port554-TCP:V=7.40%I=7%D=1/4%Time=5A4E4B5D%P=arm-unknown-linux-gnueabih
SF:f%r(SIPOptions,57,"RTSP/1\.0\x20401\x20Unauthorized\r\nCSeq:\x2042\r\nW
SF:WW-Authenticate:\x20Basic\x20realm=\"MediaServer3\.0\"\r\n\r\n");
MAC Address: E0:50:8B:35:74:02 (Zhejiang Dahua Technology)
Device type: general purpose
Running: Linux 2.6.X|3.X
OS CPE: cpe:/o:linux:linux_kernel:2.6 cpe:/o:linux:linux_kernel:3
OS details: Linux 2.6.32 - 3.5
Network Distance: 1 hop

TRACEROUTE
HOP RTT     ADDRESS
1   8.00 ms 192.168.8.236

OS and Service detection performed. Please report any incorrect results at https://nmap.org/submit/ .
# Nmap done at Thu Jan  4 23:42:28 2018 -- 1 IP address (1 host up) scanned in 116.06 seconds
```

扫描完成后看到设备上开放着 `23` `544` `5000` 3 个端口分别运行着 Telnet, RTSP, UPNP(疑似) 服务。

### 3.2 网络数据包分析

这里使用安装了 `tcpdump` 且支持外接 USB 存储的 OpenWrt 路由器设备进行抓包。

```bash
$ mount /dev/sdb1 /mnt/usb/    // 挂载 U盘
$ cd /mnt/usb/pcap/    // 进入 U盘挂载目录
$ tcpdump -i wlan0-1 -w wlan0-1_$(date +%s).cap    // 抓取无线网卡上的数据流量
```

抓取一段时间的数据包后使用 Wireshark 打开 `.pcap` 文件，分析 IPCamera 的数据通信流量。

![](//files.hakr.xyz/images/2017-12-26_01-0004.png)

## 4 固件提取

### 4.1 从 SPI Flash 芯片里提取固件

我们这里使用 Bus Pirate + 转接座 + SOP8 测试夹 工具来连接 SPI Flash 芯片提取固件。

![](//files.hakr.xyz/images/2017-12-26_01-0005.jpg)

读取 SPI Flash 芯片内的数据到文件

```bash
$ flashrom -p buspirate_spi:dev=/dev/ttyUSB0,spispeed=1M -r flash_0.bin
```

### 4.2 从空气中提取固件

**从空气中提取固件** 在物联网时代里 OTA 固件升级模式下获得厂商原始升级固件的最佳方法！

[OTA](https://zh.wikipedia.org/wiki/%E7%A9%BA%E4%B8%AD%E7%BC%96%E7%A8%8B)(Over-the-air) 从空中更新固件；从空气中提取固件其实就是从网络中提取固件，把更新固件时传输的所有数据包都抓取下来再重新把数据包组合起来还原固件的原始文件。这需要设备固件支持 OTA更新 才行，不过目前大多数厂商的 IoT 设备默认都有支持。

我们使用的这款型号的设备正好有推送新的固件更新，所以可以使用此方法获得固件。

这里使用安装了 `tcpdump` 且支持外接 USB 存储的 OpenWrt 路由器设备进行抓包。被抓包的设备必须连接到这路由器的 SSID 下。

抓取无线网卡上的数据流量

```bash
$ tcpdump -i wlan0-1 -w wlan0-1_$(date +%s).cap
```

开始抓取流量后在 APP 控制端上点击对设备固件升级(更新前最好是对 SPI Flash 先备份，以保留旧版本的固件。)

![](//files.hakr.xyz/images/2017-12-26_01-0006.png)

把抓取的数据包中的数据流保存到文件

```bash
$ tcpflow -r wlan0-1_1515316239.cap
```

![](//files.hakr.xyz/images/2017-12-26_01-0007.png)

查看未知格式的的数据文件

```bash
$ file * | grep data
```

![](//files.hakr.xyz/images/2017-12-26_01-0008.png)

递归扫描并提取出其中已知格式的文件

```bash
$ binwalk -Me 211.140.013.023.15050-172.016.042.116.42004
```

![](//files.hakr.xyz/images/2017-12-26_01-0009.png)

递归扫描并提取出的已知格式的文件

![](//files.hakr.xyz/images/2017-12-26_01-0010.png)

## 5 固件逆向

### 5.1 解包固件

从备份的 SPI Flash 数据里递归扫描并提取出其中已知格式的文件

```bash
$ binwalk -Me flash_0.bin
```

查看递归提取后的文件

```bash
$ cd _flash_0.bin.extracted/
$ tree -L 3
$ ls -l squashfs-root*
```

![](//files.hakr.xyz/images/2017-12-26_01-0011.png)

查看 Linux 用户与密码

```bash
$ cd squashfs-root/
$ cd etc/
$ cat passwd
root:$1$jSqQv.uP$jgz4lwEx2pnDh4QwXkh06/:0:0:root:/:/bin/sh
```

查看 `passwd` 文件，发现系统里只有一个 root 用户，加盐后的的密码 Hash ，登陆 shell 为 `/bin/sh`。 使用 [John the Ripper](http://www.openwall.com/john/) 对 Hash 进行解码成明文密码。

以下是解出的密码
User: `root`
Password: `vizxv`

尝试使用这个账号登陆 Telnet 但并未成功。

### 5.2 分析 Telnet

既然尝试使用系统用户登陆失败了，那只能从 Telnet 服务程序入手，分析它的登陆验证方式，找到正确的用户和密码。

查找 Telnet 服务程序

```bash
$ cd _flash_0.bin.extracted/squashfs-root/
$ find ./ -name *telnet*
./bin/telnet    // Telnet 客户端
./sbin/telnetd    // Telnet 服务端
```

使用 IDA Pro 对 `telnetd` 进行反汇编后发现 Telnet 的用户名和密码是硬编码在程序里的。

![](//files.hakr.xyz/images/2017-12-26_01-0012.png)
![](//files.hakr.xyz/images/2017-12-26_01-0013.png)

**Telnet 登陆账号**
User: `admin`
Password: `7ujMko0admin`

使用这个用户再次尝试登陆 Telnet 

![](//files.hakr.xyz/images/2017-12-26_01-0014.png)

> **成功了！！！**
> 这个我们已经获得了 Shell 与 root 权限

### 5.3 收集系统运行信息

这里登陆到 Telnet 手动收集信息，相较于使用 [Firewalker](https://github.com/craigz28/firmwalker) 脚本工具收集固件解包后的信息，能收集到设备在运行状态下内存里的更多信息。

收集运行的进程信息

```bash
~ # ps
PID   USER     TIME   COMMAND
    1 root       0:00 init
    2 root       0:00 [kthreadd]
    3 root       0:00 [ksoftirqd/0]
    4 root       0:00 [kworker/0:0]
    5 root       0:01 [kworker/u:0]
    6 root       0:06 [rcu_kthread]
    7 root       0:00 [khelper]
    8 root       0:00 [kworker/u:1]
   72 root       0:00 [sync_supers]
   74 root       0:00 [bdi-default]
   76 root       0:00 [kblockd]
  168 root       0:00 [kswapd0]
  217 root       0:00 [fsnotify_mark]
  224 root       0:00 [crypto]
  238 root       0:00 [mtdblock0]
  243 root       0:00 [mtdblock1]
  248 root       0:00 [mtdblock2]
  253 root       0:00 [mtdblock3]
  258 root       0:00 [mtdblock4]
  263 root       0:01 [mtdblock5]
  268 root       0:00 [mtdblock6]
  273 root       0:00 [mtdblock7]
  281 root       0:00 [kpsmoused]
  282 root       0:00 [kworker/0:1]
  324 root       0:00 [jffs2_gcd_mtd7]
  342 root       0:00 /sbin/telnetd
  397 root       0:00 [khubd]
  418 root       0:00 [OSA_416_1]
  478 root       0:00 [OSA_462_3]
  483 root       0:00 [OSA_462_4]
  502 root       0:00 syshelper elper 60
  526 root       0:00 [cfg80211]
  533 root       0:01 /usr/bin/wpa_supplicant -g/var/tmp/wpa_supplicant-global -P/var/tmp/eth2.pid
  543 root       0:00 [kworker/u:2]
  548 root       0:00 [flush-mtd-unmap]
  556 root       0:54 VideoDaemon AEWB
  557 root       0:00 /bin/sh /etc/init.d/appauto
  581 root       0:00 /bin/sh ./usr/etc/app.sh
  587 root       1:58 /usr/bin/sonia
  612 root       0:01 [RTW_CMD_THREAD]
  913 root       0:00 [kworker/u:3]
 1295 root       0:00 -sh
 1427 root       0:00 ps
~ #
```

收集 Linux 版本信息

```bash
/proc # cat version
Linux version 3.0.8 (@centos-68) (gcc version 4.4.1 (Hisilicon_v100(gcc4.4-290+uclibc_0.9.30.2+eabi+linuxpthread)) )
/proc #
```

收集处理器信息

```bash
~ # cd /proc/
/proc # cat cpuinfo
Processor       : ARM926EJ-S rev 5 (v5l)
BogoMIPS        : 218.72
Features        : swp half fastmult edsp java
CPU implementer : 0x41
CPU architecture: 5TEJ
CPU variant     : 0x0
CPU part        : 0x926
CPU revision    : 5

Hardware        : hi3518
Revision        : 0000
Serial          : 0000000000000000
/proc #
```

收集内存信息

```bash
/proc # cat meminfo
MemTotal:          41604 kB
MemFree:            1832 kB
Buffers:            3948 kB
Cached:            11636 kB
SwapCached:            0 kB
Active:            20528 kB
Inactive:           7928 kB
Active(anon):      12920 kB
Inactive(anon):      296 kB
Active(file):       7608 kB
Inactive(file):     7632 kB
Unevictable:           0 kB
Mlocked:               0 kB
SwapTotal:             0 kB
SwapFree:              0 kB
Dirty:                 0 kB
Writeback:             0 kB
AnonPages:         12896 kB
Mapped:             7156 kB
Shmem:               344 kB
Slab:               3356 kB
SReclaimable:        868 kB
SUnreclaim:         2488 kB
KernelStack:         728 kB
PageTables:          476 kB
NFS_Unstable:          0 kB
Bounce:                0 kB
WritebackTmp:          0 kB
CommitLimit:       20800 kB
Committed_AS:     449116 kB
VmallocTotal:     966656 kB
VmallocUsed:       17412 kB
VmallocChunk:     931184 kB
/proc #
```

收集 TCP 连接信息

```bash
/proc # cat /proc/net/tcp
  sl  local_address rem_address   st tx_queue rx_queue tr tm->when retrnsmt   uid  timeout inode
   0: 00000000:1388 00000000:0000 0A 00000000:00000000 00:00000000 00000000     0        0 403 1 c2658460 300 0 0 2 -1
   1: 00000000:022A 00000000:0000 0A 00000000:00000000 00:00000000 00000000     0        0 513 1 c2659180 300 0 0 2 -1
   2: 00000000:9390 00000000:0000 0A 00000000:00000000 00:00000000 00000000     0        0 415 1 c26588c0 300 0 0 2 -1
   3: 00000000:9391 00000000:0000 0A 00000000:00000000 00:00000000 00000000     0        0 412 1 c2658d20 300 0 0 2 -1
   4: 00000000:0017 00000000:0000 0A 00000000:00000000 00:00000000 00000000     0        0 162 1 c2658000 300 0 0 2 -1
   5: EC08A8C0:0017 7E08A8C0:CFA9 01 00000002:00000000 01:0000001D 00000000     0        0 1444 4 c26595e0 31 4 25 10 9
   6: EC08A8C0:A135 120D8CD3:BF86 01 00001E8F:00000000 01:0000001D 00000000     0        0 1052 2 c2659ea0 31 4 0 18 7
   7: EC08A8C0:B352 160D8CD3:3572 01 00000000:00000000 00:00000000 00000000     0        0 1042 1 c2659a40 21 4 30 5 3
/proc #
```

`local_address` 与 `rem_address` 都是十六进制的表示方法，并且 IP 地址是倒过来的。
`6B 02 A8 C0` 转换成石家庄为 `107 2 168 192` 转换正常的 IPv4 地址为 `192.168.2.107`。
`0017` 为端口号也是使用十六进制表示的，转换成十进制是 `23`。
闲手动麻烦可以使用 [proc_net_tcp_decode](https://gist.github.com/jkstill/5095725) 这个脚本去转换。

收集 UDP 连接信息

```bash
/proc # cat /proc/net/udp
  sl  local_address rem_address   st tx_queue rx_queue tr tm->when retrnsmt   uid  timeout inode ref pointer drops
  146: 00000000:9392 00000000:0000 07 00000000:00000000 00:00000000 00000000     0        0 416 2 c1dcf800 0
  146: 00000000:9392 00000000:0000 07 00000000:00000000 00:00000000 00000000     0        0 413 2 c1dcf600 0
  178: EC08A8C0:93B2 00000000:0000 07 00000000:00000000 00:00000000 00000000     0        0 1061 2 c0b16400 0
  178: FBFFFFEF:93B2 00000000:0000 07 00000000:00000000 00:00000000 00000000     0        0 1060 2 c0b16000 0
  186: 00000000:13BA 00000000:0000 07 00000000:00000000 00:00000000 00000000     0        0 382 2 c1dcf400 0
/proc #
```

收集已安装的命令行工具

```bash
~ #
VideoDaemon     cat             dmesg           grep            ip              logView         netinit         pwd             ssl/            top
[               chgrp           du              halt            ipaddr          login           netinit6        reboot          stat            touch
[[              chmod           echo            head            iplink          ls              netstat         redirClient     sync            udhcpd
aewDebug        chown           egrep           hostapd         iproute         lsmod           netwifi         redir_stdio     syshelper       udpsvd
appauto         chroot          env             hush            iprule          mdev            nice            rm              systools        umount
armbenv         clearparam      fdisk           hwclock         iptunnel        mkdir           nslookup        rmdir           tail            uname
arp             cp              fgrep           ifconfig        iwconfig        mknod           ping            rmmod           tcpsvd          unlzma
arping          cut             find            ifenslave       kill            mnt_jffs2       ping6           route           telnet          unzip
ash             date            free            ii              killall         modinfo         pkill           sed             telnetd         vi
audioDebug      dd              fsync           inetd           killall5        more            poweroff        seq             test            who
bash            df              gethwid         init            less            mount           printenv        sh              tftp            whoami
busybox         dh_keyboard     getty           insmod          ln              mv              ps              sonia           tftpd           wpa_supplicant
~ #
```

收集目录信息

```bash
~ # mount
rootfs on / type rootfs (rw)
/dev/root on / type squashfs (ro,relatime)
devtmpfs on /dev type devtmpfs (rw,relatime,size=20760k,nr_inodes=5190,mode=755)
proc on /proc type proc (rw,relatime)
sysfs on /sys type sysfs (rw,relatime)
devpts on /dev/pts type devpts (rw,relatime,mode=600,ptmxmode=000)
tmpfs on /var type tmpfs (rw,relatime)
/dev/mtdblock5 on /usr type squashfs (ro,relatime)
/dev/mtdblock7 on /mnt/mtd type jffs2 (rw,relatime)
usbfs on /proc/bus/usb type usbfs (rw,relatime)
~ #
~ # pwd
/
~ #
~ # touch aaa
touch: aaa: Read-only file system
~ #
~ # mount | grep rw
rootfs on / type rootfs (rw)
devtmpfs on /dev type devtmpfs (rw,relatime,size=20760k,nr_inodes=5190,mode=755)
proc on /proc type proc (rw,relatime)
sysfs on /sys type sysfs (rw,relatime)
devpts on /dev/pts type devpts (rw,relatime,mode=600,ptmxmode=000)
tmpfs on /var type tmpfs (rw,relatime)
/dev/mtdblock7 on /mnt/mtd type jffs2 (rw,relatime)
usbfs on /proc/bus/usb type usbfs (rw,relatime)
~ #
~ # cd /var/
/var # touch aaa
/var # ls -l
total 0
-rw-r--r--    1 root     root             0 Jan 25 04:23 aaa
drwxr-xr-x   10 root     root           440 Jan 25 04:02 tmp
p-wx------    1 root     root             0 Jan 25 04:00 videoDebug
drwxr-xr-x    2 root     root            80 Jan 25 04:00 web
/var #
/var # cd /mnt/mtd/
/mnt/mtd # touch aaa
/mnt/mtd # ls -l
total 6
drwxr-xr-x    2 root     root             0 Jan  1  1970 3A
drwxr-xr-x    3 root     root             0 Jan 25 04:00 Config
drwxr-xr-x    2 root     root             0 Nov 11  2016 Log
-rw-r--r--    1 root     root           256 Jan 25 04:25 RtcSramFile
-rw-r--r--    1 root     root           256 Jan 25 04:25 RtcSramFileBackUp
-rw-r--r--    1 root     root             0 Jan 25 04:27 aaa
drwxr-xr-x    2 root     root             0 Jan  1  2000 audiofiles
-rw-r--r--    1 root     root            36 Jan 25 04:00 flgFile
-rw-r--r--    1 root     root            36 Jan 25 04:00 flgFileBackUp
-rw-r--r--    1 root     root           556 Jan 25 04:15 recordSramFile
-rw-r--r--    1 root     root           556 Jan 25 04:15 recordSramFileBackUp
-rw-r--r--    1 root     root           256 Jan 25 04:25 socRtcSram
-rw-r--r--    1 root     root           256 Jan 25 04:25 socRtcSramBackUp
-rw-r--r--    1 root     root            21 Jan  1  2000 wifiModifyTime
/mnt/mtd #

~ # ls -l
total 0
drwxr-xr-x    2 root     root           993 Jan  1  1970 bin
drwxr-xr-x    7 root     root          3200 Jan 25 04:00 dev
drwxr-xr-x    4 root     root           258 Jan  1  1970 etc
drwxr-xr-x    2 root     root             3 Jan  1  1970 home
drwxr-xr-x    2 root     root           534 Jan  1  1970 lib
lrwxrwxrwx    1 root     root            11 Jan  1  1970 linuxrc -> bin/busybox
drwxr-xr-x   12 root     root           170 Jan  1  1970 mnt
drwxr-xr-x    2 root     root             3 Jan  1  1970 nfs
dr-xr-xr-x   57 root     root             0 Jan  1  1970 proc
drwxr-xr-x    2 root     root             3 Jan  1  1970 root
drwxr-xr-x    2 root     root           423 Jan  1  1970 sbin
drwxr-xr-x    2 root     root             3 Jan  1  1970 share
drwxr-xr-x    2 root     root             3 Jan  1  1970 slave
drwxr-xr-x   11 root     root             0 Jan  1  1970 sys
lrwxrwxrwx    1 root     root             8 Jan  1  1970 tmp -> var/tmp/
drwx--x--x    9 25858    25858           96 Oct 14  2015 usr
drwxrwxrwt    4 root     root           100 Jan 25 04:00 var
~ #
```

收集网卡信息

```bash
~ # ifconfig
eth2      Link encap:Ethernet  HWaddr E0:50:8B:35:74:02
          inet addr:192.168.8.236  Bcast:192.168.8.255  Mask:255.255.255.0
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:8895 errors:0 dropped:234 overruns:0 frame:0
          TX packets:35955 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000
          RX bytes:894282 (873.3 KiB)  TX bytes:43996613 (41.9 MiB)

lo        Link encap:Local Loopback
          inet addr:127.0.0.1  Mask:255.0.0.0
          UP LOOPBACK RUNNING  MTU:16436  Metric:1
          RX packets:73 errors:0 dropped:0 overruns:0 frame:0
          TX packets:73 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:0
          RX bytes:15590 (15.2 KiB)  TX bytes:15590 (15.2 KiB)

~ #
```
<!--
定位运行的服务与开放的端口号

由于 `netstat` 和 `lsof -i` 命令在这系统都用不了，所有只能从 `/proc/` 目录里手动收集原始信息再解码成可读信息。

-->
<!--



-->

### 5.4 找出 RTSP 用户名与密码

使用 [VLC media player](https://www.videolan.org/) 连接到 IPCamera 的 RTSP 服务端，发现是个需要使用用户名和密码登陆认证的服务。

![](//files.hakr.xyz/images/2017-12-26_01-0015.png)

使用 IDA Pro 对系统运行的几个私有程序进行反编译后发现配置文件大多都保存在 `/mnt/` 目录下。于是在 `/mnt/pd/product.zip` 文件里找到了几个账号。

![](//files.hakr.xyz/images/2017-12-26_01-0016.png)

尝试这些账号登陆服务发现 `admin` 账号是可用的，并成功的连接到了 IPCamera 的 RTSP 服务。在 VLC media player 里能够直接看到实时视频与音频。

![](//files.hakr.xyz/images/2017-12-26_01-0017.png)

### 5.5 嗅探 5000 端口运行的服务

使用 NetCat 连接到 `5000` 端口，连接后并不返回任何信息，尝试发送字符信息也并未回复，且发送到一定字节信息后自动了关闭连接。

```bash
$ nc 192.168.8.236 5000 
```

使用 [miranda-upnp](https://github.com/0x90/miranda-upnp) 工具扫描局域网内的运行着 UPnP 的设备也为发现有 IPCamera 的信息。目前未得出此端口运行的是什么服务。猜测可能是进行局域网内远程信息配置相关的。

## 6 APP 逆向

APP 里可能会保留部分有用的信息，这里尝试对其简单的分析。

### 6.1 解包程序逆向代码

使用 Apktool 解包 `.apk` 文件

```bash
$ apktool d hhy.apk
```

使用 dex2jar 将 `.dex` 文件转换成 `.class` 文件

```bash
$ cd hhy/assets/
$ dex2jar classes.dex
```

使用 [JD-GUI](http://jd.benow.ca/) 查看反编译后的代码

![](//files.hakr.xyz/images/2017-12-26_01-0018.png)

这里有找到 RTSP 相关的内容

### 6.2 APP 网络通信分析

可以使用 [Burp Suite](https://portswigger.net/burp) 去分析/修改 APP 网络通信的数据内容。这里不做讲解。

## 7 漏洞利用

### 7.1 作为直播摄像头

这个 IPCamera 上运行着 RTSP 服务，我们可以尝试把视频流导入到 [OBS](https://obsproject.com/) 里，作为直播摄像头。

在 OBS 里添加 RTSP 作为媒体源

![](//files.hakr.xyz/images/2017-12-26_01-0019.png)

![](//files.hakr.xyz/images/2017-12-26_01-0020.png)

### 7.2 作为 DoS 肉鸡

这个 IPCamera 还有空余存储，`/mnt/` 目录下也是可写的，并且系统内置可使用的 `tftp` `tftpd` 程序，你可以编写自己后门程序编译后通过 FTP 传输到设备上。

----------

* 注: 在最新版本的固件里已经修复了这些漏洞
