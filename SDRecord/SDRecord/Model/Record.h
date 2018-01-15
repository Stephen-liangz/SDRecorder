//
//  Record.h
//  CQJT
//
//  Created by Stephen on 2017/12/25.
//  Copyright © 2017年 YZH. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Record : NSObject<NSCopying>

@property (strong, nonatomic)   NSString    *name;
@property (strong, nonatomic)   NSString    *path;
@property (assign, nonatomic)   NSInteger    duration;

@end
