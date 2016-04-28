//
//  UIImage+JMAdd.h
//  JMPlayerDemo
//
//  Created by 毛朝龙 on 16/4/28.
//  Copyright © 2016年 jjj2mdd. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImage (JMAdd)

/**
 Create and return a 1x1 point size image with the given color.

 @param color  The color.
 */
+ (nullable UIImage *)imageWithColor:(UIColor *)color;

/**
 Create and return a pure color image with the given color and size.

 @param color  The color.
 @param size   New image's type.
 */
+ (nullable UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size;

/**
 Create and return an image with custom draw code.

 @param size      The image size.
 @param drawBlock The draw block.

 @return The new image.
 */
+ (nullable UIImage *)imageWithSize:(CGSize)size drawBlock:(void (^)(CGContextRef context))drawBlock;

@end

NS_ASSUME_NONNULL_END
