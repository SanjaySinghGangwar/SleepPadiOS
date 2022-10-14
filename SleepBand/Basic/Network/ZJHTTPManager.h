//
//  ZJHTTPManager.h
//  Pods
//
//  Created by 何助金 on 2017/3/3.
//
//

#import <Foundation/Foundation.h>
#import <AFNetworking/AFNetworking.h>

typedef NS_ENUM(NSUInteger, HTTPRequestType) {
    HTTPRequestType_GET = 0,
    HTTPRequestType_POST,
    HTTPRequestType_PUT,
    HTTPRequestType_DELETE,
    HTTPRequestType_PATCH,
    HTTPRequestType_COUNT,
};

@interface ZJHTTPManager : NSObject
@property (nonatomic, strong) AFHTTPSessionManager * _Nullable sessionManager;
@property (nonatomic, strong) NSString * _Nullable baseUrl;

#pragma mark -
+ (ZJHTTPManager *_Nullable)manager;
- (void)setRequestHeader:(NSDictionary *_Nullable)dicHeader;
#pragma mark - RequestMethods

#pragma mark  BaseMethods

/**
 HTTP 异步请求 使用BaseURL
 
 @param resquestType 请求方法 GET POST ...
 @param parameters 请求参数 key-value 格式
 @param success 成功block
 @param failure 失败block
 @return 发起请求是否成功
 */
- (BOOL)resquestWith:(HTTPRequestType)resquestType
          withParams:(nullable id)parameters
             success:(nullable void (^)(NSURLSessionDataTask * _Nullable task, id _Nullable responseObject))success
             failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSError * _Nullable error))failure;


/**
 HTTP 异步请求

 @param resquestType 请求方法 GET POST ...
 @param strURL       请求地址
 @param parameters 请求参数 key-value 格式
 @param success 成功block
 @param failure 失败block
 @return 发起请求是否成功
 */
- (BOOL)resquestWith:(HTTPRequestType)resquestType
             withURL:(NSString *_Nullable)strURL
          withParams:(nullable id)parameters
             success:(nullable void (^)(NSURLSessionDataTask * _Nullable task, id _Nullable responseObject))success
             failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSError * _Nullable error))failure;

#pragma mark -  upload image

/**
 上传图像

 @param imageData 图像Data
 @param strURL 上传路径
 @param parameters 请求参数
 @param uploadProgress 上传进度
 @param success 成功block
 @param failure 失败block
 @return 请求是否发起成功
 */
- (BOOL)uploadImageWithData:(NSData *_Nullable)imageData
                    withURL:(NSString *_Nullable)strURL
                 withParams:(nullable id)parameters
                   progress:(nullable void (^)(NSProgress * _Nonnull))uploadProgress
                    success:(void (^_Nullable)(NSURLSessionDataTask * _Nullable task, id _Nullable responseObject))success
                    failure:(void (^_Nullable)(NSURLSessionDataTask * _Nullable task, NSError * _Nullable error))failure;

//意见反馈
- (BOOL)uploadWithDictData:(NSDictionary *_Nullable)dictionary
                    withURL:(NSString *_Nullable)strURL
                 withParams:(nullable id)parameters
                   progress:(nullable void (^)(NSProgress * _Nonnull))uploadProgress
                    success:(void (^_Nullable)(NSURLSessionDataTask * _Nullable task, id _Nullable responseObject))success
                    failure:(void (^_Nullable)(NSURLSessionDataTask * _Nullable task, NSError * _Nullable error))failure;



/**
 上传自定义文件

 @param fileData 文件Data
 @param strURL 上传路径
 @param parameters 请求参数
 @param fileName 文件名
 @param mimeType 文件类型
 @param uploadProgress 上传进度
 @param success 上传成功block
 @param failure 上传失败block
 @return 是否成功发起请求
 */
- (BOOL)uploadFileWithFileData:(NSData *_Nullable)fileData
                       withURL:(NSString *_Nullable)strURL
                    withParams:(nullable id)parameters
                  withfileName:(NSString *_Nullable)fileName
                  withMimeType:(NSString *_Nullable)mimeType
                   progress:(nullable void (^)(NSProgress * _Nonnull))uploadProgress
                    success:(void (^_Nullable)(NSURLSessionDataTask * _Nullable task, id _Nullable responseObject))success
                    failure:(void (^_Nullable)(NSURLSessionDataTask * _Nullable task, NSError * _Nullable error))failure;

#pragma mark -  download

/**
 下载文件

 @param strURL 下载文件请求地址
 @param downloadProgressBlock 下载进度block
 @param complet 完成block
 @return 是否请求成功
 */
- (BOOL)dowloadFileWithURL:(NSString *_Nullable)strURL
                  progress:(void (^_Nullable)(NSProgress * _Nullable downloadProgress))
downloadProgressBlock
         completionHandler:(void (^_Nullable)(NSURLResponse * _Nullable response, NSURL * _Nullable filePath, NSError * _Nullable error))complet;
@end
