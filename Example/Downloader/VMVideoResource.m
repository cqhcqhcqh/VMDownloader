//
//  VMVideoResource.m
//  StateMachine
//
//  Created by chengqihan on 16/4/10.
//  Copyright © 2016年 chengqihan. All rights reserved.
//

#import "VMVideoResource.h"

@implementation VMVideoResource
- (instancetype)initWithDict:(NSDictionary *)dict {
    if (self == [super init]) {
        [self setValuesForKeysWithDictionary:dict];
    }
    return self;
}
+ (instancetype)videoResourceWithDict:(NSDictionary *)dict {
    return [[self alloc] initWithDict:dict];
}
@end
