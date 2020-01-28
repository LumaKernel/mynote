### 参考

- [サルでもわかる](https://backlog.com/ja/git-tutorial/stepup/06/)
- [https://learngitbranching.js.org/](https://learngitbranching.js.org/)
  - git の branch を勉強するのに特化した，視覚的に勉強できるサイト


```
$ git branch dev # dev って名前のブランチ作る，移動なし
$ git branch # ブランチのリスト
$ git checkout -b dev # ブランチ切って移動
$ git checkout master # 単に移動
$ git merge to # HEAD がいるブランチから to に向かってマージする
```

### fast-forward マージとはなんなのか

一直線にあって，実質的にポインタを動かしただけのようなマージのことですね

### rebase

```
$ git rebase to  # 今いるブランチを， to が親になるようにマージする
```


