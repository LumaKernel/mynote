
※ 上に書き足していっている


## 自己署名の作り方がよくなかった？

```
python3 ./scripts/root.py --root_key_file ./root_key --root_cert_file ./root_cert --asn_dir ./asn/
```



## 自己署名を作る

openssl genrsa -out key.pem 15360
openssl req -x509 -key key.pem -out cert.crt -days 3


証明書をインストしていても

```
curl: (60) SSL certificate problem: EE certificate key too weak
More details here: https://curl.haxx.se/docs/sslcerts.html

curl failed to verify the legitimacy of the server and therefore could not
establish a secure connection to it. To learn more about this situation and
how to fix it, please visit the web page mentioned above.
```

と出る。上 ( `EE certificate key too weak` ) は [openssl](https://github.com/openssl/openssl/blob/bbf5ccfd8729120e067de709c43be0a4cdfb423b/crypto/x509/x509_vfy.c#L290-L292)、
下はもちろん `curl` 内にある。3行すべて。


## とりあえず proxy サーバーを https で使えるようなものを立てる

以下を docker と tcpdump で調査

curl --proxy localhost:54321 http://google.com

```
11:54:43.648157 IP 172.17.0.1.36528 > 180e3f033dd3.54321: Flags [P.], seq 1:155, ack 1, win 502, options [nop,nop,TS val 2630819064 ecr 3121044841], length 154
	0x0000:  4500 00ce cf30 4000 4006 12d4 ac11 0001  E....0@.@.......
	0x0010:  ac11 0002 8eb0 d431 9123 b570 35fd 6e31  .......1.#.p5.n1
	0x0020:  8018 01f6 58e6 0000 0101 080a 9ccf 1cf8  ....X...........
	0x0030:  ba07 5d69 4745 5420 6874 7470 3a2f 2f67  ..]iGET.http://g
	0x0040:  6f6f 676c 652e 636f 6d2f 2048 5454 502f  oogle.com/.HTTP/
	0x0050:  312e 310d 0a48 6f73 743a 2067 6f6f 676c  1.1..Host:.googl
	0x0060:  652e 636f 6d0d 0a50 726f 7879 2d41 7574  e.com..Proxy-Aut
	0x0070:  686f 7269 7a61 7469 6f6e 3a20 4261 7369  horization:.Basi
	0x0080:  6320 5954 6f3d 0d0a 5573 6572 2d41 6765  c.YTo=..User-Age
	0x0090:  6e74 3a20 6375 726c 2f37 2e36 382e 300d  nt:.curl/7.68.0.
	0x00a0:  0a41 6363 6570 743a 202a 2f2a 0d0a 5072  .Accept:.*/*..Pr
	0x00b0:  6f78 792d 436f 6e6e 6563 7469 6f6e 3a20  oxy-Connection:.
	0x00c0:  4b65 6570 2d41 6c69 7665 0d0a 0d0a       Keep-Alive....
```

```
	GET / HTTP/1.1
	Host: google.com
	User-Agent: curl/7.68.0
	Accept: */*
	Accept-Encoding: gzip
```

```
13:07:56.085554 IP (tos 0x0, ttl 37, id 53593, offset 0, flags [none], proto TCP (6), length 40)
    142.250.196.110.80 > 180e3f033dd3.53400: Flags [.], cksum 0x2d02 (correct), ack 98, win 65535, length 0
13:07:56.105161 IP (tos 0x0, ttl 64, id 23054, offset 0, flags [DF], proto UDP (17), length 69)
    180e3f033dd3.51995 > 192.168.65.5.53: 17360+ PTR? 1.0.17.172.in-addr.arpa. (41)
13:07:56.133202 IP (tos 0x0, ttl 37, id 47756, offset 0, flags [none], proto TCP (6), length 568)
    142.250.196.110.80 > 180e3f033dd3.53400: Flags [P.], cksum 0xf942 (correct), seq 1:529, ack 98, win 65535, length 528: HTTP, length: 528
	HTTP/1.1 301 Moved Permanently
	Location: http://www.google.com/
	Content-Type: text/html; charset=UTF-8
	Date: Sat, 08 May 2021 13:07:58 GMT
	Expires: Mon, 07 Jun 2021 13:07:58 GMT
	Cache-Control: public, max-age=2592000
	Server: gws
	Content-Length: 219
	X-XSS-Protection: 0
	X-Frame-Options: SAMEORIGIN
	
	<HTML><HEAD><meta http-equiv="content-type" content="text/html;charset=utf-8">
	<TITLE>301 Moved</TITLE></HEAD><BODY>
	<H1>301 Moved</H1>
	The document has moved
	<A HREF="http://www.google.com/">here</A>.
	</BODY></HTML>
```


curl --proxy localhost:54321 https://google.com

```
curl: (60) SSL certificate problem: EE certificate key too weak
More details here: https://curl.haxx.se/docs/sslcerts.html

curl failed to verify the legitimacy of the server and therefore could not
establish a secure connection to it. To learn more about this situation and
how to fix it, please visit the web page mentioned above.
```


