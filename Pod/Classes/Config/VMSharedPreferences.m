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
@property (readwrite, nonatomic, strong) NSString *identifer;
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

- (instancetype)initWithIdentifier:(NSString *)identifier {
    if (self == [super init]) {
        if (!identifier.length) {
            identifier = PreferencesDefaultIdentifier;
        }
        _identifer = identifier;
        [self configureWithIdentifier:_identifer];
    }
    return self;
}

- (void)configureWithIdentifier:(NSString *)identifier {
    if(![USERDEFAULT objectForKey:identifier]) {
        [USERDEFAULT setObject:self.currentDict forKey:identifier];
        [USERDEFAULT synchronize];
    }
}

+ (instancetype)sharedPreferencesWithIdentifier:(NSString *)identifier {
    return [[self alloc] initWithIdentifier:identifier];
}


- (void)setInteger:(NSInteger)value forKey:(NSString *)key {
    self.currentDict = [USERDEFAULT dictionaryForKey:_identifer];
    [self.currentDict setValue:@(value) forKey:key];
}

- (NSInteger)integerForKey:(NSString *)key {
    NSDictionary *dict = [USERDEFAULT dictionaryForKey:_identifer];
    return [dict[key] integerValue];
}

- (void)synchronize {
    [USERDEFAULT synchronize];
}

@end
