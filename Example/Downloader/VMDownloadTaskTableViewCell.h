//
//  VMDownloadTaskTableViewCell.h
//  Downloader
//
//  Created by chengqihan on 16/4/19.
//  Copyright © 2016年 chengqihan. All rights reserved.
//

#import <UIKit/UIKit.h>
@import Downloader;

@interface VMDownloadTaskTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *titleView;
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;
@property (weak, nonatomic) IBOutlet UIView *showDownloadView;
@property (weak, nonatomic) IBOutlet UILabel *stateLabel;
@property (weak, nonatomic) IBOutlet UILabel *currentDownloadLabel;
@property (weak, nonatomic) IBOutlet UILabel *totalDownloadLabel;
@property (weak, nonatomic) IBOutlet UIView *speedView;
@property (weak, nonatomic) IBOutlet UILabel *speedLabel;
@property (weak, nonatomic) IBOutlet UILabel *percentLabel;

@property (readwrite, nonatomic, strong) VMDownloadTask *task;
@end
