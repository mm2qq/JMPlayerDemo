//
//  JMPlayerOverlay.h
//  JMPlayerDemo
//
//  Created by maocl023 on 16/4/30.
//  Copyright © 2016年 jjj2mdd. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface JMPlayerOverlay : UIView

@property (nonatomic, copy) void (^sliderValueChangedCallback)(CGFloat value);

@property (nonatomic, copy) void (^playButtonDidTapped)(BOOL isPlaying);

@property (nonatomic, copy) void (^nextButtonDidTapped)();

@property (nonatomic, copy) void (^rotateButtonDidTapped)();

@property (nonatomic, copy) void (^listItemDidSelected)(NSUInteger itemIndex);

/**
 *  Overlay show with animate manually
 */
- (void)show;

/**
 *  Overlay hide with animate manually
 */
- (void)hide;

@end

NS_ASSUME_NONNULL_END
