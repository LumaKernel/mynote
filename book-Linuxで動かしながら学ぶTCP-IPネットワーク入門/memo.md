# Linuxで動かしながら学ぶTCP-IPネットワーク入門

## ip recipes

```
sudo ip netns add ns1
sudo ip netns delete ns1
sudo ip --all netns delete
sudo ip link add ns1-veth0 type veth peer name gw-veth0
sudo ip link set ns1-veth0 netns ns1
sudo ip netns exec ns1 bash
```

## ip link show dev lo

netns 作って試すところ。

```
root@ip-172-31-39-242:/home/ubuntu# ip link show lo
1: lo: <LOOPBACK> mtu 65536 qdisc noqueue state DOWN mode DEFAULT group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
```

せっかくなので意味調べてみるか。`up` して `down` したら挙動変わってなんか不思議だったので。

- `qdisc`: queuing discipline
  - `noop`: ブラックホール。送られたパケットはすべて破棄される。
    + netns 作った直後の `lo` はこれ。
    + `ping localhost` するとエラーになり、 `ping: connect: Network is unreachable`
  - `noqueue`: 何もキューしない。
    + `up` して `down` するとこの状態になる。
    + `ping localhost` すると、 `100% packet loss` になる


References:
  - http://linux-ip.net/gl/ip-cref/ip-cref-node17.html

全部文献探そうとしたけど見つからんかった。


## router

```text
  <ns1>
  ns1-veth0:192.0.2.1/24
    |
------------------------
              |
        gw-veth0:192.0.2.254/24
            <router>
        gw-veth1:198.51.100.254/24
              |
------------------------
    |
  ns2-veth0:198.51.100.1/24
  <ns2>
```

脱線するけど、 `ping -I gw-veth0 198.51.100.1` して `ns1-veth0` から `tcpdump` すると。


```
root@ip-172-31-39-242:/home/ubuntu# tcpdump
tcpdump: verbose output suppressed, use -v or -vv for full protocol decode
listening on ns1-veth0, link-type EN10MB (Ethernet), capture size 262144 bytes
^C12:18:10.299333 ARP, Request who-has 198.51.100.1 tell 192.0.2.254, length 28
12:18:11.331295 ARP, Request who-has 198.51.100.1 tell 192.0.2.254, length 28
12:18:12.355272 ARP, Request who-has 198.51.100.1 tell 192.0.2.254, length 28

3 packets captured
3 packets received by filter
0 packets dropped by kernel
```

`192.0.2.254` から `198.51.100.1` を名乗る ARP パケットが送られてくる。


### forwarding するところ


```
# ルーティング設定したあと

# 設定の確認

root@ip-172-31-39-242:/home/ubuntu# sysctl -a | grep ip_forward
net.ipv4.ip_forward = 0
net.ipv4.ip_forward_update_priority = 1
net.ipv4.ip_forward_use_pmtu = 0

# 以下でもいい

root@ip-172-31-39-242:/home/ubuntu# cat /proc/sys/net/ipv4/ip_forward
0

# 設定する


root@ip-172-31-39-242:/home/ubuntu# sysctl net.ipv4.ip_forward=1
net.ipv4.ip_forward = 1
root@ip-172-31-39-242:/home/ubuntu# cat /proc/sys/net/ipv4/ip_forward

# このとき以下が 1 に変わる

root@ip-172-31-39-242:/home/ubuntu# sysctl -a | grep --regex 'ipv4\.conf\.all\.forwarding'
net.ipv4.conf.all.forwarding = 1
1

# IPv6 なら

root@ip-172-31-39-242:/home/ubuntu# sysctl -a | grep --regex 'ipv6\.conf\.all\.forwarding'
net.ipv6.conf.all.forwarding = 0

root@ip-172-31-39-242:/home/ubuntu# cat /proc/sys/net/ipv6/conf/all/forwarding
0

root@ip-172-31-39-242:/home/ubuntu# sysctl net.ipv4.ip_forward=1
```


## ルーター2つ


```text
  <ns1>
  ns1-veth0:192.0.2.1/24
    |
------------------------
              |
        gw1-veth0:192.0.2.254/24
            <router1>
        gw1-veth1:203.0.113.1/24
              |
------------------------
              |
        gw2-veth0:203.0.113.2/24
            <router2>
        gw2-veth1:198.51.100.254/24
              |
------------------------
    |
  ns2-veth0:198.51.100.1/24
  <ns2>
```


