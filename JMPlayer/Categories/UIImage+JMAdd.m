//
//  UIImage+JMAdd.m
//  JMPlayerDemo
//
//  Created by maocl023 on 16/4/28.
//  Copyright © 2016年 jjj2mdd. All rights reserved.
//

#import "UIImage+JMAdd.h"

@implementation UIImage (JMAdd)

+ (UIImage *)imageWithColor:(UIColor *)color {
    return [self imageWithColor:color size:CGSizeMake(1.f, 1.f)];
}

+ (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size {
    if (!color || size.width <= 0.f || size.height <= 0.f) return nil;
    CGRect rect = CGRectMake(0.f, 0.f, size.width, size.height);
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0.f);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, color.CGColor);
    CGContextFillRect(context, rect);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

+ (UIImage *)imageWithSize:(CGSize)size drawBlock:(void (^)(CGContextRef context))drawBlock {
    if (!drawBlock) return nil;
    UIGraphicsBeginImageContextWithOptions(size, NO, 0.f);
    CGContextRef context = UIGraphicsGetCurrentContext();
    if (!context) return nil;
    drawBlock(context);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

@end
