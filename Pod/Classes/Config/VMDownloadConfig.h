//
//  VMDownloadConfig.h
//  Pods
//
//  Created by chengqihan on 16/4/5.
//
//
typedef NS_OPTIONS(NSUInteger, MASK_NETWORK) {
    MASK_NETWORK_WIFI = 1 << 0,
    MASK_NETWORK_MOBILE = 1 << 1,
};

#import <Foundation/Foundation.h>
@interface VMDownloadConfig : NSObject
@property (readwrite, nonatomic, assign) BOOL allowWifiNetwork;
@property (readwrite, nonatomic, assign) BOOL allowMobileNetwork;
@property (readwrite, nonatomic, assign) BOOL maxDownloadCount;

@end
