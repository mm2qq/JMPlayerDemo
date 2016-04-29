//
//  JMPlayerView.m
//  JMPlayerDemo
//
//  Created by maocl023 on 16/4/25.
//  Copyright © 2016年 jjj2mdd. All rights reserved.
//

#import "JMPlayerView.h"
#import "JMPlayerMacro.h"
#import "JMPlayerPlayButton.h"
#import "UIControl+JMAdd.h"
#import "UIImage+JMAdd.h"
#import "UIView+JMAdd.h"
#import <AVFoundation/AVFoundation.h>

static int JMPlayerViewKVOContext = 0;

static inline NSString * _formatTimeSeconds(double time) {
    NSString *string;
    int hours = (int)floor(time / 3600);
    int minutes = (int)floor(time / 60) % 60;
    int seconds = (int)time % 60;

    if (hours > 0) {
        string = [NSString stringWithFormat:@"%02d:%02d:%02d", hours, minutes, seconds];
    } else {
        string = [NSString stringWithFormat:@"%02d:%02d", minutes, seconds];
    }

    return string;
}

@interface JMPlayerView () {
    JMPlayerStatus _playerStatus;
    id _timeObserverToken;
    __weak UIView *_previousSuperview;
}

@property (nonatomic, copy) NSMutableArray<AVPlayerItem *> *playerItems;

@property (nonatomic) AVQueuePlayer *player;

@property (nonatomic) AVPlayerLayer *playerLayer;

@property (nonatomic) UISlider *slider;

@property (nonatomic) UIProgressView *progressView;

@property (nonatomic) CMTime currentTime;

@property (nonatomic) UIActivityIndicatorView *activityIndicator;

@property (nonatomic) UILabel *timeLabel;

@property (nonatomic) UILabel *durationLabel;

@property (nonatomic) JMPlayerPlayButton *playButton;

@end

@implementation JMPlayerView

#pragma mark - Lifecycle

- (instancetype)initWithURLs:(NSArray<NSURL *> *)URLs {
    self = [super init];

    if (self) {
        _URLs = URLs.copy;
        [self _setupPlayer];
    }

    return self;
}

- (void)dealloc {
    [self _removePlayerObserver];
}

- (void)layoutSubviews {
    [self _layout];
    [super layoutSubviews];
}

#pragma mark - Public

- (void)play {
    if (_playerStatus != JMPlayerStatusPlaying) {
        [_player play];
        _playerStatus = JMPlayerStatusPlaying;
    }
}

- (void)pause {
    if (_playerStatus != JMPlayerStatusPaused) {
        [_player pause];
        _playerStatus = JMPlayerStatusPaused;
    }
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    if (&JMPlayerViewKVOContext != context) {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
        return;
    }

    if ([keyPath isEqualToString:@"player.currentItem.duration"]) {
        CMTime duration = _player.currentItem.duration;
        BOOL isValidDuration = CMTIME_IS_NUMERIC(duration) && duration.value != 0;
        double durationSeconds = isValidDuration ? CMTimeGetSeconds(duration) : 0.0;

        self.slider.maximumValue = durationSeconds;
        self.slider.value = isValidDuration ? CMTimeGetSeconds(self.currentTime) : 0.0;
        self.slider.enabled = isValidDuration;

        // set time label
        if (!isValidDuration) {
            self.timeLabel.text = _formatTimeSeconds(durationSeconds);
            [self.activityIndicator stopAnimating];
        }
        self.durationLabel.text = _formatTimeSeconds(durationSeconds);
    } else if ([keyPath isEqualToString:@"player.currentItem.loadedTimeRanges"]) {
        NSArray *loadedTimeRages = _player.currentItem.loadedTimeRanges;

        if (loadedTimeRages.count < 1) return;

        CMTimeRange timeRage = [(NSValue *)loadedTimeRages[0] CMTimeRangeValue];
        double start = CMTimeGetSeconds(timeRage.start);
        double duration = CMTimeGetSeconds(timeRage.duration);
        double loaded = start + duration;

        self.progressView.progress = loaded / CMTimeGetSeconds(_player.currentItem.duration);

        // if buffer duration is more than 8 seconds and not in pasued, go on playing
        if (duration > 8.0 && _playerStatus != JMPlayerStatusPaused) {
            [self.activityIndicator stopAnimating];
            [self play];
        }
    } else if ([keyPath isEqualToString:@"player.currentItem.playbackBufferEmpty"]) {
        _playerStatus = JMPlayerStatusBuffering;
        [self.activityIndicator startAnimating];
    }
}

#pragma mark - Getters & Setters

- (void)setURLs:(NSArray *)URLs {
    _URLs = URLs.copy;
    [self _setupPlayer];
}

- (UISlider *)slider {
    if (!_slider) {
        _slider = [UISlider new];
        _slider.minimumTrackTintColor = [UIColor colorWithRed:.5f green:.8f blue:1.f alpha:.3f];

        [_slider setMaximumTrackImage:[UIImage imageWithColor:[UIColor colorWithRed:.3f green:.3f blue:.3f alpha:.3f] size:(CGSize){1.f, 36.f}] forState:UIControlStateNormal];

        [_slider setThumbImage:[UIImage imageWithColor:[UIColor colorWithRed:.5f green:.8f blue:1.f alpha:1.f] size:(CGSize){2.f, 36.f}] forState:UIControlStateNormal];

        @weakify(self)
        [_slider setBlockForControlEvents:UIControlEventValueChanged
                                    block:^(UISlider *slider)
         {
             @strongify(self)
             _playerStatus = JMPlayerStatusBuffering;
             self.currentTime = CMTimeMakeWithSeconds(slider.value, 1000);
         }];
    }

    return _slider;
}

