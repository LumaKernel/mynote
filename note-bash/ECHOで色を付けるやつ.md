
## 参考

- [https://misc.flogisoft.com/bash/tip_colors_and_formatting](https://misc.flogisoft.com/bash/tip_colors_and_formatting)<nobr />
<sup>_[archive](https://megalodon.jp/2020-0204-1426-52/https://misc.flogisoft.com:443/bash/tip_colors_and_formatting)_</sup>

<!--_-->

`\e[` と `m` の間に数字を `;` 区切りで入れて `echo -e` すれば色を変えられる．

### 16色のターミナル

順番は実際何でもよく， `\e[31;41m` と `\e[41;31m` と `\e[31m\e[41m` は同じことをする

どこが背景色，とかではなく，どの番号が背景色か，というふうになっている. `\e[0m` でリセット． `\e[m` は特別で，これもリセット．

### 256色のターミナル

fgに `\e[38;5;{COLOR}m`, bgに `\e[48;5;{COLOR}m` が使える． 16色では `38, 48` は使われていないから，このために空いているのだと思う

88色のターミナルも存在するが，テーブルは256色とはちがうらしい

---

dotfiles の [fish/functions](https://github.com/LumaKernel/dotfiles/tree/master/fish/functions) に カラーテーブル表示を fish で書いたものをおいた

