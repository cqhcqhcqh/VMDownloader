//
//  VMDownloadTask.m
//  Pods
//
//  Created by chengqihan on 16/4/8.
//
//

#import "VMDownloadTask.h"
#import "SmHandler.h"
#import "VMDownloaderManager.h"
#import "ConnectionUtils.h"
#import "NSString+MD5.h"
#import "CPLoggerManager.h"
#import "FMDB.h"
#import "DownloaderDao.h"
#import "NSDate+NSString.h"
#import "CPLoggerManager.h"
#import "CPNotificationManager.h"
#import "VMDownloadHttp.h"

NSString* const DownloadStateDesc[] = {
    [DownloadTaskStateInit] = @"DownloadTaskStateInit",
    [DownloadTaskStateOngoing] = @"DownloadTaskStateOngoing",
    [DownloadTaskStateRetry] = @"DownloadTaskStateRetry",
    [DownloadTaskStateWaiting] = @"DownloadTaskStateWaiting",
    [DownloadTaskStateVerifying] = @"DownloadTaskStateVerifying",
    [DownloadTaskStatePaused] = @"DownloadTaskStatePaused",
    [DownloadTaskStateIOError] = @"DownloadTaskStateIOError",
    [DownloadTaskStateSuccess] = @"DownloadTaskStateSuccess",
    [DownloadTaskStateFailure] = @"DownloadTaskStateFailure",
};

@interface VMDownloadTask ()
@property (readwrite, nonatomic, copy) NSString *title;
@property (readwrite, nonatomic, copy) NSString *url;
@property (readwrite, nonatomic, copy) NSString *filePath;
@property (readwrite, nonatomic, copy) NSString *encriptDescription;
@property (readwrite, nonatomic, copy) NSString *mMd5;
@property (readwrite, nonatomic, strong) NSString *mCreate;
@property (readwrite, nonatomic, strong) NSString *mModifyDate;
@property (readwrite, nonatomic, copy) NSString *mimetype;
@property (readwrite, nonatomic, copy) NSString *sha1;
@property (readwrite, nonatomic, copy) NSString *error;
@property (readwrite, nonatomic, assign) UInt64 contentLength;
@property (readwrite, nonatomic, copy) NSString *uuid;
@property (readwrite, nonatomic, assign) UInt64 mProgress;


@property (readwrite, nonatomic, strong) DownloadState *mInit;
@property (readwrite, nonatomic, strong) DownloadState *mStarted;
@property (readwrite, nonatomic, strong) DownloadState *mDownloading;
@property (readwrite, nonatomic, strong) DownloadState *mWaiting;
@property (readwrite, nonatomic, strong) DownloadState *mRetry;
@property (readwrite, nonatomic, strong) DownloadState *mOngoing;

@property (readwrite, nonatomic, strong) DownloadState *mVerifying;

@property (readwrite, nonatomic, strong) DownloadState *mStopped;
@property (readwrite, nonatomic, strong) DownloadState *mPaused;
@property (readwrite, nonatomic, strong) DownloadState *mIOError;

@property (readwrite, nonatomic, strong) DownloadState *mDone;
@property (readwrite, nonatomic, strong) DownloadState *mSuccess;
@property (readwrite, nonatomic, strong) DownloadState *mFailure;

@property (readwrite, nonatomic, weak) VMDownloaderManager *downloaderManager;
@property (readwrite, nonatomic, weak) VMDownloadConfig *downloaderConfig;
@property (readwrite, nonatomic, weak) NSURLSessionDataTask *urlSessionDataTask;

@property (readwrite, nonatomic, assign) BOOL hasDataChanged;
@property (readwrite, nonatomic, assign) BOOL needVerify;
@property (readwrite, nonatomic, assign) NSInteger retryCount;


@property (readwrite, nonatomic, assign) BOOL isOnGoing;


/**
 *  私有的初始化方法
 *
 *  @param thread  Task.handler(Queue).operation isFinished 调用的thread
 *  @param uuid    Task的唯一UUID
 *  @param manager Task对应的Manager
 *
 *  @return Task
 */
- (instancetype)initWithRunloopThread:(NSThread *)thread uuid:(NSString *)uuid downloadManager:(VMDownloaderManager *)manager;

/**
 *  私有的下载方法
 */
- (void)downloadRun;

/**
 *  数据库恢复Task方法,并且主动[task start]
 *
 *  @param thread    Task.handler(Queue).operation isFinished 调用的thread
 *  @param key       _manager.downloadConfig.identifier
 *  @param resultSet 数据库游标
 *
 *  @return Task
 */
- (instancetype)initWithRunloopThread:(NSThread *)thread key:(NSString *)key resultSet:(FMResultSet *)resultSet autoStart:(BOOL)autoStart;
@end

@implementation VMDownloadTask
- (void)dealloc
{
    CPStateMechineLog(@"%@任务 挂了 uuid:%@ dealloc",self.uuid,self.title);
}
+ (void)initialize
{
    if (self == [VMDownloadTask class]) {
        CACHE_TASKS_REF = [NSMapTable  strongToWeakObjectsMapTable];
    }
}

