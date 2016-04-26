//
//  VMViewController.m
//  StateMachine
//
//  Created by chengqihan on 04/06/2016.
//  Copyright (c) 2016 chengqihan. All rights reserved.
//  dyld: Library not loaded: @rpath

#import "VMViewController.h"
#import "VMVideoResource.h"
#import "VMDownloadTaskTableViewCell.h"
#import "VMMoviePlayerViewController.h"
#import "UIAlertView+Blocks.h"

@import Downloader;
@interface VMViewController ()<UITableViewDelegate,UITableViewDataSource,UIActionSheetDelegate>
@property (readwrite, nonatomic, strong) VMDownloaderManager *manager;
@property (weak, nonatomic) IBOutlet UITableView *downloadTableView;
@property (weak, nonatomic) IBOutlet UITableView *resourceTableView;
@property (weak, nonatomic) IBOutlet UISwitch *mobileSwith;
@property (readwrite, nonatomic, strong) NSArray *orders;
@property (readwrite, nonatomic, assign) NSInteger selectedRow;
@property (readwrite, nonatomic, strong) NSMutableArray *videoResources;
@property (readwrite, nonatomic, strong) NSMutableArray *downloadTasks;
@end

@implementation VMViewController

- (NSMutableArray *)videoResources
{
    if (!_videoResources) {
        _videoResources = [NSMutableArray array];
    }
    return _videoResources;
}

- (IBAction)getCorrectMD5ResourceList:(UIButton *)sender {
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:@"http://service.cc.vmovier.com/Magicapi/Test/testForYe_movier"]];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse * _Nullable response, NSData * _Nullable data, NSError * _Nullable connectionError) {
        id object = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
        [self.videoResources removeAllObjects];
        for (NSDictionary *dict in object) {
            VMVideoResource *resource = [VMVideoResource videoResourceWithDict:dict];
            [self.videoResources addObject:resource];
            [self.resourceTableView reloadData];
        }
    }];
}

- (IBAction)getErrorMD5ResourceList:(UIButton *)sender {
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:@"http://service.cc.vmovier.com/Magicapi/Test/testForYe_movier?errorMd5=1"]];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse * _Nullable response, NSData * _Nullable data, NSError * _Nullable connectionError) {
        id object = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
        [self.videoResources removeAllObjects];
        for (NSDictionary *dict in object) {
            VMVideoResource *resource = [VMVideoResource videoResourceWithDict:dict];
            [self.videoResources addObject:resource];
            [self.resourceTableView reloadData];
        }
    }];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [CPNotificationManager registerWithObserver:self name:kMessageTypeEventProgress selector:@selector(progressChange:)];
    [CPNotificationManager registerWithObserver:self name:kDownloadStateChange selector:@selector(downloadStateChange:)];
    [CPNotificationManager registerWithObserver:self name:kDownloadNetworkNotPermission selector:@selector(networkNotPermission:)];
}


