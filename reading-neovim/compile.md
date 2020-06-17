Release で自分用にビルドするやつ
ついでに compiled by も変更する

## 準備

```
sudo apt-get install ninja-build gettext libtool libtool-bin autoconf automake cmake g++ pkg-config unzip -y
```


neovimをcloneして，

```
# make distclean clean
make USERNAME=luma HOSTNAME= CMAKE_BUILD_TYPE=RelWithDebInfo
sudo make install
```

これで `/usr/local/bin` とかによしなに入れてくれて， `$VIMRUNTIME` も準備してくれる

自分で場所を指定するなら `make install` に `CMAKE_INSTALL_PREFIX` .
複数バージョン入れるならこれと `update-alternatives` かな

例えば，

```
git checkout nightly
git pull origin nightly
make CMAKE_BUILD_TYPE=RelWithDebInfo USERNAME=luma HOSTNAME=
make install CMAKE_BUILD_TYPE=RelWithDebInfo CMAKE_INSTALL_PREFIX=~/.local/build/nvim/nightly

sudo update-alternatives --install $HOME/.local/bin/nvim nvim ~/.local/build/nvim/nightly/bin/nvim 10
```

(
`~/.local/build/{コマンド}/{バージョン}` にビルドして
`~/.local/bin/{コマンド}` にバイナリを置く、という運用の場合
)

