//
//  CHRecordButton.m
//  Record_iOS
//
//  Created by 陈浩 on 16/6/1.
//  Copyright © 2016年 陈浩. All rights reserved.
//

#import "CHRecordButton.h"


@interface CHRecordButton ()

@end

@implementation CHRecordButton
- (void)configer {
    //录制
    self.titleLabel.font = [UIFont systemFontOfSize:15.0];
    [self setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    [self setBackgroundImage:[[UIImage imageNamed:@"chatBar_recordBg"] stretchableImageWithLeftCapWidth:10 topCapHeight:10] forState:UIControlStateNormal];
    [self setTitle:@"按下开始录音" forState:UIControlStateNormal];
    [self setTitle:@"松开结束录音" forState:UIControlStateHighlighted];
    [self addTarget:self action:@selector(recordButtonTouchDown) forControlEvents:UIControlEventTouchDown];
    [self addTarget:self action:@selector(recordButtonTouchUpOutside) forControlEvents:UIControlEventTouchUpOutside];
    [self addTarget:self action:@selector(recordButtonTouchUpInside) forControlEvents:UIControlEventTouchUpInside];
    [self addTarget:self action:@selector(recordDragOutside) forControlEvents:UIControlEventTouchDragExit];
    [self addTarget:self action:@selector(recordDragInside) forControlEvents:UIControlEventTouchDragEnter];
}

- (void)recordButtonTouchDown
{
    if (_delegate && [_delegate respondsToSelector:@selector(didStartRecordingVoiceAction:)]) {
        [_delegate didStartRecordingVoiceAction:self];
    }
}

- (void)recordButtonTouchUpOutside
{
    if (_delegate && [_delegate respondsToSelector:@selector(didCancelRecordingVoiceAction:)])
    {
        [_delegate didCancelRecordingVoiceAction:self];
    }
}

- (void)recordButtonTouchUpInside
{
    if ([self.delegate respondsToSelector:@selector(didFinishRecoingVoiceAction:)])
    {
        [self.delegate didFinishRecoingVoiceAction:self];
    }
}

- (void)recordDragOutside
{
    if ([self.delegate respondsToSelector:@selector(didDragOutsideAction:)])
    {
        [self.delegate didDragOutsideAction:self];
    }
}

- (void)recordDragInside
{
    if ([self.delegate respondsToSelector:@selector(didDragInsideAction:)])
    {
        [self.delegate didDragInsideAction:self];
    }
}
@end
