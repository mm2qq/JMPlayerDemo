//
//  JMPlayerCloseButton.m
//  JMPlayerDemo
//
//  Created by maocl023 on 16/5/3.
//  Copyright © 2016年 jjj2mdd. All rights reserved.
//

#import "JMPlayerCloseButton.h"
#import "JMPlayerMacro.h"

@implementation JMPlayerCloseButton

- (void)drawRect:(CGRect)rect {
    CGFloat     width = MIN(rect.size.width, rect.size.height);
    CGFloat lineWidth = 2.f;
    CGPoint     start = CGPointMake(12.f, 12.f);
    CGPoint       end = CGPointMake(width - 12.f, width - 12.f);
    CGContextRef  ctx = UIGraphicsGetCurrentContext();
    CGContextSetShouldAntialias(ctx, true);

    // draw line
    CGContextMoveToPoint(ctx, start.x, start.y);
    CGContextAddLineToPoint(ctx, end.x, end.y);
    CGContextMoveToPoint(ctx, start.x, end.y);
    CGContextAddLineToPoint(ctx, end.x, start.y);
    CGContextSetStrokeColorWithColor(ctx, OverlayForegroundColor.CGColor);
    CGContextSetLineWidth(ctx, lineWidth);
    CGContextSetLineCap(ctx, kCGLineCapRound);
    CGContextStrokePath(ctx);
}

@end
