// ============================================================
// NativeS3.swift - AWS SDK for iOS 原生桥接层
// 所有 @objc 方法可被 UTS 直接调用
// ============================================================

import Foundation
import AWSCore
import AWSS3

@objc public class NativeS3: NSObject {

    // MARK: - 静态属性
    private static var s3Client: AWSS3?

    // MARK: - 初始化
    @objc public static func initS3(
        accessKey: String,
        secretKey: String,
        sessionToken: String?,
        region: String,
        endpoint: String?
    ) {
        // 构造凭证
        let credentials: AWSCredentials
        if let token = sessionToken, !token.isEmpty {
            credentials = AWSBasicSessionCredentials(
                accessKey: accessKey,
                secretKey: secretKey,
                sessionToken: token
            )
        } else {
            credentials = AWSBasicCredentials(
                accessKey: accessKey,
                secretKey: secretKey
            )
        }

        // 构造服务配置
        let regionType = regionToRegionType(region)
        var configuration: AWSServiceConfiguration

        if let endpoint = endpoint, !endpoint.isEmpty {
            configuration = AWSServiceConfiguration(
                region: regionType,
                endpoint: AWSEndpoint(urlString: endpoint),
                credentialsProvider: AWSStaticCredentialsProvider(credentials: credentials)
            )
        } else {
            configuration = AWSServiceConfiguration(
                region: regionType,
                credentialsProvider: AWSStaticCredentialsProvider(credentials: credentials)
            )
        }

        // 注册 S3 客户端
        AWSServiceManager.default().defaultServiceConfiguration = configuration
        AWSS3.register(with: configuration, forKey: "defaultS3")
        s3Client = AWSS3.s3(forKey: "defaultS3")
    }

    // MARK: - 上传文件
    @objc public static func uploadFile(
        filePath: String,
        bucket: String,
        s3Key: String,
        contentType: String?,
        completion: @escaping (Bool, String) -> Void
    ) {
        guard let client = s3Client else {
            completion(false, "S3 客户端未初始化")
            return
        }

        let fileURL = URL(fileURLWithPath: filePath)
        let uploadRequest = AWSS3TransferManagerUploadRequest()!
        uploadRequest.bucket = bucket
        uploadRequest.key = s3Key
        uploadRequest.body = fileURL
        if let ct = contentType, !ct.isEmpty {
            uploadRequest.contentType = ct
        }

        let transferManager = AWSS3TransferManager.default()
        transferManager.upload(uploadRequest).continueWith { task -> Any? in
            if let error = task.error {
                completion(false, "上传失败: \(error.localizedDescription)")
            } else {
                completion(true, "上传成功")
            }
            return nil
        }
    }

    // MARK: - 下载文件
    @objc public static func downloadFile(
        bucket: String,
        s3Key: String,
        savePath: String,
        completion: @escaping (Bool, String) -> Void
    ) {
        guard let client = s3Client else {
            completion(false, "S3 客户端未初始化")
            return
        }

        let downloadRequest = AWSS3TransferManagerDownloadRequest()!
        downloadRequest.bucket = bucket
        downloadRequest.key = s3Key
        downloadRequest.downloadingFileURL = URL(fileURLWithPath: savePath)

        let transferManager = AWSS3TransferManager.default()
        transferManager.download(downloadRequest).continueWith { task -> Any? in
            if let error = task.error {
                completion(false, "下载失败: \(error.localizedDescription)")
            } else {
                completion(true, "下载成功")
            }
            return nil
        }
    }

    // MARK: - 删除对象
    @objc public static func deleteObject(
        bucket: String,
        s3Key: String,
        completion: @escaping (Bool, String) -> Void
    ) {
        guard let client = s3Client else {
            completion(false, "S3 客户端未初始化")
            return
        }

        let deleteRequest = AWSS3DeleteObjectRequest()!
        deleteRequest.bucket = bucket
        deleteRequest.key = s3Key

        client.deleteObject(deleteRequest).continueWith { task -> Any? in
            if let error = task.error {
                completion(false, "删除失败: \(error.localizedDescription)")
            } else {
                completion(true, "删除成功")
            }
            return nil
        }
    }

    // MARK: - 列举对象
    @objc public static func listObjects(
        bucket: String,
        prefix: String?,
        delimiter: String?,
        maxKeys: Int,
        continuationToken: String?,
        completion: @escaping ([String], [String], Bool, String?, String) -> Void
    ) {
        guard let client = s3Client else {
            completion([], [], false, nil, "S3 客户端未初始化")
            return
        }

        let listRequest = AWSS3ListObjectsV2Request()!
        listRequest.bucket = bucket
        listRequest.maxKeys = maxKeys
        if let p = prefix, !p.isEmpty { listRequest.prefix = p }
        if let d = delimiter, !d.isEmpty { listRequest.delimiter = d }
        if let ct = continuationToken, !ct.isEmpty {
            listRequest.continuationToken = ct
        }

        client.listObjectsV2(listRequest).continueWith { task -> Any? in
            if let error = task.error {
                completion([], [], false, nil, "列举失败: \(error.localizedDescription)")
                return nil
            }

            let result = task.result as? AWSS3ListObjectsV2Output
            var keys: [String] = []
            var prefixes: [String] = []

            if let contents = result?.contents {
                for obj in contents {
                    if let key = obj.key { keys.append(key) }
                }
            }
            if let commonPrefixes = result?.commonPrefixes {
                for cp in commonPrefixes {
                    if let p = cp.prefix { prefixes.append(p) }
                }
            }

            let isTruncated = result?.isTruncated?.boolValue ?? false
            let nextToken = result?.nextContinuationToken
            completion(keys, prefixes, isTruncated, nextToken, "列举成功")
            return nil
        }
    }

    // MARK: - 生成预签名 URL
    @objc public static func getPresignedUrl(
        bucket: String,
        s3Key: String,
        expiresIn: Int,
        method: String,
        completion: @escaping (String) -> Void
    ) {
        let getPreSignedURLRequest = AWSS3GetPreSignedURLRequest()
        getPreSignedURLRequest.bucket = bucket
        getPreSignedURLRequest.key = s3Key
        getPreSignedURLRequest.httpMethod = method.lowercased() == "put" ? .PUT : .GET
        getPreSignedURLRequest.expires = Date().addingTimeInterval(TimeInterval(expiresIn))

        AWSS3PreSignedURLBuilder.default()
            .getPreSignedURL(getPreSignedURLRequest)
            .continueWith { task -> Any? in
                if let error = task.error {
                    completion("")
                } else if let url = task.result as? URL {
                    completion(url.absoluteString)
                } else {
                    completion("")
                }
                return nil
            }
    }

    // MARK: - Region 转换工具
    private static func regionToRegionType(_ region: String) -> AWSRegionType {
        switch region {
        case "us-east-1":      return .USEast1
        case "us-east-2":      return .USEast2
        case "us-west-1":      return .USWest1
        case "us-west-2":      return .USWest2
        case "eu-west-1":      return .EUWest1
        case "eu-west-2":      return .EUWest2
        case "eu-central-1":   return .EUCentral1
        case "ap-southeast-1": return .APSoutheast1
        case "ap-southeast-2": return .APSoutheast2
        case "ap-northeast-1": return .APNortheast1
        case "ap-northeast-2": return .APNortheast2
        case "ap-south-1":     return .APSouth1
        case "sa-east-1":      return .SAEast1
        case "cn-north-1":     return .CNNorth1
        default:               return .USEast1
        }
    }
}