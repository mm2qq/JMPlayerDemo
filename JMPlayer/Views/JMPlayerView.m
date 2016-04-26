//
//  JMPlayerView.m
//  JMPlayerDemo
//
//  Created by maocl023 on 16/4/25.
//  Copyright © 2016年 jjj2mdd. All rights reserved.
//

#import "JMPlayerView.h"
#import "JMPlayerMacro.h"
#import <AVFoundation/AVFoundation.h>

static int JMPlayerViewKVOContext = 0;

@interface JMPlayerView ()

@property (nonatomic, copy) NSMutableArray<AVPlayerItem *> *playerItems;

@property (nonatomic) AVQueuePlayer *player;

@property (nonatomic) AVPlayerLayer *playerLayer;

@property (nonatomic) UISlider *slider;

@property (nonatomic) CMTime currentTime;

@end

@implementation JMPlayerView

#pragma mark - Lifecycle

- (instancetype)initWithFrame:(CGRect)frame
                      andURLs:(NSArray<NSURL *> *)URLs {
    self = [super initWithFrame:frame];

    if (self) {
        _URLs = URLs.copy;
        [self _setupPlayer];
    }

    return self;
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

    if ([keyPath isEqualToString:@"currentItem.duration"]) {
        NSValue *newDurationAsValue = change[NSKeyValueChangeNewKey];
        CMTime newDuration = [newDurationAsValue isKindOfClass:[NSValue class]] ? newDurationAsValue.CMTimeValue : kCMTimeZero;
        BOOL hasValidDuration = CMTIME_IS_NUMERIC(newDuration) && newDuration.value != 0;
        double newDurationSeconds = hasValidDuration ? CMTimeGetSeconds(newDuration) : 0.0;

        self.slider.maximumValue = newDurationSeconds;
        self.slider.value = hasValidDuration ? CMTimeGetSeconds(self.currentTime) : 0.0;
        self.slider.enabled = hasValidDuration;
    }
//    } else if ([keyPath isEqualToString:@"currentItem.loadedTimeRanges"]) {
//        NSLog(@"1");
//    } else if ([keyPath isEqualToString:@"currentItem.playbackBufferEmpty"]) {
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
        _slider = [[UISlider alloc] initWithFrame:(CGRect){
            (CGPoint){self.frame.origin.x, self.frame.origin.y + 24.f},
            (CGSize){self.frame.size.width, 24.f}}];
        [_slider addTarget:self
                    action:@selector(sliderValueChanged:)
          forControlEvents:UIControlEventValueChanged];
    }

    return _slider;
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
    _playerLayer.frame = self.layer.frame;

    [self.layer addSublayer:_playerLayer];

    [self addSubview:self.slider];

    [self _addPlayerObserver];
}

- (void)_addPlayerObserver {
    [_player addObserver:self
              forKeyPath:@"currentItem.duration"
                 options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionInitial
                 context:&JMPlayerViewKVOContext];
//    [_player addObserver:self
//              forKeyPath:@"currentItem.loadedTimeRanges"
//                 options:NSKeyValueObservingOptionNew// | NSKeyValueObservingOptionInitial
//                 context:&JMPlayerViewKVOContext];
//    [_player addObserver:self
//              forKeyPath:@"currentItem.playbackBufferEmpty"
//                 options:NSKeyValueObservingOptionNew //| NSKeyValueObservingOptionInitial
//                 context:&JMPlayerViewKVOContext];
//    [_player addObserver:self
//              forKeyPath:@"currentItem.playbackLikelyToKeepUp"
//                 options:NSKeyValueObservingOptionNew// | NSKeyValueObservingOptionInitial
//                 context:&JMPlayerViewKVOContext];
    @weakify(self)
    [_player addPeriodicTimeObserverForInterval:CMTimeMake(1, 1)
                                          queue:NULL
                                     usingBlock:^(CMTime time)
    {
        @strongify(self)
        self.slider.value = CMTimeGetSeconds(time);
    }];
}

@end
