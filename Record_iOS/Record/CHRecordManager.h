//
//  CHRecordManager.h
//  Record_iOS
//
//  Created by 陈浩 on 16/5/31.
//  Copyright © 2016年 陈浩. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, RecordType) {
    RecordWav = 0,
    RecordCaf
};
@protocol CHRecordManagerDelegate <NSObject>
@optional
- (void)recordDidStart;
- (void)recordDidStop:(NSString *)recordPath;
- (void)recordError:(NSError *)error;
- (void)recordPowerForChannel:(double)power;
@required
@end
@interface CHRecordManager : NSObject
/*
 录音文件保存路径
 */
@property (nonatomic, strong) NSString *recordPath;
/*
 录音时长
 */
@property (nonatomic, assign) NSInteger recordTime;
/*
 音频类型 0:wav  1:caf
 */
@property (nonatomic, assign) RecordType recordType;

@property (nonatomic, assign) id <CHRecordManagerDelegate>delegate;

+ (id)sharedInstance;
- (BOOL)isRecording;
- (void)prepareRecord;
- (void)startToRecord;
- (void)stopRecorder;
- (void)cancleRecord;
@end
