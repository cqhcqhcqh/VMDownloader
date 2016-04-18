//
//  VMSharedPreferences.m
//  Pods
//
//  Created by chengqihan on 16/4/5.
//
//

#import "VMSharedPreferences.h"
#define USERDEFAULT [NSUserDefaults standardUserDefaults]
static NSString *PreferencesDefaultIdentifier = @"preferences";

@interface VMSharedPreferences ()
@property (readwrite, nonatomic, copy) NSString *identifier;
@property (readwrite, nonatomic, strong) NSMutableDictionary *currentDict;
@end

@implementation VMSharedPreferences

- (NSMutableDictionary *)currentDict
{
    if (!_currentDict) {
        _currentDict = [NSMutableDictionary dictionary];
    }
    return _currentDict;
}

#pragma mark - 默认SharedPreferences
+ (instancetype)standardSharedPreferences {
    return [[self alloc] init];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self configureWithIdentifier:PreferencesDefaultIdentifier];
    }
    return self;
}

#pragma mark -  构造方法
+ (instancetype)sharedPreferencesWithIdentifier:(NSString *)identifier
{
    return [[self alloc] initWithIdentifier:identifier];
}

- (instancetype)initWithIdentifier:(NSString *)identifier {
    if (self == [super init]) {
        if (!identifier.length) {
            identifier = PreferencesDefaultIdentifier;
        }
        _identifier = identifier;
        [self configureWithIdentifier:_identifier];
    }
    return self;
}

- (void)configureWithIdentifier:(NSString *)identifier {
    if(![USERDEFAULT objectForKey:identifier]) {
        [USERDEFAULT setObject:self.currentDict forKey:identifier];
        [USERDEFAULT synchronize];
    }
}


- (void)setInteger:(NSInteger)value forKey:(NSString *)key {
    NSMutableDictionary *mdict = [[USERDEFAULT objectForKey:_identifier] mutableCopy];
    [mdict setObject:@(value) forKey:key];
    self.currentDict = mdict;
}

- (NSInteger)integerForKey:(NSString *)key {
    NSDictionary *dict = [USERDEFAULT objectForKey:_identifier];
    return [dict[key] integerValue];
}

- (void)synchronize {
    [USERDEFAULT setObject:self.currentDict forKey:_identifier];
    [USERDEFAULT synchronize];
}

@end
