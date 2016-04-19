//
//  CPNotificationManager.h
//  StateMechine
//
//  Created by cqh on 15/3/8.
//  Copyright (c) 2015年 Cnepay. All rights reserved.
//

#import <Foundation/Foundation.h>
FOUNDATION_EXTERN NSString *const kMessageTypeEventProgress;

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