static NSMapTable *CACHE_TASKS_REF;

- (BOOL)needVerify
{
    return self.mMd5.length > 0;
}

+ (instancetype)recoveryDownloadTaskWithRunloopThread:(NSThread *)thread key:(NSString *)key resultSet:(FMResultSet *)resultSet autoStart:(BOOL)autoStart{
    return [[self alloc] initWithRunloopThread:thread key:key resultSet:resultSet autoStart:autoStart];
}


- (instancetype)initWithRunloopThread:(NSThread *)thread key:(NSString *)key resultSet:(FMResultSet *)resultSet autoStart:(BOOL)autoStart
{
    NSAssert(resultSet != NULL, @"resultSet is null");
    
    VMDownloaderManager *manager = [VMDownloaderManager getInstanceWithKey:key];
    NSAssert(manager != NULL, @"DownloadManager is null for key=%@",key);
    
    NSString *uuid = [resultSet stringForColumn:@"_id"];
    
    VMDownloadTask *task = [CACHE_TASKS_REF objectForKey:uuid];
    if (task != nil) {
        return task;
    }
    
    task = [self initWithRunloopThread:thread uuid:uuid downloadManager:manager];
    task.filePath = [resultSet stringForColumn:@"path"];
    task.title = [resultSet stringForColumn:@"title"];
    task.encriptDescription = [resultSet stringForColumn:@"description"];
    task.url = [resultSet stringForColumn:@"url"];
    task.mMd5 = [resultSet stringForColumn:@"md5"];
    task.mState = [resultSet intForColumn:@"state"];
    task.mLastState = task.mState;
    task.sha1 = [resultSet stringForColumn:@"state"];
    task.mimetype = [resultSet stringForColumn:@"mimetype"];
    task.error = [resultSet stringForColumn:@"error"];
    task.contentLength = [resultSet longLongIntForColumn:@"length"];
    task.mProgress = [resultSet longLongIntForColumn:@"progress"];
    task.mCreate = [resultSet stringForColumn:@"_create"];
    task.mModifyDate = [resultSet stringForColumn:@"_modify"];
    task.netWorkMode = [resultSet intForColumn:@"networkmode"];
    
    if (autoStart) {
        [task start];
    }
    return task;
    
}


+ (instancetype)downloadTaskWithRunloopThread:(NSThread *)thread downloadRequest:(VMDownloadRequest *)request key:(NSString *)key
{
    return [[self alloc] initWithRunloopThread:thread downloadRequest:request key:key];
}



- (instancetype)initWithRunloopThread:(NSThread *)thread downloadRequest:(VMDownloadRequest *)request key:(NSString *)key
{
    VMDownloaderManager *manager = [VMDownloaderManager getInstanceWithKey:key];
    NSAssert(manager != NULL, @"DownloadManager is null for key=%@",key);
    
    NSString *uuid = [[NSUUID UUID] UUIDString];
    VMDownloadTask * task = [self initWithRunloopThread:thread uuid:uuid downloadManager:manager];
    task.url = request.url;
    task.mMd5 = request.MD5Value;
    task.encriptDescription = request.encriptDescription;
    task.filePath = request.destinationFilePath;
    task.mState = DownloadTaskStateInit;
    task.mLastState = task.mState;
    task.title = request.title;
    task.netWorkMode = MASK_NETWORK_WIFI;
    task.contentLength = 0;
    task.error = @"";
    task.mimetype = request.mimetype;
    task.mProgress = 0;
    
    return task;
}


- (instancetype)initWithRunloopThread:(NSThread *)thread uuid:(NSString *)uuid downloadManager:(VMDownloaderManager *)manager {
    if (self == [super init]) {
        _uuid = uuid;
        _downloaderManager = manager;
        _downloaderConfig = manager.downloadConfig;
        [self.smHandler setRunloopThread:thread];
        /**
         将Task增加到弱引用缓存 中,优化为了从数据库中恢复时候的耗时.
         **/
        [CACHE_TASKS_REF setObject:self forKey:uuid];
    }
    return self;
}


- (void)setAllowMobileNetWork:(BOOL)allow {
    if (allow) {
        _netWorkMode = _netWorkMode | MASK_NETWORK_MOBILE;
    }else {
        _netWorkMode = _netWorkMode & ~MASK_NETWORK_MOBILE;
    }
    [self saveTask];
    [self sendMessageType:MessageTypeEventNetworkConnectionChange];
}

- (BOOL)allowMobileNetWork {
    return (_netWorkMode & MASK_NETWORK_MOBILE) >0;
}

- (void)setAllowWifiNetWork:(BOOL)allow {
    if (allow) {
        _netWorkMode = _netWorkMode | MASK_NETWORK_WIFI;
    }else {
        _netWorkMode = _netWorkMode & ~MASK_NETWORK_WIFI;
    }
    [self saveTask];
    [self sendMessageType:MessageTypeEventNetworkConnectionChange];
}

