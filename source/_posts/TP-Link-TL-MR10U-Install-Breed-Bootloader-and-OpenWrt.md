---
title: TP-Link TL-MR10U Install Breed Bootloader + OpenWrt
date: 2018-12-26 23:14:20
password:
abstract:
message:
tags:
  - OpenWrt
  - Breed Bootloader
  - TL-MR10U
---

淘了一个二手的 TL-MR10U 自己升级一下硬件，装个 OpenWrt 再配上 LAN-Tap 作为可随身携带的便捷抓包工具使用。
还是自带电源的，不然拖个充电宝太麻烦了，OpenWrt 官网上也有一个 [Table of Hardware: Battery powered](https://openwrt.org/toh/views/toh_battery-powered) 页面列出了所有官方支持的可刷 OpenWrt 的“充电宝”。
<!-- more -->
![](//files.hakr.xyz/images//2018-12-26_01-0001.jpg)
## 升级硬件

你需要购买 64MB RAM 芯片 (HY5DU121622DTP-D43) 16MB FLASH 芯片 (W25Q128)；准备热风枪拆焊台、电烙铁、助焊剂、镊子等工具；以及一个 CH341A 编程器外加宽体 SOP8 烧录座。
具体怎么操作可以网上找视频看看。记得别用电烙铁抵着吸锡带去拖内存焊盘上剩余的高温锡，你绝对把焊盘给弄脱落的。其实只给旁边的原件区域贴上高温胶带，在焊盘上加点助焊剂再用热风枪把新元件吹焊上去即可。
拆前最好先拍照，好记得原件的第一 Pin 是哪个位置，以免之后焊错方向。

## 备份原始固件

把拆下的 FLASH 用编程器读出所有数据并保存到备份文件里，再把读取的数据写入到新的 64MB FLASH 芯片里，最后再把新 FLASH 焊回主板上。

## 刷入 Breed Bootloader

下载未锁分区的 [openwr-ar71xx-generic-tl-mr10u-v1-squashfs-factory.bin](https://pan.baidu.com/s/1OCUnvfjJHJar7Pk0Lgt_uQ) 固件，用于刷入 U-Boot。 
下载完成后直接在 TP-Link 官方的 Web 控制台里上传固件进行升级，TL-MR10U 插上网线与电脑相联，等待数分钟让路由器完成重启。

使用 git-bash 附带的 `scp` 工具上传 Breed Bootloader 到 TL-MR10U 的 `/tmp` 目录里。

```bash
scp breed-ar9331-mr12u-r1163.bin root@192.168.1.1:/tmp/
```

通过 SSH 登录 TL-MR10U 

```bash
ssh root@192.168.1.1
```

备份 U-Boot & ART

```bash
cat /proc/mtd
dd if=/dev/mtd0 of=/tmp/u-boot.bin
dd if=/dev/mtd4 of=/tmp/art.bin
scp root@192.168.1.1:/tmp/*.bin .    # 在你的电脑终端上执行，从远端复制到电脑上
```

刷入新的 [Breed Bootloader](https://breed.hackpascal.net/EOL/breed-ar9331-mr12u-r1163.bin)

```bash
mtd -r write breed-ar9331-mr12u-r1163.bin u-boot
```

如果出现 Could not open mtd device: u-boot Can't open device for writing! 意味着你使用了 OpenWrt 官方正式版固件，默认是锁了 U-Boot 的，需要使用未锁分区才行。未锁分区的固件需要自己改 OpenWrt 源代码配置再重新编译或者下载他人编译好的。

## 还原 Atheros ART

- 注：如果你更换了 FLASH 芯片，不还原 Atheros ART 数据会导致你路由器无法使用 WiFi 功能！

ART 数据里存储着 WiFi 功能的配置和驱动，如果损坏或丢失 ART 都会导致你安装后的 OpenWrt 没有无线功能。
按住 RESET 键后打开电源，持续按住 5 秒左右就可进入 Breed 的恢复模式。确保路由器使用网线连接到了电脑后，在浏览器里输入 `192.168.1.1` 进入 Breed Web 恢复控制台。
在【固件更新】选项里选择【编程器固件】取消勾选保留 ART 只勾选保留 Bootloader ，上传之前使用编程器备份的 FLASH dump 文件。
也可直接使用之前备份的 ART 直接还原。

![](//files.hakr.xyz/images/2018-12-26_01-0002.png)

## 安装 OpenWrt

恢复完成并重启后，再次手动进入 Breed 恢复模式。在【固件更新】选项里选择【常规固件】只勾选固件并上传最新的 OpenWrt factory 固件，与此同时也可备份 ART 以便后续再次用到。固件可在 TL-MR10U 的 OpenWrt 官网页面下载。

![](//files.hakr.xyz/images//2018-12-26_01-0003.png)

如果是使用命令行安装，命令如下：

```bash
scp lede-17.01.6-ar71xx-generic-tl-mr10u-v1-squashfs-factory.bin root@192.168.1.1:/tmp/
ssh root192.168.1.1
mtd -r write lede-17.01.6-ar71xx-generic-tl-mr10u-v1-squashfs-factory.bin firmware
```

OpenWrt TP-Link TL-MR10U: [https://openwrt.org/toh/tp-link/tl-mr10u](https://openwrt.org/toh/tp-link/tl-mr10u)
Firmware OpenWrt Install: [lede-17.01.6-ar71xx-generic-tl-mr10u-v1-squashfs-factory.bin](http://downloads.openwrt.org/releases/17.01.6/targets/ar71xx/generic/lede-17.01.6-ar71xx-generic-tl-mr10u-v1-squashfs-factory.bin)
Firmware OpenWrt Upgrade: [lede-17.01.6-ar71xx-generic-tl-mr10u-v1-squashfs-sysupgrade.bin](http://downloads.openwrt.org/releases/17.01.6/targets/ar71xx/generic/lede-17.01.6-ar71xx-generic-tl-mr10u-v1-squashfs-sysupgrade.bin)

## 配置 OpenWrt

安装完成后首先在 Web 控制台里配置密码；配置子网网段以防发生冲突；配置无线功能；配置互联网访问功能，可选择使用网线连接互联网或使用无线连接到另一个可访问互联网的 WiFi AP。
如果你想在非本路由所在网段访问该路由器的 SSH 和 Web 控制台的话记得在密码设置页面勾选上允许从远端主机访问已经在防火墙里添加开放允许 `22` 和 `80` 端口访问。

更新软件包

```bash
opkg update
opkg list-upgradable | cut -f 1 -d ' ' | xargs opkg upgrade 
```

让 OpenWrt 支持挂载 U盘

```bash
opkg install usbutils
opkg install block-mount e2fsprogs kmod-usb-storage kmod-usb-storage-extras kmod-usb2 kmod-usb3 kmod-fs-ext4 kmod-fs-vfat
opkg install kmod-nls-cp437 kmod-nls-iso8859-1 kmod-nls-utf8
mkdir /mnt/sda1
block detect > /etc/config/fstab 
uci set fstab.@mount[0].enabled='1'
uci commit
uci set fstab.@global[0].check_fs='1'
uci commit
block mount
service fstab enable
```

安装常用工具

```bash
opkg install tcpdump htop lsof
```

## 遇到的坑

因为 ART 的问题我把官网所有能下载的 TL-MR10U 固件都刷了一遍；网上搜索到我 WiFi 不能用的解决办法都是修改 `/etc` 目录里的配置文件，然而我连无线网卡都识别不到。。。
TP-Link TL-MR10U 目前早已停产，能买到的都是二手的，另外这个系列还有 TL-MR11U, TL-MR12U, TL-MR13U 可以选择。

## Link

- [Obtaining Firmware [Old OpenWrt Wiki]](https://oldwiki.archive.openwrt.org/doc/howto/obtain.firmware)
- [Installing OpenWrt [Old OpenWrt Wiki]](https://oldwiki.archive.openwrt.org/doc/howto/generic.flashing)
- [OpenWrt Project: How to restore ART partition](https://openwrt.org/docs/guide-user/installation/restore_art_partition)
- [OpenWrt Project: Quick Image Building Guide](https://openwrt.org/docs/guide-developer/quickstart-build-images)
- [Openwrt中的Art区域](https://www.cnblogs.com/11hwu2/articles/3702313.html)
- [为品胜云座易充编译LEDE固件 - ZatBlog](http://blog.zyleon.net/2017/08/31/WMM003N/)
