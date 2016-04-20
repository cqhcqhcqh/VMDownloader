//
//  State.m
//  Model1
//
//  Created by cnepayzx on 15-1-19.
//  Copyright (c) 2015年 cnepay. All rights reserved.
//

#import "State.h"
#import "StateMachine.h"
#import "CPMessageOperation.h"
#import "CPLoggerManager.h"

@implementation State
- (id)copyWithZone:(nullable NSZone *)zone {
    State *copy = [[[self class] allocWithZone:zone] initWithStateMachine:_stateMachine];
    return copy;
}

- (instancetype)initWithStateMachine:(StateMachine *)stateMachine
{
    if (self = [super init]) {
        
        _stateMachine = stateMachine;
    }
    
    return self;
}

+ (instancetype)stateWithStateMachine:(StateMachine *)stateMachine {
    
    return [[self alloc] initWithStateMachine:stateMachine];
}

-(void)enter
{
//    NSString *desc = [NSString stringWithFormat:@"%@ ENTER.....",self.getName];
//    CPStateMechineLog(@"%@",desc);
}



-(void)exit
{
//    NSString *desc = [NSString stringWithFormat:@"%@ EXIT....",self.getName];
//    CPStateMechineLog(@"%@",desc);
}


-(NSString *)getName
{
    return NSStringFromClass(self.class);
}

- (void)sendMessageType:(int)type
{
    CPMessage *message = [CPMessage messageWithType:type];
    [self.stateMachine sendMessage:message];
}

- (void)sendMessageType:(int)type withObj:(id)obj
{
    CPMessage *message = [CPMessage messageWithType:type];
    message.obj = obj;
    [self.stateMachine sendMessage:message];
}

- (void)sendMessageType:(int)type withSubType:(int)subType
{
    CPMessage *message = [CPMessage messageWithType:type];
    message.subType = subType;
    [self.stateMachine sendMessage:message];
}

- (void)sendMessageType:(int)type withSubType:(int)subType withObj:(id)obj
{
    CPMessage *message = [CPMessage messageWithType:type];
    message.subType = subType;
    message.obj = obj;
    [self.stateMachine sendMessage:message];
}

- (void)deferredMessage:(CPMessage *)message
{
    [self.stateMachine deferredMessage:message];
}

- (BOOL)processMessage:(CPMessage *)message {
    return NO;
}
@end
