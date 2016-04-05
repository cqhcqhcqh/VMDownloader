//
//  VMDownloadConfig.m
//  Pods
//
//  Created by chengqihan on 16/4/5.
//
//

#import "VMDownloadConfig.h"
#import "VMSharedPreferences.h"

#define USERDEFAULT [VMSharedPreferences standardSharedPreferences]
#define DEFAULT_MAX_DOWNLOAD_COUNT 3
#define DEFAULT_NETWORK_MODE MASK_NETWORK_WIFI
static NSString * const NETWORK_MODE = @"_network_mode";
static NSString * const MAX_DOWNLOAD_COUNT = @"_max_download_count";
@implementation VMDownloadConfig

- (instancetype)init
{
    self = [super init];
    if (self) {
        //        NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0]
        [self setNetworkMode:DEFAULT_NETWORK_MODE];
        [self setAllowWifiNetwork:YES];
        [self setAllowMobileNetwork:NO];
        [self setMaxDownloadCount:DEFAULT_MAX_DOWNLOAD_COUNT];
    }
    return self;
}

- (void)setMaxDownloadCount:(NSInteger)count{
    [USERDEFAULT setInteger:count forKey:MAX_DOWNLOAD_COUNT];
    [USERDEFAULT synchronize];
}
- (void)setNetworkMode:(NSInteger)mode {
    [USERDEFAULT setInteger:mode forKey:NETWORK_MODE];
    [USERDEFAULT synchronize];
}
- (NSInteger)getNetworkMode {
    return [USERDEFAULT integerForKey:NETWORK_MODE];
}
- (NSInteger)maxDownloadCount{
    return [USERDEFAULT integerForKey:MAX_DOWNLOAD_COUNT];
}

- (BOOL)allowWifiNetwork {
    return [self getNetworkMode] & MASK_NETWORK_WIFI;
}

- (BOOL)allowMobileNetwork {
    return [self getNetworkMode] & MASK_NETWORK_MOBILE;
}

- (void)setAllowMobileNetwork:(BOOL)isAllow
{
    if (isAllow) {
        [USERDEFAULT setInteger:[self getNetworkMode] | MASK_NETWORK_MOBILE forKey:NETWORK_MODE];
    }else {
        //~按位取反
        //默认允许Wifi(0...01)
        //0...01 & ~0...10 => 0....01 & 1...01 = 0...01 = 1
        [USERDEFAULT setInteger:[self getNetworkMode] & ~MASK_NETWORK_MOBILE forKey:NETWORK_MODE];
    }
    [USERDEFAULT synchronize];
}

- (void)setAllowWifiNetwork:(BOOL)isAllow
{
    if (isAllow) {
        [USERDEFAULT setInteger:[self getNetworkMode] | MASK_NETWORK_WIFI forKey:NETWORK_MODE];
    }else {
        //~按位取反
        //默认允许Wifi(0...01)
        //0...01 & ~0...01 => 0....01 & 1...10 = 0...00 = 0
        [USERDEFAULT setInteger:[self getNetworkMode] & ~MASK_NETWORK_WIFI forKey:NETWORK_MODE];
    }
    [USERDEFAULT synchronize];
}
@end
