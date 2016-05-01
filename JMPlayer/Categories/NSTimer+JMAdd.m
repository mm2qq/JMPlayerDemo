//
//  NSTimer+JMAdd.m
//  JMPlayerDemo
//
//  Created by maocl023 on 16/5/1.
//  Copyright © 2016年 jjj2mdd. All rights reserved.
//

#import "NSTimer+JMAdd.h"

@implementation NSTimer (JMAdd)

+ (void)_jm_ExecBlock:(NSTimer *)timer {
    if ([timer userInfo]) {
        void (^block)(NSTimer *timer) = (void (^)(NSTimer *timer))[timer userInfo];
        block(timer);
    }
}

+ (NSTimer *)scheduledTimerWithTimeInterval:(NSTimeInterval)seconds
                                      block:(void (^)(NSTimer *timer))block
                                    repeats:(BOOL)repeats {
    return [NSTimer scheduledTimerWithTimeInterval:seconds target:self selector:@selector(_jm_ExecBlock:) userInfo:[block copy] repeats:repeats];
}

+ (NSTimer *)timerWithTimeInterval:(NSTimeInterval)seconds
                             block:(void (^)(NSTimer *timer))block
                           repeats:(BOOL)repeats {
    return [NSTimer timerWithTimeInterval:seconds target:self selector:@selector(_jm_ExecBlock:) userInfo:[block copy] repeats:repeats];
}

@end
