//
//  JMPlayerPlaylistCell.m
//  JMPlayerDemo
//
//  Created by maocl023 on 16/5/4.
//  Copyright © 2016年 jjj2mdd. All rights reserved.
//

#import "JMPlayerPlaylistCell.h"
#import "NSString+JMAdd.h"
#import "JMPlayerMacro.h"

@implementation JMPlayerPlaylistCell

+ (NSString *)cellId {
    return NSStringFromClass(self.class);
}

- (void)drawRect:(CGRect)rect {
    if (_itemTitle) {
        UIFont *font   = [UIFont systemFontOfSize:PlayerSmallFontSize];
        CGSize  size   = [_itemTitle sizeForFont:font size:rect.size mode:NSLineBreakByTruncatingTail];
        CGFloat indent = 5.f;

        NSMutableParagraphStyle *paraStyle = [NSMutableParagraphStyle new];
        paraStyle.lineBreakMode            = NSLineBreakByTruncatingTail;
        paraStyle.firstLineHeadIndent      = indent;

        [_itemTitle drawInRect:(CGRect){0.f, size.height / 2.f, rect.size.width - rect.size.height / 2.f - indent, size.height}
                withAttributes:@{NSFontAttributeName : font, NSForegroundColorAttributeName : OverlayForegroundColor, NSParagraphStyleAttributeName : paraStyle}];
    }

    // draw a cross
    CGFloat     width = MIN(rect.size.width, rect.size.height);
    CGFloat lineWidth = 2.f;
    CGPoint     start = CGPointMake(rect.size.width - rect.size.height + width / 3.f, rect.origin.y + width / 3.f);
    CGPoint       end = CGPointMake(rect.size.width - width / 3.f, rect.size.height - width / 3.f);
    CGContextRef  ctx = UIGraphicsGetCurrentContext();
    CGContextSetShouldAntialias(ctx, true);

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
