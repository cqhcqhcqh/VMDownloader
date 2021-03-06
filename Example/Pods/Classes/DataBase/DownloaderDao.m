//
//  DownloaderDao.m
//  Pods
//
//  Created by chengqihan on 16/4/9.
//
//

#import "DownloaderDao.h"
#import "FMDB.h"
#import "VMDownloadTask.h"
#import "CPLoggerManager.h"

@implementation DownloaderDao

/**
 *  "create table tasks (_id text primary key, " + // uuid 主键
 "url text, " + // 主地址
 "path text, " + // 下载目标地址
 "title text, " + // 下载名称
 "description text, " + // 下载描述
 "mimetype text, " + // 下载文件mimetype
 "state integer, " + // 任务状态
 "error text, " + // 错误信息
 "md5 text, " + // 需要验证MD5
 "sha1 text, " + //需要验证sha1
 "length integer, " + //文件大小
 "networkmode integer, " + //网络模式
 "progress integer, " + //文件已完成大小
 "_create text, " + // 创建时间
 "_modify text)"; // 修改时间
 */
static FMDatabase *database;
+ (void)initialize
{
    if (self == [DownloaderDao class]) {
//        NSString *documentFilePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
        NSString *sqliteFilePath = [DocumenDir stringByAppendingPathComponent:@"download.sqlite"];
        database = [FMDatabase databaseWithPath:sqliteFilePath];
        if ([database open]) {
            BOOL createSuccess = [database executeUpdate:@"create table if not exists t_downloads (_id text primary key, url text, path text, title text, description text, mimetype text, state integer, error text, md5 text, sha1 text, length integer, networkmode integer, progress integer, _create text, _modify text);"];
            DatabaseLog(@"创建t_downloads表 %@",createSuccess?@"成功":@"失败");
        }
    }
}
- (void)deleteDownloadTaskWithUUID:(NSString *)uuid {
    BOOL deleteSuccess = [database executeUpdate:@"DELETE from t_downloads WHERE _id = ?;",uuid];
    DatabaseLog(@"删除下载任务 uuid:%@ %@",uuid,deleteSuccess?@"成功":@"失败");
}

/**
 *  UPDATE COMPANY SET ADDRESS = 'Texas', SALARY = 20000.00
 */
+ (void)updateDownloadTaskWithUUID:(NSString *)uuid dictionary:(NSDictionary *)dictionary{
    BOOL updateSuccess =[database executeUpdate:@"UPDATE t_downloads SET mimetype = ?, state = ?, error = ?, length = ?, networkmode = ?, progress = ?, _modify = ?  WHERE _id = ?;",dictionary[@"mimetype"],dictionary[@"state"],dictionary[@"error"],dictionary[@"length"],dictionary[@"networkmode"],dictionary[@"progress"],dictionary[@"_modify"],uuid];
    DatabaseLog(@"更新下载任务 title:%@ uuid:%@ %@",dictionary[@"title"],uuid,updateSuccess?@"成功":@"失败");
}

/**
 *  @"INSERT INTO t_student (name, age) VALUES (?, ?);"
 *  NSDictionary *arguments = @{@"identifier": @(identifier), @"name": name, @"date": date, @"comment": comment ?: [NSNull null]};
    BOOL success = [db executeUpdate:@"INSERT INTO authors (identifier, name, date, comment) VALUES (:identifier, :name, :date, :comment)" withParameterDictionary:arguments];

 */
+ (void)createDownloadTaskWithDictionary:(NSDictionary *)dictionary {
//    [database executeUpdateWithFormat:@"DELETE from t_downloads WHERE _id=?;",uuid];
    BOOL insertSuccess = [database executeUpdate:@"INSERT INTO t_downloads (_id, url, path, title, description, mimetype, state, error, md5, sha1, length, networkmode, progress, _create, _modify) VALUES (:_id, :url, :path, :title, :description, :mimetype, :state, :error, :md5, :sha1, :length, :networkmode, :progress, :_create, :_modify)" withParameterDictionary:dictionary];
    DatabaseLog(@"插入下载任务 title:%@ uuid:%@ %@",dictionary[@"title"],dictionary[@"_id"],insertSuccess?@"成功":@"失败");
    
}

+ (NSArray *)recoverWorkingTasksWithThread:(NSThread *)thread key:(NSString *)key{
    FMResultSet *resultSet = [database executeQuery:@"SELECT * from t_downloads where state <= ?",@(DownloadTaskStateVerifying)];
    NSMutableArray *array = [NSMutableArray array];
    while ([resultSet next]) {
        VMDownloadTask *task = [VMDownloadTask recoveryDownloadTaskWithRunloopThread:thread key:key resultSet:resultSet];
        DatabaseLog(@"回复中断的下载任务 state %@ title:%@ uuid:%@",DownloadStateDesc[task.mState],task.title,task.uuid);
        [array addObject:task];
    }
    return array;
}
@end
