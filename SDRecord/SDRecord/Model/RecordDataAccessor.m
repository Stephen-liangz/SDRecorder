//
//  RecordDataAccessor.m
//  SDRecord
//
//  Created by Stephen on 2017/12/22.
//  Copyright © 2017年 Stephen. All rights reserved.
//

#import "RecordDataAccessor.h"

@implementation RecordDataAccessor

/** 保存录音 */
+ (void)saveRecord:(Record *)record{
    DBRecord *dbRecord = [DBRecord MR_createEntity];
    dbRecord.name = record.name;
    dbRecord.path = record.path;
    dbRecord.duration = @(record.duration);
    
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
}

/** 删除录音 */
+ (void)deleteRecordByName:(NSString *)name{
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K==%@", @"name", name];
    [DBRecord MR_deleteAllMatchingPredicate:predicate];
    
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
    
}

+ (NSMutableArray *)getRecord{
    NSMutableArray *recordArr = [NSMutableArray new];
    NSArray *dbRecordArr = [DBRecord MR_findAll];
    
    
    for (DBRecord* dbrecord in dbRecordArr) {
        Record *record = [Record new];
        record.name = dbrecord.name;
        record.path = dbrecord.path;
        record.duration = [dbrecord.duration intValue];
        
        [recordArr addObject:record];
    }
    
    return recordArr;
}

@end
