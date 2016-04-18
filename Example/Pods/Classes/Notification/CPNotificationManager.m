//
//  CPNotificationManager.m
//  StateMechine
//
//  Created by cqh on 15/3/8.
//  Copyright (c) 2015年 Cnepay. All rights reserved.
//

#import "CPNotificationManager.h"

#define NotificationCenter [NSNotificationCenter defaultCenter]
@implementation CPNotificationManager

+ (void)postNotificationWithName:(NSString *)aName message:(NSString *)message{
    [self postNotificationWithName:aName type:0 message:message];
}

+ (void)postNotificationWithName:(NSString *)aName type:(int)type{
    
    [self postNotificationWithName:aName type:type message:nil];
}

+ (void)postNotificationWithName:(NSString *)aName type:(int)type message:(NSString *)message obj:(id)obj {
    CPNoteMessage *noteMessage = [[CPNoteMessage alloc] init];
    noteMessage.type = type;
    noteMessage.obj = obj;
    noteMessage.message = message;
    [self postNotificationWithName:aName noteObj:noteMessage];
}

+ (void)postNotificationWithName:(NSString *)aName type:(int)type message:(NSString *)message {
    [self postNotificationWithName:aName type:type message:message obj:nil];
}


//+ (void)postNotificationWithName:(NSString *)aName valueOld:(id)aOldValue valueNew:(id)aNewValue {
//    NSDictionary *dict = @{CPStateMachineOldValue:aOldValue,CPStateMachineNewValue:aNewValue};
//    dispatch_async(dispatch_get_main_queue(), ^{
//        [NotificationCenter postNotificationName:aName object:nil userInfo:dict];
//    });
//}


+ (void)postNotificationWithName:(NSString *)aName noteObj:(id)aNoteObj {
    NSNotification *note = [NSNotification notificationWithName:aName object:aNoteObj];
    dispatch_async(dispatch_get_main_queue(), ^{
        [NotificationCenter postNotification:note];
    });
}


+ (void)registerWithObserver:(id)observer name:(NSString *)aName selector:(SEL)sel {

    [NotificationCenter addObserver:observer selector:sel name:aName object:nil];
}

+ (void)removeRegisterWithObserver:(id)aObserver{
    [NotificationCenter removeObserver:aObserver];
}

@end

@implementation CPNoteMessage

@end