//
//  ScoreVC.h
//  连连看
//
//  Created by lvjiaqi on 16/8/11.
//  Copyright © 2016年 lvjiaqi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ViewController.h"

@interface ScoreVC : UIViewController
@property (assign,nonatomic) int score;
@property (nonatomic,weak) ViewController *gameCV;
@end
