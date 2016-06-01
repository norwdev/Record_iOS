//
//  CHRecordButton.h
//  Record_iOS
//
//  Created by 陈浩 on 16/6/1.
//  Copyright © 2016年 陈浩. All rights reserved.
//

#import <UIKit/UIKit.h>
@class CHRecordButton;
@protocol CHRecordButtonDelegate <NSObject>
/**
 *  按下录音按钮开始录音
 */
- (void)didStartRecordingVoiceAction:(CHRecordButton *)recordButton;
/**
 *  手指向上滑动取消录音
 */
- (void)didCancelRecordingVoiceAction:(CHRecordButton *)recordButton;
/**
 *  松开手指完成录音
 */
- (void)didFinishRecoingVoiceAction:(CHRecordButton *)recordButton;
/**
 *  当手指离开按钮的范围内时，主要为了通知外部的HUD
 */
- (void)didDragOutsideAction:(CHRecordButton *)recordButton;
/**
 *  当手指再次进入按钮的范围内时，主要也是为了通知外部的HUD
 */
- (void)didDragInsideAction:(CHRecordButton *)recordButton;
@end
@interface CHRecordButton : UIButton
@property (nonatomic, assign) id<CHRecordButtonDelegate>delegate;
- (void)configer;
@end
