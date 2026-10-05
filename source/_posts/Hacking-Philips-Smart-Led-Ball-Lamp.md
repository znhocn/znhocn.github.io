---
title: Hacking 飞利浦智能球泡灯
date: 2017-12-17 02:12:11
password:
abstract:
message:
tags:
  - Hacking
  - Hardware
  - ESP8266
---

[飞利浦智能球泡灯](https://item.mi.com/1172100033.html)是一款可连接 WiFi 通过米家手机 APP 进行控制的小米 IoT 智能设备。
<!-- more -->
## 1 拆解硬件

拆解篇幅请参考 [《米家的飞利浦智睿球泡灯拆解与固件提取》](https://blog.hakr.xyz/posts/2017/12/08/Philips-Smart-Led-Ball-Lamp-Dismantling-and-Firmware-extraction/) 这篇文章。其控制模块用的是 [ESP8266](http://espressif.com/zh-hans/products/hardware/esp8266ex/overview) 系列里的 [ESP-WROOM-02](http://espressif.com/zh-hans/products/hardware/esp-wroom-02/overview) 模块。

## 2 串口调试

### 2.1 硬件连接

拆下 WiFi 控制模块后去掉外面包的热缩管，用热风枪吹掉背面的一颗 R41 的贴片元件(否则无法调试这个模块)。

![](//files.hakr.xyz/images/2017-12-08_01-0006.jpg)

再按下图所示在模块的对应针脚上焊上跳线接到面包板上，使用 USB to TTL 工具连接到电脑，通过虚拟终端进行调试。

![](//files.hakr.xyz/images/2017-12-08_01-0007.png)

**注:** 图上两个模式的接法是反的，`IO0` 接 `GND` 进入的是刷固件的模式，RTOS 不会启动。`IO0` 接 `3.3V` 时进入的是串口模式，可以看到调试信息。

![](//files.hakr.xyz/images/2017-12-08_01-0008.jpg)

### 2.2 调试信息

给模块设备上电后可以在虚拟终端上看到输出的启动信息，与简单的命令行控制台。

```
state: 5 -> 0 (0)
rm 0
pm close 7 0 0/18186986
del if0
usl
sul 0 0
disconnect from ssid WIFI_012345, reason 8
▒▒*▒P*V▒▒ET▒▒▒▒T▒▒+▒▒u▒U+UZ▒Z▒T▒▒TQT▒QQ▒▒jP▒T▒▒u▒▒▒▒▒ZT▒(E▒▒▒▒Q▒Eu▒▒▒▒▒QB▒▒▒U*B▒u▒▒▒ZT▒(UE▒▒▒▒Q*Eu▒▒▒▒▒URB▒▒▒Օ▒▒▒▒ZT▒(UE▒▒▒▒Q▒▒E▒j*Q▒▒EQT+▒▒u▒▒▒Zյ▒▒jUJTE▒▒jU▒▒▒▒*U▒UT▒▒▒
 ▒UT▒E▒▒▒uT
           ▒▒▒▒▒▒UE▒▒▒TT▒U▒▒UU(Z▒UR▒▒▒▒UQ*Q▒UT*E▒▒P▒P▒Vխ▒A▒QQQT▒OS SDK ver: 1.5.0-dev(7f7a714) compiled @ May 15 2017 17:20:32
phy ver: 1055_1, pp ver: 10.7

rf cal sector: 507
tcpip_task_hdl : 3fff2080, prio:10,stack:512
idle_task_hdl : 3fff2140,prio:0, stack:384
tim_task_hdl : 3fff4980, prio:2,stack:512
reset reason: 4
08:00:00.003 [PT] Booting into normal mode...
08:00:00.003 [PT] DeviceId: ZigBee Node, Dimmable Light
pwm version:1.0.2
08:00:00.003 [PT] RESTORE EVENT
08:00:04.439 [PT] pSwitchOnRstCount: 1
08:00:04.440 [PT] power on: bri 254
08:00:04.440 [PT] power on: cct 5700
08:00:04.440 [PT] StartUp to light
data  : 0x3ffe8000 ~ 0x3ffe8abc, len: 2748
rodata: 0x3ffe8b90 ~ 0x3ffeae18, len: 8840
bss   : 0x3ffeae18 ~ 0x3fff1ea0, len: 28808
heap  : 0x3fff1ea0 ~ 0x40000000, len: 57696

_|      _|  _|_|_|  _|_|_|    _|_|
_|_|  _|_|    _|      _|    _|    _|
_|  _|  _|    _|      _|    _|    _|
_|      _|    _|      _|    _|    _|
_|      _|  _|_|_|  _|_|_|    _|_|
psm init success
OTP read OK
JENKINS BUILD NUMBER: N/A
BUILD TIME: Jun 12 2017,10:09:36
MIIO APP VER: 1.3.0_0033
MIIO MCU VER: N/A
MIIO WIFI VER: 1.5.0-dev(7f7a714)
MIIO DID: 60566054
MIIO WIFI MAC: 34ce0099b601
free_heap[after init]: 12432
*****xiaomi init pass*****
mode : sta(34:ce:00:99:b6:01)
add if0
scandone
state: 0 -> 2 (b0)
state: 2 -> 3 (0)
state: 3 -> 5 (10)
add 0
aid 6
pm open phy_2,type:2 0 0
cnt

connected with WIFI_012345, channel 11
dhcp client start...
connect to ssid WIFI_012345, channel 11
wifi phy mode: 3
ip:192.168.2.109,mask:255.255.255.0,gw:192.168.2.2
ip:192.168.2.109,mask:255.255.255.0,gw:192.168.2.2

help    // 输入 help 命令
Debug commandlist
=================
[command]               [ARG]
----------------------- -------------
help
reboot
restore
setwifi                 ARG: <"ssid"> <"passwd">  RET: ok/ error
getwifi                 ARG: none RET: <"ssid"> <rssi> / error
gettemp                 ARG: get temperature data
stop_mcmd               ARG: stop miio cmd RET: none
model                   ARG: <model_string> RET: <model>
getversion              ARG: get firmware version
getheap                 ARG: get heap: ok/error
mac                     ARG: none RET: ok/error
bri                     ARG: bright pwm test, 0-100 RET: ok/error
cct                     ARG: cct pwm test, 0-100 RET: ok/error
setcct                  ARG: cct control test, 0-100 RET: ok/error
setbri                  ARG: bri control test, 0-100 RET: ok/error
setbricct               ARG: bri and cct control test, 0-100 RET: ok/error
applyscene              ARG: apply scene: ok/error

......
```

## 3 网络调试

网络调试我们需要用到一个可以使用命令行控制并带有 `tcpdump` 的 WiFi 路由器实现进/出数据包的抓取和 LAN Tap 工具实现进/出数据包的实时查看+抓取。
无线路由器一般使用 OpenWrt 系统的无线路由器都支持，这个我使用的是中国版的 WiFi Pineapple。

抓取所有通过 WiFi 连接的数据包

```bash
tcpdump -i wlan0-1 -w wlan0-1_$(date +%s).cap
```



![](//files.hakr.xyz/images/)

## 4 固件提取

* 请参考 [《米家的飞利浦智睿球泡灯拆解与固件提取》](https://blog.hakr.xyz/posts/2017/12/08/Philips-Smart-Led-Ball-Lamp-Dismantling-and-Firmware-extraction/)

## 5 固件逆向

[ESP8266](http://espressif.com/zh-hans/products/hardware/esp8266ex/overview) 芯片使用的是 [Xtensa](https://en.wikipedia.org/wiki/Tensilica)。

### 5.1 使用 IDA

IDA Pro 本身并不支持对 Xtensa 架构的反汇编，需要安装 [ida-xtensa](https://github.com/themadinventor/ida-xtensa) 这个第三方的插件来实现反汇编的功能。
ida-xtensa 插件目前仅支持 IDA Pro 6.6 以上的版本，但在最新的 IDA Pro 7.0 上使用会报错，本人后来使用的是 IDA Pro 6.8。
下载 ida-xtensa 插件把 `xtensa.py` 文件复制到 IDA Pro 安装目录里的 `procs/` 文件夹里后重新打开 IDA Pro。

![](//files.hakr.xyz/images/2017-12-17_01-0001.png)
![](//files.hakr.xyz/images/2017-12-17_01-0002.png)

### 5.2 使用 Radare2

Radare2 原生支持对 Xtensa 架构的反汇编(并非所有版本都支持)。

查看当前的 Radare2 是否支持 Xtensa 架构反汇编

```bash
$ rasm2 -L | grep xtensa
_dAe  32         xtensa      GPL3    XTensa CPU
```

使用 Radare2 打开固件

```bash
$ r2 -a xtensa flash_0.bin
```

![](//files.hakr.xyz/images/2017-12-17_01-0003.png)

> 目前本人的 Xtensa 汇编指令能力有限，后续的反汇编分析内容暂时写不出来。。。

### 5.3 固件移植

尝试将之前 Dump 出来的固件移植到到 ESP8266 的开发板，但启动时在虚拟终端上看到了如下的报错信息循环传输。

```
 ets Jan  8 2013,rst cause:2, boot mode:(3,7)

load 0x40100000, len 2416, room 16
tail 0
chksum 0x01
load 0x3ffe8000, len 764, room 8
tail 4
chksum 0x60
load 0x3ffe82fc, len 792, room 4
tail 4
chksum 0xee
csum 0xee

2nd boot version : 1.6.1(30daab7)
  SPI Speed      : 40MHz
  SPI Mode       : DIO
  SPI Flash Size & Map: 32Mbit(512KB+512KB)
jump to run user1 @ 1000

OS SDK ver: 1.5.0-dev(7f7a714) compiled @ May 15 2017 17:20:32
rf_cal[0] !=0x05,is 0x00
```

这是由于固件是从 ESP8266 系列里的 ESP-WROOM-02 模块里 Dump 出来的，我使用的 ESP8266 开发板是基于 ESP-12E 的，虽然两个模块使用的处理芯片是一个型号的，
但两个模块使用 Flash 并不一样，ESP-WROOM-02 的 Flash 大小是 `2MB`，ESP-12E 使用的 Flash 是 `4MB` 固件无法识别正确的存储空间导致无法正常启动，这跟开发有关，并非所有固件都这样。
于是我又重新买了一个基于 ESP-WROOM-02 模块的开发板重新尝试。

![](//files.hakr.xyz/images/)

给开发板上电后在虚拟终端上没看到之前的报错，但又遇到新的报错信息。

```
▒~1A▒|▒▒▒,▒h▒▒X▒OS SDK ver: 1.5.0-dev(7f7a714) compiled @ May 15 2017 17:20:32A▒▒*E(a▒▒▒ (▒dA#I-Aea*U▒I,!▒k▒t▒{▒S{`K
phy ver: 1055_1, pp ver: 10.7

rf cal sector: 1019
tcpip_task_hdl : 3fff2080, prio:10,stack:512
idle_task_hdl : 3fff2140,prio:0, stack:384
tim_task_hdl : 3fff4980, prio:2,stack:512
reset reason: 4
08:00:00.004 [PT] Booting into normal mode...
08:00:00.004 [PT] DeviceId: ZigBee Node, Dimmable Light
pwm version:1.0.2
08:00:00.005 [PT] RESTORE EVENT
08:00:00.007 [PT] pSwitchOnRstCount: 1
08:00:00.007 [PT] power on: bri 254
08:00:00.007 [PT] power on: cct 5700
08:00:00.007 [PT] StartUp to light
data  : 0x3ffe8000 ~ 0x3ffe8abc, len: 2748
rodata: 0x3ffe8b90 ~ 0x3ffeae18, len: 8840
bss   : 0x3ffeae18 ~ 0x3fff1ea0, len: 28808
heap  : 0x3fff1ea0 ~ 0x40000000, len: 57696

_|      _|  _|_|_|  _|_|_|    _|_|
_|_|  _|_|    _|      _|    _|    _|
_|  _|  _|    _|      _|    _|    _|
_|      _|    _|      _|    _|    _|
_|      _|  _|_|_|  _|_|_|    _|_|
psm init success
error: OTP read error, -2
```

提示的是 OTP 读取错误。我在 [ESP8266 Memory Map](http://wiki.jackslab.org/ESP8266_Memory_Map#dport0) 里找到了 OTP 地址的信息，是厂商烧录在芯片里的只读数据，这里存储着硬件的 MAC 地址。
我在硬件的 Flash 模式下使用 `esptool.py` 读取了这个地址块的数据，正好与设备的 MAC 地址吻合，

```bash
$ esptool.py -p /dev/ttyUSB0 dump_mem 0x3FF00000 256 dport0_1.bin
$ xxd dport0_1.bin
0000000: 0000 0000 0000 0000 0f08 0000 0300 0000  ................
0000010: 0000 0000 0000 0000 ff00 ffff 0000 0000  ................
0000020: 0000 0000 0600 0000 0000 0000 0000 0000  ................
0000030: 4040 0000 0000 0000 4108 0000 0000 0000  @@......A.......
0000040: 0000 0000 0000 0000 0000 0000 0000 0000  ................
0000050: ccb4 2601 b699 1372 26ba c239 00ce 3480  ..&....r&..9..4.
0000060: 0000 0000 0000 0000 0000 0000 0000 0000  ................
0000070: 0000 0000 0000 0000 0000 0000 0000 0000  ................
0000080: 0000 0000 0000 0000 0000 0000 0000 0000  ................
0000090: 0000 0000 0000 0000 0000 0000 0000 0000  ................
00000a0: 0000 0000 0000 0000 0000 0000 0000 0000  ................
00000b0: 0000 0000 0000 0000 0000 0000 0000 0000  ................
00000c0: 0000 0000 0000 0000 0000 0000 0000 0000  ................
00000d0: 0000 0000 0000 0000 0000 0000 0000 0000  ................
00000e0: 0000 0000 0000 0000 0000 0000 0000 0000  ................
00000f0: 0000 0000 0000 0000 0000 0000 0000 0000  ................
```

**结论:** 小米进行开发时使用了 OTP 地址的数据作为硬件的验证，OTP 保存的是 MAC 地址，且设备的 MAC 地址厂商查询到的就是小米，所以除非修改固件跳过这个验证否则无法成功移植到其他厂商生产的同型号的模块上。

## 参考链接

* [Reverse Engineering ESP8266 — часть 1](https://habrahabr.ru/post/255135/)
* [Reverse Engineering ESP8266 — часть 2](https://habrahabr.ru/post/255153/)
* [Solving game2 from the badge of Black Alps 2017 with radare2](https://dustri.org/b/solving-game2-from-the-badge-of-black-alps-2017-with-radare2.html)
* [ESP8266 Memory Map](http://wiki.jackslab.org/ESP8266_Memory_Map)
