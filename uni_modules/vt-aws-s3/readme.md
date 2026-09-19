# vt-aws-s3

uni-app x UTS 插件，用于调用 AWS S3 协议接口。

## 使用示例

```vue
<template>
  <view class="page">
    <view class="title">AWS S3 API 演示（PC 端）</view>

    <button class="btn" @click="onInit">1. 初始化 S3</button>
    <button class="btn" @click="onChooseAndUpload">2. 选择并上传文件</button>
    <button class="btn" @click="onDownload">3. 下载文件</button>
    <button class="btn" @click="onList">4. 列举对象</button>
    <button class="btn" @click="onDelete">5. 删除对象</button>
    <button class="btn" @click="onPresigned">6. 生成预签名 URL</button>

    <view class="log">
      <text>{{ logText }}</text>
    </view>
  </view>
</template>

<script>
  import {
    initS3,
    uploadFile,
    downloadFile,
    deleteObject,
    listObjects,
    getPresignedUrl,
    getObjectUrl
  } from '@/uni_modules/aws-s3-api'

  export default {
    data() {
      return {
        logText: '请先点击「初始化 S3」'
      }
    },
    methods: {
      onInit() {
        initS3({
          accessKey: 'YOUR_ACCESS_KEY_ID',
          secretKey: 'YOUR_SECRET_ACCESS_KEY',
          region: 'us-east-1',
          bucket: 'your-bucket-name'
        })
        this.logText = '✅ S3 初始化完成'
      },

      onChooseAndUpload() {
        // Web 端：通过文件选择器获取文件
        const input = document.createElement('input')
        input.type = 'file'
        input.onchange = async (e: Event) => {
          const target = e.target as HTMLInputElement
          if (!target.files || target.files.length === 0) return

          const file = target.files[0]
          const blobUrl = URL.createObjectURL(file)

          const res = await uploadFile({
            filePath: blobUrl,
            s3Key: 'uploads/' + file.name,
            contentType: file.type
          })

          URL.revokeObjectURL(blobUrl)
          this.logText = JSON.stringify(res)
        }
        input.click()
      },

      async onDownload() {
        const res = await downloadFile({
          s3Key: 'uploads/test.jpg',
          savePath: 'downloaded_test.jpg'
        })
        this.logText = JSON.stringify(res)
      },

      async onList() {
        const res = await listObjects({
          prefix: 'uploads/',
          maxKeys: 20
        })
        this.logText = JSON.stringify(res)
      },

      async onDelete() {
        const res = await deleteObject({
          s3Key: 'uploads/test.jpg'
        })
        this.logText = JSON.stringify(res)
      },

      async onPresigned() {
        const url = await getPresignedUrl({
          s3Key: 'uploads/test.jpg',
          expiresIn: 600,
          method: 'get'
        })
        this.logText = '预签名 URL：' + url
      }
    }
  }
</script>

<style>
  .page {
    padding: 24rpx;
  }
  .title {
    font-size: 34rpx;
    font-weight: bold;
    margin-bottom: 20rpx;
  }
  .btn {
    margin: 12rpx 0;
  }
  .log {
    margin-top: 24rpx;
    padding: 20rpx;
    background-color: #f5f5f5;
    border-radius: 8rpx;
    font-size: 24rpx;
    word-break: break-all;
  }
</style>
```

## 添加新平台时的流程

- 在 interface.uts 中保持类型和函数声明不变
- 新建 utssdk/app-android/index.uts（或 app-ios 等）
- 导出与 interface.uts 同名同签名的函数实现
- 在该平台目录下添加平台独有的依赖配置
- 新根 package.json 的 platforms 字段，将该平台标记为 y

调用方代码无需任何修改，即可在新平台编译运行。
