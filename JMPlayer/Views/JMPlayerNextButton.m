//
//  JMPlayerNextButton.m
//  JMPlayerDemo
//
//  Created by maocl023 on 16/5/3.
//  Copyright © 2016年 jjj2mdd. All rights reserved.
//

#import "JMPlayerNextButton.h"
#import "JMPlayerMacro.h"

@implementation JMPlayerNextButton

- (void)drawRect:(CGRect)rect {
    CGFloat     width = MIN(rect.size.width, rect.size.height);
    CGFloat lineWidth = 2.f;
    CGPoint     start = CGPointMake(10.f, 10.f);
    CGContextRef  ctx = UIGraphicsGetCurrentContext();
    CGContextSetShouldAntialias(ctx, true);

    // draw triangle
    CGPoint points[3];
    points[0] = start;
    points[1] = CGPointMake(start.x, width - start.y);
    points[2] = CGPointMake(sqrt(3.0) * (width - start.y) / 2.f, width / 2.f);
    CGContextAddLines(ctx, points, 3);
    CGContextSetFillColorWithColor(ctx, OverlayForegroundColor.CGColor);
    CGContextFillPath(ctx);

    // draw line
    CGContextMoveToPoint(ctx, sqrt(3.0) * (width - start.y) / 2.f + lineWidth, start.y);
    CGContextAddLineToPoint(ctx, sqrt(3.0) * (width - start.y) / 2.f + lineWidth, width - start.y);
    CGContextSetStrokeColorWithColor(ctx, OverlayForegroundColor.CGColor);
    CGContextSetLineWidth(ctx, lineWidth);
    CGContextStrokePath(ctx);
}

@end
