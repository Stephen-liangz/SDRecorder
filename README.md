https://www.jianshu.com/p/1a9b1435423e

功能描述：
最近，着手的项目里有一个录音15S的需求。

这两天有些空闲时间，于是乎，现在得空封装的一个OC版的录音器。

用单例模式提供一个全局的录音helper，操作录音的开始、完成、暂停、继续功能。

录音完成后，通过MagicalRecord 保存录音对象到数据库。

写了一个简陋的录音场景，有录音进度条，开始、完成、暂停、继续按钮，录音进行时的小动画。

播放录音的场景，现在未能完成，本意是和录音场景用同一个效果来操作播放。

运行效果如下图：
image
使用：
第一次分享，功能没有覆盖得很全面，目前大家可以拿来用的工具，我自以为 SD_RecordHelper 还算能帮助减轻实现录音时的负担。

SD_RecordHelper.h 的功能列表:

#import <Foundation/Foundation.h>
#import "Record.h"

typedef enum : NSUInteger {
    ///正在录音
    SD_RHRecording,
    ///录音完成
    SD_RHDone,
    ///录音暂停
    SD_RHPause,
} SD_RHRecordStatus;

typedef void(^SD_RecordTimeBlock)(NSInteger );
typedef void(^SD_RecordDoneBlock)(void);

@interface SD_RecordHelper : NSObject
///录音时间计数block
@property (copy, nonatomic) SD_RecordTimeBlock SDRecordTimeBlock;
///录音保存成功block
@property (copy, nonatomic) SD_RecordDoneBlock SDRecordDoneBlock;

///录音时长
@property (assign , nonatomic) NSInteger recordTimeIndex;

///当前录音状态
@property (assign , nonatomic) SD_RHRecordStatus recordStatus;

///获取录音helper单例
+ (instancetype)share;

///开始录音
- (void)startRecord;
///暂停录音
- (void)pauseRecord;
///继续录音
- (void)resumeRecord;
//停止录音
- (void)finishRecord;

///播放录音
- (void)playRecord:(NSString *)path;

@end
功能实现：
1. 录音
我们可以引入AVFoundation框架，使用AVAudioRecorder和AVAudioPlayer可以实现语音的录制和播放功能。

我就不太介绍AVAudioRecorder太多的属性配置了，因为我自己也没研究很深（就是不懂~）。我们就先搞定录音吧。

用燕舞录音机、步步高复读机录音的经历，和我差不多大的朋友们应该都有类似经历吧。录音首先需要一个录音设备，在代码中我就需要初始化一个AVAudioRecorder作为我们的录音设备了：

///配置录音机
-(void)configAudioRecorder{
    
    //录音文件保存路径，我设置的路径是当前时间的字符串，注意路径不要有空格
    NSURL *url=[self getSavePath];
    //录音格式设置
    NSDictionary *setting=[self getAudioSetting];
    //录音机
    NSError *error=nil;
    _audioRecorder=[[AVAudioRecorder alloc]initWithURL:url settings:setting error:&error];
    _audioRecorder.delegate=self;
    //这个设置为YES可以做音波的效果，我没有实现音波功能
    _audioRecorder.meteringEnabled=YES;
    if (error) {
        NSLog(@"创建录音机audioRecorder发生错误:%@",error.localizedDescription);
    }
    
}
在设置好录音的属性后，创建好的录音机就可以通过 record 方法开始录音。

[self.audioRecorder record];
通过 pause 方法，暂停录音。

[self.audioRecorder pause];
通过 stop 方法，结束录音。

[self.audioRecorder record];
录音结束时有一个 delegate 方法，获取录音结束相应。我就在这个代理方法里面，通过 Block 处理了录音结束的操作。

