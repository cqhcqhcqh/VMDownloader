//
//  CPState.m
//  Model
//
//  Created by cnepayzx on 15-1-21.
//  Copyright (c) 2015年 cnepay. All rights reserved.
//

#import "StateMachine.h"
#import "State.h"
#import "CPMessagesQueue.h"
#import "CPMessageOperation.h"
#import "SmHandler.h"
#import "CPLoggerManager.h"
@interface StateMachine()

@property(nonatomic,strong) State *currentState;
@property (readwrite, nonatomic, strong) SmHandler *smHandler;
@property (readwrite, nonatomic, strong) QuittingState *quittingState;
@end

@implementation StateMachine

- (void) initialState:(State *)state {
    [self.smHandler setInitialState:state];
}
- (void)transitionToState:(State *)destState
{
    [self.smHandler transitionToState:destState];
}

+ (instancetype)stateMachine
{
    return [[self alloc] init];
}
- (void)quitNow
{
    [self.smHandler quitNow];
}

- (BOOL)isQuit:(CPMessage *)msg {
    
    if (self.smHandler) {
        return [self.smHandler isQuit:msg];
    }else {
        return msg.type = MessageTypeActionQuit;
    }
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _quittingState = [[QuittingState alloc] initWithStateMachine:self];
        _smHandler = [[SmHandler alloc] init];
        [_smHandler addState:_quittingState parentState:nil];
        _smHandler.handlerDelegate = self;
    }
    return self;
}

- (void)start
{
    CPStateMechineLog(@"self %@ %@",self,[NSThread currentThread]);
    [self.smHandler completeConstruction];
}


- (BOOL)hasDeferredMessage:(MessageType)type {
    for (CPMessage *msg in self.smHandler.deferredArray) {
        if (msg.type == type) {
            return YES;
        }
    }
    return NO;
    
}

- (void)removeDeferredMessage:(MessageType)type
{
    NSMutableArray *tempDeferredArray = [NSMutableArray array];
    for (CPMessage *msg in self.smHandler.deferredArray) {
        if (msg.type != type) {
            [tempDeferredArray addObject:msg];
        }
    }
    [self.smHandler.deferredArray removeAllObjects];
    self.smHandler.deferredArray = tempDeferredArray;
}

- (void)sendMessage:(CPMessage *)message
{
    [self.smHandler addOperationAtEndOfQueue:message];
}
- (void)sendMessageType:(MessageType)type
{
    [self.smHandler addOperationAtEndOfQueue:[CPMessage messageWithType:type]];
}

- (void)sendMessageFront:(CPMessage *)message
{
    [self.smHandler addOperationAtFrontOfQueue:message];
    
}
- (void)sendMessageFrontType:(MessageType)type
{
    
    [self.smHandler addOperationAtFrontOfQueue:[CPMessage messageWithType:type]];
}
- (void) removeMessageWithType:(MessageType)type {
    [self.smHandler.operations enumerateObjectsUsingBlock:^(__kindof CPMessageOperation * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.message.type == type && ![obj isExecuting]) {
            [obj cancel];
        }
    }];
    
}


- (void)sendMessageDelayed:(CPMessage *)msg delay:(NSTimeInterval)delay
{
    [self.smHandler delayOperationAtEndOfQueue:msg delay:delay];
}

- (void)deferredMessage:(CPMessage *)message
{
    [self.smHandler.deferredArray addObject:message];
}

- (void)addState:(State *)state parentState:(State *)parentState
{
    [self.smHandler addState:state parentState:parentState];
}

- (void)smHandlerProcessFinalMessage:(CPMessage *)msg{}
@end

@implementation QuittingState
- (BOOL)processMessage:(CPMessage *)message
{
    return NO;
}
@end