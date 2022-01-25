
## Getting started

flutter 版本的插件腾讯cos插件,不依赖原生插件.参考:https://cloud.tencent.com/document/product/436/7749

## Usage

```dart
await COSClient(COSConfig(
credentials["secretId"],
credentials["secretKey"],
credentials["bucketName"],
credentials["region"],
))
.putObject(
'cos存储放的路径', '本地的file',token: '如果后台采用临时秘钥这里需要传入值,不然403错误,如果永久秘钥写在客户端,token可以不传入');
```

## Additional information

参考:https://cloud.tencent.com/developer/article/1878729
