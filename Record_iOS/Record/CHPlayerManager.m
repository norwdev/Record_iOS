//
//  CHPlayerManager.m
//  Record_iOS
//
//  Created by 陈浩 on 16/5/31.
//  Copyright © 2016年 陈浩. All rights reserved.
//

#import "CHPlayerManager.h"
#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>
@interface CHPlayerManager ()<AVAudioPlayerDelegate>
{
    AVAudioPlayer *_audioPlayer;
}
@end
@implementation CHPlayerManager
+ (id)sharedInstance
{
    static CHPlayerManager *sharedInstance  = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[CHPlayerManager alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}
- (void)preparePlayRecord:(NSString *)filePath {
    if (_audioPlayer.isPlaying) {
        [self stopPlaying];
        return ;
    }
    if (filePath && [[NSFileManager defaultManager] fileExistsAtPath:filePath] && [[NSFileManager defaultManager] isReadableFileAtPath:filePath]) {
        [[UIDevice currentDevice] setProximityMonitoringEnabled:YES];//在播放之前设置yes，播放结束设置NO，这个功能是开启红外感应
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(sensorStateChange:)
                                                     name:UIDeviceProximityStateDidChangeNotification
                                                   object:nil];
        
        UInt32 sessionCategory = kAudioSessionCategory_MediaPlayback;
        AudioSessionSetProperty(kAudioSessionProperty_AudioCategory,
                                sizeof(sessionCategory),
                                &sessionCategory);
        
        UInt32 audioRouteOverride = kAudioSessionOverrideAudioRoute_Speaker;
        AudioSessionSetProperty (kAudioSessionProperty_OverrideAudioRoute,
                                 sizeof (audioRouteOverride),
                                 &audioRouteOverride);
        
        AVAudioSession *audioSession = [AVAudioSession sharedInstance];
        //默认情况下扬声器播放
        [audioSession setCategory:AVAudioSessionCategoryPlayback error:nil];
        [audioSession setActive:YES error:nil];
        
        NSURL *playerUrl = [[NSURL alloc] initFileURLWithPath:filePath];
        NSError *error = nil;
        _audioPlayer = [[AVAudioPlayer alloc]initWithContentsOfURL:playerUrl error:&error];
        [_audioPlayer prepareToPlay];
        _audioPlayer.volume = 1.0f;
        _audioPlayer.delegate = self;
    }
}
- (double)getRecordTime {
    if (!_audioPlayer) {
        return 0.0;
    }
    return _audioPlayer.duration;
}
- (void)startPlay
{
    [_audioPlayer play];
}
-(void)sensorStateChange:(NSNotificationCenter *)notification;
{
    //如果此时手机靠近面部放在耳朵旁，那么声音将通过听筒输出，并将屏幕变暗（省电啊）
    if ([[UIDevice currentDevice] proximityState] == YES)
    {
        NSLog(@"Device is close to user");
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
        
    }
    else
    {
        NSLog(@"Device is not close to user");
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    }
}
- (BOOL)isPlaying {
    if (!_audioPlayer) {
        return NO;
    }
    return _audioPlayer.isPlaying;
}
- (void)stopPlaying {
    [_audioPlayer stop];
    [[UIDevice currentDevice] setProximityMonitoringEnabled:NO];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceProximityStateDidChangeNotification object:nil];
    _audioPlayer.delegate = nil;
    _audioPlayer = nil;
}

- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error {
    [self stopPlaying];
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    [self stopPlaying];
}

@end
