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

FOUNDATION_EXTERN NSString * const NETWORK_MODE;
FOUNDATION_EXTERN NSString * const MAX_DOWNLOAD_COUNT;
#import <Foundation/Foundation.h>
@class VMDownloadTask,VMSharedPreferences;

@interface VMDownloadConfig : NSObject
@property (readwrite, nonatomic, assign) BOOL allowWifiNetwork;
@property (readwrite, nonatomic, assign) BOOL allowMobileNetwork;
@property (readwrite, nonatomic, assign) NSInteger maxDownloadCount;
/**
 *  唯一身份识别
 */
@property (readonly, nonatomic, copy) NSString *identifier;

/**
 *  判断指定Task的是否允许网络下载
 *  主要是根据三个条件来判断是否允许下载
 *  1、手机网络可用
 *  2、Task网络可用
 *  3、Manager网络可用
 *
 *  @param task 指定Task
 *
 *  @return 是否允许网络下载任务
 */
- (BOOL)isNetworkAllowedFor:(VMDownloadTask *)task;


/**
 *  根据指定的identifier创建一个VMDownloadConfig
 *
 *  @param identifier 唯一身份标识
 *
 *  @return VMDownloadConfig实例
 */
+ (instancetype)loadLocalConfigFromPreference:(NSString *)identifier;
@end
