//
//  VMDownloaderManager.m
//  Pods
//
//  Created by chengqihan on 16/4/6.
//


//  VMDownloadManager的内部有一个mapping 存储所有的VMDownloadManager

//  可以根据Identifier来获取已经存在mapping中的VMDownloadManager

//  VMDownloadManager配备 NSThread和VMDownloadConfig

//  NSThread 是用来执行所有的MessageQueue上的Operation的

//  VMDownloadConfig也是根据[Identifier]来创建一个SharePreference对象,SharePreference对象只是维护NSUserDefault中Key:[Identifier] 对应的dict

//  所以可以根据[Identifier]来直接读取SharePreference对象,使用SharePreference对象就可以直接进行 -setInteger -setString ...


#import "VMDownloaderManager.h"
#import "CPMessageOperation.h"
#import "VMDownloadTask.h"
#import "NSString+MD5.h"
#import "VMDownloadConfig.h"
#import "CPLoggerManager.h"
#import "Reachability.h"
#import "DownloaderDao.h"

@interface VMDownloaderManager ()
@property (readwrite, nonatomic, strong) VMDownloadConfig *downloadConfig;
@property (readwrite, nonatomic, strong) NSThread *downloadTaskRunLoopThread;
@property (readwrite, nonatomic, copy) NSString *identifier;
@end

@implementation VMDownloaderManager

- (void)startDownload {
    CPMessage *msg = [[CPMessage alloc] initWithType:MessageTypeActionDelete];
    //    [self.downloader sendMessage:msg];
}
- (void)pausedDownload {
    CPMessage *msg = [[CPMessage alloc] initWithType:MessageTypeActionPaused];
    //    [self.downloader sendMessage:msg];
    
}
- (void)retryDownload {
    CPMessage *msg = [[CPMessage alloc] initWithType:MessageTypeActionStart];
    //    [self.downloader sendMessage:msg];
}

- (void)deleteDownload {
    CPMessage *msg = [[CPMessage alloc] initWithType:MessageTypeActionDelete];
    //    [self.downloader sendMessage:msg];
}


#pragma mark -- 根据指定key获取dictionary对应的value(Manager)
+ (instancetype)getInstanceWithKey:(NSString *)key
{
    return MANAGERS[key];
}



#pragma mark -- initialize 打开日志和创建MANAGERS
static NSMutableDictionary *MANAGERS;
+ (void)initialize
{
    if (self == [VMDownloaderManager class]) {
        MANAGERS = [NSMutableDictionary dictionary];
        [CPLoggerManager openLogger:YES];
    }
}

#pragma mark  -- 构造方法
+ (instancetype)managerWithIdentifier:(NSString *)identifier{
    if (MANAGERS[identifier]) {
        
        return MANAGERS[identifier];
    }else {
        return [[self alloc] initWitIdentifier:identifier];
    }
}

/**
 *  构造方法中需要实例化几个重要属性
 *  1、_downloadTaskRunLoopThread
 *  2、VMDownloadConfig 实例(VMDownloadConfig提供类似于[NSUserDefault standardUserDefault]的接口
 *     VMDownloadConfig 内部有一个VMSharedPreferences实例
 *     VMDownloadConfig 对外提供的接口就是通过VMSharedPreferences实例内部的Dictionary 来完成存储的
 
 *  3、恢复数据库中被中断下载的任务
 *  4、监听网络变化<a、配置中网络的变化(允许3/4G、不允许3/4G的切换) b、手机网络的变化
 *
 *  @param identifier key
 *
 *  @return DownloadManager实例
 */
- (instancetype)initWitIdentifier:(NSString *)identifier {
    if (self == [super init]) {
        
        _identifier = identifier;
        
        _downloadTaskRunLoopThread = [[NSThread alloc] initWithTarget:self selector:@selector(downloadTaskRunLoopThreadEntry) object:nil];
        [_downloadTaskRunLoopThread start];
        
        _downloadConfig = [VMDownloadConfig loadLocalConfigFromPreference:_identifier];
        
        [MANAGERS setObject:self forKey:_identifier];
        
        [self initWorkingTasksFromCurrentSource];
        
        [self startObserverNetworkState];
    }
    return self;
}

