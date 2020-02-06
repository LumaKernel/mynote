
opam とかの用意は dotfiles のほうにある

以下は必要だと思うけど以下だけだとどうにもならず

```
make camldevfiles
```

以下がビンゴ．コンパイルして merlin のあれこれがうまくいくようだ

```
opam install num -y
./configure -bin-annot -prefix build -coqide no -with-doc no
make
```


### aysnc-proofs とはなんなのか


### annotate は何をしているのか




