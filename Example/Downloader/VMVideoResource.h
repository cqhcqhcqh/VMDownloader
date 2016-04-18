//
//  VMVideoResource.h
//  StateMachine
//
//  Created by chengqihan on 16/4/10.
//  Copyright © 2016年 chengqihan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VMVideoResource : NSObject
@property (readwrite, nonatomic, copy) NSString *url;
@property (readwrite, nonatomic, copy) NSString *md5;
@property (readwrite, nonatomic, copy) NSString *title;
- (instancetype)initWithDict:(NSDictionary *)dict;
+ (instancetype)videoResourceWithDict:(NSDictionary *)dict;
@end
