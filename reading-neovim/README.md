
[neovim/neovim](https://github.com/neovim/neovim) を読む

※ これは 2020/01/28 から読み始めたものを記録したものです．
  情報が古くなっている可能性もあり，憶測もあるので参考にする際は自己責任でお願いします．


## 目標/目的

- OSS の読み方を勉強
- C の勉強
- CMAKE の勉強
- Lua の勉強
- Neovim, vim 自体の勉強


- Neovim に `v:none` と `default arguments` を追加
- Neovim に `method` を追加


----


## Lua + C 連携 (binding)

http://lua-users.org/wiki/BindingCodeToLua


## 問題/疑問


- Neovim に `v:none` が入る余地がない...
  - vim の `v:null` と lua の `nil` を対応させてるっぽい
  - もし `v:none` が `vim.none` みたいに追加されても `nil` に対する不整合感がある？



## テスト

狙ったものだけテストする

```
env TEST_FILTER="Special" make functionaltest
```


--

## `src/nvim/lua/converter.c` などに見られる

- `TYPVAL_ENCODE_CONV_{変換対象}` 

これはこの後で定義される `TYPVAL_ENCODE_NAME` を対象としたエンコーダを作る  
実際には `#include "nvim/eval/typval_encode.c.h"` により完了する．

`vim_to_{TYPVAL_ENCODE_NAME}` という関数が作られるようだ．
(完全名で grep しても見つからないので注意)

```
コピー用
TYPVAL_ENCODE_CONV_NIL
TYPVAL_ENCODE_CONV_NONE_VAL
TYPVAL_ENCODE_NAME
#include "nvim/eval/typval_encode.c.h"
```

### ターゲット一覧 的な

- `src/nvim/api/private/helpers.c`
  - `object` : viml 内部で使われる `Object` への変換
- `src/nvim/eval/encode.c`
  - `string` : 文字列への変換． `string()` でも使われる
  - `json` : `json`
  - `msgpack` : `msgpack`
- `src/nvim/eval/typval.c`
  - `nothing` : 内部で初期値うめ (ガベージコレクト的な) に使うみたい？
- `src/nvim/lua/converter.c`
  - `lua` : lua の値に変換． userdata への変換もここでする


## src/nvim/lua/executor.c

`nlua_state_init(...)` 内で `vim.api` や `vim.NIL` を定義


### `eval_vim` の実態は

`build/src/nvim/auto/msgpack_lua_c_bindings.generated.c`
にあるよう．
ええ，自動生成されてるのか．

その後は以下のよう

- `src/nvim/api/vim.c` `nvim_eval`
- `src/nvim/eval.c` `eval0` - expression 列を処理?
- `-` `eval1` - 単一の expression を処理
- `-` `eval2` - 三項演算子を処理
- `-` `eval3` - `||`
- `-` `eval4` - `&&`
- `-` `eval5` - `==`, `is`系
- `-` `eval6` - `+`, `-`, `.`, `..`
- `-` `eval7`
  - 数値リテラル，文字列リテラル，変数，関数呼び出し
  - 括弧，リストリテラル，辞書リテラル
  - `!`, `+`, `-` (単項演算子)
  - string,listの `[]`, 辞書の `.name`


変数は `eval7` で `s:var`, `local_val` などまで分解される．
その後，

- `-` `get_var_value`
- `-` `find_var`
  - `-` `find_var_ht` - ここで `l:` のようなコンテキストを抽出．省略されていた場合は local が変える
  - `-` `find_var_in_ht` - ここで実際に中身を取り出す
  - `-` `find_var_in_scoped_ht` - 親 のスコープを見に行く的な ?


`v:` は `vimvardict` から得られるわけだが，これがどう構成されているのか．

データは `src/nvim/eval.c` に列挙された `VV_{変数名}` で間違い無いと思う


