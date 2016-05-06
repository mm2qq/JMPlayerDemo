//
//  JMPlayer.m
//  JMPlayerDemo
//
//  Created by maocl023 on 16/4/25.
//  Copyright © 2016年 jjj2mdd. All rights reserved.
//

#import "JMPlayer.h"
#import "JMPlayerOverlay.h"
#import "JMPlayerMacro.h"
#import "UIView+JMAdd.h"
#import "UIGestureRecognizer+JMAdd.h"
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>

static const void *JMPlayerKVOContext;

typedef NS_ENUM(NSUInteger, JMPlayerPanDirection) {
    JMPlayerPanDirectionHorizontal,
    JMPlayerPanDirectionVertical,
};

@interface JMPlayer () <UIGestureRecognizerDelegate>
{
@private
    JMPlayerPanDirection _panDirection;               ///< Pan gesture direction
    __weak id            _timeObserverToken;          ///< Player's periodic timer
    __weak UIView        *_previousSuperview;         ///< Player's previous superview
}

@property (nonatomic) AVPlayer                             *player;         ///< Player instance
@property (nonatomic) AVPlayerLayer                        *playerLayer;    ///< Player layer instance
@property (nonatomic) UIActivityIndicatorView              *indicator;      ///< Player buffer status indicator
@property (nonatomic) JMPlayerOverlay                      *overlay;        ///< Player control overlay
@property (nonatomic) UISlider                             *volumeSlider;   ///< Player volume control slider
@property (nonatomic) JMPlayerStatus                       playerStatus;    ///< Player's status
@property (nonatomic) CGFloat                              currentTime;     ///< Player's current time

@end

@implementation JMPlayer

#pragma mark - Lifecycle

- (void)awakeFromNib {
    [super awakeFromNib];
    [self _setupPlayer];
}

- (instancetype)initWithItems:(NSArray<id<JMPlayerItemProtocol>> *)items {
    if (self = [super init]) {
        _items = items.copy;
        [self _setupPlayer];
    }

    return self;
}

- (void)dealloc {
    [self _removePlayerObserver];
    [self _removeGesture];
}

- (void)layoutSubviews {
    [self _layoutSubviews];
    [super layoutSubviews];
}

#pragma mark - Observers

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    if (&JMPlayerKVOContext != context) {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
        return;
    }

    if ([keyPath isEqualToString:@"player.rate"]) {
        self.playerStatus = (_player.rate == 0.f ? JMPlayerStatusPaused : JMPlayerStatusPlaying);
    } else if ([keyPath isEqualToString:@"player.currentItem.loadedTimeRanges"]) {
        CMTime         totalDuration = _player.currentItem.duration;
        BOOL           validDuration = CMTIME_IS_NUMERIC(totalDuration) && totalDuration.value != 0;
        NSArray     *loadedTimeRages = _player.currentItem.loadedTimeRanges;
        CGFloat totalDurationSeconds = validDuration ? CMTimeGetSeconds(totalDuration) : 0.f;

        if (loadedTimeRages.count < 1) return;

        CMTimeRange timeRage = [(NSValue *)loadedTimeRages[0] CMTimeRangeValue];
        CGFloat        start = CMTimeGetSeconds(timeRage.start);
        CGFloat     duration = CMTimeGetSeconds(timeRage.duration);
        CGFloat     progress = (start + duration) / totalDurationSeconds;

        // if buffered progress is more than 5 seconds and not in pasued, go on playing
        if (duration > 5.0 && JMPlayerStatusPaused != _playerStatus) {
            [self _play];
        }

        if ([_delegate respondsToSelector:@selector(player:itemDuration:loadedTime:)]) {
            [_delegate player:self itemDuration:totalDurationSeconds loadedTime:progress];
        }
    } else if ([keyPath isEqualToString:@"player.currentItem.playbackBufferEmpty"]) {
        self.playerStatus = JMPlayerStatusBuffering;
    }
}

- (void)handleItemDidPlayToEnd:(NSNotification *)notification {
    if (self.isContinuous) {
        self.playerStatus = JMPlayerStatusIdle;
    }
}

#pragma mark - Delegate

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if ([gestureRecognizer isMemberOfClass:[UIPanGestureRecognizer class]]) {
        return YES;
    }

    // if overlay is hidden, tap gesture can make a different
    return _overlay.isHidden;
}

#pragma mark - Getters & Setters

- (void)setItems:(NSArray<id<JMPlayerItemProtocol>> *)items {
    _items = items.copy;
    [self _setupPlayer];
}

