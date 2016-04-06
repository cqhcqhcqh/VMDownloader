//
//  VMAppDelegate.m
//  Downloader
//
//  Created by chengqihan on 04/04/2016.
//  Copyright (c) 2016 chengqihan. All rights reserved.
//

#import "VMAppDelegate.h"

@interface Person: NSObject<NSCoding>
@property (readwrite, nonatomic, copy) NSString *name;
@end
@implementation Person

@end
@import Downloader;

@implementation VMAppDelegate
- (void)userDefaultsDidChange:(NSNotification *)note
{
    
}
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
//    VMSharedPreferences *pf = [VMSharedPreferences sharedPreferencesWithIdentifier:@"qihan"];
//    [pf setInteger:22 forKey:@"he22"];
//    [pf synchronize];
//    
//    NSLog(@"%zd",[pf integerForKey:@"hehe233"]);
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDefaultsDidChange:) name:NSUserDefaultsDidChangeNotification object:nil];
    [[NSUserDefaults standardUserDefaults] setObject:@"nihao" forKey:@"myKey"];
    /*
    NSString *filePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"preference.plist"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        [[NSFileManager defaultManager] createFileAtPath:filePath contents:nil attributes:nil];
    }
    [@"heh" writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
    [@[@1,@2,@3] writeToFile:filePath atomically:YES];
    [@{@"key":@"value"} writeToFile:filePath atomically:YES];
//    Person *p = [Person new];
//    p.name = @"qihan";
//    
//    [[NSUserDefaults standardUserDefaults] setObject:@[p] forKey:@"qihan"];
    
//    [NSKeyedArchiver archiveRootObject:<#(nonnull id)#> toFile:<#(nonnull NSString *)#>]
     */
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
