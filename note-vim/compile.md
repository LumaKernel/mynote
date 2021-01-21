自分でコンパイルしたいお年頃

## Ubuntu

```
cd ~
git clone https://github.com/vim/vim /tmp/vim
cd /tmp/vim
branch={{ ... }}
version={{ ... }}
git checkout v$branch

PREFIX="$HOME/.local/build/vim/$version"
./configure --with-compiledby=luma --with-features=huge --enable-fail-if-missing --prefix="$PREFIX"
make && make install

INSTALL_TO="$PREFIX/bin/vim"
PRIORITY=60
sudo update-alternatives --install $HOME/.local/bin/vim vim "$INSTALL_TO" $PRIORITY
sudo update-alternatives --set vim "$INSTALL_TO"
```

head

```bash
#!/bin/bash

set -e

git switch master
git pull

version="head"
PREFIX="$HOME/.local/build/vim/$version"
./configure --with-compiledby=luma --with-features=huge --enable-fail-if-missing --prefix="$PREFIX"
make && make install

INSTALL_TO="$PREFIX/bin/vim"
PRIORITY=20
sudo update-alternatives --install $HOME/.local/bin/vim vim "$INSTALL_TO" $PRIORITY
sudo update-alternatives --set vim "$INSTALL_TO"
```
