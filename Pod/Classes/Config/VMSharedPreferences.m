//
//  VMSharedPreferences.m
//  Pods
//
//  Created by chengqihan on 16/4/5.
//
//

#import "VMSharedPreferences.h"
#define PREFERENCEFILEDERECTORY [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject]
#define FILEMANAGER [NSFileManager defaultManager]
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
        [self initFilePathWithIdentifier:PreferencesDefaultIdentifier];
    }
    return self;
}

- (instancetype)initWithIdentifier:(NSString *)identifier {
    if (self == [super init]) {
        if (!identifier.length) {
            identifier = PreferencesDefaultIdentifier;
        }
        _identifer = identifier;
        [self initFilePathWithIdentifier:_identifer];
    }
    return self;
}

- (void)initFilePathWithIdentifier:(NSString *)identifier {
    if(![USERDEFAULT objectForKey:identifier]) {
        NSString *preferencesFilePath = [[PREFERENCEFILEDERECTORY stringByAppendingPathComponent:identifier] stringByAppendingPathExtension:@"plist"];
        if (![FILEMANAGER fileExistsAtPath:preferencesFilePath]) {
            [FILEMANAGER createFileAtPath:preferencesFilePath contents:nil attributes:nil];
            [self.currentDict writeToFile:preferencesFilePath atomically:YES];
        }
        [USERDEFAULT setValue:preferencesFilePath.lastPathComponent forKey:identifier];
        [USERDEFAULT synchronize];
    }
}

+ (instancetype)sharedPreferencesWithIdentifier:(NSString *)identifier {
    return [[self alloc] initWithIdentifier:identifier];
}


- (void)setInteger:(NSInteger)value forKey:(NSString *)key {
    self.currentDict = [NSMutableDictionary dictionaryWithContentsOfFile:[self preferencesFile]];
    [self.currentDict setValue:@(value) forKey:key];
}

- (NSInteger)integerForKey:(NSString *)key {
    NSDictionary *dict = [NSMutableDictionary dictionaryWithContentsOfFile:[self preferencesFile]];
    return [dict[key] integerValue];
}

- (void)synchronize {
    [self.currentDict writeToFile:[self preferencesFile] atomically:YES];
}

- (NSString *)preferencesFile {
    return [PREFERENCEFILEDERECTORY stringByAppendingPathComponent:[USERDEFAULT objectForKey:_identifer]];
}
@end
