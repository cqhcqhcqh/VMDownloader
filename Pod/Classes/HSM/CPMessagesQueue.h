//
//  CPMessagesQueue.h
//  GCD的其他用法
//
//  Created by cqh on 15/1/27.
//  Copyright (c) 2015年 Cnepay. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CPMessageOperation.h"

@class CPMessage,CPMessagesQueue;

@interface CPMessagesQueue : NSOperationQueue<CPMessageOperationDelegate>
@property (readwrite, nonatomic, strong) NSThread *runloopThread;
- (void)addOperationAtFrontOfQueue:(CPMessage *)op;
- (void)addOperationAtEndOfQueue:(CPMessage *)op;
- (void)delayOperationAtEndOfQueue:(CPMessage *)op delay:(NSTimeInterval)delay;
- (void)removeOperationWithMessage:(CPMessage *)message;
@end
