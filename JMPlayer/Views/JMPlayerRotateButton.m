//
//  JMPlayerRotateButton.m
//  JMPlayerDemo
//
//  Created by maocl023 on 16/4/30.
//  Copyright © 2016年 jjj2mdd. All rights reserved.
//

#import "JMPlayerRotateButton.h"
#import "JMPlayerMacro.h"

@implementation JMPlayerRotateButton

- (void)drawRect:(CGRect)rect {
    CGFloat     width = MIN(rect.size.width, rect.size.height);
    CGFloat lineWidth = 2.f;
    CGPoint     start = CGPointMake(width / 7.2f + lineWidth, width / 7.2f + lineWidth);
    CGPoint       end = CGPointMake(width * 5.f / 12.f, width * 5.f / 12.f);

    // create initial path
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, start.x, start.y);
    CGPathAddLineToPoint(path, NULL, end.x, end.y);
    CGPathMoveToPoint(path, NULL, start.x, end.y);

    if (UIDeviceOrientationIsLandscape([UIDevice currentDevice].orientation)) {
        CGPathAddLineToPoint(path, NULL, end.x, end.y);
        CGPathAddLineToPoint(path, NULL, end.x, start.y);
    } else {
        CGPathAddLineToPoint(path, NULL, start.x, start.y);
        CGPathAddLineToPoint(path, NULL, end.x, start.y);
    }

    // CTM tranform
    CGContextRef   ctx = UIGraphicsGetCurrentContext();
    CGPathRef pathCopy = CGPathCreateCopy(path);
    CGContextAddPath(ctx, path);
    CGContextTranslateCTM(ctx, width, width);
    CGContextRotateCTM(ctx, M_PI);
    CGContextAddPath(ctx, pathCopy);

    // draw path
    [OverlayForegroundColor setStroke];
    CGContextSetShouldAntialias(ctx, true);
    CGContextSetLineWidth(ctx, lineWidth);
    CGContextSetLineCap(ctx, kCGLineCapRound);
    CGContextSetLineJoin(ctx, kCGLineJoinRound);
    CGContextDrawPath(ctx, kCGPathStroke);

    CGPathRelease(path);
    CGPathRelease(pathCopy);
}

@end
