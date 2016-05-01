//
//  JMPlayer.h
//  JMPlayerDemo
//
//  Created by maocl023 on 16/4/25.
//  Copyright © 2016年 jjj2mdd. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class JMPlayer;

typedef NS_ENUM(NSUInteger, JMPlayerStatus) {
    JMPlayerStatusPaused,               ///< indicates that player is paused, default status
    JMPlayerStatusPlaying,              ///< indicates that player is playing
    JMPlayerStatusBuffering,            ///< indicates that player is hang out with some stalling
};

@protocol JMPlayerDelegate <NSObject>

@optional

- (void)player:(JMPlayer *)player currentTime:(CGFloat)time;

- (void)player:(JMPlayer *)player itemDuration:(CGFloat)duration;

- (void)player:(JMPlayer *)player loadedTime:(CGFloat)time;

@end

@interface JMPlayer : UIView

@property (nonatomic, weak) id<JMPlayerDelegate> delegate;

/**
 *  Player's source, reset will reset the player too
 */
@property (nonatomic, copy) NSArray *URLs;

/**
 *  Initialize a player view with video URL
 *
 *  @param URLs  The array of video URL
 *
 *  @return Instance of player view
 */
- (instancetype)initWithURLs:(NSArray<NSURL *> *)URLs;

@end

NS_ASSUME_NONNULL_END
