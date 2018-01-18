//
//  Util.h
//  SDRecord
//
//  Created by Stephen on 2018/1/15.
//  Copyright © 2018年 Stephen. All rights reserved.
//

#import <Foundation/Foundation.h>


#define VIEW_CONTROLLER_IN_STORYBOARD(StoryBoardName, ViewControllerName) [[UIStoryboard storyboardWithName:StoryBoardName bundle:nil] instantiateViewControllerWithIdentifier:ViewControllerName]

#define DebugLog(s, ...) NSLog(@"%s(%d): %@", __FUNCTION__, __LINE__, [NSString stringWithFormat:(s), ##__VA_ARGS__])

#define kKeyWindow [UIApplication sharedApplication].keyWindow



#define Rect(x,y,w,h) CGRectMake(x, y, w, h)

#define Size(w,h) CGSizeMake(w, h)

#define FONT(fontSize) [UIFont systemFontOfSize:fontSize]

#define RGBA(r, g, b, a) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a]

#define RGB(r, g, b) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1]

#define MainScreenWidth   [UIScreen mainScreen].bounds.size.width

#define MainScreenHeight  [UIScreen mainScreen].bounds.size.height

#define MainScreenHeight_noNavigat  [UIScreen mainScreen].bounds.size.height - 64


@interface Util : NSObject

@end
