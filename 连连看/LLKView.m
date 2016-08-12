//
//  LLKView.m
//  连连看
//
//  Created by lvjiaqi on 16/8/7.
//  Copyright © 2016年 lvjiaqi. All rights reserved.
//

#define eW 50

#import <QuartzCore/CoreAnimation.h>
#import "LLKView.h"

typedef enum{
    LLKSearchDefault = 1,
    LLKSearchStart = 1<<1,
    LLKSearchDoing = 1<<2,
    LLKSearchRecover = 1<<3,
}LLKSearch;


@interface LLKView()
@property (nonatomic,strong) NSMutableArray<UIImageView *> *eleArr;
@property (nonatomic,assign) int row;
@property (nonatomic,assign) int col;

@property (nonatomic) LLKSearch status;

@property (nonatomic) NSMutableArray<NSNumber *> *eraseCouple;

@property (strong) CAEmitterLayer *heartEmitter;
@property (strong) CAEmitterCell *heartEmitterCell;

@property (strong) CAShapeLayer *linesLayer;

@property NSArray *linePoints;

@property (assign,nonatomic) int score;

@end

@implementation LLKView



-(void)drawRect:(CGRect)rect{
    [super drawRect:rect];
    /*if (_linePoints != nil && _linePoints.count != 0) {
        UIBezierPath *path = [[UIBezierPath alloc] init];
        path.lineWidth = 5;
        [path moveToPoint: [self getRectCenterRow:[_linePoints[0] intValue] Col:[_linePoints[1] intValue]]];
        for (int i = 2;  i < _linePoints.count; i=i+2) {
            [path addLineToPoint: [self getRectCenterRow:[_linePoints[i] intValue] Col:[_linePoints[i+1] intValue]]];
        }
        [[UIColor redColor] setStroke];
        [path stroke];
    }*/
}


-(CGPoint)getRectCenterRow:(int)row Col:(int)col{
    return CGPointMake(col*eW+eW/2, row*eW+eW/2);
}


#pragma mark - GameInitial

-(void)setRow:(int)row andCol:(int)col{
    
    self.backgroundColor = [UIColor clearColor];
    _row = row;
    _col = col;
    self.status = LLKSearchDefault;
    _eraseCouple = [NSMutableArray arrayWithCapacity:2];
    _eleArr = [NSMutableArray arrayWithCapacity:row*col];
    _score = 0;
    for (int i = 0 ; i < row; i++) {
        for (int j = 0 ; j < col; j++) {
            int index = [self.delegate getTypeOfRow:i andCol:j];
            UIImageView *v = [[UIImageView alloc] init];
            v.frame = CGRectMake(j*eW, i*eW, eW, eW);
            if (index != 0) {
                v.image = [UIImage imageNamed:[NSString stringWithFormat:@"yangmi_%d",index]];
            }
            [_eleArr addObject:v];
            [self addSubview:v];
        }
    }
    
    [self createVanishAnimation];
    [self startTheGame];
}



#pragma mark - GameControll

-(void)endTheGame{
    
    for (int i = 0 ; i < _eleArr.count; i++) {
        [[_eleArr  objectAtIndex:i] removeFromSuperview];
    }
    [_eleArr removeAllObjects];
    _row = 0;
    _col = 0;
    [self.delegate endGame];
    
}

-(void)startTheGame{
    
    
    float t= 2-(_score/5)*0.1;
    t = t>0?t:0.5;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(t * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSArray *newCouple= [self.delegate generateNew];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (newCouple.count == 0) {
                [self endTheGame];
            }else{
                
                
                UIImageView *v1 = [_eleArr objectAtIndex:[[newCouple objectAtIndex:0] intValue]];
                UIImageView *v2 = [_eleArr objectAtIndex:[[newCouple objectAtIndex:1] intValue]];
                
                v1.image = [UIImage imageNamed:[NSString stringWithFormat:@"yangmi_%d",[[newCouple objectAtIndex:2] intValue]]];
                v2.image = [UIImage imageNamed:[NSString stringWithFormat:@"yangmi_%d",[[newCouple objectAtIndex:3] intValue]]];
                v1.alpha = 1;
                v2.alpha = 1;

                
                CGPoint v1Center = v1.center;
                CGPoint v2Center = v2.center;
                
                v1.center = CGPointZero;
                v2.center = CGPointZero;
                
                [UIView animateWithDuration:0.5 delay:0 options:nil animations:^{
                    v1.center = v1Center;
                    v2.center = v2Center;
                } completion:^(BOOL finished) {
                    
                }];
                
                [self startTheGame];
                
            }
        });
    });
}




#pragma mark - eraseBehaviour

