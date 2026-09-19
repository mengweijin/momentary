// ============================================================
// NativeS3.ets - AWS SDK for HarmonyOS 原生桥接层
// 基于 @ohos/aws-sdk-client-s3
// ============================================================

import { S3Client, PutObjectCommand, GetObjectCommand,
         DeleteObjectCommand, ListObjectsV2Command } from '@ohos/aws-sdk-client-s3'
import { getSignedUrl } from '@ohos/aws-sdk-client-s3'
import { fileIo } from '@kit.CoreFileKit'
import { buffer } from '@kit.ArkTS'

// ============================================================
// 全局客户端
// ============================================================
let s3Client: S3Client | null = null
let bucketName: string = ''

// ============================================================
// 初始化
// ============================================================
export function initS3(
  accessKey: string,
  secretKey: string,
  region: string,
  bucket: string,
  endpoint?: string,
  sessionToken?: string
): void {
  bucketName = bucket

  const clientOptions: Record<string, Object> = {
    region: region
  }

  // 构造凭证
  if (accessKey && secretKey) {
    const credentials: Record<string, string> = {
      accessKeyId: accessKey,
      secretAccessKey: secretKey
    }
    if (sessionToken && sessionToken.length > 0) {
      credentials.sessionToken = sessionToken
    }
    clientOptions.credentials = credentials
  }

  // 自定义 endpoint
  if (endpoint && endpoint.length > 0) {
    clientOptions.endpoint = endpoint
    clientOptions.forcePathStyle = true
  }

  s3Client = new S3Client(clientOptions)
}

// ============================================================
// 上传文件
// ============================================================
export async function uploadFile(
  filePath: string,
  s3Key: string,
  contentType?: string
): Promise<string> {
  if (!s3Client) {
    throw new Error('S3 客户端未初始化')
  }

  // 读取本地文件为 ArrayBuffer
  const file = fileIo.openSync(filePath, fileIo.OpenMode.READ_ONLY)
  const stat = fileIo.statSync(filePath)
  const arrayBuffer = new ArrayBuffer(stat.size)
  fileIo.readSync(file.fd, arrayBuffer)
  fileIo.closeSync(file)

  const bytes = new Uint8Array(arrayBuffer)

  const command = new PutObjectCommand({
    Bucket: bucketName,
    Key: s3Key,
    Body: bytes,
    ContentType: contentType ?? 'application/octet-stream'
  })

  await s3Client.send(command)
  return '上传成功'
}

// ============================================================
// 下载文件
// ============================================================
export async function downloadFile(
  s3Key: string,
  savePath: string
): Promise<string> {
  if (!s3Client) {
    throw new Error('S3 客户端未初始化')
  }

  const command = new GetObjectCommand({
    Bucket: bucketName,
    Key: s3Key
  })

  const response = await s3Client.send(command)
  if (!response.Body) {
    throw new Error('响应体为空')
  }

  const bytes: Uint8Array = await response.Body.transformToByteArray()

  // 写入本地文件
  const file = fileIo.openSync(savePath,
    fileIo.OpenMode.READ_WRITE | fileIo.OpenMode.CREATE | fileIo.OpenMode.TRUNC)
  fileIo.writeSync(file.fd, bytes.buffer)
  fileIo.closeSync(file)

  return '下载成功'
}

// ============================================================
// 删除对象
// ============================================================
export async function deleteObject(s3Key: string): Promise<string> {
  if (!s3Client) {
    throw new Error('S3 客户端未初始化')
  }

  const command = new DeleteObjectCommand({
    Bucket: bucketName,
    Key: s3Key
  })

  await s3Client.send(command)
  return '删除成功'
}

// ============================================================
// 列举对象
// ============================================================
export interface ListResult {
  keys: string[]
  commonPrefixes: string[]
  isTruncated: boolean
  nextContinuationToken?: string
}

export async function listObjects(
  prefix?: string,
  delimiter?: string,
  maxKeys?: number,
  continuationToken?: string
): Promise<ListResult> {
  if (!s3Client) {
    throw new Error('S3 客户端未初始化')
  }

  const command = new ListObjectsV2Command({
    Bucket: bucketName,
    Prefix: prefix,
    Delimiter: delimiter,
    MaxKeys: maxKeys ?? 1000,
    ContinuationToken: continuationToken
  })

  const response = await s3Client.send(command)

  const keys: string[] = []
  if (response.Contents) {
    for (let i = 0; i < response.Contents.length; i++) {
      const key = response.Contents[i].Key
      if (key) keys.push(key)
    }
  }

  const prefixes: string[] = []
  if (response.CommonPrefixes) {
    for (let i = 0; i < response.CommonPrefixes.length; i++) {
      const p = response.CommonPrefixes[i].Prefix
      if (p) prefixes.push(p)
    }
  }

  return {
    keys: keys,
    commonPrefixes: prefixes,
    isTruncated: response.IsTruncated ?? false,
    nextContinuationToken: response.NextContinuationToken
  }
}

// ============================================================
// 生成预签名 URL
// ============================================================
export async function getPresignedUrl(
  s3Key: string,
  expiresIn: number,
  method: string
): Promise<string> {
  if (!s3Client) {
    throw new Error('S3 客户端未初始化')
  }

  const httpMethod = method.toLowerCase() === 'put' ? 'PUT' : 'GET'

  let command: Object
  if (httpMethod === 'PUT') {
    command = new PutObjectCommand({
      Bucket: bucketName,
      Key: s3Key
    })
  } else {
    command = new GetObjectCommand({
      Bucket: bucketName,
      Key: s3Key
    })
  }

  return await getSignedUrl(s3Client, command, { expiresIn: expiresIn })
}