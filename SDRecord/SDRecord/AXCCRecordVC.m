//
//  AXCCRecordVC.m
//  CQJT
//
//  Created by 钟亮 on 2017/12/22.
//  Copyright © 2017年 YZH. All rights reserved.
//

#import "AXCCRecordVC.h"
#import "AXCCRecordCellCell.h"

#import "SD_RecordHelper.h"

#import "RecordDataAccessor.h"


@interface AXCCRecordVC ()<UITableViewDelegate, UITableViewDataSource>
{
    ///显示tape image index
    NSInteger _tapeImgIndex;
    NSInteger _recordTimeIndex;

}
@property (strong, nonatomic) IBOutlet UIView *headerView;
@property (strong, nonatomic) IBOutlet UITableView *tableView;

//录音指示
@property (strong, nonatomic) IBOutlet UIImageView *tapeImv;
@property (strong, nonatomic) IBOutlet UILabel *tapeStatusLab;

//进度条 ß
@property (strong, nonatomic) IBOutlet UIView *timeBGView;
@property (strong, nonatomic) IBOutlet UILabel *timerLab;
@property (strong, nonatomic) IBOutlet UIView *progressView;
@property (strong, nonatomic) IBOutlet UIView *progressColorView;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *progressWi;
@property (strong, nonatomic) IBOutlet UIButton *finshBtn;
@property (strong, nonatomic) IBOutlet UIButton *pauseBtn;
///录音动画
@property (strong, nonatomic) NSTimer *recordAnimationTimer;

@property (strong, nonatomic) IBOutlet UIButton *saveBtn;
@property (strong, nonatomic) IBOutlet UIButton *commitBtn;

@property (strong, nonatomic) NSMutableArray *dataArray;

@end

@implementation AXCCRecordVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.dataArray = [NSMutableArray array];
    
    if (self.selectedRecordArray.count == 0) {
        self.selectedRecordArray = [NSMutableArray array];
    }
    
//    self.dataArray = [RecordDataAccessor getAllRecord];
    
    [self.tableView reloadData];

}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self loadUI];
    [self recordProcessAction];
}


- (void)loadUI{
    self.title = @"上传录音";
//    self.view.backgroundColor =
    
    [self setUpRecordView];
    [self setUpTableView];

}


///设置录音界面
- (void)setUpRecordView{
    
    __weak typeof(self) weakSelf = self;
    
    SD_RecordHelper *recordHelper = [SD_RecordHelper share];
    
    recordHelper.SDRecordTimeBlock = ^(NSInteger timeCount) {
        _recordTimeIndex = timeCount;
        [weakSelf recordAnimationAction];
    };
    
    recordHelper.SDRecordDoneBlock = ^{
//        self.dataArray = [RecordDataAccessor getAllRecord];
        
        [self.tableView reloadData];
    };
    
    _tapeImgIndex = recordHelper.recordTimeIndex;
    
    [self setUpRecordViewStatus];
}

///设置录音按钮状态
- (void)setUpRecordViewStatus{
     SD_RecordHelper *recordHelper = [SD_RecordHelper share];
    switch (recordHelper.recordStatus) {
        case SD_RHRecording:
            break;
        case SD_RHPause:
        {
            [self.finshBtn setTitle:@"完成" forState:UIControlStateNormal];
            [self.pauseBtn setTitle:@"继续" forState:UIControlStateNormal];
        }
            break;
        case SD_RHDone:
        {
            [self.finshBtn setTitle:@"开始" forState:UIControlStateNormal];
        }
            break;
            
        default:
            break;
    }
    _recordTimeIndex = recordHelper.recordTimeIndex;
    [self recordProcessAction];
}

- (IBAction)startRecordAction:(UIButton* )sender {
    
    SD_RecordHelper *recordHelper = [SD_RecordHelper share];
    if ([sender.titleLabel.text isEqualToString: @"完成"]) {
        [sender setTitle:@"开始" forState:UIControlStateNormal];
        
        [recordHelper finishRecord];
        
    }else{
        [sender setTitle:@"完成" forState:UIControlStateNormal];
        
        [recordHelper startRecord];
    }
}