- (void)networkNotPermission:(NSNotification *)note{
    CPNoteMessage *msg = note.object;
    if(msg.type == MessageTypeActionStart) {
        [UIAlertView showWithTitle:@"提示" message:@"网络状态不允许,是否打开3/4G网络开关?" cancelButtonTitle:@"取消" otherButtonTitles:@[@"确定"] tapBlock:^(UIAlertView * _Nonnull alertView, NSInteger buttonIndex) {
            if (buttonIndex == 1) {
                VMDownloadTask *task = msg.obj;
                if ([self.downloadTasks containsObject:task]) {
                    task.allowMobileNetWork = YES;
                    if (!self.mobileSwith.isOn) {
                        self.mobileSwith.on = YES;
                        [self swithChange:self.mobileSwith];
                    }
                    NSInteger row = [self.downloadTasks indexOfObject:task];
                    [self.downloadTableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:row inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
                }
            }
        }];
    }
}

- (IBAction)swithChange:(UISwitch *)sender {
    NSLog(@"swithChange %@",sender.isOn?@"开":@"关");
    [self.manager.downloadConfig setAllowMobileNetwork:sender.isOn];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [CPNotificationManager removeRegisterWithObserver:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.manager = [VMDownloaderManager managerWithIdentifier:@"downloader"];
    self.downloadTasks = [[DownloaderDao recoverTasksWithThread:_manager.downloadTaskRunLoopThread key:_manager.downloadConfig.identifier miniState:0] mutableCopy];
    [self.downloadTableView reloadData];
}


- (void)progressChange:(NSNotification *)note
{
    NSLog(@"obj:%@ userInfo:%@",[(CPNoteMessage *)note.object obj],note.userInfo);
    VMDownloadTask *task = [(CPNoteMessage *)note.object obj];
    if ([self.downloadTasks containsObject:task]) {
        NSInteger row = [self.downloadTasks indexOfObject:task];
        [self.downloadTableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:row inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

- (void)downloadStateChange:(NSNotification *)note {
    VMDownloadTask *task = [(CPNoteMessage *)note.object obj];
    if ([self.downloadTasks containsObject:task]) {
        NSInteger row = [self.downloadTasks indexOfObject:task];
        [self.downloadTableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:row inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == self.resourceTableView) {
        return self.videoResources.count;
    }else if (tableView == self.downloadTableView) {
        return self.downloadTasks.count;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    if (tableView == self.resourceTableView) {
        static NSString *ID = @"ID";
        cell = [tableView dequeueReusableCellWithIdentifier:ID];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ID];
        }
        VMVideoResource *resource = self.videoResources[indexPath.row];
        cell.textLabel.adjustsFontSizeToFitWidth = YES;
        cell.textLabel.text = resource.title;
        cell.detailTextLabel.text = resource.url;
    }else if (tableView == self.downloadTableView) {
        
        static NSString *ID = @"DownloadCell";
        cell = [tableView dequeueReusableCellWithIdentifier:ID forIndexPath:indexPath];
        VMDownloadTaskTableViewCell *downloadCell = (VMDownloadTaskTableViewCell*)cell;
        VMDownloadTask *task = self.downloadTasks[indexPath.row];
        downloadCell.task = task;
    }
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (tableView == self.resourceTableView) {
        VMVideoResource *resource = self.videoResources[indexPath.row];
        VMDownloadRequest *request = [[VMDownloadRequest alloc] init];
        request.url = resource.url;
        request.encriptDescription = @"MD5";
        request.destinationFilePath = resource.url.lastPathComponent;
        request.title = resource.title;
        request.MD5Value = resource.md5;
        
        for (VMDownloadTask *aTask in self.downloadTasks) {
            if([aTask.filePath isEqualToString:[resource.url lastPathComponent]]) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"文件已经在下载列表中" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
                [alert show];
                return;
            }
        }
        VMDownloadTask *task = [self.manager enqueueWithRequest:request];
        [self.downloadTasks addObject:task];
        [self.downloadTableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:self.downloadTasks.count-1 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
        
    }else if (tableView == self.downloadTableView) {
        VMDownloadTask *task = self.downloadTasks[indexPath.row];
        if (task.mState == DownloadTaskStateOngoing || task.mState == DownloadTaskStateWaiting) {
            [task pauseTask];
        }else if (task.mState == DownloadTaskStatePaused || task.mState == DownloadTaskStateRetry || task.mState == DownloadTaskStateIOError) {
            [task resumeTask];
        }else if (task.mState == DownloadTaskStateSuccess) {
            
            NSURL *fileUrl = [NSURL fileURLWithPath:[[task fileDir] stringByAppendingPathComponent:task.filePath]];
            VMMoviePlayerViewController *playerVc = [[VMMoviePlayerViewController alloc] initWithContentURL:fileUrl];
            [self presentMoviePlayerViewControllerAnimated:playerVc];
        }
    }
}

- (void)updateCell:(VMDownloadTaskTableViewCell *)cell {
    
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.downloadTableView) {
        
        return YES;
    }
    return NO;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == self.downloadTableView) {
        if (editingStyle == UITableViewCellEditingStyleDelete) {
            //        UIActionSheet *actionsheet = [[UIActionSheet alloc] initWithTitle:@"是否删除任务对应的文件" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"删除" otherButtonTitles:nil];
            //        [actionsheet showInView:self.view];
            VMDownloadTask *task = self.downloadTasks[indexPath.row];
            [UIAlertView showWithTitle:@"提示" message:@"是否删除任务对应的文件" cancelButtonTitle:@"取消" otherButtonTitles:@[@"确定"] tapBlock:^(UIAlertView * _Nonnull alertView, NSInteger buttonIndex) {
                NSLog(@"buttonIndex %zd",buttonIndex);
                if (1 == buttonIndex) {
                    [task deleteTaskIncludeFile:YES];
                }else {
                    [task deleteTaskIncludeFile:NO];
                }
                [self.downloadTasks removeObject:task];
                [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            }];
        }
    }
}

//- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
//    
//}
@end
