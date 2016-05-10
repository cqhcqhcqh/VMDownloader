//
//  CPNotificationManager.m
//  StateMechine
//
//  Created by cqh on 15/3/8.
//  Copyright (c) 2015年 Cnepay. All rights reserved.
//

#import "CPNotificationManager.h"
NSString *const kMessageTypeEventProgress = @"com.vmovier.downloadProgress";
NSString *const kDownloadTaskInsert = @"com.vmovier.downloadTaskDatabaseInsert";
NSString *const kDownloadStateChange = @"com.vmovier.downloadTaskStateChange";
NSString *const kDownloadStateOldValue = @"com.vmovier.downloadTaskStateOldValue";;
NSString *const kDownloadStateNewValue = @"com.vmovier.downloadTaskStateNewValue";;
NSString *const kDownloadNetworkNotPermission = @"com.vmovier.downloadNetworkNotPermission";
NSString *const kDownloadNetworkChange = @"com.vmovier.downloadNetworkNotChange";
#define NotificationCenter [NSNotificationCenter defaultCenter]
@implementation CPNotificationManager

+ (void)postNotificationWithName:(NSString *)aName type:(int)type{
    
    [self postNotificationWithName:aName type:type message:nil obj:nil userInfo:nil];
}

+ (void)postNotificationWithName:(NSString *)aName message:(NSString *)message{
    [self postNotificationWithName:aName type:0 message:message obj:nil userInfo:nil];
}

+ (void)postNotificationWithName:(NSString *)aName type:(int)type message:(NSString *)message {
    [self postNotificationWithName:aName type:type message:message obj:nil userInfo:nil];
}


+ (void)postNotificationWithName:(NSString *)aName type:(int)type message:(NSString *)message obj:(id)obj {
    [self postNotificationWithName:aName type:type message:message obj:obj userInfo:nil];
}


+ (void)postNotificationWithName:(NSString *)aName type:(int)type message:(NSString *)message obj:(id)obj userInfo:(NSDictionary *)userInfo {
    CPNoteMessage *noteMessage = [[CPNoteMessage alloc] init];
    noteMessage.type = type;
    noteMessage.obj = obj;
    noteMessage.userInfo = userInfo;
    noteMessage.message = message;
    [self postNotificationWithName:aName noteObj:noteMessage];
}


+ (void)postNotificationWithName:(NSString *)aName noteObj:(CPNoteMessage *)aNoteObj {
    NSNotification *note = [NSNotification notificationWithName:aName object:aNoteObj userInfo:aNoteObj.userInfo];
    [NSNotification notificationWithName:aName object:aNoteObj userInfo:nil];
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