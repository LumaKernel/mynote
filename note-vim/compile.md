自分でコンパイルしたいお年頃

## Ubuntu

```
cd ~
git clone https://github.com/vim/vim /tmp/vim
cd vim
branch={{ ... }}
version={{ ... }}
git checkout v$branch
./configure --with-compiledby=luma --with-features=huge --enable-fail-if-missing --prefix=$HOME/bin/vim/$version
make && make install

sudo update-alternatives --install $(which vim) vim ~/bin/vim/$version/bin/vim 60
sudo update-alternatives --set vim ~/bin/vim/$version/bin/vim
```

sudo update-alternatives --install $(which vim) vim ~/bin/vim/${{ version }}/bin/vim 50

