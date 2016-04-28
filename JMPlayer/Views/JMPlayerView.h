//
//  JMPlayerView.h
//  JMPlayerDemo
//
//  Created by maocl023 on 16/4/25.
//  Copyright © 2016年 jjj2mdd. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, JMPlayerStatus) {
    JMPlayerStatusBuffering,
    JMPlayerStatusPlaying,
    JMPlayerStatusPaused,
};

@interface JMPlayerView : UIView

@property (nonatomic, copy) NSArray *URLs;

/**
 *  Initialize a player view with video URL
 *
 *  @param URLs  The array of video URL
 *
 *  @return Instance of player view
 */
- (instancetype)initWithURLs:(NSArray<NSURL *> *)URLs;

/**
 *  Video play
 */
- (void)play;

/**
 *  Video pause
 */
- (void)pause;

@end