- (BOOL)allowWifiNetWork {
    return (_netWorkMode & MASK_NETWORK_WIFI) >0;
}
- (void)start
{
    _mInit = [[Init alloc] initWithDownloadTask:self];
    _mStarted = [[Started alloc] initWithDownloadTask:self];
    _mDownloading = [[Downloading alloc] initWithDownloadTask:self];
    _mOngoing = [[Ongoing alloc] initWithDownloadTask:self];
    _mRetry = [[Retry alloc] initWithDownloadTask:self];
    _mWaiting = [[Waiting alloc] initWithDownloadTask:self];
    
    _mVerifying = [[Verifying alloc] initWithDownloadTask:self];
    
    _mStopped = [[Stopped alloc] initWithDownloadTask:self];
    _mPaused = [[Paused alloc] initWithDownloadTask:self];
    _mIOError = [[IOError alloc] initWithDownloadTask:self];
    
    _mDone = [[Done alloc] initWithDownloadTask:self];
    _mSuccess = [[Success alloc] initWithDownloadTask:self];
    _mFailure = [[Failure alloc] initWithDownloadTask:self];
    
    [self addState:_mInit parentState:nil];
    [self addState:_mStarted parentState:_mInit];
    
    [self addState:_mWaiting parentState:_mStarted];
    
    [self addState:_mDownloading parentState:_mStarted];
    [self addState:_mRetry parentState:_mDownloading];
    [self addState:_mOngoing parentState:_mDownloading];
    
    [self addState:_mVerifying parentState:_mInit];
    
    [self addState:_mStopped parentState:_mInit];
    [self addState:_mPaused parentState:_mStopped];
    [self addState:_mIOError parentState:_mStopped];
    
    [self addState:_mDone parentState:_mInit];
    [self addState:_mSuccess parentState:_mDone];
    [self addState:_mFailure parentState:_mDone];
    
    //    for (NSString *key in self.smHandler.mapStateInfo.allKeys) {
    //        StateInfo *stateInfo = self.smHandler.mapStateInfo[key];
    //        //        NSLog(@"key %@ state:%@ parentState:%@",key,stateInfo.state,stateInfo.parentStateInfo.state);
    //    }
    //如果下载任务已经开始<DownloadTaskStateWaiting|DownloadTaskStateRetry|DownloadTaskStateOngoing>
    if ([self isCurrentStateLevel:DownloadTaskLevelStarted|DownloadTaskStateInit]) {
        [self.smHandler setInitialState:_mStarted];
    }else {
        [self.smHandler setInitialState:[self getHSMState]];
    }
    [super start];
}

- (State *)getHSMState {
    switch (self.mState) {
        case DownloadTaskStateRetry:
            return _mRetry;
            
        case DownloadTaskStateOngoing:
            return _mOngoing;
            
        case DownloadTaskStateWaiting:
            return _mWaiting;
            
        case DownloadTaskStateIOError:
            return _mIOError;
            
        case DownloadTaskStatePaused:
            return _mPaused;
            
        case DownloadTaskStateVerifying:
            return _mVerifying;
            
        case DownloadTaskStateSuccess:
            return _mSuccess;
            
        case DownloadTaskStateFailure:
            return _mFailure;
            
        default:
            return _mInit;
    }
}

/**
 *  状态机退出的时候调用
 *  Init状态Exit的时候会主动调用
 */
- (void)delete
{
    //根据uuid从数据库中删除对应的Task
    [DownloaderDao deleteDownloadTaskWithUUID:self.uuid];
    //发送Notification
    //    mEventBus.post
}

/**
 *  对外暴露的接口,操作DownloadTask
 */
- (void)resumeTask {
    [self sendMessageType:MessageTypeActionStart];
}
- (void)pauseTask {
    [self sendMessageType:MessageTypeActionPaused];
}

- (void)deleteTaskIncludeFile:(BOOL)includeFile{
    CPMessage *message = [CPMessage messageWithType:MessageTypeActionDelete obj:@(includeFile)];
    [self sendMessage:message];
}

- (void)saveTask {
    
    @synchronized (self) {
        if (self.mState != self.mLastState) {
            [CPNotificationManager postNotificationWithName:kDownloadStateChange type:0 message:nil obj:self userInfo:@{kDownloadStateOldValue:@(self.mLastState),kDownloadStateNewValue:@(self.mState)}];
            self.mLastState = self.mState;
        }
        _hasDataChanged = YES;
    }
}