- (UIProgressView *)progressView {
    if (!_progressView) {
        _progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleBar];
        _progressView.progressTintColor = [UIColor colorWithRed:1.f green:1.f blue:1.f alpha:.3f];
    }

    return _progressView;
}

- (UIActivityIndicatorView *)activityIndicator {
    if (!_activityIndicator) {
        _activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    }

    return _activityIndicator;
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

         if (finished) {
             // just continue playing
             [self play];
         } else {
             // pause while sliding
             [self pause];
         }
     }];
}

- (UILabel *)timeLabel {
    if (!_timeLabel) {
        _timeLabel = [[UILabel alloc] initWithFrame:(CGRect){CGPointZero, (CGSize){61.f, 17.f}}];
        _timeLabel.font = [UIFont systemFontOfSize:14.f];
        _timeLabel.textColor = [UIColor colorWithRed:1.f green:1.f blue:1.f alpha:.3f];
        _timeLabel.text = @"00:00";
    }

    return _timeLabel;
}

- (UILabel *)durationLabel {
    if (!_durationLabel) {
        _durationLabel = [[UILabel alloc] initWithFrame:(CGRect){CGPointZero, (CGSize){61.f, 17.f}}];
        _durationLabel.font = [UIFont systemFontOfSize:14.f];
        _durationLabel.textColor = [UIColor colorWithRed:1.f green:1.f blue:1.f alpha:.3f];
        _durationLabel.text = @"00:00";
        _durationLabel.textAlignment = NSTextAlignmentRight;
    }

    return _durationLabel;
}

- (JMPlayerPlayButton *)playButton {
    if (!_playButton) {
        _playButton = [[JMPlayerPlayButton alloc] initWithFrame:(CGRect){CGPointZero, (CGSize){40.f, 40.f}}];
        _playButton.backgroundColor = [UIColor clearColor];

        @weakify(self)
        [_playButton setBlockForControlEvents:UIControlEventTouchUpInside
                                        block:^(JMPlayerPlayButton *button)
        {
            @strongify(self)

            if (button.playing) {
                [self pause];
                button.playing = NO;
            } else {
                [self play];
                button.playing = YES;
            }
        }];
    }

    return _playButton;
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

    // TODO:move player view's subviews to another view

    self.backgroundColor = [UIColor blackColor];
    [self.layer addSublayer:_playerLayer];

    [self addSubview:self.timeLabel];
    [self addSubview:self.durationLabel];
    [self addSubview:self.progressView];
    [self addSubview:self.slider];
    [self addSubview:self.activityIndicator];
    [self addSubview:self.playButton];

    [self _addPlayerObserver];
}

- (void)_layout {
    UIWindow *window = [UIApplication sharedApplication].keyWindow;

    if (UIDeviceOrientationIsPortrait([UIDevice currentDevice].orientation)) {
        if (self.superview == window) {
            [self removeFromSuperview];
            // re-add self to previous superview
            [_previousSuperview addSubview:self];
        }

        self.frame = self.superview.frame;
        self.height = self.superview.width * 9.f / 16.f;
        self.center = self.superview.center;
    } else {
        if (self.superview != window) {
            // store previous superview
            _previousSuperview = self.superview;
            [self removeFromSuperview];
            [window addSubview:self];
        }

        self.frame = window.frame;
    }

    _timeLabel.bottom = self.height;
    _timeLabel.left = self.left;

    _durationLabel.bottom = self.height;
    _durationLabel.right = self.right;

    _playerLayer.frame = self.bounds;
    _slider.width = self.width + 4.f;
    _slider.height = 36.f;
    _slider.bottom = self.height;
    _slider.centerX = self.centerX;

    _progressView.width = self.width;
    _progressView.height = _slider.height;
    _progressView.center = _slider.center;

    _activityIndicator.center = self.center;
    _playButton.center = self.center;
}

- (void)_addPlayerObserver {
    [self addObserver:self
           forKeyPath:@"player.currentItem.duration"
              options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionInitial
              context:&JMPlayerViewKVOContext];
    [self addObserver:self
           forKeyPath:@"player.currentItem.loadedTimeRanges"
              options:NSKeyValueObservingOptionNew
              context:&JMPlayerViewKVOContext];
    [self addObserver:self
           forKeyPath:@"player.currentItem.playbackBufferEmpty"
              options:NSKeyValueObservingOptionNew
              context:&JMPlayerViewKVOContext];

    @weakify(self)
    _timeObserverToken = [_player addPeriodicTimeObserverForInterval:CMTimeMake(1, 1) queue:NULL usingBlock:^(CMTime time)
                          {
                              @strongify(self)
                              self.slider.value = CMTimeGetSeconds(time);
                              // set time label
                              self.timeLabel.text = _formatTimeSeconds(self.slider.value);
                          }];
}

- (void)_removePlayerObserver {
    if (_timeObserverToken) {
        [_player removeTimeObserver:_timeObserverToken];
    }

    [self removeObserver:self
              forKeyPath:@"player.currentItem.duration"
                 context:&JMPlayerViewKVOContext];
    [self removeObserver:self
              forKeyPath:@"player.currentItem.loadedTimeRanges"
                 context:&JMPlayerViewKVOContext];
    [self removeObserver:self
              forKeyPath:@"player.currentItem.playbackBufferEmpty"
                 context:&JMPlayerViewKVOContext];
}

@end
