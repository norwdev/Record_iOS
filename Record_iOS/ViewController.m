//
//  ViewController.m
//  Record_iOS
//
//  Created by 陈浩 on 16/5/31.
//  Copyright © 2016年 陈浩. All rights reserved.
//

#import "ViewController.h"
#import "CHRecordManager.h"
#import "CHPlayerManager.h"
#import "CHRecordButton.h"
#import "CHRecordView.h"

@interface ViewController ()<CHRecordButtonDelegate,CHRecordManagerDelegate>
@property (weak, nonatomic) IBOutlet UILabel *recordPath;
@property (weak, nonatomic) IBOutlet UIButton *playRecord;
@property (weak, nonatomic) IBOutlet UISegmentedControl *recordType;

@property (strong, nonatomic) CHRecordButton *recordButton;
@property (nonatomic, strong) CHRecordView *recordView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    CHRecordButton *recordBtn = [CHRecordButton buttonWithType:UIButtonTypeCustom];
    [recordBtn configer];
    recordBtn.frame = CGRectMake(15, self.view.frame.size.height - 45, self.view.frame.size.width - 30, 35);
    recordBtn.delegate = self;
    [self.view addSubview:recordBtn];
    self.recordButton = recordBtn;
}
- (IBAction)playRecord:(id)sender {
    if (![[CHRecordManager sharedInstance] isRecording]) {
        NSString *filePath = [[CHRecordManager sharedInstance] recordPath];
        [[CHPlayerManager sharedInstance] preparePlayRecord:filePath];
        [[CHPlayerManager sharedInstance] startPlay];
    }
}
#pragma mark - record
- (void)startRecord {
    CHRecordManager *manager = [CHRecordManager sharedInstance];
    manager.delegate = self;
    if (![manager isRecording]) {
        manager.recordType = self.recordType.selectedSegmentIndex;
        manager.recordTime = 60;
        [manager prepareRecord];
        [manager startToRecord];
    }
}
- (void)endRecord {
    if ([[CHRecordManager sharedInstance] isRecording]) {
        [[CHRecordManager sharedInstance] stopRecorder];
    }
}

- (void)cancleRecord {
    if ([[CHRecordManager sharedInstance] isRecording]) {
        [[CHRecordManager sharedInstance] cancleRecord];
    }
}
#pragma mark - record delegate
- (void)recordDidStop:(NSString *)recordPath {
    [self didFinishRecoingVoiceAction:self.recordButton];
    [[CHPlayerManager sharedInstance] preparePlayRecord:[[CHRecordManager sharedInstance] recordPath]];
    double time = [[CHPlayerManager sharedInstance] getRecordTime];
    self.recordPath.text = [NSString stringWithFormat:@"录音文件信息: 文件路径 = %@,音频时长 = %.5f",[[CHRecordManager sharedInstance] recordPath],time];
}
- (void)recordError:(NSError *)error {
    [self didCancelRecordingVoiceAction:self.recordButton];
}
- (void)recordPowerForChannel:(double)power {
    if (self.recordView) {
        [self.recordView setVoiceImage:power];
    }
}

#pragma mark - RecordButton delegate
- (void)didStartRecordingVoiceAction:(CHRecordButton *)recordButton
{
    if (!self.recordView) {
        self.recordView = [[CHRecordView alloc] initWithFrame:CGRectMake(self.view.frame.size.width / 2 - 70, self.view.frame.size.height / 2 - 70, 140, 140)];
    }
    if ([self.recordView isKindOfClass:[CHRecordView class]]) {
        [(CHRecordView *)self.recordView recordButtonTouchDown];
    }
    [self startRecord];
}
- (void)didCancelRecordingVoiceAction:(CHRecordButton *)recordButton
{
    if ([self.recordView isKindOfClass:[CHRecordView class]]) {
        [(CHRecordView *)self.recordView recordButtonTouchUpOutside];
    }
    [self.recordView removeFromSuperview];
    self.recordView = nil;
    [self cancleRecord];
}
- (void)didFinishRecoingVoiceAction:(CHRecordButton *)recordButton
{
    if ([self.recordView isKindOfClass:[CHRecordView class]]) {
        [(CHRecordView *)self.recordView recordButtonTouchUpInside];
    }
    [self.recordView removeFromSuperview];
    self.recordView = nil;
    [self endRecord];
}
- (void)didDragOutsideAction:(CHRecordButton *)recordButton
{
    if ([self.recordView isKindOfClass:[CHRecordView class]]) {
        [(CHRecordView *)self.recordView recordButtonDragOutside];
    }
}
- (void)didDragInsideAction:(CHRecordButton *)recordButton
{
    if ([self.recordView isKindOfClass:[CHRecordView class]]) {
        [(CHRecordView *)self.recordView recordButtonDragInside];
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
