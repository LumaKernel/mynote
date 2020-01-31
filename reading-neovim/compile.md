Release で自分用にビルドするやつ

neovimをcloneして，

```
make CMAKE_BUILD_TYPE=Release USERNAME=luma HOSTNAME=
make install
```

これで `/usr/local/bin` とかによしなに入れてくれて， `plugin` とかもちゃんとパスが通る (大事)

自分で場所を指定するなら `CMAKE_INSTALL_PREFIX` .
複数バージョン入れるならこれと `update-alternatives` かな


