//
//  RecordDataAccessor.h
//  SDRecord
//
//  Created by Stephen on 2017/12/22.
//  Copyright © 2017年 Stephen. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <MagicalRecord/MagicalRecord.h>

#import "Record.h"
#import "DBRecord.h"

@interface RecordDataAccessor : NSObject

#pragma mark - 保存/查询
//==========================================================================================================================
/** 保存录音 */
+ (void)saveRecord:(Record *)record;

/** 删除录音 */
+ (void)deleteRecordByName:(NSString *)name;

+ (NSMutableArray *)getRecord;

@end
