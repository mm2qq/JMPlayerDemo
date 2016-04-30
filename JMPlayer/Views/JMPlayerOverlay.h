//
//  JMPlayerOverlay.h
//  JMPlayerDemo
//
//  Created by maocl023 on 16/4/30.
//  Copyright © 2016年 jjj2mdd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JMPlayerOverlay : UIView

@property (nonatomic, copy) void (^sliderValueChangedCallback)(CGFloat value);

@property (nonatomic, copy) void (^playButtonDidTapped)(BOOL isPlaying);

@property (nonatomic, copy) void (^rotateButtonDidTapped)();

@end
