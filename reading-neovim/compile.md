Release で自分用にビルドするやつ
ついでに compiled by も変更する

## 準備

```
sudo apt-get install ninja-build gettext libtool libtool-bin autoconf automake cmake g++ pkg-config unzip -y
```


neovimをcloneして，

```
# make distclean
make USERNAME=luma HOSTNAME= CMAKE_BUILD_TYPE=RelWithDebInfo
sudo make install
```

これで `/usr/local/bin` とかによしなに入れてくれて， `plugin` とかもちゃんとパスが通る (大事)

自分で場所を指定するなら `make install` に `CMAKE_INSTALL_PREFIX` .
複数バージョン入れるならこれと `update-alternatives` かな

例えば，

```
git checkout nightly
git pull origin nightly
make CMAKE_BUILD_TYPE=Release USERNAME=luma HOSTNAME=
sudo make install CMAKE_BUILD_TYPE=Release CMAKE_INSTALL_PREFIX=~/bin/nvim/nightly

update-alternatives $HOME/.local/bin/nvim nvim build/bin/nvim 10
```


