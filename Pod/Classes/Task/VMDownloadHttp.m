//
//  VMDownloadHttp.m
//  Pods
//
//  Created by chengqihan on 16/4/19.
//
//

#import "VMDownloadHttp.h"
#define DownloadTimeOutInterval 15

@interface VMDownloadHttp ()<NSURLConnectionDataDelegate>
@property (nonatomic, assign)long long currentLength; /**< 当前已经下载的大小 */
@property (readwrite, nonatomic, copy) VMURLSessionTaskCompletionHandler completionHandler;
@property (readwrite, nonatomic, copy) void(^finishDownload) ();
@property (readwrite, nonatomic, copy) ProgressBlock downloadProgress;
@property (readwrite, nonatomic, copy) void (^receiveResponse)(NSURLResponse *);
@end

@implementation VMDownloadHttp

- (NSURLConnection *)downloadTaskWithRequest:(NSURLRequest *)request didReceiveResponse:(void (^)(NSURLResponse *))receiveResponse progress:(ProgressBlock)downloadProgressBlock fileURL:(NSString *(^)(NSURLResponse *))fileURL didFinishLoading:(void (^)())finish completionHandler:(void (^)(NSURLResponse *, NSError * _Nullable))completionHandler {
    self.downloadProgress = downloadProgressBlock;
    if (fileURL) {
        self.currentLength = [self getFileSizeWithPath:fileURL(nil)];
    }
    self.completionHandler = completionHandler;
    self.finishDownload = finish;
    self.receiveResponse = receiveResponse;
    NSMutableURLRequest *rangeRequest = [NSMutableURLRequest requestWithURL:request.URL];
    NSString *range = [NSString stringWithFormat:@"bytes=%lld-", self.currentLength];
    [rangeRequest setValue:range forHTTPHeaderField:@"Range"];
    [rangeRequest setTimeoutInterval:DownloadTimeOutInterval];
    NSURLConnection *conn = [NSURLConnection connectionWithRequest:rangeRequest delegate:self];
    return conn;
}

// 从本地文件中获取已下载文件的大小
- (UInt64)getFileSizeWithPath:(NSString *)path
{
    UInt64 currentSize = [[[NSFileManager defaultManager] attributesOfItemAtPath:path error:nil][NSFileSize] longLongValue];
    return currentSize;
}

#pragma mark - NSURLSessionDataDelegate
// 接收到服务器的响应时调用

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    if (self.receiveResponse) {
        self.receiveResponse(response);
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    self.currentLength += data.length;
    if (self.downloadProgress) {
        self.downloadProgress(data,self.currentLength);
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    if (self.finishDownload) {
        self.finishDownload();
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    if (self.completionHandler) {
        self.completionHandler(nil,error);
    }
}
- (void)dealloc
{
    NSLog(@"%@ delloc",[self class]);
}
@end
