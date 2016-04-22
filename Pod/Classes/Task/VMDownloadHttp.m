//
//  VMDownloadHttp.m
//  Pods
//
//  Created by chengqihan on 16/4/19.
//
//

#import "VMDownloadHttp.h"
#define DownloadTimeOutInterval 15
typedef NSURL * (^VMURLSessionDownloadTaskDidFinishDownloadingBlock)(NSURLSession *session, NSURLSessionDownloadTask *downloadTask, NSURL *location);
typedef void (^VMURLSessionTaskCompletionHandler)(NSURLResponse *response, NSError *error);

@interface VMDownloadHttp ()<NSURLConnectionDataDelegate>
@property (nonatomic, assign)long long totalLength; /**< 总大小 */

@property (nonatomic, assign)long long currentLength; /**< 当前已经下载的大小 */

//@property (nonatomic, strong) NSOutputStream *outputStream ; /**< 输出流 */

@property (nonatomic, copy) NSString *path; /**< 文件路径 */

@property (readwrite, nonatomic, strong) NSMutableURLRequest *request;

@property (readwrite, nonatomic, copy) VMURLSessionTaskCompletionHandler completionHandler;
@property (readwrite, nonatomic, copy) void(^finishDownload) ();
@property (readwrite, nonatomic, copy) ProgressBlock downloadProgress;

@property (nonatomic, strong) NSURLConnection *conn;
@end

@implementation VMDownloadHttp

- (NSURLConnection *)downloadTaskWithRequest:(NSURLRequest *)request progress:(ProgressBlock)downloadProgressBlock fileURL:(NSString *(^)(NSURLResponse *))fileURL didFinishLoading:(void (^)())finish completionHandler:(void (^)(NSURLResponse *, NSError * _Nullable))completionHandler {
    self.downloadProgress = downloadProgressBlock;
    if (fileURL) {
        self.path = fileURL(nil);
        self.currentLength = [self getFileSizeWithPath:self.path];
    }
    self.request = [NSMutableURLRequest requestWithURL:request.URL];
    self.completionHandler = completionHandler;
    self.finishDownload = finish;
    return self.conn;
}

+ (void)getHttpHeadWithUrlString:(NSString *)urlstring completion:(void(^)(NSURLResponse * response,NSData *data, NSError * connectionError))completion
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlstring]];
    request.HTTPMethod = @"HEAD";
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue new] completionHandler:^(NSURLResponse * _Nullable response, NSData * _Nullable data, NSError * _Nullable connectionError) {
        if (completion) {
            completion(response,data,connectionError);
        }
    }];
}

- (NSURLConnection *)conn
{
    if (!_conn) {
        
        // 设置请求头
        NSString *range = [NSString stringWithFormat:@"bytes=%lld-", [self getFileSizeWithPath:self.path]];
        [self.request setValue:range forHTTPHeaderField:@"Range"];
        [self.request setTimeoutInterval:DownloadTimeOutInterval];
        _conn = [NSURLConnection connectionWithRequest:self.request delegate:self];
    }
    return _conn;
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
    
    // 初始化文件总大小
    self.totalLength = response.expectedContentLength + [self getFileSizeWithPath:self.path];
    
//    // 打开输出流
//    self.outputStream = [NSOutputStream outputStreamToFileAtPath:self.path append:YES];
//    [self.outputStream open];
}


// 接收到服务器返回的数据时调用
// data 此次接收到的数据
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
//    NSLog(@"didReceiveData %zd",data.length);
    // 累加已经下载的大小
    self.currentLength += data.length;
    
    if (self.downloadProgress) {
        self.downloadProgress(data,self.currentLength,self.totalLength);
    }
    // 写入数据
//    [self.outputStream write:data.bytes maxLength:data.length];
    
}

// 请求完毕时调用, 如果error有值, 代表请求错误
- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    // 关闭输出流
//    [self.outputStream close];
    
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
