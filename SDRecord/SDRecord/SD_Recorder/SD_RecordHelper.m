//
//  SD_RecordHelper.m
//  SDRecord
//
//  Created by Stephen on 2017/12/22.
//  Copyright © 2017年 Stephen. All rights reserved.
//

#import "SD_RecordHelper.h"
#import <AVFoundation/AVFoundation.h>
#import "Record.h"

#import "RecordDataAccessor.h"

#define kRecordAudioFile @"myRecord.caf"

#define kRecordDuration 15

@interface SD_RecordHelper ()<AVAudioRecorderDelegate>
{
    
    ///录音时长
//    NSInteger _recordTimeIndex;
    ///录音地址
    NSString *_recordPath;
    
    NSString *_recordName;
    
}

@property (nonatomic,strong) AVAudioRecorder *audioRecorder;//音频录音机
@property (nonatomic,strong) AVAudioPlayer *audioPlayer;//音频播放器，用于播放录音文件

@property (nonatomic,strong) NSTimer *timer;//录音timer
///date格式器
@property (nonatomic, strong) NSDateFormatter *dateFormatter;

@end

static SD_RecordHelper *_SD_RecordHelper = nil;

@implementation SD_RecordHelper

- (instancetype)init
{
    self = [super init];
    if (self) {
        _recordStatus = SD_RHDone;
        _recordName = [self.dateFormatter stringFromDate:[NSDate date]];
        [self setAudioSession];
        [self recordClick];
    }
    return self;
}

+ (instancetype)share{
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _SD_RecordHelper = [[super allocWithZone:NULL] init];
    });
    
    return _SD_RecordHelper;
    
}

+ (id)allocWithZone:(struct _NSZone *)zone {
    return [SD_RecordHelper share];
}

- (id)copyWithZone:(struct _NSZone *)zone {
    return [SD_RecordHelper share];
}

///开始录音
- (void)startRecord{
    _recordStatus = SD_RHRecording;
    
    [self recordClick];
    
}

///暂停录音
- (void)pauseRecord{

    _recordStatus = SD_RHPause;
    
    [self pauseClick];
    
}

///继续录音
- (void)resumeRecord{
    _recordStatus = SD_RHRecording;
    
    [self resumeClick];
}

///停止录音
- (void)finishRecord{
    //设置当前录音状态
    _recordStatus = SD_RHDone;
    
    [self stopClick];
    
    //初始化录音数据
    _recordTimeIndex = 0;
    [_timer invalidate];
    _timer = nil;
}


///开始按钮点击
- (void)recordClick{
    
    [self configAudioRecorder];
    [self.audioRecorder record];//首次使用应用时如果调用record方法会询问用户是否允许使用麦克风
    [self configTimer];
    NSLog(@"录音 == 开始");
}


///暂停按钮点击
- (void)pauseClick {
    if ([self.audioRecorder isRecording]) {
        self.recordStatus = SD_RHPause;
        [self.audioRecorder pause];
        [self.timer setFireDate:[NSDate distantFuture]];
        NSLog(@"录音 == 暂停");
    }

}

///继续按钮点击
- (void)resumeClick{
    [self.audioRecorder record];
    [self.timer setFireDate:[NSDate distantPast]];
    NSLog(@"录音 == 继续");
}

///停止按钮点击
- (void)stopClick{
    [self.audioRecorder stop];
    
    if (_recordTimeIndex > 1) {
        [self saveRecord];
    }
    NSLog(@"录音 == 停止");
}

///保存录音
- (void)saveRecord{
    
    Record *record = [[Record alloc]init];
    record.name = _recordName;
    record.duration = _recordTimeIndex;
    record.path = _recordPath;
    
//#warning 保存录音
    [RecordDataAccessor saveRecord:record];
    
    NSLog(@"录音 == 保存成功");
}


//dateformatter
- (NSDateFormatter *)dateFormatter{
    if (!_dateFormatter) {
        _dateFormatter = [[NSDateFormatter alloc] init] ;
        [_dateFormatter setDateFormat:@"yyyy-MM-dd_HH:mm:ss"]; //大写的 H为24小时制，小写h为12小时制
    }
    return _dateFormatter;
}

/**
 *  timer
 */
