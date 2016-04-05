
//
//  VMDownloaderManager.m
//  Pods
//
//  Created by chengqihan on 16/4/5.
//
//

#import "VMDownloaderManager.h"
#import "VMScreenLogger.h"

@import CocoaLumberjack;
@implementation VMDownloaderManager

+ (void)initialize
{
    if (self == [VMDownloaderManager class]) {
        [DDLog addLogger:[VMScreenLogger new] withLevel:DDLogLevelDebug];
    }
}

@end
