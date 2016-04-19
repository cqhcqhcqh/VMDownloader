//
//  VMDownloadHttp.h
//  Pods
//
//  Created by chengqihan on 16/4/19.
//
//

#import <Foundation/Foundation.h>
typedef void(^ProgressBlock)(int64_t bytesWritten, int64_t totalBytesWritten, int64_t totalBytesExpectedToWrite);

@interface VMDownloadHttp : NSObject
@property (readwrite, nonatomic, copy) NSString *url;
@property (readwrite, nonatomic, copy) NSString *fileDestination;
- (NSURLSessionDataTask *)downloadTaskWithRequest:(NSURLRequest *)request
                                   progress:(ProgressBlock)downloadProgressBlock
                                    fileURL:(nullable NSString * (^)(NSURLResponse *response))fileURL
                          completionHandler:(nullable void (^)(NSURLResponse *response, NSError * _Nullable error))completionHandler;
@end
