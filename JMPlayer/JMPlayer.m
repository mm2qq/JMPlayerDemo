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

static const void *JMPlayerKVOContext;

@interface JMPlayer () <UIGestureRecognizerDelegate>
{
    @private
    JMPlayerStatus _playerStatus;
    id _timeObserverToken;
    __weak UIView *_previousSuperview;
}

@property (nonatomic, copy) NSMutableArray<AVPlayerItem *> *playerItems;

@property (nonatomic) AVQueuePlayer *player;

@property (nonatomic) AVPlayerLayer *playerLayer;

@property (nonatomic) CMTime currentTime;

@property (nonatomic) UIActivityIndicatorView *indicator;

@property (nonatomic) JMPlayerOverlay *overlay;

@end

@implementation JMPlayer

#pragma mark - Lifecycle

- (void)awakeFromNib {
    [super awakeFromNib];
    [self _setupPlayer];
}

- (instancetype)initWithURLs:(NSArray<NSURL *> *)URLs {
    if (self = [super init]) {
        _URLs = URLs.copy;
        [self _setupPlayer];
    }

    return self;
}

- (void)dealloc {
    [self _removePlayerObserver];
}

- (void)layoutSubviews {
    [self _layoutSubviews];
    [super layoutSubviews];
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    if (&JMPlayerKVOContext != context) {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
        return;
    }

    if ([keyPath isEqualToString:@"player.currentItem.duration"]) {
        CMTime duration = _player.currentItem.duration;
        BOOL isValidDuration = CMTIME_IS_NUMERIC(duration) && duration.value != 0;
        CGFloat durationSeconds = isValidDuration ? CMTimeGetSeconds(duration) : 0.0;

        if (!isValidDuration) {
            [self.indicator stopAnimating];
        }

        if ([self.delegate respondsToSelector:@selector(player:itemDuration:)]) {
            [self.delegate player:self itemDuration:durationSeconds];
        }
    } else if ([keyPath isEqualToString:@"player.currentItem.loadedTimeRanges"]) {
        NSArray *loadedTimeRages = _player.currentItem.loadedTimeRanges;

        if (loadedTimeRages.count < 1) return;

        CMTimeRange timeRage = [(NSValue *)loadedTimeRages[0] CMTimeRangeValue];
        CGFloat start = CMTimeGetSeconds(timeRage.start);
        CGFloat duration = CMTimeGetSeconds(timeRage.duration);
        CGFloat progress = (start + duration) / CMTimeGetSeconds(_player.currentItem.duration);

        // if buffered duration is more than 5 seconds and not in pasued, go on playing
        if (duration > 5.0 && _playerStatus != JMPlayerStatusPaused) {
            [self.indicator stopAnimating];
            [self _play];
        }

        if ([self.delegate respondsToSelector:@selector(player:loadedTime:)]) {
            [self.delegate player:self loadedTime:progress];
        }
    } else if ([keyPath isEqualToString:@"player.currentItem.playbackBufferEmpty"]) {
        _playerStatus = JMPlayerStatusBuffering;
        [self.indicator startAnimating];
    }
}

#pragma mark - Delegate

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    // if overlay is hidden, gesture can make a different
    return _overlay.isHidden;
}

#pragma mark - Getters & Setters

- (void)setURLs:(NSArray *)URLs {
    _URLs = URLs.copy;
    [self _setupPlayer];
}

- (CMTime)currentTime {
    return _player.currentTime;
}

- (void)setCurrentTime:(CMTime)currentTime {
    @weakify(self)
    [_player seekToTime:currentTime
        toleranceBefore:kCMTimeZero
         toleranceAfter:kCMTimeZero
      completionHandler:^(BOOL finished)
     {
         @strongify(self)
         finished ? [self _play] : [self _pause];
     }];
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
            self.currentTime = CMTimeMakeWithSeconds(value, 1000);
        };
        _overlay.playButtonDidTapped = ^(BOOL isPlaying) {
            @strongify(self)
            isPlaying ? [self _pause] : [self _play];
        };
        _overlay.rotateButtonDidTapped = ^{
            @strongify(self)
            [self _toggleScreenOrientation];
        };

        self.delegate = (id<JMPlayerDelegate>)_overlay;
    }

    return _overlay;
}

#pragma mark - Private

- (void)_setupPlayer {
    if (!_URLs || _URLs.count == 0) {
        return;
    }

    _playerItems = [NSMutableArray arrayWithCapacity:_URLs.count];

    for (NSURL *URL in _URLs) {
        [_playerItems addObject:[AVPlayerItem playerItemWithURL:URL]];
    }

    _player = [AVQueuePlayer queuePlayerWithItems:_playerItems];
    _playerLayer = [AVPlayerLayer playerLayerWithPlayer:_player];
    _playerStatus = JMPlayerStatusPaused;

    self.backgroundColor = [UIColor blackColor];
    [self.layer addSublayer:_playerLayer];
    [self addSubview:self.overlay];
    [self addSubview:self.indicator];

    [self _addPlayerObserver];
    [self _addGesture];
}

- (void)_layoutSubviews {
    UIWindow *window = [UIApplication sharedApplication].keyWindow;

    if (UIDeviceOrientationIsLandscape([UIDevice currentDevice].orientation)) {
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

        self.frame = self.superview.frame;
        self.height = self.superview.width * 9.f / 16.f;
        self.center = self.superview.center;
    }

    _playerLayer.frame = self.bounds;
    _overlay.frame = self.bounds;
    _indicator.center = self.center;
}

- (void)_addPlayerObserver {
    [self addObserver:self
           forKeyPath:@"player.currentItem.duration"
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

- (void)_addGesture {
    @weakify(self)
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithActionBlock:^(id  _Nonnull sender) {
        @strongify(self)
        [self.overlay show];
    }];

    tapGesture.delegate = self;
    [self addGestureRecognizer:tapGesture];
}

- (void)_removePlayerObserver {
    if (_timeObserverToken) {
        [_player removeTimeObserver:_timeObserverToken];
    }

    [self removeObserver:self
              forKeyPath:@"player.currentItem.duration"
                 context:&JMPlayerKVOContext];
    [self removeObserver:self
              forKeyPath:@"player.currentItem.loadedTimeRanges"
                 context:&JMPlayerKVOContext];
    [self removeObserver:self
              forKeyPath:@"player.currentItem.playbackBufferEmpty"
                 context:&JMPlayerKVOContext];
}

- (void)_play {
    if (_playerStatus != JMPlayerStatusPlaying) {
        [_player play];
        _playerStatus = JMPlayerStatusPlaying;
    }
}

- (void)_pause {
    if (_playerStatus != JMPlayerStatusPaused) {
        [_player pause];
        _playerStatus = JMPlayerStatusPaused;
    }
}

- (void)_toggleScreenOrientation {
    if ([[UIDevice currentDevice] respondsToSelector:@selector(setOrientation:)]) {
        SEL selector = NSSelectorFromString(@"setOrientation:");
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[UIDevice instanceMethodSignatureForSelector:selector]];
        [invocation setSelector:selector];
        [invocation setTarget:[UIDevice currentDevice]];
        UIDeviceOrientation orientation = UIDeviceOrientationIsLandscape([UIDevice currentDevice].orientation) ? UIDeviceOrientationPortrait : UIDeviceOrientationLandscapeLeft;
        [invocation setArgument:&orientation atIndex:2];
        [invocation invoke];
    }
}

@end
