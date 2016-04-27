//
//  JMPlayerView.m
//  JMPlayerDemo
//
//  Created by maocl023 on 16/4/25.
//  Copyright © 2016年 jjj2mdd. All rights reserved.
//

#import "JMPlayerView.h"
#import "JMPlayerMacro.h"
#import "UIView+JMAdd.h"
#import <AVFoundation/AVFoundation.h>

static int JMPlayerViewKVOContext = 0;

@interface JMPlayerView () {
    id _timeObserverToken;
    __weak UIView *_previousSuperview;
}

@property (nonatomic, copy) NSMutableArray<AVPlayerItem *> *playerItems;

@property (nonatomic) AVQueuePlayer *player;

@property (nonatomic) AVPlayerLayer *playerLayer;

@property (nonatomic) UISlider *slider;

@property (nonatomic) UIProgressView *progressView;

@property (nonatomic) CMTime currentTime;

@end

@implementation JMPlayerView

#pragma mark - Lifecycle

- (instancetype)initWithURLs:(NSArray<NSURL *> *)URLs {
    self = [super init];

    if (self) {
        _URLs = URLs.copy;
        self.backgroundColor = [UIColor blackColor];
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
    [_player play];
}

- (void)pause {
    [_player pause];
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
        double durationSecond = isValidDuration ? CMTimeGetSeconds(duration) : 0.0;

        self.slider.maximumValue = durationSecond;
        self.slider.value = isValidDuration ? CMTimeGetSeconds(self.currentTime) : 0.0;
        self.slider.enabled = isValidDuration;
    } else if ([keyPath isEqualToString:@"player.currentItem.loadedTimeRanges"]) {
        NSArray *loadedTimeRages = _player.currentItem.loadedTimeRanges;

        if (loadedTimeRages.count < 1) return;

        CMTimeRange timeRage = [(NSValue *)loadedTimeRages[0] CMTimeRangeValue];
        double start = CMTimeGetSeconds(timeRage.start);
        double duration = CMTimeGetSeconds(timeRage.duration);
        double loaded = start + duration;

        self.progressView.progress = loaded / CMTimeGetSeconds(_player.currentItem.duration);
    }// else if ([keyPath isEqualToString:@"currentItem.playbackBufferEmpty"]) {
    //        NSLog(@"2");
    //    } else if ([keyPath isEqualToString:@"currentItem.playbackLikelyToKeepUp"]) {
    //        NSLog(@"3");
    //    }
}

- (void)sliderValueChanged:(UISlider *)slider {
    self.currentTime = CMTimeMakeWithSeconds(slider.value, 1000);
}

#pragma mark - Getters & Setters

- (void)setURLs:(NSArray *)URLs {
    _URLs = URLs.copy;
    [self _setupPlayer];
}

- (UISlider *)slider {
    if (!_slider) {
        _slider = [UISlider new];
        _slider.minimumTrackTintColor = [UIColor redColor];
        _slider.maximumTrackTintColor = [UIColor colorWithRed:0.3 green:0.3 blue:0.3 alpha:0.6];

        [_slider addTarget:self
                    action:@selector(sliderValueChanged:)
          forControlEvents:UIControlEventValueChanged];
    }

    return _slider;
}

- (UIProgressView *)progressView {
    if (!_progressView) {
        _progressView = [UIProgressView new];
        _progressView.progressTintColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.3];
        _progressView.trackTintColor = [UIColor clearColor];
    }

    return _progressView;
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

    [self.layer addSublayer:_playerLayer];
    [self addSubview:self.progressView];
    [self addSubview:self.slider];

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

    _playerLayer.frame = self.bounds;
    _slider.width = self.width;
    _slider.height = 24.f;
    _slider.bottom = self.height;

    _progressView.width = _slider.width - 4.f;
    _progressView.height = _slider.height;
    _progressView.center = _slider.center;
}

- (void)_addPlayerObserver {
    [self addObserver:self
           forKeyPath:@"player.currentItem.duration"
              options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionInitial
              context:&JMPlayerViewKVOContext];
    [self addObserver:self
           forKeyPath:@"player.currentItem.loadedTimeRanges"
              options:NSKeyValueObservingOptionNew// | NSKeyValueObservingOptionInitial
              context:&JMPlayerViewKVOContext];
    //    [_player addObserver:self
    //              forKeyPath:@"currentItem.playbackBufferEmpty"
    //                 options:NSKeyValueObservingOptionNew //| NSKeyValueObservingOptionInitial
    //                 context:&JMPlayerViewKVOContext];
    //    [_player addObserver:self
    //              forKeyPath:@"currentItem.playbackLikelyToKeepUp"
    //                 options:NSKeyValueObservingOptionNew// | NSKeyValueObservingOptionInitial
    //                 context:&JMPlayerViewKVOContext];
    @weakify(self)
    _timeObserverToken = [_player addPeriodicTimeObserverForInterval:CMTimeMake(1, 1)
                                                               queue:NULL
                                                          usingBlock:^(CMTime time)
                          {
                              @strongify(self)
                              self.slider.value = CMTimeGetSeconds(time);
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
}

@end