-(void)setStatus:(LLKSearch)status{
    
    if (status == _status) {
        return;
    }
    switch (status) {
        case LLKSearchDefault:
            @synchronized (self.eraseCouple) {
                [_eraseCouple removeAllObjects];
            }
            break;
        case LLKSearchStart:
            @synchronized (self.eraseCouple) {
                [self focusEleByIndex:[[_eraseCouple objectAtIndex:0] intValue]];
            }
            break;
        case LLKSearchDoing:
            @synchronized (self.eraseCouple) {
                NSArray *points = [self.delegate checkPathOne:[[_eraseCouple objectAtIndex:0] intValue] andOther:[[_eraseCouple objectAtIndex:1] intValue]];
                if (points.count != 0) {
                    [self createLayer:points];
                    [self touchAtPosition:[self getEleCenterFromIndex:[[_eraseCouple objectAtIndex:1] intValue]]];
                    [self removeViewByIndex:[[_eraseCouple objectAtIndex:0] intValue]];
                    [self removeViewByIndex:[[_eraseCouple objectAtIndex:1] intValue]];
                    _score++;
                }else{
                    [self unfocusEleByIndex:[[_eraseCouple objectAtIndex:0] intValue]];
                }
                [_eraseCouple removeAllObjects];
                self.status = LLKSearchDefault;
                return;
            }
            break;
        case LLKSearchRecover:
            status = LLKSearchDefault;
            break;
        default:
            break;
    }
    _status = status;
    
}

-(int)indexFrom:(int)row and:(int)col{
      return row*_col + col;
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
    UITouch *t = [touches anyObject];
    CGPoint p = [t locationInView:self];
    int col = p.x/eW;
    int row = p.y/eW;
    
    int q = [self.delegate getTypeOfRow:row andCol:col];
    if ( q != 0 ) {
        @synchronized (self.eraseCouple) {
            [_eraseCouple addObject:[NSNumber numberWithInt:[self indexFrom:row and:col]]];
        }
        self.status = _status<<1;
    }
    
}


-(void)focusEleByIndex:(int)index{
    UIView *v = [_eleArr objectAtIndex:index];
    v.alpha = 0.5;
}
-(void)unfocusEleByIndex:(int)index{
    UIView *v = [_eleArr objectAtIndex:index];
    v.alpha = 1;
}
-(void)focusEle:(int )row and:(int)col{
    [self focusEleByIndex:row*_col + col];
}
-(void)unfocusEle:(int )row and:(int)col{
    [self unfocusEleByIndex:row*_col + col];
}

-(void)removeViewByIndex:(int)index{
    UIImageView *v = [self.eleArr objectAtIndex:index];
    v.alpha = 0;
}

-(CGPoint)getEleCenterRow:(int)i andCol:(int)j{
    int index = i*_col+j;
    UIImageView *v = [self.eleArr objectAtIndex:index];
    return v.center;
}
-(CGPoint)getEleCenterFromIndex:(int)x{
    return [self getEleCenterRow:x/_col andCol:x%_col];
}




#pragma mark - element animation

-(void)createVanishAnimation{

    //Configure the particle emitter to the top edge of the screen
    CAEmitterLayer *snowEmitter = [CAEmitterLayer layer];
    snowEmitter.emitterPosition = CGPointMake(self.bounds.size.width/2.0, self.bounds.size.height/2.0);
    snowEmitter.emitterSize		= CGSizeMake(20, 20);;
    
    // Spawn points for the flakes are within on the outline of the line
    
    snowEmitter.emitterMode		= kCAEmitterLayerOutline; //发射区模式 kCAEmitterLayerOutline：按照发射区形状轮廓发射(circle则是)
    snowEmitter.emitterShape	= kCAEmitterLayerCircle; //发射区的形状
    snowEmitter.renderMode		= kCAEmitterLayerAdditive;
    // Configure the snowflake emitter cell
    CAEmitterCell *snowflake = [CAEmitterCell emitterCell];
    
    
#pragma mark - Setting Emitter Cell Visual Attributes
    
    snowflake.contents		= (id) [[UIImage imageNamed:@"DazHeart"] CGImage];
    snowflake.color			= [[UIColor colorWithRed:0.5 green:0.0 blue:0.5 alpha:0.5] CGColor];
    snowflake.scale = 0.3;
    //snowflake.scaleRange = 0.5;
    snowflake.name = @"snowflake";
#pragma mark - Emitter Cell Motion Attributes
    
    snowflake.spin = 0;
    snowflake.spinRange	= 1 * M_PI;		// slow spin
    //snowflake.emissionLatitude = 10;        //发射的z轴方向
    //snowflake.emissionLongitude = 0 * M_PI; //发射的xy方向
    //snowflake.emissionRange = 0.2 * M_PI;
    
    
#pragma mark - Emission Cell Temporal Attributes
    
    snowflake.lifetime	= 2;
    // If the lifetimeRange is 3 seconds, and the lifetime of the cell is 10 seconds, the cell’s actual lifetime will be between 7 and 13 seconds.
    //snowflake.lifetimeRange = 100;
    
    //The number of emitted objects created every second. Animatable
    snowflake.birthRate	= 0;
    
    snowflake.scaleSpeed = 0.2;
    
    snowflake.velocity = 5;				// falling down slowly
    snowflake.velocityRange = 30;
    
    snowflake.alphaSpeed = -0.2;
    //snowflake.yAcceleration = 1;
    //snowflake.xAcceleration = 0;
    //snowflake.zAcceleration = 0;
    
    
    // Make the flakes seem inset in the background
    //snowEmitter.shadowOpacity = 1.0;
    //snowEmitter.shadowRadius  = 0.0;
    //snowEmitter.shadowOffset  = CGSizeMake(0.0, 1.0);
    //snowEmitter.shadowColor   = [[UIColor whiteColor] CGColor];

    // Add everything to our backing layer below the UIContol defined in the storyboard
    snowEmitter.emitterCells = [NSArray arrayWithObject:snowflake];
    [self.layer insertSublayer:snowEmitter atIndex:(int)self.layer.sublayers.count];
    _heartEmitter = snowEmitter;
    _heartEmitterCell = snowflake;
    
}

