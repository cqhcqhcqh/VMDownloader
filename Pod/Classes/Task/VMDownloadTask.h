//
//  VMDownloadTask.h
//  Pods
//
//  Created by chengqihan on 16/4/8.
//
//

#import "StateMachine.h"
#import "State.h"
#import "VMDownloadConfig.h"
@class FMResultSet;

#define Max_Retry_Times 3

typedef NS_OPTIONS(NSUInteger, DownloadTaskState) {
    DownloadTaskStateInit = 1 << 0,
    DownloadTaskStateOngoing = 1 << 1,
    DownloadTaskStateRetry = 1 << 2,
    DownloadTaskStateWaiting = 1 << 3,
    DownloadTaskStateVerifying = 1 << 4,
    DownloadTaskStatePaused = 1 << 5,
    DownloadTaskStateIOError = 1 << 6,
    DownloadTaskStateSuccess = 1 << 7,
    DownloadTaskStateFailure = 1 << 8,
};

/**
 *  打印DownloadTaskState这个枚举对应的String
 *  定义了一个C数组
 */
FOUNDATION_EXTERN NSString* const DownloadStateDesc[];

typedef NS_ENUM(NSUInteger, DownloadTaskLevel) {
    //下载任务 正在进行的/曾经进行但是进入到Retry的
    DownloadTaskLevelDownloading = DownloadTaskStateRetry | DownloadTaskStateOngoing,

    //下载任务已经开始的
    DownloadTaskLevelStarted = DownloadTaskLevelDownloading | DownloadTaskStateWaiting,
    
    //下载任务暂停的/IO失败的
    DownloadTaskLevelStopped = DownloadTaskStatePaused | DownloadTaskStateIOError,
    
    //下载任务结束
    DownloadTaskLevelDone = DownloadTaskStateSuccess | DownloadTaskStateFailure,
};

@interface VMDownloadRequest : NSObject
/**
 *  文件下载的URL
 */
@property (readwrite, nonatomic, copy) NSString *url;

/**
 *  文件的目的文件路径
 */
@property (readwrite, nonatomic, copy) NSString *destinationFilePath;
/**
 *  MD5值
 */
@property (readwrite, nonatomic, copy) NSString *MD5Value;

/**
 *  MD5类型 还是Sha1类型...
 */
@property (readwrite, nonatomic, copy) NSString *encriptDescription;
/**
 *  主题
 */
@property (readwrite, nonatomic, copy) NSString *title;

@property (readwrite, nonatomic, copy) NSString *mimetype;
@end


@class VMDownloaderManager;
@interface DownloadState : State
@property (readwrite, nonatomic, assign) BOOL isCachedTask;
/**
 *  state对应的Task
 *  注意这里是弱引用,类似避免循环引用
 */
@property (readonly, nonatomic, weak) VMDownloadTask *downloadTask;

/**
 *  默认构造方法
 *
 *  @param downloadTask State对应的Task
 *
 *  @return State实例
 */
- (instancetype)initWithDownloadTask:(VMDownloadTask *)downloadTask;
+ (instancetype)downloadStateWithDownloadTask:(VMDownloadTask *)downloadTask;

/**
 *  是否进行缓存的默认方法
 *
 *  @param downloadTask   State对应的Task
 *  @param isNotCacheTask 不需要缓存的标识
 *  不需要缓存的State默认都重写这个方法,isNotCacheTask传入YES
 *  @return State实例
 */
- (instancetype)initWithDownloadTask:(VMDownloadTask *)downloadTask isNotCacheTask:(BOOL)isNotCacheTask;
+ (instancetype)downloadStateWithDownloadTask:(VMDownloadTask *)downloadTask isNotCacheTask:(BOOL)isNotCacheTask;
/**
 *  每个State对应的Tasks
 */
@property (readonly, nonatomic, strong) NSMutableArray *tasks;

/**
 *  key-value(存储stateNameKey:[DownloadState])
 */
+ (NSMutableDictionary *)TASKS;
@end

@class VMDownloadRequest;

@interface VMDownloadTask : StateMachine
//@property (readwrite, nonatomic, strong) NSProgress *downloadProgress;
#pragma mark - 需要往数据库中存入的属性
@property (readonly, nonatomic, copy) NSString *title;
@property (readonly, nonatomic, copy) NSString *url;
@property (readonly, nonatomic, copy) NSString *filePath;
@property (readonly, nonatomic, copy) NSString *mMd5;
@property (readonly, nonatomic, strong) NSString *mCreate;
@property (readonly, nonatomic, strong) NSString *mModifyDate;
@property (readonly, nonatomic, copy) NSString *mimetype;
@property (readonly, nonatomic, copy) NSString *sha1;
@property (readonly, nonatomic, copy) NSString *error;
@property (readonly, nonatomic, copy) NSString *uuid;
@property (readonly, nonatomic, assign) UInt64 mProgress;
@property (readonly, nonatomic, assign) UInt64 contentLength;

