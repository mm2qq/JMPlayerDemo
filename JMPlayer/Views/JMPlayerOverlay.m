//
//  JMPlayerOverlay.m
//  JMPlayerDemo
//
//  Created by maocl023 on 16/4/30.
//  Copyright © 2016年 jjj2mdd. All rights reserved.
//

#import "JMPlayerOverlay.h"
#import "JMPlayer.h"
#import "JMPlayerPlayButton.h"
#import "UIControl+JMAdd.h"
#import "UIImage+JMAdd.h"
#import "UIView+JMAdd.h"
#import "JMPlayerMacro.h"

static inline NSString * _formatTimeSeconds(CGFloat time) {
    NSString *string;
    NSInteger hours = (NSInteger)floor(time / 3600);
    NSInteger minutes = (NSInteger)floor(time / 60) % 60;
    NSInteger seconds = (NSInteger)time % 60;

    if (hours > 0) {
        string = [NSString stringWithFormat:@"%02ld:%02ld:%02ld", (long)hours, (long)minutes, (long)seconds];
    } else {
        string = [NSString stringWithFormat:@"%02ld:%02ld", (long)minutes, (long)seconds];
    }

    return string;
}

@interface JMPlayerOverlay () <JMPlayerDelegate>

@property (nonatomic, weak) JMPlayer *player;

@property (nonatomic) UILabel *timeLabel;               ///< Played time label

@property (nonatomic) UILabel *durationLabel;           ///< Total time label

@property (nonatomic) UISlider *slider;                 ///< Played time progress slider

@property (nonatomic) UIProgressView *progressView;     ///< Loaded time progress view

@property (nonatomic) JMPlayerPlayButton *playButton;   ///< Play & pause button

@end

@implementation JMPlayerOverlay

#pragma mark - Lifecycle

- (instancetype)init {
    if (self = [super init]) {
        [self _setupSubviews];
    }

    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self _setupSubviews];
    }

    return self;
}

- (void)dealloc {
    // TODO
}

- (void)layoutSubviews {
    [self _layoutSubviews];
    [super layoutSubviews];
}

#pragma mark - Delegate

- (void)player:(JMPlayer *)player currentTime:(CGFloat)time {
    self.slider.value = time;
    self.timeLabel.text = _formatTimeSeconds(time);
}

- (void)player:(JMPlayer *)player itemDuration:(CGFloat)duration {
    self.slider.enabled = (duration != 0.0);
    self.slider.maximumValue = duration;
    self.durationLabel.text = _formatTimeSeconds(duration);

    if (!self.slider.enabled) {
        self.timeLabel.text = _formatTimeSeconds(0.0);
    }
}

- (void)player:(JMPlayer *)player loadedTime:(CGFloat)time {
    self.progressView.progress = time;
}

#pragma mark - Getters & Setters

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
             !self.sliderValueChangedCallback ? : self.sliderValueChangedCallback(slider.value);
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
        _durationLabel.textAlignment = NSTextAlignmentRight;
        _durationLabel.text = @"00:00";
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
             !self.playButtonDidTapped ? : self.playButtonDidTapped(button.isPlaying);
             button.playing = !button.isPlaying;
         }];
    }

    return _playButton;
}

#pragma mark - Private

- (void)_setupSubviews {
    [self addSubview:self.timeLabel];
    [self addSubview:self.durationLabel];
    [self addSubview:self.progressView];
    [self addSubview:self.slider];
    [self addSubview:self.playButton];
}

- (void)_layoutSubviews {
    _timeLabel.bottom = self.height;
    _timeLabel.left = self.left;

    _durationLabel.bottom = self.height;
    _durationLabel.right = self.right;

    _slider.width = self.width + 4.f;
    _slider.height = 36.f;
    _slider.bottom = self.height;
    _slider.centerX = self.centerX;

    _progressView.width = self.width;
    _progressView.height = _slider.height;
    _progressView.center = _slider.center;
    
    _playButton.center = self.center;
}

@end
