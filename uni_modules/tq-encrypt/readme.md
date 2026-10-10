# tq-encrypt
### 开发文档
[UTS 语法](https://uniapp.dcloud.net.cn/tutorial/syntax-uts.html)
[UTS API插件](https://uniapp.dcloud.net.cn/plugin/uts-plugin.html)
[UTS 组件插件](https://uniapp.dcloud.net.cn/plugin/uts-component.html)
[Hello UTS](https://gitcode.net/dcloud/hello-uts)

> **注意：**
> 
> 如果需要支持web，本插件依赖第三方插件miniprogram-sm-crypto和crypto-js，你需要安装它。可以到插件的目录下安装`npm install`，也可以全局目录下安装`npm install miniprogram-sm-crypto crypto-js --save`，只支持Android、iOS不需要安装

### 使用说明

|名称|描述|参数|说明|支持平台|
|:--|:--|:--|:--|:--|
|md5Sync|md5加密|str:string|返回值：string  加密出来的字母是大写|Android、Web、iOS、HarmonyNext|
|base64EncodeSync|base64加密|str:string|返回值：string|Android、Web、iOS、HarmonyNext|
|base64DecodeSync|base64解密|str:string|返回值：string|Android、Web、iOS、HarmonyNext|
|sm4ECBEncryptSync|sm4 ECB加密|参数一：str:string 参数二：key:string|返回值：string js中sm4加密ECB一般为默认|Android、Web、iOS、HarmonyNext|
|sm4ECBDecryptSync|sm4 ECB解密|参数一：str:string 参数二：key:string|返回值：string|Android、Web、iOS、HarmonyNext|
|sm4CBCEncryptSync|sm4 CBC加密|参数一：str:string 参数二：key:string 参数三：iv:string|返回值：string|Android、Web、iOS、HarmonyNext|
|sm4CBCDecryptSync|sm4 CBC解密|参数一：str:string 参数二：key:string 参数三：iv:string|返回值：string|Android、Web、iOS、HarmonyNext|
|sm3EncryptSync|sm3加密|str:string|返回值：string|Android、Web、iOS、HarmonyNext|
|sm2EncryptSync|国产SM2非对称公钥加密|参数一：dataString : string 参数二：publicKey : string|返回值：string|Android、Web、iOS、HarmonyNext|
|sm2DecryptSync|国产SM2非对称私钥解密|参数一：dataString : string 参数二：privateKey : string|返回值：string|Android、Web、iOS、HarmonyNext|
|sm2PubSignSync|sm2私钥签名|参数一：dataString : string 参数二：privateKey : string|返回值：string|Android、Web、iOS、HarmonyNext|
|sm2PubSignValSync|sm2验签|参数一：dataString : string 参数二：publicKey : string 参数三：sign : string|返回值：boolean|Android、Web、iOS、HarmonyNext|
|aesEncryptSync|AES ECB对称加密|参数一：str:string 参数二：key:string [参数三：isHex: boolean（默认值为false，值为true是旧版返回HEX值）目前只有Android支持]|返回值：string `AES加密方式为ECB模式，返回的是base64加密数据`|Android、iOS、Web、HarmonyNext|
|aesDecryptSync|AES ECB对称解密|参数一：str:string 参数二：key:string [参数三：isHex: boolean（默认值为false，值为true是旧版返回HEX值）目前只有Android支持]|返回值：string `AES解密密方式为ECB模式`|Android、iOS、Web、HarmonyNext|
|sha1Sync|SHA1加密|str:string|返回值：string|Android、iOS、Web、HarmonyNext|
|sha256Sync|SHA256加密|str:string|返回值：string|Android、iOS、Web、HarmonyNext|
|rsaEncryptSync|RSA非对称加密|参数一：dataString : string  参数二：keyPair : KeyPair  参数三：type : Int|返回值：string|Android|
|rsaDecryptSync|RSA非对称解密|参数一：dataString : string  参数二：keyPair : KeyPair  参数三：type : Int|返回值：string|Android|
|rsaEncryptSync|RSA非对称加密|参数一：dataString : string  参数二：key:string|返回值：string（base64字符串）|iOS、HarmonyNext|
|rsaDecryptSync|RSA非对称解密|参数一：dataString : string  参数二：key:string|返回值：string|iOS、HarmonyNext|
|rsaSHA256PrivateSync|RSA SHA256签名|参数一：dataString : string  参数二：keyPair : KeyPair|返回值：string|Android|
|rsaMD5PrivateSync|RSA MD5签名|参数一：dataString : string  参数二：keyPair : KeyPair|返回值：string|Android|
|rsaSHA256PubValSync|RSA SHA256签名验签|参数一：dataString : string  参数二：result: string  参数三：keyPair : KeyPair|返回值：boolean|Android|
|rsaMD5PubValSync|RSA MD5签名验签|参数一：dataString : string  参数二：result: string  参数三：keyPair : KeyPair|返回值：boolean|Android|
|hmacSHA1Sync|hmacSHA1加密|参数一：plaintext : string 参数二：key : string|返回值：string|Android、iOS、Web、HarmonyNext|
|aesCBCEncryptSync|aes CBC加密|参数一：str:string 参数二：key:string 参数三：iv:string|返回值：string|Android、iOS、Web、HarmonyNext|
|aesCBCDecryptSync|aes CBC解密|参数一：str:string 参数二：key:string 参数三：iv:string|返回值：string|Android、iOS、Web、HarmonyNext|
|generateKeyPair|生成RSA KeyPair密钥|参数一：pubStr:string(只接受hex字符串) 参数二：privateStr:string(只接受hex字符串)|返回值：KeyPair|Android|

### 使用示例

``` html
<template>
	<view class="content">
		<image class="logo" src="/static/logo.png"></image>
		<view @click="go">
			<text class="title">{{title}}</text>
		</view>
		<button @click="testaes">testaes</button>
		<button @click="test">testmd5</button>
		<button @click="testsm3">testsm3</button>
		<button @click="testHmac">testHmac</button>
		<!-- #ifdef APP-IOS || APP-HARMONY -->
		<button @click="testRsaiOS">testRsa-ios</button>
		<!-- #endif -->
		<!-- #ifdef APP-ANDROID -->
		<button @click="testRsa">testRsa</button>
		<!-- #endif -->
		<input type="text"
			style="height: 30px;width: 300px;background-color: #999;pointer-events: none;padding-left: 10px;" />
	</view>
</template>

<script setup lang="uts">
	import {
		base64EncodeSync,
		base64DecodeSync,
		md5Sync,
		sm4ECBEncryptSync,
		sm4ECBDecryptSync,
		sm4CBCEncryptSync,
		sm4CBCDecryptSync,
		sm3EncryptSync,
		sm2EncryptSync,
		sm2DecryptSync,
		aesCBCEncryptSync,
		aesCBCDecryptSync,
		aesEncryptSync,
		aesDecryptSync,
		sha1Sync,
		sha256Sync,
		hmacSHA1Sync,
		sm2PubSignSync,
		sm2PubSignValSync,
		// #ifdef APP-IOS || APP-HARMONY
		rsaEncryptSync,
		rsaDecryptSync,
		// #endif
		// #ifdef APP-ANDROID
		generateKeyPair,
		rsaEncryptSync,
		rsaDecryptSync,
		getKeyPair
		// #endif
	} from "@/uni_modules/tq-encrypt"
	import { ref } from "vue"
	// #ifdef APP-ANDROID
	import KeyPair from 'java.security.KeyPair';
	// #endif

	const title = ref('Hello')
	function test() {
		// const pw = md5Sync("123456")
		// console.log(pw);
		try {
			const md5 = md5Sync('123456')
			console.log(md5);
			const str = base64EncodeSync("123456")
			console.log(str);
			const origin = base64DecodeSync(str)
			console.log(origin);
			const sha1 = sha1Sync("123456")
			console.log(sha1);
			const sha256 = sha256Sync("123456")
			console.log(sha256);
			

		} catch (e) {
			console.log(e);
		}

	}

	function testaes() {
		const key = "457E900861A54A3A56A1B7BA69455073"
		const iv = "450A5408611B77E9"
		let plaitext = "123456"
		const aes = aesCBCEncryptSync(plaitext, key, iv)
		console.log(aes);
		const origin = aesCBCDecryptSync(aes,key,iv)
		console.log(origin);
		const res = aesEncryptSync(plaitext, key,true)
		console.log(res);
		const dom = aesDecryptSync(res, key,true)
		console.log(dom);
	}
	
	function testsm3() {
		let key = "EA4EBDC1DCEAEC733FFD358BA15E8DCD";
		const sm4 = sm4ECBEncryptSync("123456",key)
		console.log(sm4);
		const originSm4 = sm4ECBDecryptSync(sm4,key);
		console.log(originSm4);
		const iv = 'fedcba98765432100123456789abcdef';
		const cbcsm4 = sm4CBCEncryptSync("123456",key,iv)
		console.log(cbcsm4);
		const origincbcsm4 = sm4CBCDecryptSync(cbcsm4,key,iv)
		console.log(origincbcsm4);
		const sm3 = sm3EncryptSync("123456")
		console.log(sm3);//207CF410532F92A47DEE245CE9B11FF71F578EBD763EB3BBEA44EBD043D018FB
		let pubKey = "0438C061808B14AACBEBE18540C8EC1C64488372482FD439D2F1B672AD77D83E01B044487313EAB49F9B28DDCC698CBBEF667AAE645AC27DEBD8C5B64F72EC5335"
		let prikey = "00A14F4C5CC1EB5CEB302F68B3F308E96F434301596223544F86BE14FB528336F8"
		const sm2 = sm2EncryptSync("123456",pubKey)
		console.log(sm2);
		const originsm2 = sm2DecryptSync(sm2,prikey)
		console.log(originsm2);
		let plaitext = "123456"
		const sm2PubSign = sm2PubSignSync(plaitext,prikey)
		console.log(sm2PubSign);
		const verifySign = sm2PubSignValSync(plaitext,pubKey,sm2PubSign)
		console.log(verifySign);
	}
	
	function testHmac() {
		let plaintext = "123456"
		let key = "qwertyuiop1234567890"
		let hmac = hmacSHA1Sync(plaintext, key)
		console.log(hmac);
	}
	
	
	function testRsa() {
		// #ifdef APP-ANDROID
		try{
			const pub = "30820122300d06092a864886f70d01010105000382010f003082010a0282010100b97861cef7fa3998489a7a49ce80f59de128ab22c3864bdb86a0781ff3f8f3200ef4419e7baad6cfcb5b245a059344a24833a686e5ab879599a7a756447d0f34dcd8f0fee883a4a82af8388eaa7b2b9bf7ef60a823217b3d944bdbca18f12916f93456c8331f8552ed264c1f46f05b39e243b6c804129a9e1bf6e442ed7ce528e692cd12306375c35b870627390e0af41b41e6c0cf250f0ed37ba4efc93de7c8c4e4a0b1a6ec4a6d7241fa5dfe23ef98840ba4a295d14482b6a5a25f9b3f38d0db99b9ed2d4963b02dd8f00a56ab95b48654a7d14fca892f8d03b38a9bd2086615ffddff43a03b1ea03997e238e90fb647476db919895f9e1c7b53c7afbe47190203010001"
			const pri = "308204c0020100300d06092a864886f70d0101010500048204aa308204a60201000282010100b97861cef7fa3998489a7a49ce80f59de128ab22c3864bdb86a0781ff3f8f3200ef4419e7baad6cfcb5b245a059344a24833a686e5ab879599a7a756447d0f34dcd8f0fee883a4a82af8388eaa7b2b9bf7ef60a823217b3d944bdbca18f12916f93456c8331f8552ed264c1f46f05b39e243b6c804129a9e1bf6e442ed7ce528e692cd12306375c35b870627390e0af41b41e6c0cf250f0ed37ba4efc93de7c8c4e4a0b1a6ec4a6d7241fa5dfe23ef98840ba4a295d14482b6a5a25f9b3f38d0db99b9ed2d4963b02dd8f00a56ab95b48654a7d14fca892f8d03b38a9bd2086615ffddff43a03b1ea03997e238e90fb647476db919895f9e1c7b53c7afbe4719020301000102820101008ae7c1011c31b88ef7d9523b12c0fcb3389d97c65a7fab32879a893d0d20e71d9c758ceba01d2bf2c68fc522f2c80000366910903954852022cb30856897ed1a9f488efdaab0655259943bef8578e80950e06418a8eefb78fc26f03e64fdc0d366e2af181349c935794d54779c4e895449c483113c139edf497c582a53e9554a4cd770dc15687db28e228abb3e040339cc150954a8736f0ceaa826fba45268d2db5fc538479c354fd9c4afc7c7ac807692c947136cd1593dca3ec06d79588903bf70a35f09aa424afa519f2836eab24702bd2d205175f6adc985831aae13bdc1f1bbe8d1891f757e50106d98400a5a2b5f91413d43704a57b4f4ba4cf9a498b102818100e4b7bae4405936307f040bbc8c05f563f631a2eed6c6d881c3d750a2a6f35d3b4da5ec025b3248b81d25335e0db836f80d9e29add7973ffbd2c94ab58b879754d0be2b32a8b3de7c220c63bbf9f66b1874d03211e293194354871ee57f6a0e01645b1166a4c7c2d56fe5db33da9ccd3570711ec3ac473e42611c812017bd40b502818100cf980525e374f5c847eec956a8d7927949c5adcc76ae269c32ce352a3800f13e03c308c81e34ff58679c0aaba2da22ca83dfd83d54744ebab47feee41b8bde9c4c82a3063e6a9328beec1f04a372b5223db6c2abbeb1acffd5ef6e6b1dfd519dcad76209bb92cd17f8900acedfcca9b3a01b229e2251205f619dfd0336567f5502818100867ca2a0645610cf2360b5a6008fe0630ef8d0ddafdceca2210e129411a738430ebd69b158fe9053f28f554d10b4295e6263860e7a9ead38de110ea5018e91258638cc1dd5a52e45bf9f996586eda6bb92b4793c9b05f3eceb5f2883ba101a7c270e8584dd8fb8b8d83b48518d527637de0e2610d8d46b7f8caabe22a8d2d7a10281810080864f11a11c659b2525ea93739f5bb929fa705af95362e62bf24d2a21583c03b812851a58d15911e3bbd1436865034b3c9056f1c99ae4af65571b913098cd2f19937bd93ec57eeca81fca2876056bad9265d76abb7a87703184b6692d3d0bcdd4aabab0e9e7be80cbcc6a54a06cb6d85614d6beeee22957c4392b4f54d202ad02818100a9bfc79216f6d9b45c851822063ff68368beecd249ad9d8e602860da931afc04990ed06937989ab7bb0f66cac5f6e9e51f3984502833fafcfacb613dde52434193fac8f5d91bedfa02b151042e31e86b6eddabecda2dab9b786723fdaf8d16df1240fc5feea251a8b1380a8b19facc8c59ff4aae264ef2ecc9d9a799a9afdaf8"
			const key:KeyPair = generateKeyPair(pub,pri)
			
			const res = rsaEncryptSync("123456", key, 1)//公钥加密
			console.log(res);
			const origin = rsaDecryptSync(res, key, 2)//私钥解密
			console.log(origin);
		}catch(e){
			//TODO handle the exception
			console.log(e);
		}
		// #endif
	}

	function go() {
		uni.navigateTo({
			url: "/pages/index/demo"
		})
	}
	// #ifdef APP-IOS || APP-HARMONY
	function testRsaiOS() {
		let pemKey = `-----BEGIN PUBLIC KEY-----
MIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEA1KnGxzkVbWZNa+7v0rFF
NWVCDYbg2bqUt5YuKDfgAmy0LK7kUwLKy9f4pQl/f9EWJYZAN8ZShG7gdNMfo1bZ
sGvIRz58HRA6yzLVbO7rfwpCbW0XKtVRbuY4yZZQ5ELIDPPOGkXP+kbO+r7hwf+s
YrtlZ/kCV7TmAz585N39lgPudn8fBIbIRO4nN/U4dnpK9LUA/94xJyTq68nbuQ3I
sct6eTR4ewP2dHf9rUqk0RZWd8vOHBE5UMFDjSf5nnIoQAtYMGfarnbiqXNYp16m
dwzV+8WhGEOTsADrkp2vSJbqARvAH/UMDEJrHwUGC/4SHeDbTAypPRq+qchzV+MP
yso3+pqw01lrvPhazotvihfiqnSwcqZ8nNUKcDTPA6QAWDGXK1jWJjxL0xDyOoXF
MuLzsIP3WttsHIXAYqpke5NXbY8T9jOsLQ9cOhN0zLcLkbZpza5C1v36AR1oZuBo
3BaRbt85SCMWP26wVwvjf7+denqvwcBjMTJA99OPkPL2yEo9B0jNdhguI1aeeHr4
uXMYGys2XFlEv6ezKPP4nB7lmK1gOBtI7tE2eXTIThXRSsahO2mSzH8MkWzfsM0e
t5QtksuvWXKEtJbIaidq6Kpwm//Rj+nERovhdS8GOKGEZKxliJ08pQP2Vm3FqMi+
GZ/s+7okZ/za3WAIvZqaa/0CAwEAAQ==
-----END PUBLIC KEY-----
`
		let encrypted = rsaEncryptSync("Hello, World!", pemKey);
		console.log(encrypted);
		
		let privateStr = `-----BEGIN PRIVATE KEY-----
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
xygDgf/o3S0ddZP/146cro///F7X1w==
-----END PRIVATE KEY-----
`
		let origin = rsaDecryptSync(encrypted,privateStr)
		console.log(origin);
	}
	// #endif
</script>

<style>
	.content {
		display: flex;
		align-items: center;
		justify-content: center;
	}

	.logo {
		height: 200rpx;
		width: 200rpx;
		margin-top: 200rpx;
		margin-bottom: 50rpx;
	}

	.title {
		font-size: 36rpx;
		color: #8f8f94;
	}
</style>
```


### 注意

1、本插件包含原生第三方库需要配置gradle库和sdk库

[Android UTS扩展开发](https://uniapp.dcloud.net.cn/tutorial/run/uts-development-android.html)

![](https://qiniu-web-assets.dcloud.net.cn/unidoc/zh/%E9%85%8D%E7%BD%AE.png)

![](https://cdn.jsdelivr.net/gh/qitiandear/qtpic/img/20240328113941.png)

HBuilder X新版本更新后需要升级gradle库，本人使用的版本是gradle8.2.1配置jdk路径为jdk17，其他版本可使用官方推荐版本

> ps: 如果有问题可以咨询作者，本人QQ：1307905648，也可以在评论区留言截图配置环境和错误信息