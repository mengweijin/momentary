# vt-s3

基于 AWS Signature Version 4 手写请求签名，通过 `uni.request` 调用 S3 兼容服务，提供 ListObjectsV2 列举、对象读取和删除。签名算法独立放在 `utssdk/sigv4.uts` 中，SHA-256 和 HMAC-SHA256 均在插件内实现。

## 初始化

```ts
import { initS3, bucketExists, createBucket, listObjects, getObject, deleteObject } from '@/uni_modules/vt-s3'

await initS3({
  endpoint: 'http://127.0.0.1:9000',
  accessKey: 'minio-access-key',
  secretKey: 'minio-secret-key',
  bucket: 'my-bucket',
  region: 'us-east-1',
  forcePathStyle: true
})
```

`endpoint` 必须填写 MinIO / RustFS 服务地址，并包含 `http://` 或 `https://`；例如 `http://127.0.0.1:9000`。本插件不使用 AWS 默认 endpoint。

`initS3` 会先检查配置中的 bucket：已存在则直接完成初始化；服务返回 404 时会自动创建。调用者应等待初始化 Promise 完成后再执行对象操作。

## 手动检查或创建 bucket

```ts
const exists = await bucketExists()
await createBucket()
```

`bucketExists()` 检查初始化配置中 `bucket` 指定的存储桶是否存在，返回 `boolean`；非 2xx（404 除外）响应或网络错误会使 Promise reject。`createBucket()` 先调用该检查，仅在 bucket 不存在时创建；已有 bucket 时以 `{ statusCode: 200, data: null, header: {} }` resolve。

## 对象操作

三个方法仅需传入对应的前缀或对象 path：

```ts
// 列举，result.data 是 S3 返回的 XML 文本
const list = await listObjects('photos/')

// prefix 为 null 时列举 bucket 下所有对象
const all = await listObjects(null)

// 获取对象，result.data 为 ArrayBuffer
const object = await getObject('photos/example.jpg')

// 删除对象
await deleteObject('photos/example.jpg')
```

请求成功时 resolve `{ statusCode, data, header }`，读取对象返回 `ArrayBuffer`；HTTP 非 2xx 响应以及网络错误会使 Promise reject。