-(void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag{

    ///录音完成
    if (self.SDRecordDoneBlock) {
        self.SDRecordDoneBlock();
    }
    NSLog(@"录音完成!");
}


- 进度条变化效果
用一个定长View，和一个不同颜色的View实现，随着时间的推移，将深色View的长度变长来实现的：


- 录音图片变化效果
通过循环三张图片实现的效果。

因为我要实现的功能是开始录制后，每一条录制15S，所以我加了一个
Timer 计数15S，然后停止录音，保存录音，然后开始新的一条录音的录制。

同时这个 Timer 的计数，我通过 Block 传出，然后用Timer的计数做了录音的两个效果：

SD_RecordHelper *recordHelper = [SD_RecordHelper share];
    
    //录音计数回调
    recordHelper.SDRecordTimeBlock = ^(NSInteger timeCount) {
        [self setUpRecordViewStatus];
        _recordTimeIndex = timeCount;
        [weakSelf recordAnimationAction];
    };
    
    //录音结束回调
    recordHelper.SDRecordDoneBlock = ^{
        self.dataArray = [[[RecordDataAccessor getRecord]reverseObjectEnumerator] allObjects];
        
        [self zeroProcessAction];
        
        [self.tableView reloadData];
    };
    
    _tapeImgIndex = recordHelper.recordTimeIndex;
进度条效果：

///录音进度条显示动画
- (void)recordProcessAction{
    self.timerLab.text = [NSString stringWithFormat:@"00:%@",_recordTimeIndex < 10 ? [NSString stringWithFormat:@"0%ld",_recordTimeIndex] : [NSString stringWithFormat:@"%ld",_recordTimeIndex]];

    self.progressWi.constant = (MainScreenWidth - 194.5)/15 * _recordTimeIndex;
    
}
录音图片效果：

///录音效果图显示动画
- (void)tapeImvAnimationAction{
    
    self.tapeImv.image = [UIImage imageNamed:[NSString stringWithFormat:@"tape%ld",(long)_tapeImgIndex]];

    NSString *recordStatusLabStr = @"正在录音中";
    for (int i = 0; i < _tapeImgIndex; i ++) {
        recordStatusLabStr = [NSString stringWithFormat:@"%@.",recordStatusLabStr];
    }
    self.tapeStatusLab.text = recordStatusLabStr;

}
2. MagicalRecord 存取录音
MagicalRecord 是用来操作Core Data的一个第三方工具，使用起来比较方便。理论一点的东西，大家可以深入去研究一下，我这是实现了简单的存取。

MagicalRecord 的基本配置、使用方法，在简书里面就可以找到，我收藏夹里面也有一些写得清晰的简书。

CoreData 会根据数据库表的 Model 生成相应的文件，在 MagicalRecord 中需要 Model 继承于 NSManagedObject 就好了。

我这里有一个普通的 Record Model ，和与之对应的 DBRecord Model。

Record：

@interface Record : NSObject<NSCopying>

@property (strong, nonatomic)   NSString    *name;
@property (strong, nonatomic)   NSString    *path;
@property (assign, nonatomic)   NSInteger    duration;

@end

DBRecord：

@interface DBRecord : NSManagedObject

@property (nullable, nonatomic, retain)   NSString    *name;
@property (nullable, nonatomic, retain)   NSString    *path;
@property (nullable, nonatomic, retain)   NSNumber    *duration;

@end

然后通过 RecordDataAccessor 来操作录音数据得存取：

@interface RecordDataAccessor : NSObject

#pragma mark - 保存/查询
//==========================================================================================================================
/** 保存录音 */
+ (void)saveRecord:(Record *)record;

/** 删除录音 */
+ (void)deleteRecordByName:(NSString *)name;

+ (NSMutableArray *)getRecord;

@end

我这里的删除仅仅是删除了数据库录音的记录，如果你需要 MagicalRecord 在你项目中发挥作用，记得要在删除时，删掉本地的文件。

强行结束：
第一次写分享，发现代码并没有封装得顺手好用，只能算是勉强实现功能。但是这次之后，有了经验下次，应该能做好一点。
