//
//  AXCCRecordVC.h
//  CQJT
//
//  Created by 钟亮 on 2017/12/22.
//  Copyright © 2017年 YZH. All rights reserved.
//

#import "BaseViewController.h"

///录音回调
typedef void(^recordVCSelectBlock)(NSArray*);

@interface AXCCRecordVC : BaseViewController

///选中的录音
@property (strong, nonatomic) NSMutableArray *selectedRecordArray;
///录音选中回调
@property (copy, nonatomic) recordVCSelectBlock recordSelectBlock;

@end
