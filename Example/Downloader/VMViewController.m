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

@import Downloader;
@interface VMViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (readwrite, nonatomic, strong) VMDownloaderManager *manager;
@property (weak, nonatomic) IBOutlet UITableView *downloadTableView;
@property (weak, nonatomic) IBOutlet UITableView *resourceTableView;

@property (readwrite, nonatomic, strong) NSArray *orders;
@property (readwrite, nonatomic, assign) NSInteger selectedRow;
@property (readwrite, nonatomic, strong) NSMutableArray *videoResources;
@property (readwrite, nonatomic, strong) NSMutableArray *downloadTasks;
@end

@implementation VMViewController
- (NSMutableArray *)downloadTasks
{
    if (!_downloadTasks) {
        _downloadTasks = [NSMutableArray array];
    }
    return _downloadTasks;
}

//- (NSString *)documentFilePath
//{
//    if (!_documentFilePath) {
//        _documentFilePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:[[NSUUID UUID] UUIDString]];
//        NSLog(@"%@",_documentFilePath);
//    }
//    return _documentFilePath;
//}
- (NSMutableArray *)videoResources
{
    if (!_videoResources) {
        _videoResources = [NSMutableArray array];
    }
    return _videoResources;
}

typedef NS_ENUM(NSUInteger, Command) {
    CommandStart = 0,
    CommandPaused,
    CommandRetry,
    CommandDelete
};

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

- (VMDownloaderManager *)manager
{
    if (!_manager) {
        _manager = [VMDownloaderManager managerWithIdentifier:@"downloader"];
    }
    return _manager;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [CPNotificationManager registerWithObserver:self name:kMessageTypeEventProgress selector:@selector(progressChange:)];
}
- (void)progressChange:(NSNotification *)note{
    NSLog(@"obj:%@ userInfo:%@",[(CPNoteMessage *)note.object obj],note.userInfo);
    VMDownloadTask *task = [(CPNoteMessage *)note.object obj];
    NSInteger row = [self.downloadTasks indexOfObject:task];
    [self.downloadTableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:row inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
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
        downloadCell.titleView.text = task.title;
        downloadCell.totalDownloadLabel.text = [NSString stringWithFormat:@"%.2fMB",task.downloadProgress.totalUnitCount/(1024*1024.0)];
        downloadCell.currentDownloadLabel.text = [NSString stringWithFormat:@"%.2fMB",task.downloadProgress.completedUnitCount/(1024*1024.0)];
        downloadCell.progressView.progress = task.downloadProgress.fractionCompleted;
        downloadCell.percentLabel.text = [NSString stringWithFormat:@"%.2f%%",task.downloadProgress.fractionCompleted * 100];
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
        
        VMDownloadTask *tasks = [self.manager enqueueWithRequest:request];
        [self.downloadTasks addObject:tasks];
        [self.downloadTableView reloadData];
        
    }else if (tableView == self.downloadTableView) {
        VMDownloadTask *task = self.downloadTasks[indexPath.row];
        if (task.mState == DownloadTaskStateOngoing) {
            [task pauseTask];
        }else if (task.mState == DownloadTaskStatePaused) {
            [task resumeTask];
        }
    }
    
}

- (void)updateCell:(VMDownloadTaskTableViewCell *)cell {
    
}

@end
