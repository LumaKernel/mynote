
まだ読んで全体を把握したとかいうわけではない

- https://langserver.org/


## lspサーバごとの設定について

例えば vim-lsp では `workspace_config` を設定すればいい

- 接頭辞の `pyls` みたいなのは lsp の実装側が勝手に決めている
  - https://github.com/palantir/python-language-server/blob/0.31.10/pyls/python_ls.py#L356-L362
```
    def m_workspace__did_change_configuration(self, settings=None):
        self.config.update((settings or {}).get('pyls', {}))
        for workspace_uri in self.workspaces:
            workspace = self.workspaces[workspace_uri]
            workspace.update_config(self.config)
            for doc_uri in workspace.documents:
                self.lint(doc_uri, is_saved=False)
```

- `vim-lsp` ではサーバーごとに設定を別にできるので、名前空間の制約を受けるのは vscode のような設定方法を考えたときだろう

