---
title: YubiKey 4 PGP 功能使用教程
date: 2017-06-03 00:23:15
tags:
  - YubiKey
  - PGP
---

[YubiKey](https://www.yubico.com/) 是一款用于安全认证的硬件工具，其中的 YubiKey 4, YubiKey 4 Nano, YubiKey 4C, YubiKey NEO, YubiKey NEO-n，这些产品型号是包含 OpenPGP Card 功能的。

你可将你的私钥移动到 YubiKey 里，在需要使用的时候插上，而不必担心私钥泄露或被恶意程序盗取，并且支持在多种操作系统上使用。

<!-- more -->

## 1、生成密钥对

```bash
$ gpg --gen-key

gpg (GnuPG) 2.0.30; Copyright (C) 2015 Free Software Foundation, Inc.
This is free software: you are free to change and redistribute it.
There is NO WARRANTY, to the extent permitted by law.

Please select what kind of key you want:
   (1) RSA and RSA (default)
   (2) DSA and Elgamal
   (3) DSA (sign only)
   (4) RSA (sign only)
Your selection? 1  // 输入 1 选择默认的 RSA 加密算法
RSA keys may be between 1024 and 4096 bits long.
What keysize do you want? (2048) 4096
Requested keysize is 4096 bits
Please specify how long the key should be valid.
         0 = key does not expire
      <n>  = key expires in n days
      <n>w = key expires in n weeks
      <n>m = key expires in n months
      <n>y = key expires in n years
Key is valid for? (0)  // 直接回车选择 0 默认永不过期
Key does not expire at all
Is this correct? (y/N) y  // 输入 y 确定 下一步

GnuPG needs to construct a user ID to identify your key.

Real name: Test User  // 输入你的姓名
Email address: test@example.com  // 输入你的邮箱
Comment:  // 输入你的附加信息，可以是你的网络 ID 名称，或者直接回车跳过
You selected this USER-ID:
    "Test User <test@example.com>"

Change (N)ame, (C)omment, (E)mail or (O)kay/(Q)uit? o  // 输入 o 回车后会要求你设置一个私钥的密码
You need a Passphrase to protect your secret key.

We need to generate a lot of random bytes. It is a good idea to perform
some other action (type on the keyboard, move the mouse, utilize the
disks) during the prime generation; this gives the random number
generator a better chance to gain enough entropy.
We need to generate a lot of random bytes. It is a good idea to perform
some other action (type on the keyboard, move the mouse, utilize the
disks) during the prime generation; this gives the random number
generator a better chance to gain enough entropy.
gpg: key A8C37A46 marked as ultimately trusted
public and secret key created and signed.

gpg: checking the trustdb
gpg: 3 marginal(s) needed, 1 complete(s) needed, PGP trust model
gpg: depth: 0  valid:   2  signed:   0  trust: 0-, 0q, 0n, 0m, 0f, 2u
pub   4096R/F891791F 2017-05-29
      Key fingerprint = 628C 7B5D D284 224A 3321  4369 BC71 9F68 F891 791F
uid       [ultimate] Test User <test@example.com>
sub   4096R/46D4D220 2017-05-29

```

## 2、添加验证密钥

```bash
$ gpg --expert --edit-key F891791F

gpg (GnuPG) 2.0.30; Copyright (C) 2015 Free Software Foundation, Inc.
This is free software: you are free to change and redistribute it.
There is NO WARRANTY, to the extent permitted by law.

Secret key is available.

pub  4096R/F891791F  created: 2017-05-29  expires: never       usage: SC
                     trust: ultimate      validity: ultimate
sub  4096R/46D4D220  created: 2017-05-29  expires: never       usage: E
[ultimate] (1). Test User <test@example.com>

gpg> addkey
This key is not protected.
Please select what kind of key you want:
   (3) DSA (sign only)
   (4) RSA (sign only)
   (5) Elgamal (encrypt only)
   (6) RSA (encrypt only)
   (7) DSA (set your own capabilities)
   (8) RSA (set your own capabilities)
Your selection? 8

Possible actions for a RSA key: Sign Encrypt Authenticate
Current allowed actions: Sign Encrypt

   (S) Toggle the sign capability
   (E) Toggle the encrypt capability
   (A) Toggle the authenticate capability
   (Q) Finished

Your selection? A

Possible actions for a RSA key: Sign Encrypt Authenticate
Current allowed actions: Sign Encrypt Authenticate

   (S) Toggle the sign capability
   (E) Toggle the encrypt capability
   (A) Toggle the authenticate capability
   (Q) Finished

Your selection? S

Possible actions for a RSA key: Sign Encrypt Authenticate
Current allowed actions: Encrypt Authenticate

   (S) Toggle the sign capability
   (E) Toggle the encrypt capability
   (A) Toggle the authenticate capability
   (Q) Finished

Your selection? E

Possible actions for a RSA key: Sign Encrypt Authenticate
Current allowed actions: Authenticate

   (S) Toggle the sign capability
   (E) Toggle the encrypt capability
   (A) Toggle the authenticate capability
   (Q) Finished

Your selection? Q
RSA keys may be between 1024 and 4096 bits long.
What keysize do you want? (2048) 4096
Requested keysize is 4096 bits
Please specify how long the key should be valid.
         0 = key does not expire
      <n>  = key expires in n days
      <n>w = key expires in n weeks
      <n>m = key expires in n months
      <n>y = key expires in n years
Key is valid for? (0)
Key does not expire at all
Is this correct? (y/N) y
Really create? (y/N) y
We need to generate a lot of random bytes. It is a good idea to perform
some other action (type on the keyboard, move the mouse, utilize the
disks) during the prime generation; this gives the random number
generator a better chance to gain enough entropy.

pub  4096R/F891791F  created: 2017-05-29  expires: never       usage: SC
                     trust: ultimate      validity: ultimate
sub  4096R/46D4D220  created: 2017-05-29  expires: never       usage: E
sub  4096R/C10AE6D4  created: 2017-05-29  expires: never       usage: A
[ultimate] (1). Test User <test@example.com>

gpg> q
Save changes? (y/N) y

```

## 3、备份密钥

```bash
gpg --armor --output public-key.asc --export F891791F  // 导出公钥到文件
gpg --armor --output private-key.asc --export-secret-keys F891791F  // 导出私钥到文件
gpg --armor --output subkeys-key.asc --export-secret-subkeys F891791F  // 导出子钥到文件
```

## 4、设置 OpenPGP 卡

```bash
$ gpg --card-edit

Application ID ...: D2760001240102000060000000420000
Version ..........: 2.1
Manufacturer .....: Yubico
Serial number ....: 00000042
Name of cardholder: [not set]
Language prefs ...: [not set]
Sex ..............: unspecified
URL of public key : [not set]
Login data .......: [not set]
Signature PIN ....: forced
Key attributes ...: 2048R 2048R 2048R
Max. PIN lengths .: 127 127 127
PIN retry counter : 3 0 3
Signature counter : 0
Signature key ....: [none]
Encryption key....: [none]
Authentication key: [none]
General key info..: [none]

gpg/card> admin  // 进入管理员模式
Admin commands are allowed

gpg/card> passwd  // 设置密码
gpg: OpenPGP card no. D2760001240102000060000000420000 detected

1 - change PIN
2 - unblock PIN
3 - change Admin PIN
4 - set the Reset Code
Q - quit

Your selection? 1  // 输入 1 选择设置普通 PIN 码，默认的 PIN 码为 123456 如果是新设备或重置后的都是默认码。
PIN changed.       // 设置时会先要求你输入普通 PIN 码的当前的密码，然后是设置新的 PIN 码，再是新的 PIN 码的二次确认。如果当前的 PIN 码输错 3 次就会被锁。

1 - change PIN
2 - unblock PIN
3 - change Admin PIN
4 - set the Reset Code
Q - quit

Your selection? 3  // 输入 3 选择设置 Admin PIN 码，默认的 PIN 码为 12345678 如果是新设备或重置后的都是默认码。
PIN changed.       // 设置时会先要求你输入 Admin PIN 码的当前的密码，然后是设置新的 PIN 码，再是新的 PIN 码的二次确认。如果当前的 PIN 码输错 3 次就会被锁。

1 - change PIN
2 - unblock PIN
3 - change Admin PIN
4 - set the Reset Code
Q - quit

Your selection? 2  // （可选）输入 2 选择设置 unblock PIN 码，也就解锁码，用于在普通 PIN 码被锁后解锁并重置新的普通 PIN 码。unblock PIN 码只能用于解锁普通 PIN 码，无法用于 Admin PIN 码。
PIN unblocked and new PIN set.  // 设置时会先要求你输入 Admin PIN 码的当前的密码，然后是设置新的 unblock PIN 码，再是新的 unblock PIN 码的二次确认。

1 - change PIN
2 - unblock PIN
3 - change Admin PIN
4 - set the Reset Code
Q - quit

Your selection? q  // 输入 q 退出密码设置

gpg/card> name  // 设置姓名
Cardholder's surname: User  // 持卡人的姓
Cardholder's given name: Test  // 持卡人的名字

gpg/card> lang  // 设置语言
Language preferences: en

gpg/card> sex  // 设置性别 M 为男性 F 为女性
Sex ((M)ale, (F)emale or space): m

gpg/card> url  // 设置公钥的网络链接
URL to retrieve public key: https://www.example.com/public-key.asc  // 链接地址

gpg/card> login  // 设置用户名
Login data (account name): test

gpg/card> 

Application ID ...: D2760001240102000060000000420000
Version ..........: 2.1
Manufacturer .....: Yubico
Serial number ....: 00000042
Name of cardholder: Test User
Language prefs ...: en
Sex ..............: male
URL of public key : https://www.example.com/public-key.asc
Login data .......: test
Signature PIN ....: forced
Key attributes ...: 2048R 2048R 2048R
Max. PIN lengths .: 127 127 127
PIN retry counter : 3 3 3  // 3 3 3 分别表示普通 PIN 码、unblock PIN 码、Admin PIN 码的输入错误计数器，默认为 3 输错一次减 1 ，减到 0 会被锁，被锁之前输入正确的 PIN 码会自动还原计数器。
Signature counter : 0
Signature key ....: [none]
Encryption key....: [none]
Authentication key: [none]
General key info..: [none]

gpg/card> quit  // 退出 OpenPGP 卡设置

```

* 注：在 Yubikey 4 中引入了一个新功能，当用户输入正确的 PIN 码和 **触摸硬件** 后才会进行签名、解密或身份验证操作。具体参考 [YubiKey 4 touch](https://developers.yubico.com/PGP/Card_edit.html) 里的内容。

## 5、移动密钥到 YubiKey 4

* 注：OpenPGP Card 是支持在自身硬件上直接生成密钥对的，但多数使用 PGP 非对称加密的用户都有自己的密钥所以这里使用移动已有密钥到 YubiKey 里。直接在硬件上生成密钥对是在 admin 模式下使用 `generate` 命令，生成的密钥是无法导出备份的！

```bash
$ gpg --edit-key F891791F

gpg (GnuPG) 2.0.30; Copyright (C) 2015 Free Software Foundation, Inc.
This is free software: you are free to change and redistribute it.
There is NO WARRANTY, to the extent permitted by law.

Secret key is available.

pub  4096R/F891791F  created: 2017-05-29  expires: never       usage: SC
                     trust: ultimate      validity: ultimate
sub  4096R/46D4D220  created: 2017-05-29  expires: never       usage: E
sub  4096R/C10AE6D4  created: 2017-05-29  expires: never       usage: A
[ultimate] (1). Test User <test@example.com>

gpg> toggle

sec  4096R/F891791F  created: 2017-05-29  expires: never
ssb  4096R/46D4D220  created: 2017-05-29  expires: never
ssb  4096R/C10AE6D4  created: 2017-05-29  expires: never
(1)  Test User <test@example.com>

gpg> keytocard
Really move the primary key? (y/N) y
Signature key ....: [none]
Encryption key....: [none]
Authentication key: [none]

Please select where to store the key:
   (1) Signature key
   (3) Authentication key
Your selection? 1

You need a passphrase to unlock the secret key for
user: "Test User <test@example.com>"
4096-bit RSA key, ID F891791F, created 2017-05-29


sec  4096R/F891791F  created: 2017-05-29  expires: never
                     card-no: 0006 00000042
ssb  4096R/46D4D220  created: 2017-05-29  expires: never
ssb  4096R/C10AE6D4  created: 2017-05-29  expires: never
(1)  Test User <test@example.com>

gpg> key 1

sec  4096R/F891791F  created: 2017-05-29  expires: never
                     card-no: 0006 00000042
ssb* 4096R/46D4D220  created: 2017-05-29  expires: never
ssb  4096R/C10AE6D4  created: 2017-05-29  expires: never
(1)  Test User <test@example.com>

gpg> keytocard
Signature key ....: 743A 2D58 688A 9E9E B4FC  493F 70D1 D7A8 13AF CE85
Encryption key....: [none]
Authentication key: [none]

Please select where to store the key:
   (2) Encryption key
Your selection? 2

You need a passphrase to unlock the secret key for
user: "Test User <test@example.com>"
4096-bit RSA key, ID 46D4D220, created 2017-05-29


sec  4096R/F891791F  created: 2017-05-29  expires: never
                     card-no: 0006 00000042
ssb* 4096R/46D4D220  created: 2017-05-29  expires: never
                     card-no: 0006 00000042
ssb  4096R/C10AE6D4  created: 2017-05-29  expires: never
(1)  Test User <test@example.com>

gpg> key 1

sec  4096R/F891791F  created: 2017-05-29  expires: never
                     card-no: 0006 00000042
ssb  4096R/46D4D220  created: 2017-05-29  expires: never
                     card-no: 0006 00000042
ssb  4096R/C10AE6D4  created: 2017-05-29  expires: never
(1)  Test User <test@example.com>

gpg> key 2

sec  4096R/F891791F  created: 2017-05-29  expires: never
                     card-no: 0006 00000042
ssb  4096R/46D4D220  created: 2017-05-29  expires: never
                     card-no: 0006 00000042
ssb* 4096R/C10AE6D4  created: 2017-05-29  expires: never
(1)  Test User <test@example.com>

gpg> keytocard
Signature key ....: 743A 2D58 688A 9E9E B4FC  493F 70D1 D7A8 13AF CE85
Encryption key....: 8D17 89A0 5C2F B804 22E5  5C04 8A68 9CC0 D742 1CDF
Authentication key: [none]

Please select where to store the key:
   (3) Authentication key
Your selection? 3

You need a passphrase to unlock the secret key for
user: "Test User <test@example.com>"
4096-bit RSA key, ID C10AE6D4, created 2017-05-29


sec  4096R/F891791F  created: 2017-05-29  expires: never
                     card-no: 0006 00000042
ssb  4096R/46D4D220  created: 2017-05-29  expires: never
                     card-no: 0006 00000042
ssb* 4096R/C10AE6D4  created: 2017-05-29  expires: never
                     card-no: 0006 00000042
(1)  Test User <test@example.com>

gpg> quit
Save changes? (y/N) y

```

当前密钥移动到 OpenPGP 卡后就没法再导出无须硬件卡就可直接使用的密钥了，如果你在上面的步骤没有导出备份密钥，那么 OpenPGP 卡里是私钥将是你唯一的私钥且没法备份。

查看 OpenPGP 卡状态信息

```bash
$ gpg --card-status

Application ID ...: D2760001240102000060000000420000
Version ..........: 2.1
Manufacturer .....: Yubico
Serial number ....: 00000042
Name of cardholder: Test User
Language prefs ...: en
Sex ..............: male
URL of public key : https://www.example.com/public-key.asc
Login data .......: test
Signature PIN ....: forced
Key attributes ...: 4096R 4096R 4096R
Max. PIN lengths .: 127 127 127
PIN retry counter : 3 3 3
Signature counter : 0
Signature key ....: 743A 2D58 688A 9E9E B4FC  493F 70D1 D7A8 13AF CE85
      created ....: 2017-05-29 22:11:07
Encryption key....: 8D17 89A0 5C2F B804 22E5  5C04 8A68 9CC0 D742 1CDF
      created ....: 2017-05-29 22:11:07
Authentication key: 628C 7B5D D284 224A 3321  4369 BC71 9F68 F891 791F
      created ....: 2017-05-29 22:11:07
General key info..: pub  4096R/F891791F 2017-05-29 Test User <test@example.com>
sec>  4096R/F891791F  created: 2017-05-29  expires: never
                      card-no: 0006 00000042
ssb>  4096R/46D4D220  created: 2017-05-29  expires: never
                      card-no: 0006 00000042
ssb>  4096R/C10AE6D4  created: 2017-05-29  expires: never
                      card-no: 0006 00000042

```

## 6、在其他电脑上使用

当你配置好了一个 YubiKey 的 OpenPGP 智能卡后你可以在其他任何支持 PGP 客户端的电脑上插上 YubiKey 使用你是私钥进行签名、加密、认证操作，而不用担心私钥泄露。

从文件导入公钥

```bash
gpg --import public-key.asc
```

或者从公钥服务器上导入公钥

```bash
gpg --keyserver keys.gnupg.net --recv 0xF891791F
```

插入 YubiKey 查看 OpenPGP 卡信息，这一步会自动映射 YubiKey 里的私钥到 OpenPGP 的配置里。

```bash
gpg --card-status
```

设置密钥在本系统上的信任状态

```bash
$ gpg --edit-key F891791F

gpg (GnuPG) 1.4.21; Copyright (C) 2015 Free Software Foundation, Inc.
This is free software: you are free to change and redistribute it.
There is NO WARRANTY, to the extent permitted by law.


pub  4096R/F891791F  created: 2017-05-29  expires: never       usage: SC
                     trust: ultimate      validity: ultimate
sub  4096R/46D4D220  created: 2017-05-29  expires: never       usage: E
sub  4096R/C10AE6D4  created: 2017-05-29  expires: never       usage: A
[ unknown] (1). Test User <test@example.com>

gpg> trust
pub  4096R/F891791F  created: 2017-05-29  expires: never       usage: SC
                     trust: unknown      validity: unknown
sub  4096R/46D4D220  created: 2017-05-29  expires: never       usage: E
sub  4096R/C10AE6D4  created: 2017-05-29  expires: never       usage: A
[unknown] (1). Test User <test@example.com>

Please decide how far you trust this user to correctly verify other users' keys
(by looking at passports, checking fingerprints from different sources, etc.)

  1 = I don't know or won't say
  2 = I do NOT trust
  3 = I trust marginally
  4 = I trust fully
  5 = I trust ultimately
  m = back to the main menu

Your decision? 5  // 输入 5 设置为终极信任
Do you really want to set this key to ultimate trust? (y/N) y

pub  4096R/F891791F  created: 2017-05-29  expires: never       usage: SC
                     trust: ultimate      validity: unknown
sub  4096R/46D4D220  created: 2017-05-29  expires: never       usage: E
sub  4096R/C10AE6D4  created: 2017-05-29  expires: never       usage: A
[unknown] (1). Test User <test@example.com>
Please note that the shown key validity is not necessarily correct
unless you restart the program.

gpg> q

```

查看系统上的密钥

```bash
$ gpg -k  // 查看所有的公钥

~/.gnupg/pubring.gpg
-----------------------------------------------
pub   4096R/F891791F 2017-05-29
uid       [ultimate] Test User <test@example.com>
sub   4096R/46D4D220 2017-05-29
sub   4096R/C10AE6D4 2017-05-29

$ gpg -K  // 查看所有的私钥

~/.gnupg/secring.gpg
-----------------------------------------------
sec>  4096R/F891791F 2017-05-29
      Card serial no. = 0006 00000042  // 这里可以看出这个私钥的位置是指向 OpenPGP 智能卡的
uid                  Test User <test@example.com>
ssb>  4096R/46D4D220 2017-05-29
ssb>  4096R/C10AE6D4 2017-05-29
```

公钥加密文件

```bash
gpg -ea -r test@example.com msg.txt
```

私钥解密文件

```bash	
gpg msg.txt.asc
```

文件签名

```bash
gpg -o msg.txt.sig -ab msg.txt
```

签名验证

```bash
gpg --verify msg.txt.sig
```

## 7、重置 YubiKey 4 PGP 功能

新建一个 `reset.txt` 的文本文件，并写入以下内容

```
/hex
scd serialno
scd apdu 00 20 00 81 08 40 40 40 40 40 40 40 40
scd apdu 00 20 00 81 08 40 40 40 40 40 40 40 40
scd apdu 00 20 00 81 08 40 40 40 40 40 40 40 40
scd apdu 00 20 00 81 08 40 40 40 40 40 40 40 40
scd apdu 00 20 00 83 08 40 40 40 40 40 40 40 40
scd apdu 00 20 00 83 08 40 40 40 40 40 40 40 40
scd apdu 00 20 00 83 08 40 40 40 40 40 40 40 40
scd apdu 00 20 00 83 08 40 40 40 40 40 40 40 40
scd apdu 00 e6 00 00
scd apdu 00 44 00 00
/echo Card has been successfully reset.
```

重置 YubiKey 4 的 OpenPGP 卡功能

```bash
gpg-connect-agent -r reset.txt
```

重新插拔 YubiKey 并查看 OpenPGP 卡状态信息，如果查看信息遇到错误可能是 OpenPGP 卡功能还没打开，需要通过命令手动启用。

```
$ gpg --card-status

gpg: selecting openpgp failed: Card error  // OpenPGP Card 错误
gpg: OpenPGP card not available: Card error
```

启用 OpenPGP 卡功能

```bash
gpg-connect-agent -–hex
> scd apdu 00 44 00 00
D[0000]  90 00                                              ..
OK
>  // 直接回车推出

```

手动启用 `OK` 后你可能还需要重新插拔 YubiKey 再重新查看 OpenPGP 卡状态信息

```bash
$ gpg --card-status

Application ID ...: D2760001240102000060000000420000
Version ..........: 2.1
Manufacturer .....: Yubico
Serial number ....: 00000042
Name of cardholder: [not set]
Language prefs ...: [not set]
Sex ..............: unspecified
URL of public key : [not set]
Login data .......: [not set]
Signature PIN ....: forced
Key attributes ...: 2048R 2048R 2048R
Max. PIN lengths .: 127 127 127
PIN retry counter : 3 0 3
Signature counter : 0
Signature key ....: [none]
Encryption key....: [none]
Authentication key: [none]
General key info..: [none]
```

重置后的 OpenPGP 卡可以重新进行配置。


----------

### 链接

* [The GNU Privacy Handbook](https://www.gnupg.org/gph/en/manual.html)
* [YubiKey PGP](https://developers.yubico.com/PGP/)
* [How to Use Your YubiKey With OpenPGP](https://www.yubico.com/support/knowledge-base/categories/articles/use-yubikey-openpgp/)
* [PIN and Management Key](https://developers.yubico.com/yubikey-piv-manager/PIN_and_Management_Key.html)
* [How to Reset Your Applet on Your YubiKey](https://www.yubico.com/support/knowledge-base/categories/articles/reset-applet-yubikey/)
* [YubiKey ResetApplet](https://developers.yubico.com/ykneo-openpgp/ResetApplet.html)
* [Make OpenPGP Card](https://openpgpcard.org/makecard/)
* [Guide to using YubiKey as a SmartCard for GPG and SSH](https://github.com/drduh/YubiKey-Guide)
* [Using an OpenPGP Smartcard with GnuPG](https://spin.atomicobject.com/2014/02/09/gnupg-openpgp-smartcard/)
* [Yubikey/OpenPGP Smartcards for Newbies](https://www.sidorenko.io/blog/2014/11/04/yubikey-slash-openpgp-smartcards-for-newbies/)
* [PGP and SSH keys on a Yubikey NEO](https://www.esev.com/blog/post/2015-01-pgp-ssh-key-on-yubikey-neo/)
* [Using GPG with Smart Cards](https://www.jfry.me/articles/2015/gpg-smartcard/)
