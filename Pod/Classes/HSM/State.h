//
//  State.h
//  Model1
//
//  Created by cnepayzx on 15-1-19.
//  Copyright (c) 2015年 cnepay. All rights reserved.
//

#import <Foundation/Foundation.h>

@class StateMachine,CPMessage;
@interface State : NSObject <NSCopying>

@property(nonatomic,weak) StateMachine *stateMachine;

- (instancetype)initWithStateMachine:(StateMachine *)stateMachine;
+ (instancetype)stateWithStateMachine:(StateMachine *)stateMachine;

- (void)enter;
- (void)exit;

- (BOOL)processMessage:(CPMessage *)message;
- (NSString *)getName;

- (void)sendMessageType:(int)type;
- (void)sendMessageType:(int)type withObj:(id)obj;
- (void)sendMessageType:(int)type withSubType:(int)subType;
- (void)sendMessageType:(int)type withSubType:(int)subType withObj:(id)obj;
- (void)deferredMessage:(CPMessage *)message;
@end


