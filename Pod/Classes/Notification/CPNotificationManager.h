//
//  CPNotificationManager.h
//  StateMechine
//
//  Created by cqh on 15/3/8.
//  Copyright (c) 2015年 Cnepay. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import "CPNotificationCommon.h"

@interface CPNotificationManager : NSObject
+ (void)registerWithObserver:(id)observer name:(NSString *)aName selector:(SEL)sel;

+ (void)postNotificationWithName:(NSString *)aName message:(NSString *)AnewValue;

//+ (void)postNotificationWithName:(NSString *)aName valueOld:(id)aOldValue valueNew:(id)aNewValue;

+ (void)postNotificationWithName:(NSString *)aName type:(int)type;

+ (void)postNotificationWithName:(NSString *)aName noteObj:(id)aNoteObj;

+ (void)postNotificationWithName:(NSString *)aName type:(int)type message:(NSString *)message;

+ (void)postNotificationWithName:(NSString *)aName type:(int)type message:(NSString *)message obj:(id)obj;

+ (void)removeRegisterWithObserver:(id)aObserver;
@end


@interface CPNoteMessage : NSObject
@property (nonatomic ,copy) NSString *message;
@property (nonatomic ,assign) int type;
@property (nonatomic ,strong) id obj;
@end