- (void)smHandlerProcessFinalMessage:(CPMessage *)msg
{
    if (_hasDataChanged) {
        if (self.mCreate == nil) {
            //create
            self.mCreate = [NSDate dateWithFormatterString:nil];
            self.mModifyDate = [NSDate dateWithFormatterString:nil];
            
            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            [dict setObject:self.uuid forKey:@"_id"];
            [dict setObject:self.url forKey:@"url"];
            [dict setObject:self.filePath forKey:@"path"];
            [dict setObject:self.title forKey:@"title"];
            [dict setObject:self.encriptDescription forKey:@"description"];
            [dict setValue:self.mimetype?:@"" forKey:@"mimetype"];
            [dict setValue:self.error?:@"" forKey:@"error"];
            [dict setObject:@(self.mState) forKey:@"state"];
            [dict setObject:self.mMd5 forKey:@"md5"];
            [dict setObject:self.sha1?:@"" forKey:@"sha1"];
            [dict setObject:[NSNumber numberWithLongLong:self.contentLength] forKey:@"length"];
            [dict setObject:@(self.netWorkMode) forKey:@"networkmode"];
            [dict setObject:[NSNumber numberWithLongLong:self.mProgress] forKey:@"progress"];
            [dict setObject:self.mCreate forKey:@"_create"];
            [dict setObject:self.mModifyDate forKey:@"_modify"];
            [DownloaderDao createDownloadTaskWithDictionary:dict];
            
            [CPNotificationManager postNotificationWithName:kDownloadTaskInsert type:0 message:nil obj:self userInfo:nil];
            
        }else {
            //save
            self.mModifyDate = [NSDate dateWithFormatterString:nil];
            
            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            
            [dict setObject:@(self.mState) forKey:@"state"];
            [dict setObject:@(self.netWorkMode) forKey:@"networkmode"];
            [dict setObject:[NSNumber numberWithLongLong:self.contentLength] forKey:@"length"];
            [dict setObject:[NSNumber numberWithLongLong:self.mProgress] forKey:@"progress"];
            [dict setObject:self.mModifyDate forKey:@"_modify"];
            //            [dict setValue:self.mimetype?:@"" forKey:@"mimetype"];
            [dict setValue:self.error?:@"" forKey:@"error"];
            [DownloaderDao updateDownloadTaskWithUUID:self.uuid dictionary:dict];
        }
        
        _hasDataChanged = NO;
    }
}
- (BOOL)isCurrentStateLevel:(DownloadTaskLevel)level
{
    return (self.mState & level) >0;
}

- (NSString *)fileDir
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *createDir = nil;
    NSString *DirPath = [DocumenDir stringByAppendingPathComponent:self.downloaderConfig.identifier];
    if (![fileManager fileExistsAtPath:DirPath]) {
        BOOL createSuccess = [fileManager createDirectoryAtPath:DirPath withIntermediateDirectories:NO attributes:nil error:&createDir];
        NSAssert(createSuccess, @"文件夹创建失败 error:%@",DirPath,[createDir localizedDescription]);
    }
    return DirPath;
}

- (void)downloadRun
{
    NSString *filePath = [[self fileDir] stringByAppendingPathComponent:self.filePath];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:self.url]];
    if (self.contentLength == 0) {
        CPStateMechineLog(@"获取请求头 %s %zd",__PRETTY_FUNCTION__, __LINE__);
        self.urlSessionDataTask = [VMDownloadHttp HEADRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            self.error = error.localizedDescription;
            if (error) {
                CPStateMechineLog(@"获取请求头失败 %@ %s %zd",error.localizedDescription,__PRETTY_FUNCTION__, __LINE__);
                if (![error.localizedDescription isEqualToString:@"cancelled"]) {
                    [self sendMessage:[CPMessage messageWithType:MessageTypeEventDownloadException obj:error]];
                }
            }else {
                CPStateMechineLog(@"获取请求头成功 %s %zd",__PRETTY_FUNCTION__, __LINE__);
                self.contentLength = response.expectedContentLength;
                if (![[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
                    [[NSFileManager defaultManager] createFileAtPath:filePath contents:nil attributes:nil];
                }
                [self processDownloadWithFilePath:filePath];
            }
        }];
    }else if (self.mProgress == self.contentLength) {
        [self sendMessageType:MessageTypeEventTaskDone];
    }else {
        [self processDownloadWithFilePath:filePath];
    }
}

