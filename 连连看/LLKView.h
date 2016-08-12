//
//  LLKView.h
//  连连看
//
//  Created by lvjiaqi on 16/8/7.
//  Copyright © 2016年 lvjiaqi. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol LLKViewDataSource <NSObject>

-(int)getTypeOfRow:(int)row andCol:(int)col;
-(NSArray *)checkPathOne:(int)point1 andOther:(int)point2;
-(void)endGame;
-(NSArray *)generateNew;
@end

@interface LLKView : UIView

@property (nonatomic,weak) id<LLKViewDataSource> delegate;

-(void)setRow:(int)row andCol:(int)col;

@end
