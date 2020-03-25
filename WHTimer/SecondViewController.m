//
//  SecondViewController.m
//  SNKTimer
//
//  Created by liwenhao on 2020/3/24.
//  Copyright © 2020 liwenhaopro. All rights reserved.
//

#import "SecondViewController.h"
#import "SNKTimer.h"

@interface SecondViewController ()
@property(nonatomic, strong) SNKTimer *snktimer1;
@property(nonatomic, strong) SNKTimer *snktimer2;
@end

@implementation SecondViewController

- (void)dealloc
{
    NSLog(@"SecondViewController dealloc timer没有强引用");
}

- (void)viewDidLoad
{
    [super viewDidLoad];
//    _snktimer = [[SNKTimer alloc] snk_dispatchWithInterval:1 block:^{
//        NSLog(@"timer");
//    }];
    _snktimer1 = [[SNKTimer alloc] snk_displayLinkWithFrameInterval:10 callback:^(CADisplayLink * _Nonnull displayLink) {
        NSLog(@"111111");
    }];
    
    _snktimer2 = [[SNKTimer alloc] snk_displayLinkWithFrameInterval:10 callback:^(CADisplayLink * _Nonnull displayLink) {
        NSLog(@"22222222");
    }];
    
    [_snktimer1.displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    [_snktimer2.displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
//    _snktimer = [[SNKTimer alloc] snk_scheduledTimerWithTimeInterval:1 repeats:YES block:^(NSTimer * _Nonnull timer) {
//        NSLog(@"timer");
//    }];
    
//    [SNKTimer snk_gcdAfterTime:1 mainQueueCallback:^{
//       NSLog(@"timer");
//    }];
}


- (IBAction)dismiss:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}



@end