- (void)processDownloadWithFilePath:(NSString *)filePath{
    
    @synchronized (self) {
        if (!_isOnGoing) {
            CPStateMechineLog(@"urlSessionDataTask has cancel %s %zd",__PRETTY_FUNCTION__, __LINE__);
            return;
        }
    }
    NSFileHandle *writeHandle = nil;
    @try {
        writeHandle = [NSFileHandle fileHandleForWritingAtPath:filePath];
    } @catch (NSException *exception) {
        CPStateMechineLog(@"writeHandle创建失败 %@ %s %zd",exception.name,__PRETTY_FUNCTION__, __LINE__);
        self.error = exception.name;
    } @finally {
        
    }
    
    NSAssert(writeHandle, @"writeHandle is nil");
    if (![self.downloaderConfig isNetworkAllowedFor:self]) {
        CPStateMechineLog(@"网络不允许下载 %s %zd",__PRETTY_FUNCTION__, __LINE__);
        self.error = @"网络不允许下载";
        [self sendMessage:[CPMessage messageWithType:MessageTypeEventDownloadException]];
        return;
    }
    CPStateMechineLog(@"获取下载内容 %s %zd",__PRETTY_FUNCTION__, __LINE__);
    __block UInt64 lastDownloadProgress = self.mProgress;
    __block UInt64 lastTimeInterval = [[NSDate date] timeIntervalSince1970]*1000;
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:self.url]];
    VMDownloadHttp *downloadHttp = [[VMDownloadHttp alloc] init];
    
    self.urlSessionDataTask = [downloadHttp downloadTaskWithRequest:request progress:^(NSData *data, int64_t totalBytesWritten) {
        if (!_isOnGoing) {
            return;
        }
        
        NSAssert(writeHandle, @"writeHandle is nil");
        self.mProgress = totalBytesWritten;
        [writeHandle seekToEndOfFile];
        // 从当前移动的位置(文件尾部)开始写入数据
        
#warning 内存警告没有error输出.....
        @try {
            [writeHandle writeData:data];
        } @catch (NSException *exception) {
            CPStateMechineLog(@"文件写入失败 %@ %s %zd",exception.name,__PRETTY_FUNCTION__, __LINE__);
            self.error = exception.name;
        } @finally {
            
        }
        
        if (self.retryCount != 0) {
            self.retryCount = 0;
        }
        if (totalBytesWritten < self.contentLength) {
            UInt64 currentTimeInterval = [[NSDate date] timeIntervalSince1970]*1000;
            
            UInt64 deltaTimeInterval = currentTimeInterval - lastTimeInterval;
            
            UInt64 deltaProgress = totalBytesWritten - lastDownloadProgress;
            
            if (deltaTimeInterval >= 1000) {
                
                self.mSpeed = (deltaProgress/deltaTimeInterval) * 1000.0f;//# bype/s
                [self sendMessageDelayed:[CPMessage messageWithType:MessageTypeEventProgress] delay:1.0];
                lastDownloadProgress = totalBytesWritten;
                lastTimeInterval = currentTimeInterval;
            }
        }else {
#warning ....sendMessage:[CPMessage messageWithType:MessageTypeEventProgress obj:self].....delloc Failure... Why?
            //            [self sendMessage:[CPMessage messageWithType:MessageTypeEventProgress obj:self]];
            [self sendMessage:[CPMessage messageWithType:MessageTypeEventProgress]];
        }
        
    } fileURL:^NSString *(NSURLResponse *response) {
        return filePath;
    }  completionHandler:^(NSURLResponse *response, NSError * _Nullable error) {
        [writeHandle closeFile];
        if (error) {
            CPStateMechineLog(@"文件下载失败:%@ %s %zd",error.localizedDescription,__PRETTY_FUNCTION__, __LINE__);
            self.error = error.localizedDescription;
            if (![error.localizedDescription isEqualToString:@"cancelled"]) {
                [self sendMessage:[CPMessage messageWithType:MessageTypeEventDownloadException obj:error]];
            }
        }else {
            [writeHandle closeFile];
            [self sendMessageType:MessageTypeEventTaskDone];
        }
    }];
}
@end



@implementation Init

- (instancetype)initWithDownloadTask:(VMDownloadTask *)downloadTask
{
    /**
     重写父类的构造方法
     Init状态不需要缓存
     */
    return [super initWithDownloadTask:downloadTask isNotCacheTask:YES];
}

- (void)enter
{
}

- (void)exit
{
    [self.downloadTask delete];
}

- (BOOL)processMessage:(CPMessage *)message
{
    //处理DELETE_TASK Event
    switch (message.type) {
        case MessageTypeActionDelete:
            //删除任务和文件 OR Just 任务
            if([message.obj boolValue]){
                NSError *deleteError = nil;
                BOOL deleteSuccess = [[NSFileManager defaultManager] removeItemAtPath:[[self.downloadTask fileDir] stringByAppendingPathComponent: self.downloadTask.filePath] error:&deleteError];
                if (deleteError) {
                    CPStateMechineLog(@"删除文件:%@ error%@",deleteSuccess?@"成功":@"失败",[deleteError userInfo]);
                }
            }
            [self.downloadTask quitNow];
            return YES;
        default:
            return NO;
    }
    
}
@end



//需要缓存
@implementation Started

- (void)enter
{
    [super enter];
    [self.downloadTask transitionToState:self.downloadTask.mWaiting];
}
- (void)exit
{
    [super exit];
}

- (BOOL)processMessage:(CPMessage *)message
{
    switch (message.type) {
        case MessageTypeActionPaused:
            [self.downloadTask transitionToState:self.downloadTask.mPaused];
            return YES;
            
        default:
            return NO;
    }
}
@end



@implementation Downloading

- (void)enter
{
    [super enter];
    NSLog(@"====>%p  %@",self.tasks,self.tasks);
    CPStateMechineLog(@"进入到Downloading的task的数量%zd",self.tasks.count);
}

