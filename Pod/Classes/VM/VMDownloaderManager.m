
//
//  VMDownloaderManager.m
//  Pods
//
//  Created by chengqihan on 16/4/5.
//
//
#import <Downloader/Downloader-Swift.h>
#import "VMDownloaderManager.h"
#import "VMScreenLogger.h"
#import "Reachability.h"
#import "VMDownloadConfig.h"

@import CocoaLumberjack;
#define MAXONGOINGCOUNT 3
@interface VMDownloaderManager ()
@property (readwrite, nonatomic, strong) NSThread *downloadTaskRunLoopThread;
@end
@implementation VMDownloaderManager
static NSDictionary *MANAGERS;

- (instancetype)init
{
    self = [super init];
    if (self) {
        _downloadTaskRunLoopThread = [[NSThread alloc] initWithTarget:self selector:@selector(downloadTaskRunLoopThreadEntry) object:nil];
        [_downloadTaskRunLoopThread start];
    }
    return self;
}

- (void)downloadTaskRunLoopThreadEntry {
    NSThread * currentThread = [NSThread currentThread];
    currentThread.name = @"DownloadTaskManagerThread";
    NSRunLoop *currentRunloop = [NSRunLoop currentRunLoop];
    [currentRunloop addPort:[NSMachPort port] forMode:NSDefaultRunLoopMode];
    [currentRunloop run];
}

+ (void)initialize
{
    if (self == [VMDownloaderManager class]) {
        [DDLog addLogger:[VMScreenLogger new] withLevel:DDLogLevelDebug];
        MANAGERS = [NSDictionary dictionary];
    }
}

- (instancetype)getInstance:(NSString *)key
{
    return MANAGERS[key];
}

#pragma mark ----------- AddObserver
- (void)startObserverNetworkState {
    Reachability* reach = [Reachability reachabilityWithHostname:@"www.baidu.com"];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
    
    [reach startNotifier];
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self forKeyPath:MAX_DOWNLOAD_COUNT options:NSKeyValueObservingOptionNew context:nil];
    [nc addObserver:self forKeyPath:NETWORK_MODE options:NSKeyValueObservingOptionNew context:nil];
}


- (void)reachabilityChanged:(Reachability *)reach
{
    VMScreenLogger(@"%zd",reach.currentReachabilityStatus);
    [self sendNetworkChanged];
}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    if ([keyPath isEqualToString:NETWORK_MODE]) {
        [self sendNetworkChanged];
    }
    if ([keyPath isEqualToString:MAX_DOWNLOAD_COUNT]) {
        [self sendMaxDownloadCountChanged];
    }
}

- (void)sendNetworkChanged {
    
}

- (void)sendMaxDownloadCountChanged {
    
}

- (void)dealloc
{
    NSUserDefaults *uc = [NSUserDefaults standardUserDefaults];
    [uc removeObserver:self forKeyPath:MAX_DOWNLOAD_COUNT];
    [uc removeObserver:self forKeyPath:NETWORK_MODE];
}

- (VMDownloadTask *)enqueueWithDownloadRequest:(DownloadRequest *)request
{
    VMDownloadTask *task = [[VMDownloadTask alloc] initWithRunloopThread:self.downloadTaskRunLoopThread];
    
}

@end
