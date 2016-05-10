//
//  CPNotificationManager.h
//  StateMechine
//
//  Created by cqh on 15/3/8.
//  Copyright (c) 2015年 Cnepay. All rights reserved.
//

#import <Foundation/Foundation.h>
FOUNDATION_EXTERN NSString *const kMessageTypeEventProgress;
FOUNDATION_EXTERN NSString *const kDownloadTaskInsert;
FOUNDATION_EXTERN NSString *const kDownloadStateChange;
FOUNDATION_EXTERN NSString *const kDownloadStateOldValue;
FOUNDATION_EXTERN NSString *const kDownloadStateNewValue;
FOUNDATION_EXTERN NSString *const kDownloadNetworkNotPermission;
FOUNDATION_EXTERN NSString *const kDownloadNetworkChange;

@interface CPNotificationManager : NSObject
+ (void)postNotificationWithName:(NSString *)aName type:(int)type;
+ (void)postNotificationWithName:(NSString *)aName message:(NSString *)message;
+ (void)postNotificationWithName:(NSString *)aName type:(int)type message:(NSString *)message;
+ (void)postNotificationWithName:(NSString *)aName type:(int)type message:(NSString *)message obj:(id)obj;
+ (void)postNotificationWithName:(NSString *)aName type:(int)type message:(NSString *)message obj:(id)obj userInfo:(NSDictionary *)userInfo;


+ (void)registerWithObserver:(id)observer name:(NSString *)aName selector:(SEL)sel;
+ (void)removeRegisterWithObserver:(id)aObserver;
@end


@interface CPNoteMessage : NSObject
@property (nonatomic ,copy) NSString *message;
@property (nonatomic ,assign) int type;
@property (nonatomic ,strong) id obj;
@property (readwrite, nonatomic, strong) NSDictionary *userInfo;
@end