- (void)exit
{
    [super exit];
    VMDownloadTask *firstWaitingTask = [self.downloadTask.mWaiting.tasks firstObject];
    /**
     *  当某个Downloading状态下的Task 退出Downloading状态的话,就立马向Waiting状态下的第一个Task发MessageTypeEventDownloadingAvailable消息
     */
    if (firstWaitingTask) {
        [firstWaitingTask sendMessageType:MessageTypeEventDownloadingAvailable];
    }
}

- (BOOL)processMessage:(CPMessage *)message
{
    switch (message.type) {
        case MessageTypeEventTaskDone:
#warning 为什么要在这里存储一下状态呢?==>Downloading的过程中收到了下载完成的Event。。。
            CPStateMechineLog(@"下载完成");
            [self.downloadTask saveTask];
            if([self.downloadTask needVerify]){
                [self.downloadTask transitionToState:self.downloadTask.mVerifying];
            }else {
                [self.downloadTask transitionToState:self.downloadTask.mSuccess];
            }
            return YES;
            
        default:
            return NO;
    }
}
@end



@implementation Ongoing
/**
 *  需要缓存Ongoing状态
 */
- (void)enter
{
    [super enter];
    self.downloadTask.mState = DownloadTaskStateOngoing;
    [self.downloadTask saveTask];
    
    @synchronized (self) {
        self.downloadTask.isOnGoing = YES;
        [self.downloadTask downloadRun];
    }
}

- (void)exit
{
    [super exit];
    [self.downloadTask removeMessageWithType:MessageTypeEventProgress];
    [self.downloadTask removeMessageWithType:MessageTypeEventDownloadException];
    
    //在mStarted状态下接受到MessageTypeActionPaused的时候
    //将状态切换到mPaused,此时OnGoing状态将会从状态栈中Exit
    //所以在这个时候处理Paused
    @synchronized (self) {
        self.downloadTask.isOnGoing = NO;
        //        NSAssert(self.downloadTask.urlSessionDataTask, @"urlSessionDataTask is nil");
        [self.downloadTask.urlSessionDataTask cancel];
    }
}

- (BOOL)processMessage:(CPMessage *)message
{
    switch (message.type) {
        case MessageTypeEventNetworkConnectionChange:
            if ([self.downloadTask.downloaderConfig isNetworkAllowedFor:self.downloadTask]) {
                return YES;
            }
        case MessageTypeEventDownloadException:
            [self.downloadTask transitionToState:self.downloadTask.mRetry];
            [self.downloadTask removeMessageWithType:MessageTypeEventProgress];
        case MessageTypeEventProgress:
            //notify 下载进度
            [CPNotificationManager postNotificationWithName:kMessageTypeEventProgress type:0 message:nil obj:self.downloadTask];
            return YES;
            
        default:
            return NO;
    }
}
@end



@implementation Retry
//缓存Retry状态

- (void)enter
{
    [super enter];
    self.downloadTask.mState = DownloadTaskStateRetry;
    
    if ([self.downloadTask.downloaderConfig isNetworkAllowedFor:self.downloadTask]) {
        self.downloadTask.retryCount++;
        CPStateMechineLog(@"进入到Retry状态,重试%d次数",self.downloadTask.retryCount);
        CPMessage *msg = [CPMessage messageWithType:MessageTypeEventRetryRequest];
        [self.downloadTask sendMessageDelayed:msg delay:3.0];
        
    }else {
        if (![ConnectionUtils isNetworkConnected]) {
            CPStateMechineLog(@"没有网络");
            self.downloadTask.error = @"没有网络";
        }else {
            CPStateMechineLog(@"网络不允许");
            self.downloadTask.error = @"网络不允许";
        }
        [CPNotificationManager postNotificationWithName:kDownloadNetworkNotPermission type:0 message:self.downloadTask.error obj:self.downloadTask userInfo:nil];
    }
    [self.downloadTask saveTask];
}

- (void)exit
{
    [super exit];
    [self.downloadTask removeMessageWithType:MessageTypeEventRetryRequest];
}

