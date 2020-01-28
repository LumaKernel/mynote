
公式ドキュメントの About シリーズがわかりやすい

- [About](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/?view=powershell-6)
  - [About Splatting](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_splatting?view=powershell-6)

- [コマンドの慣れ親しんだ略名について](https://docs.microsoft.com/en-us/powershell/scripting/learn/using-familiar-command-names?view=powershell-6)

- 変数名は case-insentive みたい． PascalCase で書くのが無難かな



# 他の .ps1 ファイルを実行する

`a.ps1` を実行するとする

- `./a.ps1 <引数>` とかく
- `iex "./a.ps1 <引数>"` とかく
- `iex` は [Invoke-Expression](https://forsenergy.com/ja-jp/windowspowershellhelp/html/04b8e90a-7d28-4ab2-ad13-b0316c231c77.htm) の略
  - `-Command` という必須パラメーターがあるが，ひとつしかないからなのか，これを書くことは
    省略できる

