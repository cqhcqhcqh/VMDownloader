//
//  ConnectionUtils.m
//  Pods
//
//  Created by chengqihan on 16/4/7.
//
//

#import "ConnectionUtils.h"
#import <objc/runtime.h>

@implementation ConnectionUtils
static char kNetWorkStatusBlock;
static Reachability* reach;
+ (void)initialize
{
    if (self == [ConnectionUtils class]) {
        [self startObserver];
    }
}

+ (void)startObserver {
    
    reach = [Reachability reachabilityWithHostname:@"www.baidu.com"];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
    [reach startNotifier];
}

+ (void)reachabilityChanged:(NSNotification *)note {
    NetworkStatusBlock networkStatus =  objc_getAssociatedObject(self, &kNetWorkStatusBlock);
    if (networkStatus) {
        networkStatus(note.object);
    }
}
+ (BOOL)isWifiConnected {
    return [reach isReachableViaWiFi];
}

+ (BOOL)isMobileConnected {
    return [reach isReachableViaWWAN];
}

+ (BOOL)isNetworkConnected {
    return [reach isReachable];
}

+ (void)connectionChange:(void(^)(NetworkStatus status))netWorkStatus {
    if (!objc_getAssociatedObject(self, &kNetWorkStatusBlock)) {
        objc_setAssociatedObject(self, &kNetWorkStatusBlock, netWorkStatus, OBJC_ASSOCIATION_COPY_NONATOMIC);
    }
}

+ (Reachability *)reachability {
    return reach;
}

@end