- (void)configTimer{
    if (!_timer) {
        _recordTimeIndex = 0;
        _timer = [NSTimer timerWithTimeInterval:1
                                         target:self
                                       selector:@selector(startRecordAction)
                                       userInfo:nil
                                        repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
    }
}

///开始录音的各种操作
- (void)startRecordAction{
    
    NSLog(@"%@", [NSString stringWithFormat:@"录音%ld秒",(long)_recordTimeIndex]);
    
    //传出时间技术
    if (self.SDRecordTimeBlock) {
        self.SDRecordTimeBlock(_recordTimeIndex);
    }
    
    if (_recordTimeIndex < kRecordDuration) {
        self.recordStatus = SD_RHRecording;
        _recordTimeIndex += 1;
    }else{
        [self stopClick];
        _recordTimeIndex = 0;
        _recordName = [self.dateFormatter stringFromDate:[NSDate date]];
        [self recordClick];
    }
}


/**
 *  设置音频会话
 */
-(void)setAudioSession{
    AVAudioSession *audioSession=[AVAudioSession sharedInstance];
    //设置为播放和录音状态，以便可以在录制完之后播放录音
    [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    [audioSession setActive:YES error:nil];
}

///获取录音地址
-(NSURL *)getSavePath{
    _recordPath =[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    _recordPath = [_recordPath stringByAppendingPathComponent:_recordName];
    NSLog(@"录音路径:file path:%@",_recordPath);
    NSURL *url=[NSURL fileURLWithPath:_recordPath];
    return url;
}


///取得录音文件设置
-(NSDictionary *)getAudioSetting{
    NSMutableDictionary *dicM=[NSMutableDictionary dictionary];
    //设置录音格式, iOS录音的格式为PCM格式,可以转换其他的录音格式，具体的Google一下吧
    [dicM setObject:@(kAudioFormatMPEG4AAC) forKey:AVFormatIDKey];
    //设置录音采样率，8000是电话采样率，对于一般录音已经够了
    [dicM setObject:@(8000) forKey:AVSampleRateKey];
    //设置通道,这里采用单声道
    [dicM setObject:@(1) forKey:AVNumberOfChannelsKey];
    //每个采样点位数,分为8、16、24、32
    [dicM setObject:@(8) forKey:AVLinearPCMBitDepthKey];
    //是否使用浮点数采样
    [dicM setObject:@(YES) forKey:AVLinearPCMIsFloatKey];
    //....其他设置等
    return dicM;
}


///获得录音机对象
-(AVAudioRecorder*)audioRecorder{
    if (!_audioRecorder) {
        //创建录音文件保存路径
        NSURL *url=[self getSavePath];
        //创建录音格式设置
        NSDictionary *setting=[self getAudioSetting];
        //创建录音机
        NSError *error=nil;
        _audioRecorder=[[AVAudioRecorder alloc]initWithURL:url settings:setting error:&error];
        _audioRecorder.delegate=self;
        _audioRecorder.meteringEnabled=YES;//如果要监控声波则必须设置为YES
        if (error) {
            NSLog(@"创建录音机对象时发生错误，错误信息：%@",error.localizedDescription);
            return nil;
        }
    }
    return _audioRecorder;
}


///配置录音机
-(void)configAudioRecorder{
    
    //创建录音文件保存路径
    NSURL *url=[self getSavePath];
    //创建录音格式设置
    NSDictionary *setting=[self getAudioSetting];
    //创建录音机
    NSError *error=nil;
    _audioRecorder=[[AVAudioRecorder alloc]initWithURL:url settings:setting error:&error];
    _audioRecorder.delegate=self;
    _audioRecorder.meteringEnabled=YES;//如果要监控声波则必须设置为YES
    if (error) {
        NSLog(@"创建录音机对象时发生错误,错误信息：%@",error.localizedDescription);
    }
    
}

#pragma mark - 录音机代理方法
/**
 *  录音完成
 */
-(void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag{

    ///录音完成
    if (self.SDRecordDoneBlock) {
        self.SDRecordDoneBlock();
    }
    NSLog(@"录音完成!");
}

///获取播放器
-(AVAudioPlayer *)audioPlayer{
    if (!_audioPlayer) {
        NSURL *url=[self getSavePath];
        NSError *error=nil;
        _audioPlayer=[[AVAudioPlayer alloc]initWithContentsOfURL:url error:&error];
        _audioPlayer.numberOfLoops=0;
        [_audioPlayer prepareToPlay];
        if (error) {
            NSLog(@"创建播放器过程中发生错误,错误信息：%@",error.localizedDescription);
            return nil;
        }
    }
    return _audioPlayer;
}

///播放录音
- (void)playRecord:(NSString *)path{
    NSURL *url=[NSURL fileURLWithPath:path];
    NSError *error=nil;
    
    self.audioPlayer = [[AVAudioPlayer alloc]initWithContentsOfURL:url error:&error];
    self.audioPlayer.numberOfLoops=0;
    [self.audioPlayer prepareToPlay];
    if (error) {
        NSLog(@"创建播放器过程中发生错误,错误信息：%@",error.localizedDescription);
    }
    [self.audioPlayer play];
}


@end