- (void)setCurrentTime:(CGFloat)currentTime {
    CGFloat duration = CMTimeGetSeconds(_player.currentItem.duration);
    _currentTime     = (currentTime > duration ? duration : currentTime);

    @weakify(self)
    [_player seekToTime:CMTimeMakeWithSeconds(_currentTime, 1000)
        toleranceBefore:kCMTimeZero
         toleranceAfter:kCMTimeZero
      completionHandler:^(BOOL finished)
     {
         @strongify(self)
         finished ? [self _play] : [self _pause];
     }];
}

- (void)setPlayerStatus:(JMPlayerStatus)playerStatus {
    // update status only in status really changed
    if (_playerStatus == playerStatus) return;

    _playerStatus = playerStatus;
    JMPlayerStatusBuffering == _playerStatus ?
    [self.indicator startAnimating] : [self.indicator stopAnimating];

    if ([_delegate respondsToSelector:@selector(player:currentStatus:)]) {
        [_delegate player:self currentStatus:_playerStatus];
    }
}

- (UIActivityIndicatorView *)indicator {
    if (!_indicator) {
        _indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    }

    return _indicator;
}

- (JMPlayerOverlay *)overlay {
    if (!_overlay) {
        _overlay = [JMPlayerOverlay new];

        @weakify(self)
        _overlay.sliderValueChangedCallback = ^(CGFloat value) {
            @strongify(self)
            self.currentTime = value;
        };
        _overlay.playButtonDidTapped = ^(BOOL isPlaying) {
            @strongify(self)
            isPlaying ? [self _pause] : [self _play];
        };
        _overlay.nextButtonDidTapped = ^(NSUInteger itemIndex) {
            @strongify(self)
            [self _playItemAtIndex:++itemIndex];
        };
        _overlay.rotateButtonDidTapped = ^{
            @strongify(self)
            [self _toggleScreenOrientation];
        };
        _overlay.listItemDidSelected = ^(NSUInteger itemIndex) {
            @strongify(self)
            [self _playItemAtIndex:itemIndex];
        };

        self.delegate = (id<JMPlayerPlaybackDelegate>)_overlay;
    }

    return _overlay;
}

#pragma mark - Private

- (void)_setupPlayer {
    if (!_items || _items.count == 0) {
        return;
    }

    _continuous          = YES;
    self.backgroundColor = [UIColor blackColor];

    dispatch_async_on_global_queue(^{
        _player      = [AVPlayer playerWithURL:[NSURL URLWithString:[_items[0] playUrl]]];
        _playerLayer = [AVPlayerLayer playerLayerWithPlayer:_player];

        dispatch_async_on_main_queue(^{
            [self.layer addSublayer:_playerLayer];
            [self addSubview:self.indicator];
            [self addSubview:self.overlay];

            [self _addPlayerObserver];
            [self _addGesture];
            [self _configVolumeSlider];
        });
    });
}

- (void)_layoutSubviews {
    UIWindow *window = [UIApplication sharedApplication].keyWindow;

    if (OrientationIsLandscape) {
        if (self.superview != window) {
            // store previous superview
            _previousSuperview = self.superview;
            [self removeFromSuperview];
            [window addSubview:self];
        }

        self.frame = window.frame;
    } else {
        if (self.superview == window) {
            [self removeFromSuperview];
            // re-add self to previous superview
            [_previousSuperview addSubview:self];
        }

        self.frame  = self.superview.frame;
        self.height = self.superview.width * 9.f / 16.f;
        self.center = self.superview.center;
    }

    _playerLayer.frame = self.bounds;
    _overlay.frame     = self.bounds;
    _indicator.center  = self.center;
}

- (void)_addPlayerObserver {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleItemDidPlayToEnd:)
                                                 name:AVPlayerItemDidPlayToEndTimeNotification
                                               object:nil];
    [self addObserver:self
           forKeyPath:@"player.rate"
              options:NSKeyValueObservingOptionNew
              context:&JMPlayerKVOContext];
    [self addObserver:self
           forKeyPath:@"player.currentItem.loadedTimeRanges"
              options:NSKeyValueObservingOptionNew
              context:&JMPlayerKVOContext];
    [self addObserver:self
           forKeyPath:@"player.currentItem.playbackBufferEmpty"
              options:NSKeyValueObservingOptionNew
              context:&JMPlayerKVOContext];

    @weakify(self)
    _timeObserverToken = [_player addPeriodicTimeObserverForInterval:CMTimeMake(1, 1) queue:NULL usingBlock:^(CMTime time)
                          {
                              @strongify(self)
                              if ([self.delegate respondsToSelector:@selector(player:currentTime:)]) {
                                  [self.delegate player:self currentTime:CMTimeGetSeconds(time)];
                              }
                          }];
}

