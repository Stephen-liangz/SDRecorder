//
//  Record.h
//  SDRecord
//
//  Created by Stephen on 2017/12/22.
//  Copyright © 2017年 Stephen. All rights reserved.
//


#import <Foundation/Foundation.h>

@interface Record : NSObject<NSCopying>

@property (strong, nonatomic)   NSString    *name;
@property (strong, nonatomic)   NSString    *path;
@property (assign, nonatomic)   NSInteger    duration;

@end
