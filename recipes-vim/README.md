
### バッファ列挙

```
let buffers = filter(range(1, bufnr('$')), 'bufexists(v:val)')
```