- (void) touchAtPosition:(CGPoint)position
{
    //Bling bling..
    CABasicAnimation *burst = [CABasicAnimation animationWithKeyPath:@"emitterCells.snowflake.birthRate"];
    burst.fromValue			= [NSNumber numberWithFloat: 10.0];	// short but intense burst
    burst.toValue			= [NSNumber numberWithFloat: 0.0];		// each birth creates 20 aditional cells!
    burst.duration			= 0.4;
    burst.timingFunction	= [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    [self.heartEmitter addAnimation:burst forKey:@"burst"];
    
    [CATransaction begin];
    [CATransaction setDisableActions: YES];
    self.heartEmitter.emitterPosition = position;
    [CATransaction commit];
    
}


#pragma mark - lines animation

-(void)createLayer:(NSArray *)points{
    
    CAShapeLayer *lineLayer = [CAShapeLayer layer];
    lineLayer.frame = self.bounds;
    
    UIBezierPath *path = [[UIBezierPath alloc] init];
    [path moveToPoint: [self getEleCenterFromIndex:[[points objectAtIndex:0] intValue]]];
    for (int i = 1;  i < points.count; i++) {
        [path addLineToPoint: [self getEleCenterFromIndex:[[points objectAtIndex:i] intValue]]];
    }
   
    lineLayer.path = path.CGPath;
    lineLayer.strokeColor = [UIColor colorWithRed:254.0/256 green:189.0/256 blue:206.0/256 alpha:1].CGColor;
    lineLayer.fillColor     = [UIColor clearColor].CGColor;   // 闭环填充的颜色
    lineLayer.lineCap       = kCALineCapSquare;               // 边缘线的类型                  // 从贝塞尔曲线获取到形状
    lineLayer.lineWidth     = 5.0f;                           // 线条宽度
    lineLayer.strokeStart   = 0.0f;
    lineLayer.strokeEnd     = 1.f;
    lineLayer.opaque = 0;
    
    [self.layer insertSublayer:lineLayer atIndex:(int)self.layer.sublayers.count];
    
    CABasicAnimation *pathAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    CAKeyframeAnimation *vanishAnimation = [CAKeyframeAnimation animationWithKeyPath:@"opacity"];
    
    pathAnimation.duration = 0.3;
    pathAnimation.fromValue = [NSNumber numberWithFloat:0.0f];
    pathAnimation.toValue = [NSNumber numberWithFloat:1.0f];
    pathAnimation.delegate = self;
    pathAnimation.removedOnCompletion = NO;
    pathAnimation.fillMode = kCAFillModeForwards;
    
    vanishAnimation.duration = 0.5 ;
    vanishAnimation.keyTimes = @[@0,@0.5,@1];
    vanishAnimation.values = @[@1,@1,@0];
    vanishAnimation.delegate = self;
    vanishAnimation.fillMode = kCAFillModeForwards;
    vanishAnimation.removedOnCompletion = NO;
    [vanishAnimation setValue:@"lineLayerStrokeEnd" forKey:@"pathAnimation"];
    
    [lineLayer addAnimation:pathAnimation forKey:@"lineLayerStrokeEnd"];
    [lineLayer addAnimation:vanishAnimation forKey:@"vanishAnimation"];
    
    _linesLayer= lineLayer;
    
}

-(void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag{
    if ([[anim valueForKey:@"pathAnimation"] isEqualToString:@"lineLayerStrokeEnd"]) {
           [_linesLayer removeFromSuperlayer];
    }
}

@end
