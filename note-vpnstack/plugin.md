自分でフィルタシステムをプラグインとして作れるようにする。

## 引数提供

Web Interface でも扱えるようにするか、トップレベルの設定はそれも専用のプラグインをつくるようにするのか。

## 書き味

```
struct Props {
  apiKey int
}

func onRequest(req Request, res Response) {
  
}

func onRegister(ctx *Context, props *Props) {
  svc, err := youtubeApi.service(props.apiKey)
  if err != nil {
    ctr.sendError("YouTube API Key Initialize", err)
    return
  }

  OnRequest(ctx, onRequest)
  ctx.registerDescription("This plugin can...")
}

func OnYoutubeOpenVideo(ctx *ctx, handler func() bool) {
  // ...
}

func OnYoutubeOpenChannel(ctx *ctx, handler func()) {
  // ...
}

```


