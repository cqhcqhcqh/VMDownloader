//
//  HMMoviePlayerViewController.m
//  01-黑酷
//
//  Created by apple on 14-6-27.
//  Copyright (c) 2014年 heima. All rights reserved.
//

#import "VMMoviePlayerViewController.h"

@interface VMMoviePlayerViewController ()

@end

@implementation VMMoviePlayerViewController
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // 移除程序进入后台的通知
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
}

#pragma mark - 实现这个方法来控制屏幕方向
/**
 *  控制当前控制器支持哪些方向
 *  返回值是UIInterfaceOrientationMask*
 */
- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskLandscape;
}
@end