- (BOOL)processMessage:(CPMessage *)message
{
    switch (message.type) {
        case MessageTypeActionStart:
            if (![self.downloadTask.downloaderConfig isNetworkAllowedFor:self.downloadTask]) {
                //[CPNotificationManager postNotificationWithName:kDownloadNetworkNotPermission type:message.type message:self.downloadTask.error obj:self.downloadTask userInfo:nil];
//                [self.downloadTask transitionToState:self.downloadTask.mPaused];
//                return YES;
                if (![ConnectionUtils isNetworkConnected]) {
                    CPStateMechineLog(@"没有网络");
                    self.downloadTask.error = @"没有网络";
                    [self.downloadTask saveTask];
                }else {
                    
                    CPStateMechineLog(@"网络不允许");
                    self.downloadTask.error = @"网络不允许";
                    [self.downloadTask saveTask];
                }
                
                [CPNotificationManager postNotificationWithName:kDownloadNetworkNotPermission type:message.type message:self.downloadTask.error obj:self.downloadTask userInfo:nil];
                return YES;
            }
            /*
             * 在Retry的状态下,如果网络状况发生了变化
             * 如果有网络的话,直接切换到下载状态
             * 如果没有网络的话,还是在当前状态下等着
             
             * 如果用户在等待的过程中,RetryRequest的话,还是需要判断网络状态
             * Retry的次数,只有三次机会。每次进入到Retry的时候,会隔三秒时间去重新发一个RetryRequest。
             *
             */
        case MessageTypeEventNetworkConnectionChange:
        case MessageTypeEventRetryRequest:
            if ([self.downloadTask retryCount] <= self.downloadTask.downloaderConfig.maxDownloadCount) {
                if ([self.downloadTask.downloaderConfig isNetworkAllowedFor:self.downloadTask]) {
                    //进入到Retry时
                    if([[NSFileManager defaultManager] fileExistsAtPath:[[self.downloadTask fileDir] stringByAppendingPathComponent:self.downloadTask.filePath]]){
                        [self.downloadTask transitionToState:self.downloadTask.mOngoing];
                    }else {
                        self.downloadTask.error = @"文件路径不存在";
                        [self.downloadTask saveTask];// 进行save的原因是因为要保存mError
                        [self.downloadTask transitionToState:self.downloadTask.mIOError];
                    }
                }
            } else {
                CPStateMechineLog(@"多次重试都失败");
                self.downloadTask.error = @"多次重试都失败";
                [self.downloadTask saveTask];
                
                [self.downloadTask transitionToState:self.downloadTask.mIOError];
            }
            return YES;
            
        default:
            return NO;
    }
    
}
@end

@implementation Waiting
/**
 *  当Task的状态切换成Waiting,判断downloading状态下的Task的数量是否小于配置中可以同时下载的数量,如果小于的话,直接将Task的状态切成Ongoing状态
 *  如果没有网络的话,将Task的状态切换成retry
 */
- (void)enter
{
    [super enter];
    self.downloadTask.mState = DownloadTaskStateWaiting;
    self.downloadTask.error = @"";
    [self.downloadTask saveTask];
    
    NSArray *tasks = self.downloadTask.mDownloading.tasks;
    if([tasks count] < self.downloadTask.downloaderConfig.maxDownloadCount) {
        
        if([self.tasks firstObject] == self.downloadTask) {
            if (([ConnectionUtils isNetworkConnected] && [self.downloadTask.downloaderConfig isNetworkAllowedFor:self.downloadTask]) || (self.downloadTask.contentLength == 0)) {
                // 网络允许或者还没有获取到文件大小时, 直接进入下载过程
                [self.downloadTask transitionToState:self.downloadTask.mOngoing];
            }else {
                
                // 否则进入重试阶段(网络不允许&&文件大小获取到了)
                [self.downloadTask transitionToState:self.downloadTask.mRetry];
            }
        }
    }else {
        CPStateMechineLog(@"下载数量>=3");
    }
}

- (BOOL)processMessage:(CPMessage *)message
{
    switch (message.type) {
        case MessageTypeEventDownloadingAvailable:
        {
            VMDownloadTask *firstWaitingTask = [self.tasks firstObject];
            if (firstWaitingTask == self.downloadTask) {
                if ([self.downloadTask.mDownloading tasks].count < self.downloadTask.downloaderConfig.maxDownloadCount) {
                    if (([ConnectionUtils isNetworkConnected] && [self.downloadTask.downloaderConfig isNetworkAllowedFor:firstWaitingTask]) || (self.downloadTask.contentLength == 0)) {
                        // 网络允许或者还没有获取到文件大小时, 直接进入下载过程
                        [self.downloadTask transitionToState:self.downloadTask.mOngoing];
                    }else{
                        // 否则进入重试阶段(网络不允许&&文件大小获取到了)
                        [self.downloadTask transitionToState:self.downloadTask.mRetry];
                    }
                }
            }else if(firstWaitingTask != nil){
                [firstWaitingTask sendMessageType:MessageTypeEventDownloadingAvailable];
            }
        }
            return YES;
            
        default:
            return NO;
    }
    
}
@end




//需要缓存
@implementation Verifying

- (void)enter
{
    [super enter];
    //有MD5的话，就进行MD5校验
    self.downloadTask.mState = DownloadTaskStateVerifying;
    [self.downloadTask saveTask];
    
    if([self.downloadTask needVerify]) {
        if([self.downloadTask.downloaderManager verifyMd5WithFilePath:[[self.downloadTask fileDir] stringByAppendingPathComponent:self.downloadTask.filePath] md5Result:self.downloadTask.mMd5]) {
            [self sendMessageType:MessageTypeEventVerifyPass];
        }else{
            [self sendMessageType:MessageTypeEventVerifyFail];
        }
    }else {
        [self.downloadTask transitionToState:self.downloadTask.mSuccess];
    }
}
- (BOOL)processMessage:(CPMessage *)message
{
    switch (message.type) {
        case MessageTypeEventVerifyPass:
            [self.downloadTask transitionToState:self.downloadTask.mSuccess];
            return YES;
        case MessageTypeEventVerifyFail:
            [self.downloadTask transitionToState:self.downloadTask.mFailure];
            return YES;
        default:
            return NO;
    }
}
@end