`tcpdump` で疎通確認するときに、 `-i any` ないと一番上の IF 見るんだなあとなった。少し混乱した。

## ip,router,イーサネット用語

- ブロードバンドルータ: 家庭にある一般的なルータ
- ブロードキャストフレーム: 宛先がブロードキャストアドレスになっているイーサネットフレーム
- ブロードキャストドメイン: ブロードキャストフレームが届く範囲
- スタティックルーティング: `ip route add` でやるように手動で経路を設定する
- ダイナミックルーティングルーティング: BGP や OSPF などを使い自動で情報を教え合う


## tcpdump

- `-t`: 時刻表示しない
- `-n`: IP 逆引きしない
- `-e`: ethernete の情報を出す
- `-l`: 位置行ごとに flush
  - netns exec 環境ではこれがないとリアルタイムに書き出してくれない
  - `-U` だとパケットごとらしい
- `-A`: ASCII 文字で表示
  - `.....Hello, World` みたいに表示するやつ


## ARP

- `ip neigh flush all` で ARP キャッシュをリセット
- `ip neigh` で ARP 関連
  - `ip n` まで略せそうだな
  - 使った直後は `REACHABLE` でその後 `STALE` になるな


## Bridge

```
ip link add br0 type bridge
ip link set ns1-br0 master br0

# MAC アドレステーブルを確認する方法

bridge fdb show br br0
33:33:00:00:00:01 dev br0 self permanent
01:00:5e:00:00:6a dev br0 self permanent
33:33:00:00:00:6a dev br0 self permanent
01:00:5e:00:00:01 dev br0 self permanent
33:33:ff:64:74:be dev br0 self permanent
00:00:5e:00:53:01 dev ns1-br0 master br0
42:cd:ac:6e:c6:67 dev ns1-br0 vlan 1 master br0 permanent
42:cd:ac:6e:c6:67 dev ns1-br0 master br0 permanent
33:33:00:00:00:01 dev ns1-br0 self permanent
01:00:5e:00:00:01 dev ns1-br0 self permanent
33:33:ff:6e:c6:67 dev ns1-br0 self permanent
00:00:5e:00:53:02 dev ns2-br0 master br0
02:2b:da:31:61:49 dev ns2-br0 vlan 1 master br0 permanent
02:2b:da:31:61:49 dev ns2-br0 master br0 permanent
33:33:00:00:00:01 dev ns2-br0 self permanent
01:00:5e:00:00:01 dev ns2-br0 self permanent
33:33:ff:31:61:49 dev ns2-br0 self permanent
00:00:5e:00:53:03 dev ns3-br0 master br0
6e:d5:62:a5:22:57 dev ns3-br0 vlan 1 master br0 permanent
6e:d5:62:a5:22:57 dev ns3-br0 master br0 permanent
33:33:00:00:00:01 dev ns3-br0 self permanent
01:00:5e:00:00:01 dev ns3-br0 self permanent
33:33:ff:a5:22:57 dev ns3-br0 self permanent
```

### ブリッジ関連用語

- スイッチングハブ、スイッチ、ハブ: ブリッジをするデータリンク層の機器
- ポート: TCP/UDP とは別。1つ1つのインタフェース。ケーブルの接続先など
- MAC アドレステーブル: MACアドレス <-> ポート を結びつける学習することで得たテーブル
- ブリッジ: スイッチングハブをより一般化した用語。データリンク層でフレームを送信する機器のこと
  - イーサネットブリッジ: データリンク層の実装がイーサネットであるとき特別に強調する場合
- ネットワークブリッジ: Linux で実装されたブリッジ機能 ( type bridge な IF )
- リピータハブ: 物理層(レイヤ1)の機器。電気信号を転送するだけ (流れるフレームの意味を理解しない)
  - どのポートがどの MAC アドレスか、ということを知らないので全部に流す
- ミラーリングポート: スイッチングハブなどにある、すべてのフレームを流すポート。ネットワークのデバッグなどに用いる


## netcat


