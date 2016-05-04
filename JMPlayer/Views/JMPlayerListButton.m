//
//  JMPlayerListButton.m
//  JMPlayerDemo
//
//  Created by maocl023 on 16/5/3.
//  Copyright © 2016年 jjj2mdd. All rights reserved.
//

#import "JMPlayerListButton.h"
#import "JMPlayerMacro.h"

@implementation JMPlayerListButton

- (void)drawRect:(CGRect)rect {
    CGFloat     width = MIN(rect.size.width, rect.size.height);
    CGFloat lineWidth = 2.f;
    CGPoint     start = CGPointMake(width / 4.f, width / 2.f);
    CGPoint      mid1 = CGPointMake(start.x + lineWidth / 2.f, start.y);
    CGPoint      mid2 = CGPointMake(mid1.x + lineWidth * 2.f, start.y);
    CGPoint       end = CGPointMake(width - start.x, start.y);

    // create initial path
    CGMutablePathRef midPath = CGPathCreateMutable();
    CGPathMoveToPoint(midPath, NULL, start.x, start.y);
    CGPathAddLineToPoint(midPath, NULL, mid1.x, mid1.y);
    CGPathMoveToPoint(midPath, NULL, mid2.x, mid2.y);
    CGPathAddLineToPoint(midPath, NULL, end.x, end.y);

    // CTM tranform
    CGContextRef   ctx = UIGraphicsGetCurrentContext();
    CGPathRef topPath = CGPathCreateCopy(midPath);
    CGContextAddPath(ctx, midPath);
    CGContextTranslateCTM(ctx, 0.f, -width / 6.f);
    CGContextAddPath(ctx, topPath);
    CGPathRef bottomPath = CGPathCreateCopy(midPath);
    CGContextTranslateCTM(ctx, 0.f, width / 3.f);
    CGContextAddPath(ctx, bottomPath);

    // draw path
    [OverlayForegroundColor setStroke];
    CGContextSetShouldAntialias(ctx, true);
    CGContextSetLineWidth(ctx, lineWidth);
    CGContextSetLineCap(ctx, kCGLineCapRound);
    CGContextDrawPath(ctx, kCGPathStroke);

    CGPathRelease(midPath);
    CGPathRelease(topPath);
    CGPathRelease(bottomPath);
}

@end
