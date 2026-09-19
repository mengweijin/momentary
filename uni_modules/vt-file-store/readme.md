# vt-file-store

跨平台文件持久化读写插件，支持 Android / iOS / HarmonyOS / Web / 微信小程序。

useStore — 响应式 uni-app-x store 组合式函数：返回与用户目录下的配置文件内容双向绑定的 Ref，改值即写文件内容。

这样就可以把一些配置持久化存放到用户目录下。由于是双向绑定的，因此会省去一些中间过程，简化了编码人员的使用。

## 业务端组合式函数使用示例

```uts
import { useStore } from '@/uni_modules/vt-file-store/composables/use-store.uts'

const user = useStore('user.json', { username: 'Tom', age: 12})
// 自动写入文件
user.value = { username: 'Jack', age: 24}
user.value.username = 'Jerry';
// 置 null 即删除该文件
user.value = null      
```

说明：

- content 不存在时返回 defaultValue 并立即持久化，保证下次创建直接读到
- 相同 fileName 的多个实例各自持有独立 Ref，但引用同一份文件，因此值可以联动

## 内部 API

```uts
import { load, save, clear } from '@/uni_modules/vt-file-store'

// 读取（返回 string | null）
const content = load('user_config.json')
const config: UserConfig = JSON.parse(response);

// 保存（文件/目录不存在时自动创建）
save('user_config.json', JSON.stringify({ theme: 'dark' }))

// 删除文件
clear('user_config.json')
```
