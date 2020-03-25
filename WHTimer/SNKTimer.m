//
//  SNKTimer.m
//  SNKTimer
//
//  Created by liwenhao on 2020/3/24.
//  Copyright © 2020 liwenhaopro. All rights reserved.
//

#import "SNKTimer.h"
@interface  SNKTimerProxy : NSProxy
@property(nonatomic, weak) id target;
@end

@implementation SNKTimerProxy
- (nullable NSMethodSignature *)methodSignatureForSelector:(SEL)sel
{
    return [_target methodSignatureForSelector:sel];
}

- (void)forwardInvocation:(NSInvocation *)invocation
{
    if (_target) {
        [invocation invokeWithTarget:_target];
    }
}
@end

@interface SNKTimer ()

@property(nonatomic, strong) SNKTimerProxy *timerProxy;//中间键

@property(nonatomic, copy) void (^linkCallback)(CADisplayLink *displayLink);
@property(nonatomic, copy) void (^timerCallback)(NSTimer *timer);

@end

@implementation SNKTimer

//MARK:NSTimer
- (SNKTimer *)snk_timerWithTimeInterval:(NSTimeInterval)interval repeats:(BOOL)repeats callback:(void (^)(NSTimer *timer))callback
{
    _timerCallback =  callback;
    _timerProxy = [SNKTimerProxy alloc];
    _timerProxy.target = self;
    _timer = [NSTimer timerWithTimeInterval:interval target:_timerProxy selector:@selector(timerIntervalAction:) userInfo:callback repeats:repeats];
    return self;
}

- (SNKTimer *)snk_scheduledTimerWithTimeInterval:(NSTimeInterval)interval repeats:(BOOL)repeats callback:(void (^)(NSTimer *timer))callback
{
    _timerCallback =  callback;
    _timerProxy = [SNKTimerProxy alloc];
    _timerProxy.target = self;
    
    _timer = [NSTimer scheduledTimerWithTimeInterval:interval target:_timerProxy selector:@selector(timerIntervalAction:) userInfo:callback repeats:repeats];
    return self;
}

//MARK:timer action
- (void)timerIntervalAction:(NSTimer *)timer
{
    !_timerCallback? :_timerCallback(timer);
}

//MARK:displaylink
- (SNKTimer *)snk_displayLinkWithFrameInterval:(NSInteger)frameInterval callback:(void (^)(CADisplayLink *displayLink))callback
{
    _linkCallback =  callback;
    _timerProxy = [SNKTimerProxy alloc];
    _timerProxy.target = self;
    _displayLink = [CADisplayLink displayLinkWithTarget:_timerProxy selector:@selector(displayLinkAction:)];
    if (frameInterval > 0) {
        _displayLink.frameInterval = frameInterval;
    }
    return self;
}

//MARK:displayLink action
- (void)displayLinkAction:(CADisplayLink *)displayLink
{
    !_linkCallback? :_linkCallback(displayLink);
}

//MARK:gcdTimer
- (SNKTimer *)snk_gcdWithInterval:(NSTimeInterval)interval callback:(void (^)(void))callback
{
    dispatch_queue_t timerQueue = dispatch_queue_create("timer", DISPATCH_QUEUE_SERIAL);
    _gcdTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, timerQueue);
    uint64_t start = dispatch_time(DISPATCH_TIME_NOW, 0);
    uint64_t nsec = (uint64_t)(interval * NSEC_PER_SEC / 1000);
    dispatch_source_set_timer(_gcdTimer, start, nsec, 0);
    dispatch_source_set_event_handler(_gcdTimer, callback);
    dispatch_resume(_gcdTimer);
    return self;
}

//倒计时
//seconds 倒计时秒
//times 到技术结束 再次重复次数
- (SNKTimer *)snk_countDownTimerForInterval:(NSTimeInterval)seconds repeatTimes:(NSUInteger)times callback:(void (^)(NSUInteger time))callback competion:(void (^)(void))completion
{
    __block NSUInteger count = times;
    _gcdTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_main_queue());
    uint64_t nsec = (uint64_t)(seconds * NSEC_PER_SEC);
    dispatch_source_set_timer(_gcdTimer, dispatch_time(DISPATCH_TIME_NOW, 0), nsec, 0);
    __weak __typeof(self)weakSelf = self;
    dispatch_source_set_event_handler(_gcdTimer, ^(){
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        if (strongSelf) {
            if (count <= 0) {
                !completion? :completion();
                dispatch_source_cancel(strongSelf.gcdTimer);
            } else {
                !callback? :callback(count);
                count--;
            }
        }
    });
    dispatch_resume(_gcdTimer);
    return self;
}

//gcd几秒延迟执行,callback在主线程
+ (void)snk_gcdAfterTime:(CGFloat)delayInSeconds mainQueueCallback:(void (^)(void))callback
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        !callback? :callback();
    });
}

//MARK:cancelTimer
- (void)cancelTimer
{
    [_displayLink invalidate];
    _displayLink = nil;
    
    [_timer invalidate];
    _timer = nil;
    
    if (_gcdTimer) {
        dispatch_source_cancel(_gcdTimer);
    }
}

 //MARK:dealloc
- (void)dealloc
{
    [self cancelTimer];
    NSLog(@"timer没有强引用");
}
@end
