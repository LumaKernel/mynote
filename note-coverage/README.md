カバレッジを取ることに関するあれこれ勉強したこと

### codevimerage

```
vimがプロファイルを出す
          ↓
codevimerage の write_coverage がそれを解析してデータ化 ( .coverage_covimerage )
          ↓
coverage.py でそれを読んで XML reporting する ( coverage.xml ) ( .coveragerc を読む )
          ↓
codecov コマンドで codecov.io にデータを飛ばす ( .codecov.yml を読む )
```

- https://github.com/vim-jp/vital.vim/pull/554/files
- [coverage.py | XML reporting](https://coverage.readthedocs.io/en/v4.5.x/cmd.html#xml-reporting)
- [coverage.py | .coveragerc の仕様](https://coverage.readthedocs.io/en/v4.5.x/config.html)
- [codecov.io | codecov.yml Reference](https://docs.codecov.io/docs/codecovyml-reference)

