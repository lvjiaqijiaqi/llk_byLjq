//
//  ScoreVC.m
//  连连看
//
//  Created by lvjiaqi on 16/8/11.
//  Copyright © 2016年 lvjiaqi. All rights reserved.
//

#import "ScoreVC.h"

@interface ScoreVC()
@property (strong, nonatomic) IBOutlet UILabel *scoreView;
@end

@implementation ScoreVC

-(void)viewWillAppear:(BOOL)animated{
    self.scoreView.text = [NSString stringWithFormat:@"%d",(_score*100)];
}

- (IBAction)backToGame:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{
        [_gameCV startGame];
    }];
}




@end
