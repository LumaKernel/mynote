
注意 : 体系的な学び方ではない．超基本はわかっているが，仕組みとかがよくわからないので拾い読みしていく方針

# Git の勉強

- [http://koseki.github.io/git-object-browser/ja/#/step1/.git/](http://koseki.github.io/git-object-browser/ja/#/step1/.git/)
  - 視覚的に勉強
  - かなりコアな話をしていると思う
- [https://learngitbranching.js.org/](https://learngitbranching.js.org/)
- [gitでアレを元に戻す108の方法](http://labs.timedia.co.jp/2011/08/git-undo-999.html)



# 基本

### タグを追加

```
git tag -a my_tag -m "タグをコミットに追加"
```

参考 : [https://learngitbranching.js.org/](https://learngitbranching.js.org/)

### HEAD

もともとは `HEAD -> master -> C1` という構成だが，
`git checkout C1` により `HEAD -> C1` のような構成になる

### origin

`origin` とは "リモート" に自分でこっちが勝手につけた呼び名．

origin/masterは 「originのmasterはどこに相当するか」を表すブランチ

通常は master に追随するが，`git branch -u origin/master foo` や `git checkout -b bar origin/master` のようにすることで追随する先を変えることができる ( `-u` は `--set-upstream-to`)

`git push <remote> <place>` は `<remote>/<place>` に対して `<place>` をpushする

`git push <remote> <source>:<destination>` は `<remote>/<destination>` に `<source>` をpushする

remote側に新しいブランチを作るなら，

`git push origin master:newBranch` のようにすればよい

`origin/newBranch` は `master` の位置にくる

消す場合は `git push origin :newBranch`

`git fetch/pull` も似たようなインターフェースを持つ．
`<source>` の視点がリモートになることに注意


