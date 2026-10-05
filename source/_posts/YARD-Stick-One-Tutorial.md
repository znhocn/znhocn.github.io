---
title: YARD Stick One 使用教程
date: 2017-05-17 23:27:28
tags:
  - Hardware
  - Radio
  - YARD Stick One
---

[YARD Stick One](https://greatscottgadgets.com/yardstickone/) 是一款 1 GHz 以下的 USB 无线收发器设备，基于 TI 的 [CC1111](http://www.ti.com/product/CC1110-CC1111) 芯片。你可以将 YARD Stick One 用于进行各种遥控信号的重放，汽车遥控锁的安全研究等。

<!-- more -->

* 半双工发送和接收
* 工作频率-官方：300 - 348 MHz, 391 - 464 MHz 和 782 - 928 MHz
* 工作频率-非官方：281 - 361 MHz, 378 - 481 MHz 和 749 - 962 MHz
* 信号调制：ASK, OOK, GFSK, 2-FSK, 4-FSK, MSK
* 传输速率：500 kbps
* 全速 USB 2.0
* SMA 母头天线连接器（50欧姆）
* 软件控制的天线端口功率（3.3 V 时最大为 50 mA）
* 低通滤波器，用于在 800 和 900 MHz 频带中工作时消除谐波
* GoodFET 兼容的扩展和编程接口
* GIMME 兼容编程测试点
* 开源硬件

官方的工作频率是德州仪器 (TI) CC1111 芯片所支持的频率。但实际测试发现非官方的范围是可靠的，使用依旧正常。

* 注：YARD Stick One 并不支持在 Windows 上使用，虽然有第三方尝试更改固件去支持 Windows 10 的 Linux 子系统，但目前官方并没宣布支持 Windows 系统。

## 1. 使用

YARD State One 并不与任何通用的 SDR 软件相兼容，你只能使用他指定的客户端 [RfCat](https://bitbucket.org/atlas0fd00m/rfcat)。

### 1.1 安装 RfCat

从源码安装

```bash
apt-get install python-usb
wget https://bitbucket.org/atlas0fd00m/rfcat/downloads/rfcat_170508.tgz
tar xvzf rfcat_170508.tgz
cd rfcat_170508/
python setup.py install
```

Kali Linux

```bash
apt-get install rfcat
```

###  1.2 RfCat 帮助

```bash
rfcat -h
```
```
usage: rfcat [-h] [-r] [-i INDEX] [-s] [-f BASEFREQ] [-c INC] [-n SPECCHANS]
             [--bootloader] [--force]

optional arguments:
  -h, --help            show this help message and exit
  -r, --research        Interactive Python and the "d" instance to talk to
                        your dongle. melikey longtime.
  -i INDEX, --index INDEX
  -s, --specan          start spectrum analyzer
  -f BASEFREQ, --basefreq BASEFREQ
  -c INC, --inc INC
  -n SPECCHANS, --specchans SPECCHANS
  --bootloader          trigger the bootloader (use in order to flash the
                        dongle)
  --force               use this to make sure you want to set bootloader mode
                        (you *must* flash after setting --bootloader)
```

### 1.3 频谱分析

```bash
rfcat -s -f 433e6
```

![](//files.hakr.xyz/images/2017-05-17_01-0002.png)

### 1.4 RfCat 命令行

```bash
rfcat -r
```

```bash
'RfCat, the greatest thing since Frequency Hopping!'

Research Mode: enjoy the raw power of rflib

currently your environment has an object called "d" for dongle.  this is how
you interact with the rfcat dongle:
    >>> d.ping()  // 
    >>> d.setFreq(433000000)  // 设置信号频段
    >>> d.setMdmModulation(MOD_ASK_OOK)  // 设置信号调制模式
    >>> d.makePktFLEN(250)  // 
    >>> d.RFxmit("HALLO")  // 发送数据
    >>> d.RFrecv()  // 接收数据
    >>> print d.reprRadioConfig() // 打印配置选项


In [1]: print d.reprRadioConfig()  // 打印配置选项
== Hardware ==
Dongle:              YARDSTICKONE
Firmware rev:        0348
Compiler:            Not found! Update needed!
Bootloader:          CC-Bootloader

== Software ==
rflib rev:           450

== Frequency Configuration ==
Frequency:           901999877.929688 hz (0x259555L)
Channel:             0
Intermediate freq:   281250 hz
Frequency Offset:    0 +/-
Est. Freq Offset:    241

== Modem Configuration ==
Modulation:          2FSK
DRate:               38360.595703 hz
ChanBW:              93750.000000 hz
DEVIATION:           20507.812500 hz
Sync Mode:           15 of 16 bits must match
Min TX Preamble:     4 bytes
Chan Spacing:        199951.171875 hz
BSLimit:             No data rate offset compensation performed
DC Filter:           enabled
Manchester Encoding: disabled
Fwd Err Correct:     disabled

== Packet Configuration ==
Sync Word:           0x0C4E
Packet Length:       255
Length Config:       Fixed Packet Mode
Configured Address:  0x0
Preamble Quality Threshold: 4 * 2
Append Status:       No
Rcvd Packet Check:   No address check
Data Whitening:      off
Packet Format:       Normal mode
CRC:                 disabled

== AES Crypto Configuration ==
AES Mode:            CBC - Cipher Block Chaining
Crypt RF Input:      off
Crypt RF Output:     off

== Radio Test Signal Configuration ==
TEST2:               0x88
TEST1:               0x31
TEST0:               0x9
VCO_SEL_CAL_EN:      0x0

== Radio State ==
     MARCSTATE:      MARC_STATE_RX (d)
     DONGLE RESPONDING:  mode :c, last error# 1

== Client State ==
========================================================================================================================
     client thread cycles:      99/14
     client errored cycles:     0
     recv_queue:                (0 bytes) ''
     trash:                     (3 blobs) "[128, 142, (1495128220.831341, '')]"
     recv_mbox                  (2 keys)  "['0x42', '0xff']"
       app 0x42 (1 records)
             [0x7]    (0 frames)  "[]"

       app 0xff (4 records)
             [0x88]    (0 frames)  "[]"
             [0x80]    (0 frames)  "[]"
             [0x82]    (0 frames)  "[]"
             [0x86]    (0 frames)  "[]"


In [2]: d.ping()
PING: 26 bytes transmitted, received: 'ABCDEFGHIJKLMNOPQRSTUVWXYZ' (0.003433 seconds)
PING: 26 bytes transmitted, received: 'ABCDEFGHIJKLMNOPQRSTUVWXYZ' (0.003278 seconds)
PING: 26 bytes transmitted, received: 'ABCDEFGHIJKLMNOPQRSTUVWXYZ' (0.003287 seconds)
PING: 26 bytes transmitted, received: 'ABCDEFGHIJKLMNOPQRSTUVWXYZ' (0.003417 seconds)
PING: 26 bytes transmitted, received: 'ABCDEFGHIJKLMNOPQRSTUVWXYZ' (0.003243 seconds)
PING: 26 bytes transmitted, received: 'ABCDEFGHIJKLMNOPQRSTUVWXYZ' (0.003240 seconds)
PING: 26 bytes transmitted, received: 'ABCDEFGHIJKLMNOPQRSTUVWXYZ' (0.003528 seconds)
PING: 26 bytes transmitted, received: 'ABCDEFGHIJKLMNOPQRSTUVWXYZ' (0.003263 seconds)
PING: 26 bytes transmitted, received: 'ABCDEFGHIJKLMNOPQRSTUVWXYZ' (0.003441 seconds)
PING: 26 bytes transmitted, received: 'ABCDEFGHIJKLMNOPQRSTUVWXYZ' (0.003416 seconds)
Out[2]: (10, 0, 0.03384900093078613)

In [3]: d.setFreq(433000000)  // 设置信号频段为 433 MHz

In [4]: d.specan(433e6)  // 频谱分析界面，433e6 设置的是频段，这里使用的写法是科学计数法等同于 433000000

In [5]: bin(0x1234f)  // 进制转换 十六进制转二进制
Out[5]: '0b10010001101001111'

In [6]: help(d)  // 查看所有参数的帮助

In [7]: d.  // 按 Tab 键，查看所有参数
Display all 182 possibilities? (y or n)
d.FHSSxmit                   d.getChannel                 d.mac_SyncCell               d.rf_redirection             d.setMdmNumPreamble
d.RESET                      d.getChannels                d.makePktFLEN                d.rsema                      d.setMdmSyncMode
d.RFcapture                  d.getCompilerInfo            d.makePktVLEN                d.runEP5_recv                d.setMdmSyncWord
d.RFdump                     d.getDebugCodes              d.max_packet_size            d.runEP5_send                d.setModeIDLE
d.RFlisten                   d.getEnableMdmDCFilter       d.mhz                        d.run_ctrl                   d.setModeRX
d.RFrecv                     d.getEnableMdmFEC            d.nextChannel                d.scan                       d.setModeTX
d.RFtestLong                 d.getEnableMdmManchester     d.peek                       d.send                       d.setPktAddr
d.RFxmit                     d.getEnablePktAppendStatus   d.ping                       d.send_thread                d.setPktPQT
d.RFxmitLong                 d.getEnablePktCRC            d.poke                       d.send_threadcounter         d.setPower
d.adjustFreqOffset           d.getEnablePktDataWhitening  d.pokeReg                    d.setAESiv                   d.setRFRegister
d.bootloader                 d.getFHSSstate               d.printClientState           d.setAESkey                  d.setRFbits
d.calculateFsIF              d.getFreq                    d.printRadioConfig           d.setAESmode                 d.setRFparameters
d.calculateFsOffset          d.getFreqEst                 d.printRadioState            d.setAmpMode                 d.setRadioConfig
d.calculateMdmDeviatn        d.getFsIF                    d.radiocfg                   d.setBSLimit                 d.setRfMode
d.calculatePktChanBW         d.getFsOffset                d.recv                       d.setChannel                 d.setup
d.changeChannel              d.getInterruptRegisters      d.recvAll                    d.setChannels                d.setup24330MHz
d.checkRepr                  d.getLQI                     d.recv_event                 d.setEnDeCoder               d.setup900MHz
d.chipnum                    d.getMACdata                 d.recv_mbox                  d.setEnableCCA               d.setup900MHzContTrans
d.chipstr                    d.getMACthreshold            d.recv_queue                 d.setEnableMdmDCFilter       d.setup900MHzHopTrans
d.cleanup                    d.getMARCSTATE               d.recv_thread                d.setEnableMdmFEC            d.setup_rfstudio_902PktTx
d.clearDebugCodes            d.getMdmChanBW               d.recv_threadcounter         d.setEnableMdmManchester     d.specan
d.ctrl_thread                d.getMdmChanSpc              d.reprAESMode                d.setEnablePktAppendStatus   d.startHopping
d.debug                      d.getMdmDRate                d.reprClientState            d.setEnablePktCRC            d.stopHopping
d.devnum                     d.getMdmDeviatn              d.reprDebugCodes             d.setEnablePktDataWhitening  d.strobeModeCAL
d.discover                   d.getMdmModulation           d.reprFreqConfig             d.setFHSSstate               d.strobeModeFSTXON
d.endec                      d.getMdmNumPreamble          d.reprHardwareConfig         d.setFreq                    d.strobeModeIDLE
d.ep0GetAddr                 d.getMdmSyncMode             d.reprMACdata                d.setFsIF                    d.strobeModeRX
d.ep0Peek                    d.getMdmSyncWord             d.reprMdmModulation          d.setFsOffset                d.strobeModeReturn
d.ep0Ping                    d.getPartNum                 d.reprModemConfig            d.setMACdata                 d.strobeModeTX
d.ep0Poke                    d.getPktAddr                 d.reprPacketConfig           d.setMACperiod               d.testTX
d.ep0Reset                   d.getPktLEN                  d.reprRadioConfig            d.setMACthreshold            d.trash
d.ep5timeout                 d.getPktPQT                  d.reprRadioState             d.setMaxPower                d.xmit_event
d.freq_offset_accumulator    d.getRSSI                    d.reprRadioTestSignalConfig  d.setMdmChanBW               d.xmit_queue
d.getAESmode                 d.getRadioConfig             d.reprSoftwareConfig         d.setMdmChanSpc              d.xsema
d.getAmpMode                 d.idx                        d.reset_event                d.setMdmDRate
d.getBSLimit                 d.lowball                    d.resetup                    d.setMdmDeviatn
d.getBuildInfo               d.lowballRestore             d.rf_configure               d.setMdmModulation

In [10]: d.

```

### 1.5 接收信号

```bash
'RfCat, the greatest thing since Frequency Hopping!'

Research Mode: enjoy the raw power of rflib

currently your environment has an object called "d" for dongle.  this is how
you interact with the rfcat dongle:
    >>> d.ping()
    >>> d.setFreq(433000000)
    >>> d.setMdmModulation(MOD_ASK_OOK)
    >>> d.makePktFLEN(250)
    >>> d.RFxmit("HALLO")
    >>> d.RFrecv()
    >>> print d.reprRadioConfig()


In [1]: d.setFreq(433800000)  // 设置信号频段为 433.8 MHz

In [2]: d.setMdmModulation(MOD_ASK_OOK)  // 设置信号调制模式为 ASK / OOK

In [3]: d.setMdmDRate(4800)  // 

In [4]: d.setMaxPower()

In [5]: d.lowball()

In [6]: d.RFlisten()  // 开始监听数据
Entering RFlisten mode...  packets arriving will be displayed on the screen
(press Enter to stop)
(1495207873.725) Received:  80004405072024210db80100080041004098760290020241482206c3b000014bc18c000000280360200b0f20281b0f60000000000088490f23d9f2004140969ea0900433f930088290b0118028e48430540183f04010843c800180008c82840004042021000000000004c640020a43c0120ec1c4010010200000606c7c012168295b50084318f00000040a028242c8e428126200481100000031c838004151a000c2080081012800081800001e40000006405c120a00928420c2c8681843040a180000000000000016c000020646c0080000084040400000000000063e0000020200909206ae1000103f68540220e5bd05a06cfa10023616b040  | ..D...$!......A.@.v....AH".....K.....(.`....(..`......I.#...A@.....3.0......(..0T...@..<...........!.......@..C...........`l|.!h)[P.C........B..(.b.H....1.8.AQ.......(......@...@\........h.C...............F.....@@@......>............?hT......l...6..@
(1495207875.830) Received:  5322e404212004130000202300186020000000bc31842044218000120008410000100800400020000048681fb780010027008000002200002c3c9e0001008002c0c83a164240620ec5c0c61006000000000012044148740840025810c0000040039b043000000000043d8441484008488842000013e8180a6368e90b43000021200400000000000521ac50400140084200000000000014020500c87a04c01200b3c0060000040025150b2aa020000080c20a2212c00000000063e0310f7338290f63565e984840884b0f40d80a0040000002c200000008000202029252824000028604100000f750c200000000382d842003bf8400200056c0d0  | S"..!......#..`.....1..D!.....A.....@....Hh.....'...."..,<........:.B@b.............AHt.@.X....@...0.....=.AH@.H.B......ch..C..!........!.P@.@.B...........z...........%..*......."......c.1.s8).cV^.H@.K.@...@.............R.@........P.....8-........V..
(1495207876.325) Received:  b1a435883185958430057439c60e10c00001000010f0000000420251400212400040ccc20050000000173d8ea1143983b0f43d8490840040a10c00020000010f20a02b17404c7b0f434801001a2c2100000000004020794f43d8da14c7d1046187258c0000008000041d8e21ec256200040402210c21eda18400400000000f23e83b0f43d87a3c218ba58422000000000c2d87a06c6d0820241d0b631821c7050800000000031763e85b0f73f0c150d610c21ee610c00783b1fcf63ec639be75c2b1fc3c87b9ec2d87b0c01002063010800000000010d63e8790f43d829010118031839d843000000091fc1d83b1f73d85a1ec7d0ce1ec63811f  | ..5.1...0.t9.............B.Q@..@.@...P....=...9...=....@..........+.@L{.CH...,!.....@.yOC......a.%.........!.%b....!.!....@....#.;.C.z<!...".....-..lm..$..c.!.........c.[.s..P............>.9.u...<...-......0........>...=.....1...0.........=...}...c..
(1495207877.241) Received:  e0240400212c0004010f3c042000000000187a0b43d8fb1fdfc8fa1ec23387688d60000000000808010004880020244c0120000029210800080000000321e86d17a1ec1d0f21e42000326520000002000020a005010020001020e40000200874802000008000080485e02011036120040021842112908400000000018fa1e43d8fa3f8e3e863087de4204000000000110000000000004f63ffe3ecf90f63a84100490882000000000043d80b998000281042985b08431e2808000000000018fe1ec3c08202c04006004280c0ee820000000000243e8790f6024550361e87b28610f790c20004000000c2d8fa1ec3b1b1fce61ec2100182063000  | .$..!,....<.......z.C........3.h.`............$L....)!.......!.m.....!...2e....................t.............a...!.!...........=.....c.}..@...........Oc.....c.A.I.......C.....(.B.[.C.(..............@..B.........$>....EP6............................0.
(1495207877.706) Received:  ff5f63840c81b09433801085b480000000010004048082a0048080f43fafb18c21ef829800000000060e87d0f63eced8fa1ed3c63ef63182b0b6220290863a8210101080008600a000000000000000acb0100284905000801083bfd6b0000000000650d61ec7c0f21245c01a04c0020020000000040010503c8798f43d87b1f420801007be8630000000013d0f6bf86c7d0fa1fc733f4ba80282f65ac7d0f9100058b81042109614040002000010b2020480801241d082048210c3dec710000000029aed7bfb1fbe1ec2dc4218fbc841000400000047d8721e47f0f43c7b586309690000000000000001092002030120a8e10720040125a10c00  | ._c.....3...................?...!............>......>.1..."...:......................P............P......E.............P<...=.........0....=.k.l}...s?K....Z.....X..B...............A...............{......B...A.....G.r.G..<{Xc.i....................%...
```

### 1.5 发送 OOK 信号

方法一

```bash
'RfCat, the greatest thing since Frequency Hopping!'

Research Mode: enjoy the raw power of rflib

currently your environment has an object called "d" for dongle.  this is how
you interact with the rfcat dongle:
    >>> d.ping()
    >>> d.setFreq(433000000)
    >>> d.setMdmModulation(MOD_ASK_OOK)
    >>> d.makePktFLEN(250)
    >>> d.RFxmit("HALLO")
    >>> d.RFrecv()
    >>> print d.reprRadioConfig()


In [1]: d.setFreq(433e6)  // 设置信号频段为 433 MHz

In [2]: d.setMdmModulation(MOD_ASK_OOK)  // 设置信号调制模式为 ASK / OOK

In [3]: d.setMdmDRate(int(1.0/0.000550))  // 

In [4]: d.RFxmit("\x8E\x8E\x88\x88\x8E\x88\x88\x00\x00\x00" * 20)  // 发送十六进制编码的信号 "\x8E\x8E\x88\x88\x8E\x88\x88\x00\x00\x00" 20次
```

方法二

```bash
'RfCat, the greatest thing since Frequency Hopping!'

Research Mode: enjoy the raw power of rflib

currently your environment has an object called "d" for dongle.  this is how
you interact with the rfcat dongle:
    >>> d.ping()
    >>> d.setFreq(433000000)
    >>> d.setMdmModulation(MOD_ASK_OOK)
    >>> d.makePktFLEN(250)
    >>> d.RFxmit("HALLO")
    >>> d.RFrecv()
    >>> print d.reprRadioConfig()


In [1]: d.setFreq(433800000)  // 设置信号频段为 433.8 MHz

In [2]: d.setMdmModulation(MOD_ASK_OOK)  // 设置信号调制模式为 ASK / OOK

In [3]: d.makePktFLEN(4)  // 设置包长度为 4 以为我们这里只发送 4 bytes

In [4]: d.setMdmDRate(4800)  // 设置波特率

In [5]: d.setMaxPower()

In [6]: for i in range(0,15):d.RFxmit('\xDE\xAD\xBE\xEF')  // 重复发送 15 次数据

```

### 1.6 使用 Python 脚本

Python 脚本

```python
#!/usr/bin/python
#
# Ths is a rudimentary implementation of packet reception using YARD Stick One
# with RfCat demonstrated in Rapid Radio Reversing presented at ToorCon 17
# (2015).
#
# File Name: sl.py
# usage from rfcat interactive shell:
#   %run sl.py
#   rxsl(d)

from rflib import *
import sys

# This validity check is only verifying certain bytes that are present in all
# packets.  It really should be followed up (or replaced) by a checksum
# verification.
def packet_valid(p):
	if ord(p[0]) != 0x6d:
		return False
	if ord(p[1]) != 0xb6:
		return False
	if ord(p[6]) != 0x6d:
		return False
	if ord(p[7]) != 0xb6:
		return False
	if (ord(p[29]) & 0xfc) != 0:
		return False
	return True

# This could probably be simpler and/or easier to read.  It extracts every
# third bit in order to decode the pulse width modulation (PWM).  The PWM
# implemented by StealthLock is well behaved in that the pulse durations and
# interval durations are all one or two times the length of a time unit and
# data bits are represented by a consistent number (3) of time units.  This is
# the time unit I have used in the RfCat symbol rate configuration, so a long
# pulse appears as symbols (1, 1, 0) and a short pulse appears as (1, 0, 0).
def pwm_decode(p):
	biginteger = 0
	for byte in p:
		biginteger <<= 8
		biginteger |= ord(byte)
	biginteger >>= 12
	out = 0
	for i in range(28, (len(p)*8-12)/3, 1):
		out <<= 1
		out |= ((biginteger & 1) ^ 1)
		biginteger >>=3
	return out

# checksum byte is 0xff minus 8-bit addition of previous bytes, like so:
# hex(0xff-(0x02+0x98+0x76+0xff+0xff)&0xff)

def rxsl(device):  # 函数方法
	device.setFreq(314980000)
	device.setMdmModulation(MOD_ASK_OOK)
	device.setMdmDRate(2450)
	device.setPktPQT(0)
	device.setMdmSyncMode(2)
	device.setMdmSyncWord(0x06db)
	device.setMdmNumPreamble(0)
	device.setMaxPower()
	device.lowball()
	device.makePktFLEN(30)

	while not keystop():
		try:
			pkt, ts = device.RFrecv()
			if packet_valid(pkt):
				#print "Received:  %s" % pkt.encode('hex')
				print "0x%012x" % pwm_decode(pkt)
		except ChipconUsbTimeoutException:
			pass
	sys.stdin.read(1)
```

在 RfCat 命令行内调用

```bash
# rfcat -r
'RfCat, the greatest thing since Frequency Hopping!'

Research Mode: enjoy the raw power of rflib

currently your environment has an object called "d" for dongle.  this is how
you interact with the rfcat dongle:
    >>> d.ping()
    >>> d.setFreq(433000000)
    >>> d.setMdmModulation(MOD_ASK_OOK)
    >>> d.makePktFLEN(250)
    >>> d.RFxmit("HALLO")
    >>> d.RFrecv()
    >>> print d.reprRadioConfig()


In [1]: %run sl.py  // 运行 sl.py 脚本

In [2]: rxsl(d)  // 使用脚本内的方法

```

## 2. rfpwnon 信号暴力穷举

[rfpwnon](https://github.com/exploitagency/github-rfpwnon) 是一款基于 rfcat 实现的的无线电信号暴力穷举攻击的 Python 脚本

### 2.1 安装
```bash
apt-get install python python-pip rfcat
pip install bitstring
wget https://raw.githubusercontent.com/exploitagency/github-rfpwnon/master/rfpwnon.py
./rfpwnon.py --help
```

### 2.2 帮助信息

```bash
# ./rfpwnon.py -h
usage: rfpwnon.py [-h] [-v] [-f BASEFREQ] [-b BAUDRATE] [-l BINLENGTH]
                  [-r REPEATTIMES] [--keys] [-p PPAD] [-t TPAD] [--raw]
                  [--tri] [--show]

Application to use a rfcat compatible device to brute force a particular AM
OOK or raw binary signal.

optional arguments:
  -h, --help      show this help message and exit  // 显示帮助信息
  -v, --version   show program's version number and exit  // 显示软件版本
  -f BASEFREQ     Specify the target frequency to transmit on, default is  // 指定信号频段，默认为 915000000 Hz
                  915000000.
  -b BAUDRATE     Specify the baudrate of the signal, default is 2000.  // 指定波特率，默认为 2000
  -l BINLENGTH    Specify the binary length of the signal to brute force. By  // 指定要生成的二进制长度
                  default this is the binary length before pwm encoding. When
                  the flag --raw is set this is the binary length of the pwm
                  encoded signal.
  -r REPEATTIMES  Specify the number of times to repeat the signal. By default  // 指定一个信号重复的次数
                  this is set to 1 and uses the de bruijn sequence for speed.   // 当设为 1 时使用 de bruijn 序列的速度
                  When set greater than one the script sends each possible      // 当设置大于 1 时脚本会花费更多的时间去执行
                  permutation of the signal individually and takes much longer
                  to complete. For some applications the signal is required to
                  be sent multiple times.
  --keys          Displays the values being transmitted in binary, hex, and  // 显示正在传输的二进制，十六进制和十进制值
                  decimal both before and after pwm encoding.
  -p PPAD         Specify your own binary padding to be attached before the  // 指定要附加在所生成二进制之前的固定二进制值
                  brute forced binary.
  -t TPAD         Specify your own binary padding to be attached after the  // 指定要附加在所生成二进制之后的固定二进制值
                  brute forced binary.
  --raw           This flag disables the script from performing the pwm
                  encoding of the binary signal. When set you must specify the
                  full pwm encoded binary length using -l.
  --tri           This flag sets up the script to brute force a trinary
                  signal.
  --show          Prints de Bruijn sequence before transmitting.  // 显示 de Bruijn 序列

```

### 2.3 使用实例

指定波特率为 `2000` 生成 `4` 位长的所有二进制信号，每个信号重复发送 `5` 次

```bash
./rfpwnon.py -f 315000000 -b 2000 -l 4 -r 5
```

指定波特率为 `1818` 每个信号的开头的二进制编码为 `100101` 在其之后生成 `10` 为长的所有二进制信号，每个信号重复发送 `2` 次

```bash
./rfpwnon.py -f 315060000 -b 1818 -p 100101 -l 10 -r 2
```

指定波特率为 `1818` 生成 `16` 为长的所有二进制信号，每个信号重复发送 `2` 次。这会花费很多时间来发送完所有的信号。

```bash
./rfpwnon.py -f 315060000 -b 1818 -l 16 -r 2
```

## 3. ToorChat

[ToorChat](https://github.com/hathcox/ToorChat) 是一款使用 [ToorCon 2013 徽章](https://greatscottgadgets.com/tc13badge/)的聊天应用程序。
YARD State One 的硬件设计上与 ToorCon 2013 badge 使用的芯片与固件是一样的，所以这程序也是可以通用的。
ToorChat 聊天工具使用时需要至少两个 RfCat 支持的硬件才能通过无线电正常通信。

```bash
git clone https://github.com/hak5/ToorChat.git
cd ToorChat
./toorchat.py
```

![](//files.hakr.xyz/images/2017-05-17_01-0003.png)

## 4. 固件

YARD Stick One 的固件就是 [rfcat](https://bitbucket.org/atlas0fd00m/rfcat) 提供的，Bootloader 使用的是 [CC-Bootloader](https://github.com/AdamLaurie/CC-Bootloader)。固件和硬件是开源的，你可以自己编写固件实现你需要的功能。

----------

## 链接

* [Great Scott Gadgets - YARD Stick One](http://greatscottgadgets.com/yardstickone/)
* [GitHub: YARD Stick One](https://github.com/greatscottgadgets/yardstick)
* [rfcat project](https://bitbucket.org/atlas0fd00m/rfcat)
* [Hacking fixed key remotes](https://andrewmohawk.com/2012/09/06/hacking-fixed-key-remotes/)
* [Hacking fixed key remotes with (only) RFCat](http://andrewmohawk.com/2015/08/31/hacking-fixed-key-remotes-with-only-rfcat/)
* [How to begin hacking with the YARD Stick One - Hak5 1908](https://www.youtube.com/watch?v=pkTlTCUeec0)
* [How to Hack Wireless Remotes with Radio Replay Attacks - Hak5 1909](https://www.youtube.com/watch?v=F3bISk5t8cA)
* [Hacking Wireless Doorbells and Software Defined Radio tips - Hak5 1910](https://www.youtube.com/watch?v=EZU2AZtfJbI)
* [Hacking Keyless Entry Remotes - Hak5 1911](https://www.youtube.com/watch?v=LqmVaf2KHYA)
* [How to Hack Radio with Brute Force Attacks - Hak5 1912](https://www.youtube.com/watch?v=blpycY5JCm0)
* [Radio Hacking: Reverse Engineering Protocols Part 1 - Hak5 1913](https://www.youtube.com/watch?v=eVqIe3na_Zk)
* [Radio Hacking: Reverse Engineering Protocols Part 2 - Hak5 1914](https://www.youtube.com/watch?v=vf38-8LbDuw)
* [Yard Stick One vs RTL-SDR vs PandwaRF: Fight of the dwarves](https://pandwarf.com/news/yard-stick-one-vs-rtl-sdr-vs-pandwarf/)
* [Rapid Radio Reversing, ToorCon 2015](http://greatscottgadgets.com/2015/12-29-rapid-radio-reversing-toorcon-2015/)
* [opensesame-yardstick](https://github.com/gyaresu/opensesame-yardstick)
* [Hak5 1908 – How to begin hacking with the YARD Stick One](https://www.hak5.org/episodes/hak5-1908-how-to-begin-hacking-with-the-yard-stick-one)
* [You know how to send my signal — Setting up RFCat from scratch](http://leetupload.com/blagosphere/index.php/2014/02/16/you-know-how-to-send-my-signal-setting-up-rfcat-from-scratch/)
* [rfpwnon.py rfcat ASK OOK brute force tool](https://www.legacysecuritygroup.com/index.php/categories/13-sdr/22-rfpwnon-py-the-ultimate-rfcat-ask-ook-brute-force-tool)
