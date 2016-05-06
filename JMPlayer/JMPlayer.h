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
    JMPlayerStatusPaused,               ///< Indicates that the player is paused
    JMPlayerStatusPlaying,              ///< Indicates that the player is playing now
    JMPlayerStatusBuffering,            ///< Indicates that the player is buffering
    JMPlayerStatusIdle,                 ///< Indicates that the player finish to play item
};

@protocol JMPlayerPlaybackDelegate <NSObject>

@optional

- (void)player:(JMPlayer *)player currentStatus:(JMPlayerStatus)status;

- (void)player:(JMPlayer *)player currentTime:(CGFloat)time;

- (void)player:(JMPlayer *)player itemDuration:(CGFloat)duration loadedTime:(CGFloat)time;

- (void)player:(JMPlayer *)player itemDidChangedAtIndex:(NSUInteger)index;

@end

@protocol JMPlayerItemProtocol <NSObject>

@property (nullable, nonatomic, copy) NSString *itemTitle;
@property (nullable, nonatomic, copy) NSString *itemDescription;
@property (nonatomic, copy)           NSString *playUrl;

@end

@interface JMPlayer : UIView

/**
 *  Indicates whether player should continuous play next item
 */
@property (nonatomic, getter=isContinuous) BOOL continuous;

/**
 *  Player's source, reset will reset the player too
 */
@property (nonatomic, copy) NSArray<id<JMPlayerItemProtocol>> *items;

/**
 *  Initialize a player view with video item
 *
 *  @param items  The array of video item
 *
 *  @return Instance of player view
 */
- (instancetype)initWithItems:(NSArray<id<JMPlayerItemProtocol>> *)items;

/**
 *  Communicate with JMPlayerOverlay instance, do not sign a variable to it
 */
@property (nonatomic, weak) id<JMPlayerPlaybackDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
