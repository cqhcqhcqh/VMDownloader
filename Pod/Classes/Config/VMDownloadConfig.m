//
//  VMDownloadConfig.m
//  Pods
//
//  Created by chengqihan on 16/4/5.
//
//

#import "VMDownloadConfig.h"
#import "VMSharedPreferences.h"
#import "VMDownloadTask.h"
#import "ConnectionUtils.h"

#define USERDEFAULT [NSUserDefaults standardUserDefaults]

#define DEFAULT_MAX_DOWNLOAD_COUNT 3
#define DEFAULT_NETWORK_MODE MASK_NETWORK_WIFI
NSString * const NETWORK_MODE = @"_network_mode";
NSString * const MAX_DOWNLOAD_COUNT = @"_max_download_count";

@interface VMDownloadConfig ()
@property (readwrite, nonatomic, copy) NSString *identifier;
//@property (readwrite, nonatomic, strong) VMSharedPreferences *sharePreference;
- (instancetype)initWithIdentifier:(NSString*)key;
@end
@implementation VMDownloadConfig

#pragma mark -  向外暴露的方法
+ (instancetype)loadLocalConfigFromPreference:(NSString *)identifier {
    
//    NSString *downloadIdentifier = [NSString stringWithFormat:@"_download_config_%@",identifier];
//    VMSharedPreferences *sharePreferences = [VMSharedPreferences sharedPreferencesWithIdentifier:downloadIdentifier];
    return [[self alloc] initWithIdentifier:identifier];
}

#pragma mark - 内部的构造方法
- (instancetype)initWithIdentifier:(NSString*)identifier{
    if (self == [super init]) {
        _identifier = identifier;
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

- (BOOL)isNetworkAllowedFor:(VMDownloadTask *)task {
    
    if (self.allowMobileNetwork && task.allowMobileNetWork && [ConnectionUtils isMobileConnected]) {
        return YES;
    }
    
    if (self.allowWifiNetwork && task.allowWifiNetWork && [ConnectionUtils isWifiConnected]) {
        return YES;
    }
    return  NO;
}

@end