```
# UDP

nc -ulnv 127.0.0.1 54321
nc -u 127.0.0.1 54321

sudo tcpdump -i lo -tnlA "udp and port 54321"

# TCP

nc -lnv 127.0.0.1 54321
nc 127.0.0.1 54321

sudo tcpdump -i lo -tnlA "tcp and port 54321"
```


### nc

- `-u`: UDP
- `-l`: server
- `-n`: 逆引きしない
- `-v`: verbose


## http/1.1

実家のような安心感

## dns

> メッセージのサイズが 512 バイトをこえるときは TCP が使われます。

へー。クソ長い domain name を resolve (dig) しようとしたけどフォーマット違反で普通に怒られたし、無視するオプションつけても長さたりねーって言われて終わった。
クライアントは実装依存なのかな。と思ったり。

https://datatracker.ietf.org/doc/html/rfc7766

上記で定められてるっぽい？

## /etc/resolv.conf

Ubuntu20.04 はデフォルトで /etc/resolv.conf を管理

### DNS 関連の名前とか

- リゾルバ。より正確にスタブリゾルバ
- ネームサーバー。フルサービスリゾルバ、キャッシュサーバーとも
- プライマリサーバ、セカンダリサーバ
- キャッシュサーバ、コンテンツサーバ

基本はキャッシュサーバに問い合わせる。
した２つの分類は別。

## dhcp

クライアント・サーバ方式。
UDPっぽい。port `68 -> 67` だったけど決まってんのかな。

> 67	Assigned	Yes			Bootstrap Protocol (BOOTP) server;[11] also used by Dynamic Host Configuration Protocol (DHCP)
> 68	Assigned	Yes			Bootstrap Protocol (BOOTP) client;[11] also used by Dynamic Host Configuration Protocol (DHCP)

