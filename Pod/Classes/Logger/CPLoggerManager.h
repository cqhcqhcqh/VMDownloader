//
//  CPLoggerManager.h
//  StateMechine
//
//  Created by cqh on 15/2/8.
//  Copyright (c) 2015年 Cnepay. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^LoggerPrint)(NSString* message);

@interface CPLogger : NSObject
- (void) addBlock:(LoggerPrint) printBlock;
- (void) removeBlock:(LoggerPrint) printBlock;
- (void) print:(NSString *)message,...;
- (void) printv:(NSString *)message list:(va_list)args;
@end

@interface CPLoggerManager : NSObject
+ (void)openLogger:(BOOL)open;
+ (CPLogger *) getLoggerWithName:(NSString *)name;

@end


#define SDKLog(...) [CPSDKLogger printMessage:__VA_ARGS__]

@interface CPSDKLogger : NSObject

+ (CPLogger *) getLogger;
+ (void) printMessage:(NSString *)message, ...;
@end


#define CPStateMechineLog(...) [CPStateMechineLog printMessage:__VA_ARGS__]

@interface CPStateMechineLog : NSObject
+ (CPLogger *) getLogger;
+ (void) printMessage:(NSString *)message, ...;
@end


#define DevLog(...)[CPDevLogger printMessage:__VA_ARGS__]

@interface CPDevLogger : NSObject

+ (CPLogger *) getLogger;
+ (void) printMessage:(NSString *)message, ...;
@end


#define ApplicationLog(...)[CPApplicationLogger printMessage:__VA_ARGS__]

@interface CPApplicationLogger : NSObject
+ (CPLogger *) getLogger;
+ (void) printMessage:(NSString *)message, ...;
@end


#define DatabaseLog(...)[DatabaseLogger printMessage:__VA_ARGS__]
@interface DatabaseLogger : NSObject
+ (CPLogger *) getLogger;
+ (void) printMessage:(NSString *)message, ...;
@end