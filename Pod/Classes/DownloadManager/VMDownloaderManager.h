//
//  VMDownloaderManager.h
//  Pods
//
//  Created by chengqihan on 16/4/6.
//
//

#import <Foundation/Foundation.h>
#import "VMDownloadTask.h"

@class CPMessage,VMDownloadConfig,State,VMDownloadTask,VMDownloadRequest;

@interface VMDownloaderManager : NSObject

/**
 *  每一个Manager都有指定的downloadConfig(配置)
 */
@property (readonly, nonatomic, strong) VMDownloadConfig *downloadConfig;

/**
 *  Manager->DownloadTask(StateMachine)->smshandler(queue)->Operation([self isReady]之后 执行代码 所在的线程)
 */
@property (readonly, nonatomic, strong) NSThread *downloadTaskRunLoopThread;
/**
 *  指定构造器
 *
 *  @param identifier 根据identifier创建Manager
 *
 *  @return 实例
 */
- (instancetype)initWitIdentifier:(NSString *)identifier;


+ (instancetype)managerWithIdentifier:(NSString *)identifier;

/**
 *  根据指定的key获取DownloadManager
 *
 *  @param key key
 *
 *  @return downloaderManager
 */
+ (instancetype)getInstanceWithKey:(NSString *)key;

/**
 *  根据VMDownloadRequest实例创建一个VMDownloadRequest实例
 *
 *  @param request VMDownloadRequest
 *
 *  @return VMDownloadRequest
 */
- (VMDownloadTask *)enqueueWithRequest:(VMDownloadRequest *)request;

/**
 *  获取某个状态下对应的TASKS[NSArray]
 */
- (NSArray *)getTasksInState:(Class)stateClass;

/**
 *  校验MD5
 *
 *  @param filePath  文件路径
 *  注意:这这里的文件路径是沙箱中 Documents文件夹的子文件的路径
 *  /Vedio/xxx.mp4
 
 *  @param md5Result 源MD5值
 *
 *  @return 校验是否成功
 */
- (BOOL)verifyMd5WithFilePath:(NSString *)filePath md5Result:(NSString *)md5Result;

//+ (VMDownloadTask *)getTaskById:(NSString *)uuid;

@end
