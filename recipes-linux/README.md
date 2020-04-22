
```
$ # script タグで使う integrity 属性のハッシュを求める
$ sha256sum nyan.js | awk '{print$1}' | xxd -r -p | base64
$ # これに sha256- をつければいい
$ # -r : revert, hexdump から バイナリに変換
$ # -p : plain, hexdump の書式．余計な情報なし
```

