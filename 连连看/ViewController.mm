//
//  ViewController.m
//  连连看
//
//  Created by lvjiaqi on 16/8/6.
//  Copyright © 2016年 lvjiaqi. All rights reserved.
//

#import "ViewController.h"
#import "llk.hpp"
#import "LLKView.h"
#import "ScoreView.h"
#import "ScoreVC.h"
#import <objc/runtime.h>

@interface ViewController ()<LLKViewDataSource>
{
   @private
       llk *myllk;
}
@property (nonatomic,strong) NSMutableArray *eleArr;
@property (nonatomic,strong) LLKView *llkView;
@property (nonatomic,strong) ScoreView *scoreView;
@property (nonatomic,assign) int score ;


@end


@implementation ViewController



+ (void)load
{
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        const char *orignSelName = "dealloc";
        SEL orignSelector = sel_registerName(orignSelName);
        const char *newSelName = "deallocWithC";
        SEL newSelector = sel_registerName(newSelName);
        Method originM = class_getInstanceMethod([self class], orignSelector);
        Method newM = class_getInstanceMethod([self class], newSelector);
        if (class_addMethod([self class], orignSelector, method_getImplementation(newM), method_getTypeEncoding(newM)))
        {
            class_replaceMethod([self class], newSelector, method_getImplementation(originM), method_getTypeEncoding(originM));
        }
        else
        {
            method_exchangeImplementations(originM, newM);
        }
    });
}

-(void)deallocWithC{
    delete myllk;
    [self deallocWithC];
}


- (void)viewDidLoad {
    
    [super viewDidLoad];
    _scoreView = [[ScoreView alloc] initWithFrame:CGRectMake(0, 20, self.view.frame.size.width, 80)];
    _scoreView.count = 10 * 6;
    [self.view addSubview:_scoreView];
    [self startGame];
    
}

-(UIImage *)setBarTranslucent{
    
    UIGraphicsBeginImageContext(CGSizeMake(self.view.bounds.size.width,64));
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [UIColor colorWithRed:0.3 green:0.4 blue:0.1 alpha:0].CGColor);
    CGContextFillRect(context, CGRectMake(0, 0, self.view.bounds.size.width, 64));
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return img;
    
}

-(void)viewDidAppear:(BOOL)animated{
    
    self.navigationController.navigationBar.translucent = YES;
    [self.navigationController.navigationBar setBackgroundImage:[self setBarTranslucent] forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:[[UIImage alloc] init]];
    
}



#pragma mark -  LLKViewDataSource

-(void)startGame{
    _score = 0;
    [self initGame:12 andCol:8 withType:7];
}

-(void)endGame{
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    //由storyboard根据myView的storyBoardID来获取我们要切换的视图
    ScoreVC *scoreVC = [story instantiateViewControllerWithIdentifier:@"ScoreVC"];
    scoreVC.score = _score;
    scoreVC.gameCV = self;
    [self presentViewController:scoreVC animated:YES completion:^{

        [self.llkView removeFromSuperview];
        [self.scoreView setCurrentCount:0];
        delete myllk;
    }];
}

-(void)initGame:(int)row andCol:(int)col withType:(int)type{
    myllk = new llk(row,col,type);
    if (self.llkView) {
        [self.llkView removeFromSuperview];
    }
    self.llkView = [[LLKView alloc] initWithFrame:CGRectMake(0, 0, col*50, row*50)];
    self.llkView.center = CGPointMake(self.view.frame.size.width/2, (self.view.frame.size.height+64)/2);
    self.llkView.delegate = self;
    [self.llkView setRow:row andCol:col];
    [self.view addSubview:self.llkView];
    
}

-(int)getTypeOfRow:(int)row andCol:(int)col{
    return myllk->getQ(row, col);
}

-(NSArray *)checkPathOne:(int)point1 andOther:(int)point2{
    NSMutableArray *points = [NSMutableArray arrayWithCapacity:4];
    list<int> *paths = myllk->startCheckWithIndex(point1,point2);
    if(paths){
        while (!paths->empty()) {
            int x = paths->front();
            [points addObject:[NSNumber numberWithInt:x]];
            paths->pop_front();
        }
        
        delete paths;
        [self.scoreView setCurrentCount:myllk->currentCount];
        _score++ ;
        return [points copy];
    }else return [NSArray array];
}

-(NSArray *)generateNew{
    
    coupleEle *c = myllk->generateCoupleEle();
    
   /* vector<int>::iterator ii;
    for (ii=myllk->emptyEle.begin(); ii!=myllk->emptyEle.end() ; ++ii)
    {
        printf("%d",*ii);
    }
    printf("\n");
   */
    printf("%d",myllk->currentCount);
    if ( c == NULL) {
        printf("%d ",myllk->currentCount);
        return [NSArray array];
    }
    NSArray *newCouple = [NSArray arrayWithObjects:[NSNumber numberWithInt:c->s],[NSNumber numberWithInt:c->e],[NSNumber numberWithInt:c->sQ] ,[NSNumber numberWithInt:c->eQ] , nil];
    delete c;
    [self.scoreView setCurrentCount:myllk->currentCount];
    return [newCouple copy];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
