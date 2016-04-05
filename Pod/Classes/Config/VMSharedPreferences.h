//
//  VMSharedPreferences.h
//  Pods
//
//  Created by chengqihan on 16/4/5.
//
//

#import <Foundation/Foundation.h>

@interface VMSharedPreferences : NSObject
- (instancetype)initWithIdentifier:(NSString *)identifier;
+ (instancetype)standardSharedPreferences;
+ (instancetype)sharedPreferencesWithIdentifier:(NSString *)identifier;
- (void)setInteger:(NSInteger)value forKey:(NSString *)key;
- (NSInteger)integerForKey:(NSString *)key;
- (void)synchronize;
@end