source: [wikipedia//List of TCP and UDP port numbers](https://en.wikipedia.org/wiki/List_of_TCP_and_UDP_port_numbers)

BOOTP というのと同じ位置として決められているみたいだ


```sh
dnsmasq \
  --dhcp-range=192.0.2.100,192.0.2.200,255.255.255.0 \
  --interface=s-veth0 \
  --port 0 \
  --no-resolv \
  --no-daemo
```

`dnsmasq` は DHCP としても使えるようです。

```sh
dhclient -d c-veth0
```

`dhclient` はデフォルトで入ってたっぽい。もうこの `dhclient` の実装が全部感あるな。 dhcp 解釈してネットワークの設定をして...といろいろやっているのか
DNSのネームサーバの設定や、時刻動機するための NTP サーバの設定もできる。


中身は見てみると面白い、何も知らないやつが自分を知ろうとするみたいな。

- `0.0.0.0` -> `255.255.255.255` で client -> server に通信が起こる。
- server は `ip1` 使ってる人いるー？みたいに ARP Probe を broadcast で飛ばす
- おまえ(client)は `ip1` だ！って `server_ip` -> `ip1` に DHCP の返答。 DHCP Offer とか DHCP ACK って書いてあり
- server 側が `ip1` 誰？と ARP 飛ばす
- client が無事に自分が `ip1` だと答える

という流れだった。いつもこうなのかは知らん。


### global ip のブロードバンドルータへの割当

- DHCP が使われることもある。ケーブルテレビ局など。
- フレッツでは代わりに PPPoE 、より正確に IPCP というプロトコルのオプションでアドレスが配布される。
- IPv6 では PPPoE の他に、ICMPv5 のルータ広告 (Router Advertisement) というメッセージや、DHCPv6 といったプロトコルを使う

なんかトラブルが合ったときにモニョモニョ PPPoE でテストさせられたな...

[OS の標準機能による接続設定方法を知りたい（Windows 10）](https://support.so-net.ne.jp/supportsitedetailpage?id=000012665)

これだな。

## NAT

## iptables

`iptables -t nat -A POSTROUTING -s 192.0.2.0/24 -o gw-veth1 -j MASQUERAD`

- `-t`: 処理対象のテーブルを指定
- `-A`: add。 `-D` で delete。チェインも指定する。 `INPUT/OUTPUT/PREROUTING/POSTROUTING` など
- `-p`: プロトコル (tcp/udp/icmp/icmp6/etc...)
- `-s`: source ip range
- `-d`: destination ip range
- `--dport`: destination port
- `-o`: 対象の IF
- `-j`: ターゲットを指定する

## NAT周辺用語

- iptables ターゲット: MASQUERADE、SNAT など。なにをするか、ということ
- CGN(Carrier Grade NAT): ISP などで複数の ISP シェアーアドレス ( 100.64.0.0./10 ) と 1 つのグローバル IP アドレスを結びつける
  - モバイルネットワークなどで使われているらしい。自分の調べてみたけど `10.1**.*.*` とかだったな。まあただ private IP なのでこれで CGN してるってことだね。
  - Port を開放するには、 ISP に DNAT を新たに設定してもらわないといけない（つまり無理）
- P2P 通信: サーバ・クライアントといった役割を定めずに行う通信形態のこと

## IPv4周辺用語

- インターネットレジストリ: IPv4 の割当を管理。IANA を頂点とした階層構造。
- 地域インターネットレジストリ(RIR: Regional Internet Registry): IANA の直下にある組織
  - 世界で 5 つ。
- APNIC(Asia-Pacific Network Information Centre): もっとも早く IPv4 アドレスの在庫が枯渇
  - RIR のひとつ
- JPNIC(Japan Network Information Center): APNIC の下
- IPアドレス枯渇: それぞれのインターネットレジストリが独自に判断して宣言する。例えば JPNIC は /8 サイズの IPv4 があと一つになったとき
- アドレス移転: 枯渇したあとにも事業者による需要に対応するために整備された

IP売買のオークションサイト: https://auctions.ipv4.global/

## ping でも iptables の SNAT が使えるわけ

ICMPのエコーリクエストとエコーリプライに存在する Identifier というフィールドをポート代わりにしている。


## ソケットプログラミング

クライアント: `setsockopt()`, `connect()`, `send()`, `recv()`, `close()`
サーバー: `setsockopt()`, `bind()`, `listen()`, `accept()`, `recv()`, `send()`, `close()`

python3 の `socket` では、 `accept()` がブロッキングをする。その後、クライアントの IP, Port などがわかり、返答用のソケットインスタンスも得られる。

- python3: https://docs.python.org/3/library/socket.html
- 定数とかは普通に [`sys/socket.h`](https://pubs.opengroup.org/onlinepubs/7908799/xns/syssocket.h.html) 由来っぽい感じ。
- この辺の図 ( https://www.geeksforgeeks.org/socket-programming-cc/ ) とかも参考になりそう。
- `AF_INET`: IPv4
- `AF_INET6`: IPv6
- `AF` は address family らしい？
- unix ソケットも使っている機会結構ありそう。
- `SOCK_STREAM`: TCP
- `SOCK_DGRAM`: UDP
- 参考: https://stackoverflow.com/questions/5815675/what-is-sock-dgram-and-sock-stream

### ソケットプログラミングの用語

- ネットワークプログラミング: ネットワークを扱うプログラムを記述すること
- ソケット: Unix 系で提供されるネットワークを扱うためのデファクトスタンダードな API
- ソケットプログラミング: ソケットを使ったネットワークプログラミング
- 相互接続性(Interoperability): 異なるシステム同士をつなぐことができる特性
- エンディアンバグ: エンディアンによるバグ
- ネットワークエンディアン: TCP/IP ではバイトオーダーがビッグエンディアンに固定されている。それをこう呼ぶ。
- ホストバイトオーダー: CPU のアーキテクチャに依存したコンピュータ内部での表現方法
  - [Libs/structure.py](https://docs.python.org/ja/3/library/struct.html)
  - 上記等によってネットワークエンディアンとホストバイトオーダーを変換できる
  - ホストバイトオーダーは native に上記の対応している。

## ss

Socket Statistics

`ss -tlnp`

- `-t`: TCP を表示
- `-u`: UDP を表示 ( `-tn` と指定すれば両方)
- `-l`: listening に関して表示する
- `-n`: numeric (ポートの逆引きしない)
  - 逆引きは IANA Assignment のものかな？ 53 が domain なのが特徴としてわかりやすい気がする。しらんけど
- `-p`: process に関する情報を出す


```sh

ubuntu@ip-172-31-39-242:~$ ss -tlpn
State     Recv-Q    Send-Q       Local Address:Port        Peer Address:Port    Process
LISTEN    0         128              127.0.0.1:54321            0.0.0.0:*        users:(("python3",pid=43941,fd=3))
LISTEN    0         4096         127.0.0.53%lo:53               0.0.0.0:*
LISTEN    0         128                0.0.0.0:22               0.0.0.0:*
LISTEN    0         128                   [::]:22                  [::]:*

# sudo つけよう
ubuntu@ip-172-31-39-242:~$ sudo ss -tlpn
State    Recv-Q   Send-Q     Local Address:Port       Peer Address:Port   Process
LISTEN   0        128            127.0.0.1:54321           0.0.0.0:*       users:(("python3",pid=43941,fd=3))
LISTEN   0        4096       127.0.0.53%lo:53              0.0.0.0:*       users:(("systemd-resolve",pid=379,fd=13))
LISTEN   0        128              0.0.0.0:22              0.0.0.0:*       users:(("sshd",pid=647,fd=3))
LISTEN   0        128                 [::]:22                 [::]:*       users:(("sshd",pid=647,fd=4))

# -a を使って使用中も表示。 nc したあと。python3 が２つ確認できる
# nc するまでは ESTAB は現れない
ubuntu@ip-172-31-39-242:~$ sudo ss -tapn
State  Recv-Q Send-Q Local Address:Port    Peer Address:Port  Process
LISTEN 0      128        127.0.0.1:54321        0.0.0.0:*      users:(("python3",pid=43941,fd=3))
LISTEN 0      4096   127.0.0.53%lo:53           0.0.0.0:*      users:(("systemd-resolve",pid=379,fd=13))
LISTEN 0      128          0.0.0.0:22           0.0.0.0:*      users:(("sshd",pid=647,fd=3))
ESTAB  0      0      172.31.39.242:22    106.72.142.160:10678  users:(("sshd",pid=1563,fd=4),("sshd",pid=1481,fd=4))
ESTAB  0      0      172.31.39.242:22    106.72.142.160:14779  users:(("sshd",pid=38117,fd=4),("sshd",pid=38046,fd=4))
ESTAB  0      0      172.31.39.242:22    106.72.142.160:6589   users:(("sshd",pid=6784,fd=4),("sshd",pid=6710,fd=4))
ESTAB  0      0      172.31.39.242:22    106.72.142.160:63935  users:(("sshd",pid=3364,fd=4),("sshd",pid=3282,fd=4))
ESTAB  0      0          127.0.0.1:54321      127.0.0.1:33536  users:(("python3",pid=43941,fd=4))
ESTAB  0      0          127.0.0.1:33536      127.0.0.1:54321  users:(("nc",pid=43979,fd=3))
ESTAB  0      0      172.31.39.242:22    106.72.142.160:47550  users:(("sshd",pid=1405,fd=4),("sshd",pid=1323,fd=4))
LISTEN 0      128             [::]:22              [::]:*      users:(("sshd",pid=647,fd=4))
```

- `State`:
  - `LISTEN`: 待ち受けている状態。 `Peer` が 0 になってるのはそういうことかな？
  - `ESTAB`: ハンドシェイク終わった状態。 `nc` したあとに新しく表示されるのはそういうこと。LISTEN が消えないのは、明示的に消したりしない限り消えない感じかな。
    - どちらにせよ `accept()` が一回きりなので新しい通信はできない。けど新しく `nc -> python3` 方向の `ESTAB` だけ現れる。ハンドシェイク自体はあるのかな？あとで確かめよう
  - `DISCONN`: 接続できていない状態。観測できていない。 `TIME-WAIT` というのは観測できた。
- `Recv-Q/Send-Q`: `State` によって意味が違う
  - `State=ESTAB`: 名前が自然なのがこっち。
    - `Recv-Q`: 受信パケット中、まだプロセスに引き渡していないものの数
    - `Send-Q`: 送信パケット中、 TCP Ack が帰ってきていないものの数
  - `State=LISTEN`:
    - `Recv-Q`: 現在ハンドシェイク処理中のコネクション数
    - `Send-Q`: 接続可能なコネクションの最大数

参考: https://milestone-of-se.nesuke.com/sv-basic/linux-basic/ss-netstat/

この状態だとつまり ssh は最大 128 台までしか使えないってことかな。それとも単にハンドシェイクの待ちのみかな。そっちっぽいかな。

