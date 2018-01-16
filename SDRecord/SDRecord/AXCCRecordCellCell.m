//
//  AXCCRecordCellCell.m
//  SDRecord
//
//  Created by Stephen on 2017/12/22.
//  Copyright © 2017年 Stephen. All rights reserved.
//


#import "AXCCRecordCellCell.h"

@implementation AXCCRecordCellCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (IBAction)tapeSelectAction:(UIButton *)sender {
    sender.selected = !sender.selected;
    if (self.tapeSelectBlock) {
        self.tapeSelectBlock(sender.selected);
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
