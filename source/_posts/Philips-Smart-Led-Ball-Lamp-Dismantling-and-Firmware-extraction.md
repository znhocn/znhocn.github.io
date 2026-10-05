---
title: 米家的飞利浦智睿球泡灯拆解与固件提取
date: 2017-12-08 18:51:54
password:
abstract:
message:
tags:
  - Mijia
  - ESP8266
  - Firmware
---

[飞利浦智睿球泡灯](https://item.mi.com/1172100033.html)是一款可连接 WiFi 的小米智能设备，可通过米家手机应用进行控制。通过外包装上的 [CMIIT-ID: 2016DP3252](https://fccid.io/CMIIT-ID-2016DP3252) 号可查询到其使用的控制芯片是 ESP8266 系列里的 [ESP-WROOM-02](http://espressif.com/zh-hans/products/hardware/esp-wroom-02/overview) 模块。
<!-- more -->
# 1 设备拆解

## 1.1 打开灯罩

使用热风枪先把粘胶加热一下，对着粘合处灯泡转着吹，别一直吹一个点否则会直接融化灯罩。

加热的差不多的时候可以用手掰开一条缝隙，拿可以撬的工具沿着边一点点撬开，这里使用开夏威夷果的钥匙挺方便的。

![](//files.hakr.xyz/images/2017-12-08_01-0001.jpg)

## 1.2 拆除 LED 板

先用电烙铁拆焊掉 3 根导线，再把 LED 板撬下来，板与底座是胶粘合的，可以尝试先加热一下再撬。

![](//files.hakr.xyz/images/2017-12-08_01-0002.jpg)

## 1.3 取出电源与控制模块

电源模块与控制模块是焊在一起的，被一颗胶粘着与底座固定。需要用美工刀把这颗胶割开，再把整个模块向外拉。底部的零线和火线与灯座的金属接触部分并非是焊接上的而是卡住的，拉的时候用点力，多拉几次就能取出来。

![](//files.hakr.xyz/images/2017-12-08_01-0003.jpg)

## 1.4 拆下 WiFi 控制模块

WiFi 控制模块是通过 4 个针脚焊接在电源模块上的，需要用电烙铁来拆下它。

![](//files.hakr.xyz/images/2017-12-08_01-0004.jpg)
![](//files.hakr.xyz/images/2017-12-08_01-0005.jpg)

## 1.5 焊接跳线

拆下 WiFi 控制模块后去掉外面包的热缩管，再用热风枪吹掉背面的一颗 R41 的贴片元件(否则无法调试这个模块)。

![](//files.hakr.xyz/images/2017-12-08_01-0006.jpg)

再按下图所示在模块的对应针脚上焊上跳线接到面包板上 

* 注: 图上两个模式的接法是反的，`IO0` 接 `GND` 进入的是刷固件的模式，RTOS 不会启动。`IO0` 接 `3.3V` 时进入的是串口模式，可以看到调试信息。

![](//files.hakr.xyz/images/2017-12-08_01-0007.png)
![](//files.hakr.xyz/images/2017-12-08_01-0008.jpg)

# 2 固件提取

## 2.1 安装工具软件

WiFi 控制模块是 ESP8266 的芯片，这里我们使用 [esptool](https://github.com/espressif/esptool) 这个工具。
这是一个 [Python](https://www.python.org/) 写的工具所以你需要先安装 `python` 和 `python-pip` 再用 `pip` 安装 `esptool` 。

```bash
pip install esptool
```

## 2.2 固件提取操作

使用 USB to TTL 工具 (建议使用 CP2102 芯片的) 把设备连接到你的电脑找到设备的串口号。

查看模块上的 Flash 芯片信息

```bash
# esptool.py -p COM3 flash_id

esptool.py v2.2
Connecting....
Detecting chip type... ESP8266
Chip is ESP8266EX
Uploading stub...
Running stub...
Stub running...
Manufacturer: c8
Device: 4015
Detected flash size: 2MB    // 这个可以看到 Flash 芯片的大小是 2MB
Hard resetting...
```

读取芯片数据到文件


```bash
esptool.py -p COM3 read_flash 0x00000 0x200000 flash_0.bin    // 0x00000 是起始地址， 0x200000 是结束地址，这里所指定 dump 的大小是 2MB
```

一些使用示例

```bash
esptool.py -p COM3 chip_id    // 查看主控芯片信息
esptool.py -p COM3 flash_id    // 查看 Flash 信息
esptool.py -p COM3 read_mac    // 查看 MAC 地址
esptool.py -p COM3 image_info my_app.bin    // 读取二进制固件文件的信息
esptool.py -p COM3 dump_mem 0x3FF00000 65552 dport0_0.bin    // dump 芯片内 Dport0 地址块的数据到文件
esptool.py -p COM3 dump_mem 0x3ffe8000 2748 data_0.bin
esptool.py -p COM3 dump_mem 0x3ffe8b90 8840 rodata_0.bin
esptool.py -p COM3 dump_mem 0x3ffeae18 28808 bss_0.bin
esptool.py -p COM3 dump_mem 0x3fff1ea0 57696 heap_0.bin
esptool.py -p COM3 dump_mem 0x40000000 65536 iram_0.bin
esptool.py -p COM3 read_flash_status    // 查看 Flash 状态
esptool.py -p COM3 read_flash 0x00000 0x100000 flash_0.bin   // dump 1MB 大小的 Flash 数据到文件
esptool.py -p COM3 read_flash 0x00000 0x200000 flash_0.bin   // 2MB
esptool.py -p COM3 read_flash 0x00000 0x400000 flash_0.bin   // 4MB
esptool.py -p COM3 read_flash 0x00000 0x800000 flash_0.bin   // 4MB
esptool.py -p COM3 read_flash 0x00000 0x1600000 flash_0.bin  // 16MB
esptool.py -p COM3 erase_flash    // 擦除 Flash 芯片上的所有数据
esptool.py -p COM3 write_flash 0x00000 my_app.bin    // 写入新固件到 Flash
```

更多用法去查看帮助

```
esptool.py help
```
