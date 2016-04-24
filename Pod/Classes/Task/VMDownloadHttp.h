//
//  VMDownloadHttp.h
//  Pods
//
//  Created by chengqihan on 16/4/19.
//
//

#import <Foundation/Foundation.h>
typedef void(^ProgressBlock)(NSData* data, int64_t totalBytesWritten);
typedef void (^VMURLSessionTaskCompletionHandler)(NSURLResponse *response, NSError *error);

@interface VMDownloadHttp : NSObject
- (NSURLSessionDataTask *)downloadTaskWithRequest:(NSURLRequest *)request progress:(ProgressBlock)downloadProgressBlock fileURL:(nullable NSString * (^)(NSURLResponse *response))fileURL completionHandler:(nullable void (^)(NSURLResponse *response, NSError * _Nullable error))completionHandler;

+ (NSURLSessionDataTask *)HEADRequest:(NSURLRequest *)request completionHandler:(void(^)(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error))completionHandler;
@end
