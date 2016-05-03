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
    CGFloat     width = MIN(rect.size.width, rect.size.height);
    CGFloat rectWidth = 13.f;
    CGPoint     start = CGPointMake(0.f, 0.f);
    CGContextRef  ctx = UIGraphicsGetCurrentContext();

    if (self.isPlaying) {
        CGRect  leftRect = (CGRect){start, rectWidth, width};
        CGRect rightRect = (CGRect){width - rectWidth, start.y, rectWidth, width};
        CGRect rects[2];
        rects[0] = leftRect;
        rects[1] = rightRect;
        CGContextAddRects(ctx, rects, 2);
    } else {
        CGPoint points[3];
        points[0] = start;
        points[1] = CGPointMake(start.x, width);
        points[2] = CGPointMake(sqrt(3.0) * width / 2.f, width / 2.f);
        CGContextAddLines(ctx, points, 3);
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
