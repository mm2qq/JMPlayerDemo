//
//  JMPlayerPlayButton.m
//  JMPlayerDemo
//
//  Created by maocl023 on 16/4/29.
//  Copyright © 2016年 jjj2mdd. All rights reserved.
//

#import "JMPlayerPlayButton.h"

@implementation JMPlayerPlayButton

- (void)drawRect:(CGRect)rect {
    self.isPlaying ? [self _drawLineInRect:rect] : [self _drawTriangleInRect:rect];
}

- (void)setPlaying:(BOOL)playing {
    _playing = playing;
    [self setNeedsDisplay];
}

- (void)_drawTriangleInRect:(CGRect)rect {
    CGFloat width = MIN(rect.size.width, rect.size.height);
    CGContextRef ctx = UIGraphicsGetCurrentContext();

    CGContextBeginPath(ctx);
    CGPoint points[3];
    points[0] = CGPointMake(0.f, 0.f);
    points[1] = CGPointMake(0.f, width);
    points[2] = CGPointMake(sqrt(3.0) * width / 2.f, width / 2.f);
    CGContextAddLines(ctx, points, 3);
    CGContextClosePath(ctx);

    CGContextSetShouldAntialias(ctx, true);
    CGContextSetFillColorWithColor(ctx, [UIColor colorWithRed:.3f green:.3f blue:.3f alpha:.3f].CGColor);
    CGContextFillPath(ctx);
}

- (void)_drawLineInRect:(CGRect)rect {
    CGFloat width = MIN(rect.size.width, rect.size.height);
    CGContextRef ctx = UIGraphicsGetCurrentContext();

    CGContextBeginPath(ctx);
    CGPoint leftPoints[2];
    leftPoints[0] = CGPointMake(0.f, 0.f);
    leftPoints[1] = CGPointMake(0.f, width);
    CGPoint rightPoints[2];
    rightPoints[0] = CGPointMake(width, 0.f);
    rightPoints[1] = CGPointMake(width, width);
    CGContextAddLines(ctx, leftPoints, 2);
    CGContextAddLines(ctx, rightPoints, 2);
    CGContextClosePath(ctx);

    CGContextSetShouldAntialias(ctx, true);
    CGContextSetLineWidth(ctx, 25.f);
    CGContextSetStrokeColorWithColor(ctx, [UIColor colorWithRed:.3f green:.3f blue:.3f alpha:.3f].CGColor);
    CGContextStrokePath(ctx);
}

@end