- (IBAction)pauseRecordAction:(UIButton *)sender {
    
    SD_RecordHelper *recordHelper = [SD_RecordHelper share];
    if ([sender.titleLabel.text isEqualToString: @"暂停"]) {
        //暂停操作
        [sender setTitle:@"继续" forState:UIControlStateNormal];
        
        [recordHelper pauseRecord];
    }else{
        [sender setTitle:@"暂停" forState:UIControlStateNormal];
         //暂停操作继续操作
        
        [recordHelper resumeRecord];
    }
}

///录音效果动画
- (void)recordAnimationAction{
    if (_tapeImgIndex <3) {
        _tapeImgIndex += 1;
    }else{
        _tapeImgIndex = 1;
    }
    
    [self tapeImvAnimationAction];
    
    if (_recordTimeIndex < 15) {
        _recordTimeIndex += 1;
    }else{
        _recordTimeIndex = 0;
    }
    
    [self recordProcessAction];
}

///录音进度条显示动画
- (void)recordProcessAction{
    self.timerLab.text = [NSString stringWithFormat:@"00:%@",_recordTimeIndex < 10 ? [NSString stringWithFormat:@"0%ld",_recordTimeIndex] : [NSString stringWithFormat:@"%ld",_recordTimeIndex]];

    self.progressWi.constant = (MainScreenWidth - 194.5)/15 * _recordTimeIndex;
    
}

///录音效果图显示动画
- (void)tapeImvAnimationAction{
    
    self.tapeImv.image = [UIImage imageNamed:[NSString stringWithFormat:@"tape%ld",(long)_tapeImgIndex]];
}

- (void)setUpTableView{
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.tableFooterView = [[UIView alloc]init];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}

#pragma mark - tableView delegate datasource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 44;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *identifier=@"tg";
    AXCCRecordCellCell *cell=[tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (cell==nil) {
        cell= [[[NSBundle mainBundle]loadNibNamed:@"AXCCRecordCellCell" owner:nil options:nil] firstObject];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    
    
    cell.tapeSelectBlock = ^(BOOL selected) {
        if (selected) {
            NSLog(@"选中");
            [self selectRecord:indexPath];
        }else{
            NSLog(@"取消选中");
            [self unSelectRecord:indexPath];
        }
    };
    
    Record * record = self.dataArray[indexPath.row];
    
    cell.dateLab.text = record.name;
    cell.timeLab.text = [NSString stringWithFormat:@"%ld",(long)record.duration];
    
    
    ///设置已经选中的文件
    for (Record *ssrecord in _selectedRecordArray) {
        if ([record.name isEqualToString:ssrecord.name] ) {
            [cell.selectedBtn setSelected:YES];
        }
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    SD_RecordHelper *recordHelper = [SD_RecordHelper share];
    Record *record = self.dataArray[indexPath.row];
    [recordHelper playRecord:record.path];
  
}


///选中录音
- (void)selectRecord:(NSIndexPath *)indexPath{
    
    ///传出选中录音
    if (self.recordSelectBlock) {
        [_selectedRecordArray addObject:self.dataArray[indexPath.row]];
        
        self.recordSelectBlock(_selectedRecordArray);
    }
}
///取消选中录音
- (void)unSelectRecord:(NSIndexPath *)indexPath{

    ///传出选中录音
    if (self.recordSelectBlock) {
        
        Record *seR = self.dataArray[indexPath.row];
        
        NSMutableArray *temp = [NSMutableArray array];
        
        for (Record *record in _selectedRecordArray) {
            if (![seR.name isEqualToString: record.name]) {
                [temp addObject:record];
            }
        }
        
        [_selectedRecordArray removeAllObjects];
        [_selectedRecordArray addObjectsFromArray:temp];
        
        self.recordSelectBlock(_selectedRecordArray);
    }
}

- (IBAction)saveAction:(id)sender {
 
}

- (IBAction)commitAction:(id)sender {
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
