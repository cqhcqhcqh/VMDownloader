//
//  VMDownloadHttp.h
//  Pods
//
//  Created by chengqihan on 16/4/19.
//
//

#import <Foundation/Foundation.h>
typedef void(^ProgressBlock)(NSData* data, int64_t totalBytesWritten, int64_t totalBytesExpectedToWrite);

@interface VMDownloadHttp : NSObject
@property (readwrite, nonatomic, copy) NSString *url;
@property (readwrite, nonatomic, copy) NSString *fileDestination;
- (NSURLConnection *)downloadTaskWithRequest:(NSURLRequest *)request
                                   progress:(ProgressBlock)downloadProgressBlock
                                     fileURL:(nullable NSString * (^)(NSURLResponse *response))fileURL didFinishLoading:(void(^)())finish
                          completionHandler:(nullable void (^)(NSURLResponse *response, NSError * _Nullable error))completionHandler;
+ (void)getHttpHeadWithUrlString:(NSString *)urlstring completion:(void(^)(NSURLResponse * response,NSData *data, NSError * connectionError))completion;
@end
