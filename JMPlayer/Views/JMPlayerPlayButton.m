//
//  JMPlayerPlayButton.m
//  JMPlayerDemo
//
//  Created by maocl023 on 16/4/29.
//  Copyright © 2016年 jjj2mdd. All rights reserved.
//

#import "JMPlayerPlayButton.h"
#import "JMPlayerMacro.h"

@implementation JMPlayerPlayButton

- (void)drawRect:(CGRect)rect {
    CGFloat width = MIN(rect.size.width, rect.size.height);
    CGContextRef ctx = UIGraphicsGetCurrentContext();

    if (self.isPlaying) {
        CGRect leftRect = (CGRect){0.f, 0.f, 13.f, width};
        CGRect rightRect = (CGRect){width - 13.f, 0.f, 13.f, width};
        CGRect rects[2];
        rects[0] = leftRect;
        rects[1] = rightRect;
        CGContextAddRects(ctx, rects, 2);
    } else {
        CGContextBeginPath(ctx);
        CGPoint points[3];
        points[0] = CGPointMake(0.f, 0.f);
        points[1] = CGPointMake(0.f, width);
        points[2] = CGPointMake(sqrt(3.0) * width / 2.f, width / 2.f);
        CGContextAddLines(ctx, points, 3);
        CGContextClosePath(ctx);
    }

    CGContextSetShouldAntialias(ctx, true);
    CGContextSetFillColorWithColor(ctx, OverlayBackgroundColor.CGColor);
    CGContextFillPath(ctx);
}

- (void)setPlaying:(BOOL)playing {
    _playing = playing;
    [self setNeedsDisplay];
}

@end
