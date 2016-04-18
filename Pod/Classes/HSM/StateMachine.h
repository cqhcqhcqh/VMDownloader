//
//  CPState.h
//  Model
//
//  Created by cnepayzx on 15-1-21.
//  Copyright (c) 2015年 cnepay. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CPMessageOperation.h"
#import "SmHandler.h"

@class State,CPMessagesQueue,SmHandler;

@interface StateMachine : NSObject <SmHandlerDelegate>

@property(nonatomic, strong) State *destState;

@property (readonly, nonatomic, strong) SmHandler *smHandler;
+ (instancetype) stateMachine;

//顺序发送事件
- (void) sendMessage:(CPMessage *)message;
- (void) sendMessageType:(MessageType)type;
//插入到队列的前面
- (void) sendMessageFront:(CPMessage *)message;
- (void) sendMessageFrontType:(MessageType)type;
- (void) removeMessageWithType:(MessageType)type;
//缓存
- (void) deferredMessage:(CPMessage *)message;
- (BOOL) hasDeferredMessage:(MessageType)type;
- (void) removeDeferredMessage:(MessageType)type;
//- (BOOL) hasOnWaitingOperationsMessage:(MessageType)type;

//设置初始的状态
- (void) initialState:(State *)state;

- (void) addState:(State *)state parentState:(State *)parentState;

- (void) start;

- (void) transitionToState:(State *)destState;

- (void) sendMessageDelayed:(CPMessage *)msg delay:(NSTimeInterval)delay;
@end

