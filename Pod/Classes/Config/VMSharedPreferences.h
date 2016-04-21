//
//  VMSharedPreferences.h
//  Pods
//
//  Created by chengqihan on 16/4/5.
//
//

#import <Foundation/Foundation.h>

@interface VMSharedPreferences : NSObject

@property (readonly, nonatomic, copy) NSString *identifier;

/**
 *  默认SharedPreferences
 *  在USERDEFAULT中存储一个preferences对应的Dictionary
 *  @return 实例
 */
+ (instancetype)standardSharedPreferences;


/**
 *  构造方法
 *
 *  @param identifier 唯一身份识别
 *
 *  @return VMSharedPreferences实例
 */
- (instancetype)initWithIdentifier:(NSString *)identifier;

+ (instancetype)sharedPreferencesWithIdentifier:(NSString *)identifier;

/**
 *  类似于USERDEFAULT的方法
 *  还可以继续向外提供
 */

- (void)setInteger:(NSInteger)value forKey:(NSString *)key;
- (NSInteger)integerForKey:(NSString *)key;
- (void)synchronize;
@end
