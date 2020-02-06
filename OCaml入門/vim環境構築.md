

少し探すと [Reason](https://reasonml.github.io/en/) って言語と一緒に紹介されていたりする
OCamlとJSにトランスパイル可能な言語っぽい

- 1 [ocaml-language-server](https://github.com/ocaml-lsp/ocaml-language-server)
  - 以下のどちらかで設定する
  - [vim-reason-plus](https://github.com/reasonml-editor/vim-reason-plus)
    - こいつは [LanguageClient-neovim](https://github.com/autozimu/LanguageClient-neovim) ていうプラグインをすすめてくる
  - coc.nvim
  - もしくは他のLSPプラグイン
- 2 [reason-language-server](https://github.com/jaredly/reason-language-server)
- [merlin](https://github.com/ocaml/merlin)
  - 一応これだけで問題なく動くっぽい?
- 3 [ocaml-lsp](https://github.com/ocaml/ocaml-lsp)
  - 第3の刺客
  - merlin から分離されたLSP部分
  - 公式
  - 他の2つと比べて，(1)とは差がない．OCamlで書かれている分，より活発だろう，的な

coc.nvimで設定すると不安定なかんじがするので，めんどいけどぶよぶよ入れていくか...
と思ったけど，どっちにしろLSPクライアント入れさせられるのは気持ち悪いな...

## merlin

で，(1) は別になんか [merlin](https://github.com/ocaml/merlin) てのを入れるように言われる
(1) には dependencies みたいに書いてないのに...


---


https://vim-bootstrap.com/ を見る限りでは merlin だけつかう，でだいぶ良さそう ?
LSP 対応を ocaml-lsp に分離しているらしい．

---

coc.nvim で動いた．

```
    "ocaml-language-server": {
      "command": "opam",
      "args": ["config", "exec", "--", "ocaml-language-server", "--stdio"],
      "filetypes": ["ocaml", "reason"],
    },
    "ocaml-lsp": {
      "command": "opam",
      "args": ["config", "exec", "--", "ocamllsp"],
      "filetypes": ["ocaml", "reason"],
    },
```

[公式のwiki](https://github.com/neoclide/coc.nvim/wiki/Language-servers) にも追記しといた．

LSP が Unbound module Preferences とか言ってるけど，たぶんプロジェクトの `.merlin` の設定がうまく行っていないのかも


Coqのrepoなら `make camldevfiles` とかしてみたんだけど， `src` 配下しか見ないっぽいし，何がトリガーになっているかもよくわからない

まあ，作業が一番効率よくできる好きなやり方でやればいいと思うけど

Cより乏しく感じるのはなんともなあ

CocRestart をバチバチ撃ちまくるのがいいのかどうか


