//
//  CPLoggerManager.m
//  StateMechine
//
//  Created by cqh on 15/2/8.
//  Copyright (c) 2015年 Cnepay. All rights reserved.
//

#import "CPLoggerManager.h"

@implementation CPLoggerManager

static NSMutableDictionary *_poolDict;

+ (void)openLogger:(BOOL)open
{
    if(open){
        
        CPLogger *logger = [CPSDKLogger getLogger];
        [logger addBlock:^(NSString * message) {
            NSLog(@"SDK ===== > %@",message);
        }];
        
        CPLogger *stateMachineLogger = [CPStateMechineLog getLogger];
        [stateMachineLogger addBlock:^(NSString * message) {
            NSLog(@"StateMachine ===== > %@",message);
        }];
        
        CPLogger *devLogger = [CPDevLogger getLogger];
        [devLogger addBlock:^(NSString * message) {
            NSLog(@"State ===== > %@",message);
        }];
        
        CPLogger *applicationLogger = [CPDevLogger getLogger];
        [applicationLogger addBlock:^(NSString * message) {
            NSLog(@"State ===== > %@",message);
        }];
        
        CPLogger *dbLogger = [DatabaseLogger getLogger];
        [dbLogger addBlock:^(NSString * message) {
            NSLog(@"DataBase ===== > %@",message);
        }];
    }
}

+ (void)initialize
{
    if (self == [CPLoggerManager class]) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            _poolDict = [NSMutableDictionary dictionary];
        });
    }
}

+ (id) getLoggerWithName:(NSString *)name {
    
    id obj = [_poolDict objectForKey:name];
    
    if(!obj) {
        obj = [[CPLogger alloc] init];
        [_poolDict setObject:obj forKey:name];
    }
    return obj;
}

@end


@interface CPLogger ()
@property (nonatomic ,strong) NSMutableArray *loggers;
@property (nonatomic ,strong) dispatch_queue_t myQueue;
@end

@implementation CPLogger
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.myQueue = dispatch_queue_create("com.cnepay.LoggerBlockQueue", DISPATCH_QUEUE_CONCURRENT);
    }
    return self;
}

- (NSMutableArray *)loggers {
    if (!_loggers) {
        _loggers = [NSMutableArray array];
    }
    return _loggers;
}


- (void) addBlock:(LoggerPrint) printBlock{
    
    if(!printBlock)return;
    dispatch_barrier_async(self.myQueue, ^{
        [self.loggers addObject:printBlock];
    });
    
}


- (void) removeBlock:(LoggerPrint) printBlock {
    
    dispatch_barrier_async(self.myQueue, ^{
        [self.loggers removeObject:printBlock];
    });
}


- (void)print:(NSString *)message,...{
    va_list list;
    va_start(list, message);
    [self printv:message list:list];
    va_end(list);
}

- (void)printv:(NSString *)message list:(va_list)args{
    
    message = [[NSString alloc] initWithFormat:message arguments:args];
    
    [self.loggers enumerateObjectsUsingBlock:^(LoggerPrint printBlock, NSUInteger idx, BOOL *stop) {
        
        printBlock(message);
        
    }];
}

@end


@implementation CPSDKLogger

+ (void) printMessage:(NSString *)message, ... {
    
    //指向变参的指针
    va_list list;
    //使用第一个参数来初使化list指针
    va_start(list, message);
    [[self getLogger] printv:message list:list];
    va_end(list);
}

+ (CPLogger *) getLogger{
    
    return [CPLoggerManager getLoggerWithName:NSStringFromClass([self class])];
}

@end



@implementation CPStateMechineLog
+ (void) printMessage:(NSString *)message, ... {
    
    //指向变参的指针
    va_list list;
    //使用第一个参数来初使化list指针
    va_start(list, message);
    [[self getLogger] printv:message list:list];
    va_end(list);
}

+ (CPLogger *) getLogger{
    
    return [CPLoggerManager getLoggerWithName:NSStringFromClass([self class])];
    
}
@end


@implementation CPDevLogger

+ (void) printMessage:(NSString *)message, ... {
    
    //指向变参的指针
    va_list list;
    //使用第一个参数来初使化list指针
    va_start(list, message);
    [[self getLogger] printv:message list:list];
    va_end(list);
}

+ (CPLogger *) getLogger{
    
    return [CPLoggerManager getLoggerWithName:NSStringFromClass([self class])];
    
}

@end


@implementation CPApplicationLogger

+ (void) printMessage:(NSString *)message, ... {
    
    //指向变参的指针
    va_list list;
    //使用第一个参数来初使化list指针
    va_start(list, message);
    [[self getLogger] printv:message list:list];
    va_end(list);
}

+ (CPLogger *) getLogger{
    
    return [CPLoggerManager getLoggerWithName:NSStringFromClass([self class])];
    
}

@end

@implementation DatabaseLogger
+ (void) printMessage:(NSString *)message, ... {
    
    //指向变参的指针
    va_list list;
    //使用第一个参数来初使化list指针
    va_start(list, message);
    [[self getLogger] printv:message list:list];
    va_end(list);
}

+ (CPLogger *) getLogger{
    
    return [CPLoggerManager getLoggerWithName:NSStringFromClass([self class])];
    
}


@end