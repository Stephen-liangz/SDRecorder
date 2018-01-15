//
//  RecordDataAccessor.m
//  SDRecord
//
//  Created by Stephen on 2018/1/15.
//  Copyright © 2018年 Stephen. All rights reserved.
//

#import "RecordDataAccessor.h"

#define RecordData @"RecordData"

@implementation RecordDataAccessor

//设置录音存储器，为空添加空数组
+ (void)configRecordDataAccessor{
    if ([RecordDataAccessor getAllRecord] == nil) {
        NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
        [ud setObject:[NSMutableArray array] forKey:RecordData];
        [ud synchronize];
    }
}

//保存录音
+ (void)saveRecord:(Record *)record{
    
    [RecordDataAccessor configRecordDataAccessor];
    
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    
    NSMutableArray *rArray = [RecordDataAccessor getAllRecord];
    
    [rArray addObject:record];
    
    [ud setObject:rArray forKey:RecordData];
    
    [ud synchronize];
    
}
//获取录音
+ (NSMutableArray *)getAllRecord{
    [RecordDataAccessor configRecordDataAccessor];
    
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    
    NSMutableArray *rArray = [ud valueForKey:RecordData];
    
    NSMutableArray *allRecored = [NSMutableArray arrayWithArray:rArray];
    
    return allRecored;
}

//删除所有录音
+ (void)deleteAllRecord{
    [RecordDataAccessor configRecordDataAccessor];
    
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [ud setObject:[NSMutableArray array] forKey:RecordData];
    
    [ud synchronize];
}

@end