#pragma mark -- 创建Manager指定的线程,并且根据此线程,启动一个与线程对应的Runloop来管理事件源
- (void)downloadTaskRunLoopThreadEntry
{
    @autoreleasepool {
        NSThread * currentThread = [NSThread currentThread];
        currentThread.name = @"DownloadTaskManagerThread";
        NSRunLoop *currentRunloop = [NSRunLoop currentRunLoop];
        [currentRunloop addPort:[NSMachPort port] forMode:NSDefaultRunLoopMode];
        [currentRunloop run];
    }
}


#pragma 从数据库中恢复哪些曾经下载中被中断了的Task
- (void)initWorkingTasksFromCurrentSource {
    NSArray *allRunningTasks = [DownloaderDao recoverWorkingTasksWithThread:_downloadTaskRunLoopThread key:_downloadConfig.identifier];
    if (allRunningTasks.count) {
        
        NSMutableArray *downloadTasks = [NSMutableArray array];
        NSMutableArray *waitingTasks = [NSMutableArray array];
        NSMutableArray *leftTasks = [NSMutableArray array];
        
        NSMutableArray *allTask = [NSMutableArray array];
        
        for (VMDownloadTask *task in allRunningTasks) {
            if ([task isCurrentStateLevel:DownloadTaskLevelDownloading]) {
                [downloadTasks addObject:task];
            }
            
            else if ([task isCurrentStateLevel:DownloadTaskStateWaiting]) {
                [waitingTasks addObject:task];
            }
            
            else {
                [leftTasks addObject:task];
            }
        }
        
        //why?....
        [allTask insertObjects:downloadTasks atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, downloadTasks.count)]];
        [allTask insertObjects:waitingTasks atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, waitingTasks.count)]];
        [allTask insertObjects:leftTasks atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, leftTasks.count)]];
        
        [self startAll:allTask];
    }
}

- (void)startAll:(NSArray *)allTasks {
    for (VMDownloadTask *task in allTasks) {
        [task start];
    }
}

#pragma mark --- StartObserver
- (void)startObserverNetworkState {
    Reachability* reach = [Reachability reachabilityWithHostname:@"www.baidu.com"];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
    [reach startNotifier];
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self forKeyPath:MAX_DOWNLOAD_COUNT options:NSKeyValueObservingOptionNew context:nil];
    [nc addObserver:self forKeyPath:NETWORK_MODE options:NSKeyValueObservingOptionNew context:nil];
}


- (void)reachabilityChanged:(NSNotification *)note
{
    NSLog(@"reachabilityChanged --->>>>>>%zd",[note.object currentReachabilityStatus]);
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
    for (VMDownloadTask *task in [self getTasksInState:DownloadState.self]) {
        [task sendMessageType:MessageTypeEventNetworkConnectionChange];
    }
}

- (void)sendMaxDownloadCountChanged {
    
}



#pragma mark -- 往Manager入队一个DownloadTask
- (VMDownloadTask *)enqueueWithRequest:(VMDownloadRequest *)request {
    VMDownloadTask *downloadTask = [VMDownloadTask downloadTaskWithRunloopThread:self.downloadTaskRunLoopThread downloadRequest:request key:self.downloadConfig.identifier];
    [downloadTask start];
    return downloadTask;
}


#pragma mark -- 获取某个状态下对应的Tasks
- (NSArray *)getTasksInState:(Class)stateClass
{
    NSString *className = NSStringFromClass(stateClass);
    NSString *STATE_KEY = [NSString stringWithFormat:@"%@-%@",className,self.downloadConfig.identifier];
    
    id states = [DownloadState.TASKS objectForKey:STATE_KEY];
    if(states == nil) {
        states = [NSMutableArray array];
        [DownloadState.TASKS setObject:states forKey:STATE_KEY];
    }
    return states;
}

#pragma mark - MD5校验
- (BOOL)verifyMd5WithFilePath:(NSString *)filePath md5Result:(NSString *)md5Result
{
    NSString *fullFilePath = [DocumenDir stringByAppendingPathComponent:filePath];
    NSLog(@"fullFilePath  %@",fullFilePath);
    if([md5Result isEqualToString:[fullFilePath MD5FilePath]]) {
        return YES;
    }
    return NO;
}
@end
