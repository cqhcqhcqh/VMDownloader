//
//  CPSendMessageOperation.h
//  GCD的其他用法
//
//  Created by cqh on 15/1/27.
//  Copyright (c) 2015年 Cnepay. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef NS_ENUM(NSUInteger, MessageType) {
    MessageTypeEventInit = 1,
    MessageTypeEventRetryRequest,
    MessageTypeEventVerifyPass,
    MessageTypeEventVerifyFail,
    MessageTypeEventDownloadingAvailable,
    MessageTypeEventProgress,
    MessageTypeEventTaskDone,
    
    MessageTypeEventDownloadException,
    MessageTypeEventNetworkConnectionChange,
    
    MessageTypeActionStart,
    MessageTypeActionPaused,
    MessageTypeActionDelete,
    MessageTypeActionQuit
};

FOUNDATION_EXPORT NSString* const MessageMapping [];
//extern inline NSString* MessageTypeDescription(MessageType type);

@class CPMessage,CPMessageOperation;

@protocol CPMessageOperationDelegate <NSObject>
@optional
- (void) sendMessageOperationDidStart:(CPMessageOperation *)operation message:(CPMessage *)message;
@end

@interface CPMessageOperation : NSOperation
@property (nonatomic ,weak) id <CPMessageOperationDelegate> delegate;
@property (nonatomic ,strong) CPMessage *message;
@property (readwrite, nonatomic, strong) NSThread *runloopThread;
@property (readwrite, nonatomic, assign) NSTimeInterval delayTime;

- (instancetype) initWithTask:(CPMessage *)message;
+ (instancetype) sendMessageOperationWithTask:(CPMessage *)message;
@end

@interface CPMessage : NSObject
@property (nonatomic ,assign) MessageType type;
@property (nonatomic ,assign) int subType;
@property (nonatomic ,assign) int code;
@property (nonatomic ,strong) id obj;

- (instancetype)initWithType:(MessageType)type;
+ (instancetype)messageWithType:(MessageType)type;
- (instancetype)initWithType:(MessageType)type obj:(id)object;
+ (instancetype)messageWithType:(MessageType)type obj:(id)object;
- (instancetype)initWithType:(MessageType)type subType:(int)subType code:(int)code obj:(id)object;
+ (instancetype)messageWithType:(MessageType)type subType:(int)subType code:(int)code obj:(id)object;
@end
