//
//  VMDownloadHttp.m
//  Pods
//
//  Created by chengqihan on 16/4/19.
//
//

#import "VMDownloadHttp.h"
#define DownloadTimeOutInterval 15

@interface VMDownloadHttp ()<NSURLSessionDataDelegate>
@property (nonatomic, assign)long long currentLength; /**< 当前已经下载的大小 */
@property (readwrite, nonatomic, copy) VMURLSessionTaskCompletionHandler completionHandler;
@property (readwrite, nonatomic, copy) ProgressBlock downloadProgress;
@end

@implementation VMDownloadHttp
+ (NSURLSessionDataTask *)HEADRequest:(NSURLRequest *)request completionHandler:(void(^)(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error))completionHandler {
    NSURLSession *session = [NSURLSession sharedSession];
    NSMutableURLRequest *HEADRequest = [NSMutableURLRequest requestWithURL:request.URL];
    HEADRequest.HTTPMethod = @"HEAD";
    [HEADRequest setTimeoutInterval:DownloadTimeOutInterval];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:HEADRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (completionHandler) {
            completionHandler(data,response,error);
        }
    }];
    [dataTask resume];
    return dataTask;
}


- (NSURLSessionDataTask *)downloadTaskWithRequest:(NSURLRequest *)request progress:(ProgressBlock)downloadProgressBlock fileURL:(nullable NSString * (^)(NSURLResponse *response))fileURL completionHandler:(nullable void (^)(NSURLResponse *response, NSError * _Nullable error))completionHandler {
    self.downloadProgress = downloadProgressBlock;
    if (fileURL) {
        self.currentLength = [self getFileSizeWithPath:fileURL(nil)];
    }
    self.completionHandler = completionHandler;
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:[NSOperationQueue new]];
    NSMutableURLRequest *rangeRequest = [NSMutableURLRequest requestWithURL:request.URL];
    NSString *range = [NSString stringWithFormat:@"bytes=%lld-", self.currentLength];
    [rangeRequest setValue:range forHTTPHeaderField:@"Range"];
    [rangeRequest setTimeoutInterval:DownloadTimeOutInterval];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:rangeRequest];
    [dataTask resume];
    return dataTask;
    
//    NSURLConnection *conn = [NSURLConnection connectionWithRequest:rangeRequest delegate:self];
//    return conn;
}

// 从本地文件中获取已下载文件的大小
- (UInt64)getFileSizeWithPath:(NSString *)path
{
    UInt64 currentSize = [[[NSFileManager defaultManager] attributesOfItemAtPath:path error:nil][NSFileSize] longLongValue];
    return currentSize;
}

#pragma mark - NSURLSessionDataDelegate
// 接收到服务器的响应时调用
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler
{
    // 告诉系统需要接收数据
    if (completionHandler) {
        completionHandler(NSURLSessionResponseAllow);
    }
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data
{
    self.currentLength += data.length;
    if (self.downloadProgress) {
        self.downloadProgress(data,self.currentLength);
    }
}

// 请求完毕时调用, 如果error有值, 代表请求错误
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
{
    if (self.completionHandler) {
        self.completionHandler(task.response,error);
    }
    [session finishTasksAndInvalidate];
}

- (void)dealloc
{
    NSLog(@"%@ delloc",[self class]);
}
@end
