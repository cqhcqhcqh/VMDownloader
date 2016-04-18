//
//  CPMessagesQueue.m
//  GCD的其他用法
//
//  Created by cqh on 15/1/27.
//  Copyright (c) 2015年 Cnepay. All rights reserved.
//

#import "CPMessagesQueue.h"
#import "CPMessageOperation.h"

@interface CPMessagesQueue ()
@property (atomic ,strong) CPMessageOperation *lastOperation;
@end

@implementation CPMessagesQueue
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.maxConcurrentOperationCount = 1;
    }
    return self;
}

- (void)addOperationAtEndOfQueue:(CPMessage *)message {
    CPMessageOperation *op = [CPMessageOperation sendMessageOperationWithTask:message];
    op.runloopThread = self.runloopThread;
    op.delegate = self;
    
    if (self.lastOperation) {
        [op addDependency:self.lastOperation];
    }
    
    self.lastOperation = op;
    [super addOperation:op];
}


- (void)addOperationAtFrontOfQueue:(CPMessage *)message {
    //EVENT_REPEAT_CONNECT
    //EVENT_INTERUPT
    CPMessageOperation *op = [CPMessageOperation sendMessageOperationWithTask:message];
    op.runloopThread = self.runloopThread;
    op.delegate = self;
    
    NSArray *operations = self.operations;
    [operations enumerateObjectsUsingBlock:^(CPMessageOperation* operation, NSUInteger idx, BOOL *stop) {
        
        if([operation isExecuting]){
            
            [op addDependency:operation];
            
        }else{
            
            [operation addDependency:op];
        }
    }];
    
    [super addOperation:op];
}


- (void)removeOperationWithMessage:(CPMessage *)message {
    
    NSArray *operations = self.operations;
    [operations enumerateObjectsUsingBlock:^(CPMessageOperation* operation, NSUInteger idx, BOOL *stop){
        if(message.type == operation.message.type) {
            [operation cancel];
        }
    }];
}

- (void)delayOperationAtEndOfQueue:(CPMessage *)message delay:(NSTimeInterval)delay {
    
    CPMessageOperation *op = [CPMessageOperation sendMessageOperationWithTask:message];
    op.runloopThread = self.runloopThread;
    op.delegate = self;
    op.delayTime = delay;
    if (self.lastOperation) {
        [op addDependency:self.lastOperation];
    }
    self.lastOperation = op;
    [super addOperation:op];

    
}
- (void)sendMessageOperation:(CPMessageOperation *)operation didFinishSendMessage:(CPMessage *)message {

}
@end

