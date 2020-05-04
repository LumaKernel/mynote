centosとかubuntuとかサーバーとか仮想環境とかvirtual box とか vagrant とか docker とか

### centos と systemctl

- https://milestone-of-se.nesuke.com/sv-basic/linux-basic/systemctl/

バージョン7 から service ではなく systemctl を使うらしい ( init プロセスとの関係とかもいろいろあるらしい )

```
$ systemctl start httpd  # httpd を開始
$ systemctl enable httpd  # httpd を 自動起動
$ systemctl list-unit-files -t service   # 自動起動のオンオフチェック ( chkconfig --list のかわり )
```

vagrant は高確率でなぜかうまくいかない...


```
$ vagrant halt
$ vagrant up
```

をやりまくればどうにか

