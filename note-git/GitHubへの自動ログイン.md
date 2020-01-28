

- https://help.github.com/en/github/authenticating-to-github/connecting-to-github-with-ssh
  - 公式のヘルプ

### 手順

- SSHキーがあるか確認

```bash
$ ls -al ~/.ssh
id_rsa.pub # これとかが出ればいい
...
```

### 確認

```bash
$ ssh -T git@github.com
Hi LumaKernel! You've successfully authenticated, but GitHub does not provide shell access.
```

と出れば成功


### 公開鍵は確認できる

`.keys` をつければ確認できる

https://github.com/lumakernel.keys