- (void)_removePlayerObserver {
    if (_timeObserverToken) {
        [_player removeTimeObserver:_timeObserverToken];
    }

    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:AVPlayerItemDidPlayToEndTimeNotification
                                                  object:nil];
    [self removeObserver:self
              forKeyPath:@"player.rate"
                 context:&JMPlayerKVOContext];
    [self removeObserver:self
              forKeyPath:@"player.currentItem.loadedTimeRanges"
                 context:&JMPlayerKVOContext];
    [self removeObserver:self
              forKeyPath:@"player.currentItem.playbackBufferEmpty"
                 context:&JMPlayerKVOContext];
}

- (void)_addGesture {
    @weakify(self)
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithActionBlock:^(id  _Nonnull sender) {
        @strongify(self)
        [self.overlay show];
    }];

    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithActionBlock:^(id  _Nonnull sender) {
        @strongify(self)
        [self _handlePanGestureRecognizer:sender];
    }];

    tapGesture.delegate = self;
    panGesture.delegate = self;

    [self addGestureRecognizer:tapGesture];
    [self addGestureRecognizer:panGesture];
}

- (void)_removeGesture {
    [self.gestureRecognizers makeObjectsPerformSelector:@selector(removeAllActionBlocks)];
}

- (void)_configVolumeSlider {
    MPVolumeView *volumeView = [MPVolumeView new];

    for (UIView *view in volumeView.subviews){
        if ([view isMemberOfClass:NSClassFromString(@"MPVolumeSlider")]) {
            _volumeSlider = (UISlider *)view;
            break;
        }
    }
}

- (void)_play {
    if (JMPlayerStatusPlaying != _playerStatus) {
        [_player play];
        self.playerStatus = JMPlayerStatusPlaying;
    }
}

- (void)_pause {
    if (JMPlayerStatusPaused  != _playerStatus) {
        [_player pause];
        self.playerStatus = JMPlayerStatusPaused;
    }
}

- (void)_playItemAtIndex:(NSUInteger)itemIndex {
    // pause player for better experience
    [self _pause];

    if ([_delegate respondsToSelector:@selector(player:itemDidChangedAtIndex:)]) {
        [_delegate player:self itemDidChangedAtIndex:itemIndex];
    }

    // back to first item
    itemIndex = (itemIndex == _items.count ? 0 : itemIndex);

    NSString *urlString = [_items[itemIndex] playUrl];

    // add this task to global concurrent queue
    dispatch_async_on_global_queue(^{
        AVPlayerItem *item  = [AVPlayerItem playerItemWithURL:[NSURL URLWithString:urlString]];

        dispatch_async_on_main_queue(^{
            [_player replaceCurrentItemWithPlayerItem:item];
        });
    });
}

- (void)_toggleScreenOrientation {
    if ([[UIDevice currentDevice] respondsToSelector:@selector(setOrientation:)]) {
        SEL             selector = NSSelectorFromString(@"setOrientation:");
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[UIDevice instanceMethodSignatureForSelector:selector]];
        [invocation setSelector:selector];
        [invocation setTarget:[UIDevice currentDevice]];
        UIDeviceOrientation orientation = OrientationIsLandscape ? UIDeviceOrientationPortrait : UIDeviceOrientationLandscapeLeft;
        [invocation setArgument:&orientation atIndex:2];
        [invocation invoke];
    }
}

- (void)_handlePanGestureRecognizer:(UIPanGestureRecognizer *)recognizer {
    CGPoint   location = [recognizer locationInView:self];
    CGPoint   velocity = [recognizer velocityInView:self];
    // right half screen move to control volume, the left control brightness
    BOOL volumeControl = (location.x > self.width / 2.f);

    switch (recognizer.state) {
        case UIGestureRecognizerStateBegan:
        {
            if (fabs(velocity.x) > fabs(velocity.y)) {// horizontal move to control playback
                // show overlay
                [_overlay show];
                _panDirection = JMPlayerPanDirectionHorizontal;
                _currentTime  = CMTimeGetSeconds(_player.currentTime);
                [self _pause];
            } else {// vertical move to control volume or brightness
                _panDirection = JMPlayerPanDirectionVertical;
            }
        }
            break;
        case UIGestureRecognizerStateChanged:
        {
            if (JMPlayerPanDirectionHorizontal == _panDirection) {
                _currentTime    += velocity.x / 200.f;
                self.currentTime = _currentTime;
            } else {
                volumeControl ? (_volumeSlider.value -= velocity.y / 10000) : ([UIScreen mainScreen].brightness -= velocity.y / 10000);
            }
        }
            break;
        case UIGestureRecognizerStateEnded:
            [_overlay hide];
            break;
        default:
            break;
    }
}

@end
