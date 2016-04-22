//
//  VMDownloadTaskTableViewCell.m
//  Downloader
//
//  Created by chengqihan on 16/4/19.
//  Copyright © 2016年 chengqihan. All rights reserved.
//

#import "VMDownloadTaskTableViewCell.h"
@import Downloader;
@implementation VMDownloadTaskTableViewCell


- (void)setTask:(VMDownloadTask *)task
{
    _task = task;
    
    self.swithControl.on = task.allowMobileNetWork;
    self.titleView.text = task.title;
    
    self.totalDownloadLabel.text = [NSString stringWithFormat:@"%.2f MB",task.contentLength/(1024*1024.0)];
    self.currentDownloadLabel.text = [NSString stringWithFormat:@"%.2f MB",task.mProgress/(1024*1024.0)];
    if (task.contentLength > 0) {
        self.progressView.progress = task.mProgress*1.0 / task.contentLength;
    }else {
        self.progressView.progress = 0.0f;
    }
    self.percentLabel.text = [NSString stringWithFormat:@"%.2f%%",self.progressView.progress * 100];
    self.speedLabel.text = [NSString stringWithFormat:@"%.2fMB/s",task.mSpeed];
    
    if (task.mState == DownloadTaskStateOngoing) {
        self.speedView.hidden = NO;
        self.stateLabel.hidden = YES;
    }else {
        self.speedView.hidden = YES;
        self.stateLabel.hidden = NO;
    }
    
    switch (task.mState) {
        case DownloadTaskStatePaused:
            self.stateLabel.text = @"暂停";
            break;
        case DownloadTaskStateRetry:
            self.stateLabel.text = [task.error stringByAppendingString:@"点击重试"];
            break;
        case DownloadTaskStateSuccess:
            self.stateLabel.text = @"下载成功";
            break;
        case DownloadTaskStateFailure:
            self.stateLabel.text = @"下载失败(校验失败)";
            break;
        case DownloadTaskStateWaiting:
            self.stateLabel.text = @"等待中";
            break;
        case DownloadTaskStateIOError:
            self.stateLabel.text = @"多次下载失败";
            break;
        default:
            break;
    }
    
}
- (IBAction)swithValueChange:(UISwitch *)sender {
    [self.task setAllowMobileNetWork:sender.isOn];
}

- (void)dealloc
{
    NSLog(@"%@ -- dealloc",NSStringFromClass([self class]));
}
@end
