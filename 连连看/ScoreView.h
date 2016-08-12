//
//  ScoreView.h
//  连连看
//
//  Created by lvjiaqi on 16/8/11.
//  Copyright © 2016年 lvjiaqi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ScoreView : UIView

@property (nonatomic,assign) int count;
@property (nonatomic,assign) int currentCount;
@property (nonatomic,assign) int score;


-(void)updateProcess:(double)process;
@end
