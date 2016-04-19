//
//  VMDownloadHttp.m
//  Pods
//
//  Created by chengqihan on 16/4/19.
//
//

#import "VMDownloadHttp.h"

typedef NSURL * (^VMURLSessionDownloadTaskDidFinishDownloadingBlock)(NSURLSession *session, NSURLSessionDownloadTask *downloadTask, NSURL *location);
typedef void (^VMURLSessionTaskCompletionHandler)(NSURLResponse *response, NSError *error);

@interface VMDownloadHttp ()<NSURLSessionDataDelegate>
@property (nonatomic, assign)long long totalLength; /**< 总大小 */

@property (nonatomic, assign)long long currentLength; /**< 当前已经下载的大小 */

@property (nonatomic, strong) NSOutputStream *outputStream ; /**< 输出流 */

@property (nonatomic, strong) NSURLSession *session; /**< session */

@property (nonatomic, strong) NSURLSessionDataTask *task; /**< 任务 */

@property (nonatomic, copy) NSString *path; /**< 文件路径 */

@property (readwrite, nonatomic, strong) NSMutableURLRequest *request;
@property (readwrite, nonatomic, copy) VMURLSessionTaskCompletionHandler completionHandler;

@property (readwrite, nonatomic, copy) ProgressBlock downloadProgress;
@end

@implementation VMDownloadHttp
- (NSURLSessionDataTask *)downloadTaskWithRequest:(NSURLRequest *)request
                                   progress:(ProgressBlock)downloadProgressBlock
                                fileURL:(nullable NSString * (^)(NSURLResponse *response))fileURL
                          completionHandler:(nullable void (^)(NSURLResponse *response, NSError * _Nullable error))completionHandler {
    self.downloadProgress = downloadProgressBlock;
    if (fileURL) {
        self.path = fileURL(nil);
    }
    self.request = [NSMutableURLRequest requestWithURL:request.URL];
    self.completionHandler = completionHandler;
    return self.task;
}

#pragma mark - lazy
- (NSURLSession *)session
{
    if (!_session) {
        // 1.创建Session
#warning delegate会对self有个强引用,注意回收...,防止内存泄露
        _session =  [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    }
    return _session;
}



- (NSURLSessionDataTask *)task
{
    if (!_task) {
        
        // 设置请求头
        NSString *range = [NSString stringWithFormat:@"bytes:%zd-", [self getFileSizeWithPath:self.path]];
        [self.request setValue:range forHTTPHeaderField:@"Range"];
        
        _task = [self.session dataTaskWithRequest:self.request];
    }
    return _task;
}

// 从本地文件中获取已下载文件的大小
- (NSUInteger)getFileSizeWithPath:(NSString *)path
{
    NSUInteger currentSize = [[[NSFileManager defaultManager] attributesOfItemAtPath:path error:nil][NSFileSize] integerValue];
    return currentSize;
}

#pragma mark - NSURLSessionDataDelegate
// 接收到服务器的响应时调用
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler
{
    NSLog(@"didReceiveResponse");
    // 告诉系统需要接收数据
    if (completionHandler) {
        completionHandler(NSURLSessionResponseAllow);
    }

    // 初始化文件总大小
    self.totalLength = response.expectedContentLength + [self getFileSizeWithPath:self.path];
    
    // 打开输出流
    self.outputStream = [NSOutputStream outputStreamToFileAtPath:self.path append:YES];
    [self.outputStream open];
}

// 接收到服务器返回的数据时调用
// data 此次接收到的数据
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data
{
    NSLog(@"didReceiveData %zd",data.length);
    // 累加已经下载的大小
    self.currentLength += data.length;
    
    if (self.downloadProgress) {
        self.downloadProgress(data.length,self.currentLength,self.totalLength);
    }
    // 写入数据
    [self.outputStream write:data.bytes maxLength:data.length];
    
}

// 请求完毕时调用, 如果error有值, 代表请求错误
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
{
    NSLog(@"didCompleteWithError");
    
    // 关闭输出流
    [self.outputStream close];
    
    if (self.completionHandler) {
        self.completionHandler(task.response,error);
    }
}

- (void)dealloc
{
    NSLog(@"%@ delloc",[self class]);
}
@end