@implementation Stopped
- (instancetype)initWithDownloadTask:(VMDownloadTask *)downloadTask
{
    return [super initWithDownloadTask:downloadTask isNotCacheTask:YES];
}
- (BOOL)processMessage:(CPMessage *)message
{
    switch (message.type) {
        case MessageTypeActionStart:
            [self.downloadTask transitionToState:self.downloadTask.mStarted];
            return YES;
        default:
            return NO;
    }
}
@end



@implementation Paused
- (void)enter
{
    self.downloadTask.mState = DownloadTaskStatePaused;
    [self.downloadTask saveTask];
}
- (instancetype)initWithDownloadTask:(VMDownloadTask *)downloadTask
{
    return [super initWithDownloadTask:downloadTask isNotCacheTask:YES];
}

@end



@implementation IOError
- (void)enter
{
    self.downloadTask.mState = DownloadTaskStateIOError;
    //如果retry三次还是失败的话,就进入到IOErrorState,然后给retryCount归0
    self.downloadTask.retryCount = 0;
    [self.downloadTask saveTask];
}

- (instancetype)initWithDownloadTask:(VMDownloadTask *)downloadTask
{
    return [super initWithDownloadTask:downloadTask isNotCacheTask:YES];
}
@end



@implementation Done
- (instancetype)initWithDownloadTask:(VMDownloadTask *)downloadTask
{
    return [super initWithDownloadTask:downloadTask isNotCacheTask:YES];
}

@end


//无需缓存
@implementation Success
- (instancetype)initWithDownloadTask:(VMDownloadTask *)downloadTask
{
    return [super initWithDownloadTask:downloadTask isNotCacheTask:YES];
}
- (void)enter
{
    self.downloadTask.mState = DownloadTaskStateSuccess;
    [self.downloadTask saveTask];
}
@end


//无需缓存
@implementation Failure
- (instancetype)initWithDownloadTask:(VMDownloadTask *)downloadTask
{
    return [super initWithDownloadTask:downloadTask isNotCacheTask:YES];
}

- (void)enter
{
    self.downloadTask.mState = DownloadTaskStateFailure;
    [self.downloadTask saveTask];
}
@end



@interface DownloadState ()
@property (readwrite, nonatomic, strong) NSMutableArray *tasks;
@end
@implementation DownloadState

- (void)enter
{
    [super enter];
    if(_isCachedTask) {
        //        NSAssert(self.downloadTask != nil, @"downloadTask is a nil");
        if (self.downloadTask) {
            [_tasks addObject:self.downloadTask];
        }
    }
}
- (void)exit
{
    [super exit];
    if (_isCachedTask) {
        //        NSAssert(self.downloadTask != nil, @"downloadTask is a nil");
        if (self.downloadTask) {
            [_tasks removeObject:self.downloadTask];
        }
    }
}

/**
 *  存储所有TaskName作为key,对应的Tasks
 */
static NSMutableDictionary *TASKS;
+ (void)initialize
{
    if (self == [DownloadState class]) {
        TASKS = [NSMutableDictionary dictionary];
    }
}

+ (NSMutableDictionary *)TASKS {
    return TASKS;
}


- (instancetype)initWithDownloadTask:(VMDownloadTask *)downloadTask {
    return [self initWithDownloadTask:downloadTask isNotCacheTask:NO];
}
+ (instancetype)downloadStateWithDownloadTask:(VMDownloadTask *)downloadTask {
    return [[self alloc] initWithDownloadTask:downloadTask];
}
/**
 *  初始化方法
 *
 *  @param downloadTask   下载任务,状态机
 *  @param isNotCacheTask 不需要缓存TASK
 *
 *  @return self
 */
- (instancetype)initWithDownloadTask:(VMDownloadTask *)downloadTask isNotCacheTask:(BOOL)isNotCacheTask {
    if (self == [super initWithStateMachine:downloadTask]) {
        _isCachedTask = !isNotCacheTask;
        
        //需要缓存的downloadTask
        if (!isNotCacheTask) {
            _tasks = [[self.downloadTask downloaderManager] getTasksInState:[self class]];
        }
    }
    return self;
}


+ (instancetype)downloadStateWithDownloadTask:(VMDownloadTask *)downloadTask isNotCacheTask:(BOOL)isNotCacheTask {
    return [[self alloc] initWithDownloadTask:downloadTask isNotCacheTask:isNotCacheTask];
}

//- (void)processDownload
- (VMDownloadTask *)downloadTask
{
    return (VMDownloadTask *)self.stateMachine;
}
@end

@implementation VMDownloadRequest

@end