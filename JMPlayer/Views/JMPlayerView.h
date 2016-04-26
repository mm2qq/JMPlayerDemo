//
//  JMPlayerView.h
//  JMPlayerDemo
//
//  Created by maocl023 on 16/4/25.
//  Copyright © 2016年 jjj2mdd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JMPlayerView : UIView

@property (nonatomic, copy) NSArray *URLs;

//@property (nonatomic, copy) void (^currentTimeCallback)(double currentTimeSecond);

/**
 *  Initialize a player view with frame and video URL
 *
 *  @param frame The frame of player view
 *  @param URLs  The array of video URL
 *
 *  @return Instance of player view
 */
- (instancetype)initWithFrame:(CGRect)frame andURLs:(NSArray<NSURL *> *)URLs;

/**
 *  Video play
 */
- (void)play;

/**
 *  Video pause
 */
- (void)pause;

@end
