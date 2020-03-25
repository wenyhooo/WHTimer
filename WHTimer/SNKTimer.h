//
//  SNKTimer.h
//  SNKTimer
//
//  Created by liwenhao on 2020/3/24.
//  Copyright © 2020 liwenhaopro. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>

NS_ASSUME_NONNULL_BEGIN

//页面退出时 定时无需手动管理
@interface SNKTimer : NSObject

//三种定时器  相关runloop 调用者自行设置 启动
@property(nonatomic, strong) NSTimer *timer;
@property(nonatomic, strong) CADisplayLink *displayLink;
@property(nonatomic, strong) dispatch_source_t gcdTimer;

//MARK:NStimer
- (SNKTimer *)snk_timerWithTimeInterval:(NSTimeInterval)interval repeats:(BOOL)repeats callback:(void (^)(NSTimer *timer))callback;
- (SNKTimer *)snk_scheduledTimerWithTimeInterval:(NSTimeInterval)interval repeats:(BOOL)repeats callback:(void (^)(NSTimer *timer))callback;

//MARK:displaylink  和FPS同步
//frameInterval 几帧回调一次  <=0是默认和屏幕刷新次数一直
- (SNKTimer *)snk_displayLinkWithFrameInterval:(NSInteger)frameInterval callback:(void (^)(CADisplayLink *displayLink))callback;

//MARK:gcdTimer 优势:支持毫秒
//interval 毫秒
- (SNKTimer *)snk_gcdWithInterval:(NSTimeInterval)interval callback:(void (^)(void))callback;

//倒计时
//seconds 倒计时-秒
//times 倒计时结束 再次重复计时器次数
- (SNKTimer *)snk_countDownTimerForInterval:(NSTimeInterval)seconds repeatTimes:(NSUInteger)times callback:(void (^)(NSUInteger time))callback competion:(void (^)(void))completion;

//gcd几秒延迟执行,callback在主线程
+ (void)snk_gcdAfterTime:(CGFloat)delayInSeconds mainQueueCallback:(void (^)(void))callback;

//根据业务决定调用时机, ⚠️无需在页面退出时手动调用
- (void)cancelTimer;

@end

NS_ASSUME_NONNULL_END
