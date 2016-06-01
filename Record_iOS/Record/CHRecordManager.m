//
//  CHRecordManager.m
//  Record_iOS
//
//  Created by 陈浩 on 16/5/31.
//  Copyright © 2016年 陈浩. All rights reserved.
//

#import "CHRecordManager.h"
#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>
@interface CHRecordManager()<AVAudioRecorderDelegate>
{
    AVAudioRecorder *_recorder;
    NSTimer *_timerRec;
}

@end

@implementation CHRecordManager
+ (id)sharedInstance
{
    static CHRecordManager *sharedInstance  = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[CHRecordManager alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
    }
    return self;
}
- (NSString *)dateToLongInt;
{
    NSString *returnStr = @"";
    NSString *longint = [NSString stringWithFormat:@"%.5f",[[NSDate date] timeIntervalSince1970]];
    NSRange range = [longint rangeOfString:@"."];
    if (range.location != NSNotFound) {
        returnStr = [longint substringToIndex:range.location];
        returnStr = [returnStr stringByAppendingString:[longint substringFromIndex:range.location + 1]];
    }
    if (returnStr.length) {
        return returnStr;
    }
    else
    {
        return longint;
    }
}
- (void)prepareRecord {
    
    if (_recorder.isRecording) {
        NSLog(@"正在录音");
        return ;
    }
    
    if (self.recordPath == nil) {
        NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)objectAtIndex:0];
        documentPath = [documentPath stringByAppendingPathComponent:@"Record"];
        self.recordPath = documentPath;
    }
    BOOL isDirectory = NO;
    if ([[NSFileManager defaultManager] fileExistsAtPath:self.recordPath isDirectory:&isDirectory]) {
        if (!isDirectory) {
            [[NSFileManager defaultManager] createDirectoryAtPath:self.recordPath withIntermediateDirectories:YES attributes:nil error:nil];
        }
    } else {
        [[NSFileManager defaultManager] createDirectoryAtPath:self.recordPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    self.recordPath = [self.recordPath stringByAppendingString:[NSString stringWithFormat:@"%@.%@",[self dateToLongInt],self.recordType ? @"caf":@"wav"]];
    NSMutableDictionary *recordSetting = [NSMutableDictionary dictionary];
    if (self.recordType == RecordWav) {
        self.recordPath = [self.recordPath stringByAppendingString:[NSString stringWithFormat:@"%@.wav",[self dateToLongInt]]];
        [recordSetting setObject:[NSNumber numberWithFloat: 8000.0] forKey:AVSampleRateKey];
        [recordSetting setObject:[NSNumber numberWithInt: kAudioFormatLinearPCM] forKey:AVFormatIDKey];
        [recordSetting setObject:[NSNumber numberWithInt:16] forKey:AVLinearPCMBitDepthKey];
        [recordSetting setObject:[NSNumber numberWithInt: 1] forKey:AVNumberOfChannelsKey];
    } else if (self.recordType == RecordCaf) {
        self.recordPath = [self.recordPath stringByAppendingString:[NSString stringWithFormat:@"%@.caf",[self dateToLongInt]]];
        //设置录音格式  AVFormatIDKey==kAudioFormatLinearPCM
        [recordSetting setValue:[NSNumber numberWithInt:kAudioFormatLinearPCM] forKey:AVFormatIDKey];
        //设置录音采样率(Hz) 如：AVSampleRateKey==8000/44100/96000（影响音频的质量）, 采样率必须要设为11025才能使转化成mp3格式后不会失真
        [recordSetting setValue:[NSNumber numberWithFloat:11025.0] forKey:AVSampleRateKey];
        //录音通道数  1 或 2 ，要转换成mp3格式必须为双通道
        [recordSetting setValue:[NSNumber numberWithInt:2] forKey:AVNumberOfChannelsKey];
        //线性采样位数  8、16、24、32
        [recordSetting setValue:[NSNumber numberWithInt:16] forKey:AVLinearPCMBitDepthKey];
        //录音的质量
        [recordSetting setValue:[NSNumber numberWithInt:AVAudioQualityHigh] forKey:AVEncoderAudioQualityKey];
    }
    NSError *error = nil;
    _recorder = [[AVAudioRecorder alloc] initWithURL:[NSURL fileURLWithPath:self.recordPath] settings:recordSetting error:&error];
    if (error) {
        NSLog(@"error:  %@",error);
        if (self.delegate && [self.delegate respondsToSelector:@selector(recordError:)]) {
            [self.delegate recordError:error];
        }
        return ;
    }
    if (self.recordTime > 0) {
        [_recorder recordForDuration:self.recordTime];
    }
    
    _recorder.delegate = self;
    _recorder.meteringEnabled = YES;
    [_recorder prepareToRecord];
}

- (void)startToRecord {
    //开始录音
    [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryPlayAndRecord error:nil];
    [[AVAudioSession sharedInstance] setActive:YES error:nil];
    [_recorder record];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(recordDidStart)]) {
        [self.delegate recordDidStart];
    }
    _timerRec = [NSTimer scheduledTimerWithTimeInterval:0.25 target:self selector:@selector(detectionVoice) userInfo:nil repeats:YES];
}
- (void)stopRecorder
{
    if (_recorder && (_recorder.isRecording == YES)) {
        [_recorder stop];
    }
}

- (BOOL)isRecording {
    if (!_recorder) {
        return NO;
    }
    return _recorder.isRecording;
}
- (void)applicationDidEnterBackground {
    if (_recorder && _recorder.isRecording) {
        [_recorder stop];
    }
}

- (void)cancleRecord {
    if (_recorder && _recorder.isRecording) {
        [_recorder stop];
        [_recorder deleteRecording];
    }
}
#pragma Mark - timerAction
- (void)detectionVoice {
    [_recorder updateMeters];//刷新音量数据
    //获取音量的平均值  [recorder averagePowerForChannel:0];
    //音量的最大值  [recorder peakPowerForChannel:0];
    
    double lowPassResults = pow(10, (0.05 * [_recorder peakPowerForChannel:0]));
    dispatch_async(dispatch_get_main_queue(), ^{
        if (_delegate && [_delegate respondsToSelector:@selector(recordPowerForChannel:)]) {
            [_delegate recordPowerForChannel:lowPassResults];
        }
    });
    
}
#pragma mark - audioRecorderDelegate
- (void)audioRecorderEncodeErrorDidOccur:(AVAudioRecorder *)recorder error:(NSError *)error {
    if (_timerRec) {
        [_timerRec invalidate];
        _timerRec = nil;
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(recordError:)]) {
        [self.delegate recordError:error];
    }
}

- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag {
    if (_timerRec) {
        [_timerRec invalidate];
        _timerRec = nil;
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(recordDidStop:)]) {
        [self.delegate recordDidStop:self.recordPath];
    }
}
@end
