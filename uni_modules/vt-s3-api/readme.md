# vt-s3-api
### 开发文档
[UTS 语法](https://uniapp.dcloud.net.cn/tutorial/syntax-uts.html)
[UTS API插件](https://uniapp.dcloud.net.cn/plugin/uts-plugin.html)
[UTS uni-app兼容模式组件](https://uniapp.dcloud.net.cn/plugin/uts-component.html)
[UTS 标准模式组件](https://doc.dcloud.net.cn/uni-app-x/plugin/uts-vue-component.html)
[Hello UTS](https://gitcode.net/dcloud/hello-uts)

### Android

Android 实现使用 AWS Android S3 SDK。网络请求在工作线程执行，失败时 Promise 会 reject。
`getObject(key)` 会将对象写入应用缓存目录，成功结果中的 `localPath` 是该临时文件的绝对路径；缓存文件可能被系统清理。