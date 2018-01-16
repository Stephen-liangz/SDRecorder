//
//  DBRecord.h
//  SDRecord
//
//  Created by Stephen on 2017/12/22.
//  Copyright © 2017年 Stephen. All rights reserved.
//


#import <CoreData/CoreData.h>

@interface DBRecord : NSManagedObject

@property (nullable, nonatomic, retain)   NSString    *name;
@property (nullable, nonatomic, retain)   NSString    *path;
@property (nullable, nonatomic, retain)   NSNumber    *duration;

@end
