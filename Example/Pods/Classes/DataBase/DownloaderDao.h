//
//  DownloaderDao.h
//  Pods
//
//  Created by chengqihan on 16/4/9.
//
//

#import <Foundation/Foundation.h>

@interface DownloaderDao : NSObject
+ (void)createDownloadTaskWithDictionary:(NSDictionary *)dictionary;

+ (void)deleteDownloadTaskWithUUID:(NSString *)uuid;

+ (void)updateDownloadTaskWithUUID:(NSString *)uuid dictionary:(NSDictionary *)dictionary;

+ (NSArray *)recoverWorkingTasksWithThread:(NSThread *)thread key:(NSString *)key;
@end
