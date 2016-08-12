//
//  ScoreView.m
//  连连看
//
//  Created by lvjiaqi on 16/8/11.
//  Copyright © 2016年 lvjiaqi. All rights reserved.
//

#import "ScoreView.h"

@interface ScoreView()
@property (nonatomic,assign) double process;
@property (nonatomic,strong) UIImageView *desView;
@property (nonatomic,strong) UIImageView *sourView;

@end


@implementation ScoreView


-(void)drawRect:(CGRect)rect{
 
    [super drawRect:rect];
    
    /*CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, 10);
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    //颜色的分量表示
    CGFloat components[] = {1.0, 0.0, 0.0, 1.0, 0.0, 0.0};
    //颜色的位置
    CGFloat locations[] = {0.0,1.0};
    //获得一个CGRect

    CGRect clip = CGRectInset(CGContextGetClipBoundingBox(context), 20.0, 20.0);
    //剪切到合适的大小
    CGContextClipToRect(context, clip);
    
    CGGradientRef gradient = CGGradientCreateWithColorComponents(colorSpace, components, NULL, 3);
    CGColorSpaceRelease(colorSpace);
    //渐变的区域是当前context，垂直于startPoint <-> endPoint线段，并且于这条线段相交的直线
    
    CGContextDrawLinearGradient(context, gradient, CGPointMake(0, 0), CGPointMake(100, 0), 0);
    
    CGGradientRelease(gradient);
    */
    
    
}

-(void)setCurrentCount:(int)currentCount{
    double process = (double)currentCount/_count;
    [self updateProcess:1-process];
    
    _currentCount = currentCount;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        _process = 0.0;
        _desView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.height/2, frame.size.height/2)];
        _sourView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.height/2, frame.size.height/2)];
        [_sourView setCenter:CGPointMake(frame.size.height, frame.size.height/2)];
        [_desView setCenter:CGPointMake(frame.size.width-frame.size.height, frame.size.height/2)];
        
        _desView.image = [UIImage imageNamed:@"ym"];
        _sourView.image = [UIImage imageNamed:@"fsf"];
        _sourView.layer.cornerRadius = _sourView.layer.frame.size.width/2;
        _desView.layer.cornerRadius = _sourView.layer.frame.size.width/2;
        _sourView.layer.masksToBounds = YES;
        _desView.layer.masksToBounds = YES;
        
        [self addSubview:_desView];
        [self addSubview:_sourView];
        
    }
    return self;
}

-(void)updateProcess:(double)process{
    _process = process;
    [_sourView setCenter:CGPointMake(self.frame.size.height+process*(self.frame.size.width-self.frame.size.height*2), self.frame.size.height/2)];
}
@end
