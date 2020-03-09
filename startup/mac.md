
1. OSのバージョンを上げる
2. フォント入れる
  tty 全部選択して 開けばいい
  - https://github.com/macchaberrycream/RictyDiminished-Nerd-Fonts
3. git と GitHub への ssh接続 のセットアップ

xcodeも必要であれば

[GitHub に SSH で，公式解説](https://help.github.com/en/github/authenticating-to-github/connecting-to-github-with-ssh)

```bash
ssh-keygen -t rsa -b 4096 -C "tomorinao.info@gmail.com"
eval "$(ssh-agent -s)"

echo <<EOF >> ~/.ssh/config
Host *
  AddKeysToAgent yes
  UseKeychain yes
  IdentityFile ~/.ssh/id_rsa
EOF

ssh-add -K ~/.ssh/id_rsa

# GitHub に 公開鍵を登録
pbcopy ~/.ssh/id_rsa.pub
# GitHub 側に貼り付け

# git config
git config --global user.name Luma
git config --global user.email tomorinao.info@gmai.com

```

4. dotfiles でインストール

```
cd ~
git clone git@github.com:LumaKernel/dotfiles
cd dotfiles
sudo bash mac/install.sh
```

4. アプリ設定する (インストールは brew cask)
  - chrome
    * ログインなど
    * 拡張の設定
  - iterm2
    * フォントを設定
    * テーマを設定，などなど
  - Google IME
    *https://ke-complex-modifications.pqrs.org/ https://ke-complex-modifications.pqrs.org/日本語と英字のみ残す．切り替えは CTRL + SPACE
    * 設定をする
    * 後はユーザー辞書など
  - HyperSwitch
    * Command Space をのっとって便利に
  - Karabiner-Elements
    * https://ke-complex-modifications.pqrs.org/
    * Command + H や + Q などを消す
