//
//  VMDownloadTaskTableViewCell.m
//  Downloader
//
//  Created by chengqihan on 16/4/19.
//  Copyright © 2016年 chengqihan. All rights reserved.
//

#import "VMDownloadTaskTableViewCell.h"

@implementation VMDownloadTaskTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.stateLabel.hidden = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
