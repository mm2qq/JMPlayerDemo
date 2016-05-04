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

#pragma mark - Lifecycle

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.backgroundColor = [UIColor clearColor];
        self.selectionStyle  = UITableViewCellSelectionStyleNone;
    }

    return self;
}

- (void)drawRect:(CGRect)rect {
    if (_itemTitle) {
        UIFont *font    = self.isChoosed ? [UIFont boldSystemFontOfSize:PlayerSmallFontSize]
        : [UIFont systemFontOfSize:PlayerSmallFontSize];
        UIColor * color = self.isChoosed ? OverlayProgressColor : OverlayForegroundColor;
        CGSize  size    = [_itemTitle sizeForFont:font size:rect.size mode:NSLineBreakByTruncatingTail];
        CGFloat indent  = 5.f;

        NSMutableParagraphStyle *paraStyle = [NSMutableParagraphStyle new];
        paraStyle.lineBreakMode            = NSLineBreakByTruncatingTail;
        paraStyle.firstLineHeadIndent      = indent;

        [_itemTitle drawInRect:(CGRect){0.f, size.height / 2.f, rect.size.width, size.height}
                withAttributes:@{NSFontAttributeName : font, NSForegroundColorAttributeName : color, NSParagraphStyleAttributeName : paraStyle}];
    }
}

#pragma mark - Setters

- (void)setChoosed:(BOOL)choosed {
    _choosed = choosed;
    [self setNeedsDisplay];
}

#pragma mark - Public

+ (NSString *)cellId {
    return NSStringFromClass(self.class);
}

@end
