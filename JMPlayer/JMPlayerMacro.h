//
//  JMPlayerMacro.h
//  JMPlayerDemo
//
//  Created by maocl023 on 16/4/27.
//  Copyright © 2016年 jjj2mdd. All rights reserved.
//

#ifndef JMPlayerMacro_h
#define JMPlayerMacro_h

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
