//
//  ConnectionUtils.h
//  Pods
//
//  Created by chengqihan on 16/4/7.
//
//

#import <Foundation/Foundation.h>
#import "Reachability.h"
typedef void(^NetworkStatusBlock)(Reachability* reach);

@interface ConnectionUtils : NSObject
+ (BOOL)isWifiConnected;
+ (BOOL)isMobileConnected;
+ (BOOL)isNetworkConnected;
+ (void)connectionChange:(NetworkStatusBlock)netWorkStatus;
+ (Reachability *)reachability;
@end
