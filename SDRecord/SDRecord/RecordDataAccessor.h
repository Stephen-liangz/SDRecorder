//
//  RecordDataAccessor.h
//  SDRecord
//
//  Created by Stephen on 2018/1/15.
//  Copyright © 2018年 Stephen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Record.h"

@interface RecordDataAccessor : NSObject

+ (void)configRecordDataAccessor;

//保存录音
+ (void)saveRecord:(Record *)record;
//获取录音
+ (NSMutableArray *)getAllRecord;
//删除所有录音
+ (void)deleteAllRecord;

@end
