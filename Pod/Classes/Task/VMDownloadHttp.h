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
- (NSURLConnection *)downloadTaskWithRequest:(NSURLRequest *)request didReceiveResponse:(void(^)(NSURLResponse *response))receiveResponse
                                   progress:(ProgressBlock)downloadProgressBlock
                                     fileURL:(nullable NSString * (^)(NSURLResponse *response))fileURL didFinishLoading:(void(^)())finish
                          completionHandler:(nullable void (^)(NSURLResponse *response, NSError * _Nullable error))completionHandler;
@end
