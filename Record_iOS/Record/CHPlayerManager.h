//
//  CHPlayerManager.h
//  Record_iOS
//
//  Created by 陈浩 on 16/5/31.
//  Copyright © 2016年 陈浩. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CHPlayerManager : NSObject
@property (nonatomic, strong) NSString *recordPath;
+ (id)sharedInstance;
- (BOOL)isPlaying;
- (void)preparePlayRecord:(NSString *)filePath;
- (void)startPlay;
- (double)getRecordTime;
@end
