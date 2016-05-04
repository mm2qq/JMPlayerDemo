//
//  JMPlayerMacro.h
//  JMPlayerDemo
//
//  Created by maocl023 on 16/4/27.
//  Copyright © 2016年 jjj2mdd. All rights reserved.
//

#ifndef JMPlayerMacro_h
#define JMPlayerMacro_h

#pragma mark - Device orientation

#define OrientationIsLandscape UIDeviceOrientationIsLandscape([UIDevice currentDevice].orientation)
#define OrientationIsPortrait UIDeviceOrientationIsPortrait([UIDevice currentDevice].orientation)

#pragma mark - Player theme

#define PlayerNormalFontSize 16.f
#define PlayerSmallFontSize 14.f
#define OverlayBackgroundColor [UIColor colorWithRed:.3f green:.3f blue:.3f alpha:.3f]
#define OverlayForegroundColor [UIColor colorWithRed:1.f green:1.f blue:1.f alpha:.3f]
#define OverlayProgressColor [UIColor colorWithRed:.5f green:.8f blue:1.f alpha:1.f]
#define OverlayProgressLightColor [UIColor colorWithRed:.5f green:.8f blue:1.f alpha:.3f]

#pragma mark - Utilities

#ifndef weakify
    #if DEBUG
        #if __has_feature(objc_arc)
            #define weakify(object) autoreleasepool{} \
            __weak __typeof__(object) weak##_##object = object;
        #else
            #define weakify(object) autoreleasepool{} \
            __block __typeof__(object) block##_##object = object;
        #endif
    #else
        #if __has_feature(objc_arc)
            #define weakify(object) try{} @finally{} {} \
            __weak __typeof__(object) weak##_##object = object;
        #else
            #define weakify(object) try{} @finally{} {} \
            __block __typeof__(object) block##_##object = object;
        #endif
    #endif
#endif

#ifndef strongify
    #if DEBUG
        #if __has_feature(objc_arc)
            #define strongify(object) autoreleasepool{} \
            __typeof__(object) object = weak##_##object;
        #else
            #define strongify(object) autoreleasepool{} \
            __typeof__(object) object = block##_##object;
        #endif
    #else
        #if __has_feature(objc_arc)
            #define strongify(object) try{} @finally{} \
            __typeof__(object) object = weak##_##object;
        #else
            #define strongify(object) try{} @finally{} \
            __typeof__(object) object = block##_##object;
        #endif
    #endif
#endif

#endif /* JMPlayerMacro_h */
