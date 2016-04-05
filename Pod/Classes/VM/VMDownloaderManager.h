//
//  VMDownloaderManager.h
//  Pods
//
//  Created by chengqihan on 16/4/5.
//
//

#import <Foundation/Foundation.h>

@class VMDownloadTask,DownloadRequest;
@interface VMDownloaderManager : NSObject
- (instancetype)getInstance:(NSString *)key;
- (VMDownloadTask *)enqueueWithDownloadRequest:(DownloadRequest *)request;
@end
