//
//  DownloaderDao.h
//  Pods
//
//  Created by chengqihan on 16/4/9.
//
//

#import <Foundation/Foundation.h>

@interface DownloaderDao : NSObject
/**
 *  根据一个字典往数据库中存入一个Task对象
 *
 *  @param dictionary 字典
 */
+ (void)createDownloadTaskWithDictionary:(NSDictionary *)dictionary;

/**
 *  根据指定的UUID从数据库中删除一个Task对象
 *
 *  @param uuid 任务的唯一身份ID
 */
+ (void)deleteDownloadTaskWithUUID:(NSString *)uuid;

/**
 *  根据指定的ID更新数据库中的一条Task对象
 *
 *  @param uuid       Task的唯一身份ID
 *  @param dictionary 字典
 */
+ (void)updateDownloadTaskWithUUID:(NSString *)uuid dictionary:(NSDictionary *)dictionary;

/**
 *  从数据库中回复被中断的任务
 *
 *  @param thread 任务所在的线程
 *  @param key    Manager对应的key
 *
 *  @return Tasks
 */
+ (NSArray *)recoverWorkingTasksWithThread:(NSThread *)thread key:(NSString *)key;
@end
