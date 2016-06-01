//
//  CHRecordView.h
//  Record_iOS
//
//  Created by 陈浩 on 16/6/1.
//  Copyright © 2016年 陈浩. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CHRecordView : UIView
// 录音按钮按下
-(void)recordButtonTouchDown;
// 手指在录音按钮内部时离开
-(void)recordButtonTouchUpInside;
// 手指在录音按钮外部时离开
-(void)recordButtonTouchUpOutside;
// 手指移动到录音按钮内部
-(void)recordButtonDragInside;
// 手指移动到录音按钮外部
-(void)recordButtonDragOutside;
-(void)recordButtonTouchCancle;
-(void)setVoiceImage:(double)voiceSound;
@end