@property (readwrite, nonatomic, assign) MASK_NETWORK netWorkMode;
@property (readwrite, nonatomic, assign) DownloadTaskState mState;
#pragma mark -
@property (readwrite, nonatomic, assign) CGFloat mSpeed;

#pragma mark - 内部状态
@property (readwrite, nonatomic, assign) DownloadTaskState mLastState;

@property (readonly, nonatomic, assign) BOOL needVerify;
#pragma mark - 任务中的状态
@property (readonly, nonatomic, strong) DownloadState *mInit;
@property (readonly, nonatomic, strong) DownloadState *mStarted;
@property (readonly, nonatomic, strong) DownloadState *mDownloading;
@property (readonly, nonatomic, strong) DownloadState *mWaiting;
@property (readonly, nonatomic, strong) DownloadState *mRetry;
@property (readonly, nonatomic, strong) DownloadState *mOngoing;
@property (readonly, nonatomic, strong) DownloadState *mVerifying;
@property (readonly, nonatomic, strong) DownloadState *mStopped;
@property (readonly, nonatomic, strong) DownloadState *mPaused;
@property (readonly, nonatomic, strong) DownloadState *mIOError;
@property (readonly, nonatomic, strong) DownloadState *mDone;
@property (readonly, nonatomic, strong) DownloadState *mSuccess;
@property (readonly, nonatomic, strong) DownloadState *mFailure;

/**
 *  Task的基本网络配置
 */
@property (readwrite, nonatomic, assign) BOOL allowMobileNetWork;
@property (readwrite, nonatomic, assign) BOOL allowWifiNetWork;

/**
 *  Task对应的DownloaderManager
 *  注意是弱引用
 */
@property (readonly, nonatomic, weak) VMDownloaderManager *downloaderManager;

/**
 *  Task对应的DownloaderConfig
 *  注意是弱引用
 */
@property (readonly, nonatomic, weak) VMDownloadConfig *downloaderConfig;

/**
 *  Manager enqueue时候 创建Task的事例方法
 *
 *  @param thread  Task.handler(Queue).operation isFinished 调用的thread
 *  @param request 下载请求
 *  @param key     根据key取得对应的Manager,然后给Task的manager 赋值 task归属某个Manager
 *
 *  @return Task    
 */
+ (instancetype)downloadTaskWithRunloopThread:(NSThread *)thread downloadRequest:(VMDownloadRequest *)request key:(NSString *)key;
- (instancetype)initWithRunloopThread:(NSThread *)thread downloadRequest:(VMDownloadRequest *)request key:(NSString *)key;

/**
 *  从数据库中恢复指定的Task
 *
 *  @param thread    Task.handler(Queue).operation isFinished 调用的thread
 *  @param key       数据库configuration的key
 *  @param resultSet 游标
 *  @param autoStart 是否自动启动
 *  @return Task
 */
+ (instancetype)recoveryDownloadTaskWithRunloopThread:(NSThread *)thread key:(NSString *)key resultSet:(FMResultSet *)resultSet autoStart:(BOOL)autoStart;

#pragma mark - 对外暴露的接口,操作DownloadTask
/**
 * 恢复任务
 */
- (void)resumeTask;
/**
 *  暂停任务
 */
- (void)pauseTask;
/**
 *  删除任务
 */
- (void)deleteTaskIncludeFile:(BOOL)includeFile;

/**
 *  开始任务
 */
- (void)start;
/**
 *  存储任务实例
 */
- (void)saveTask;
/**
 *  判断当前任务对应的状态层级
 *  这个有不懂的可以讨论BITMASK
 *
 *  @param level 状态层级
 *
 *  @return 是否为此层级
 */
- (BOOL)isCurrentStateLevel:(DownloadTaskLevel)level;

/**
 *  文件所在文件夹
 *
 *  @return 文件夹路径
 */
- (NSString *)fileDir;
@end

@interface Init : DownloadState
@end
@interface Started : DownloadState
@end
@interface Waiting : DownloadState
@end
@interface Downloading : DownloadState
//@property (readwrite, nonatomic, assign) NSInteger tryCount;
@end
@interface Ongoing : DownloadState
@end
@interface Retry : DownloadState
@end
@interface Verifying : DownloadState
@end
@interface Stopped : DownloadState
@end
@interface Paused : DownloadState
@end
@interface IOError : DownloadState
@end
@interface Done : DownloadState
@end
@interface Success : DownloadState
@end
@interface Failure : DownloadState
@end

