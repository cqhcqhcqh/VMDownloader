
//
//  VMDownloaderManager.m
//  Pods
//
//  Created by chengqihan on 16/4/5.
//
//

#import "VMDownloaderManager.h"
#import "VMScreenLogger.h"
#import "Reachability.h"
#import <Downloader/Downloader-Swift.h>
@import CocoaLumberjack;
@implementation VMDownloaderManager
static NSDictionary *MANAGERS;
#define MAXONGOINGCOUNT 3
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

- (void)startObserverNetworkState {
    Reachability* reach = [Reachability reachabilityWithHostname:@"www.baidu.com"];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
    
    [reach startNotifier];
}

- (void)reachabilityChanged:(Reachability *)reach
{
    VMScreenLogger(@"%zd",reach.currentReachabilityStatus);
}


- (VMDownloadTask *)enqueueWithDownloadRequest:(DownloadRequest *)request
{
    
}
@end
