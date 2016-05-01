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
#import "JMPlayerRotateButton.h"
#import "UIControl+JMAdd.h"
#import "UIGestureRecognizer+JMAdd.h"
#import "UIImage+JMAdd.h"
#import "UIView+JMAdd.h"
#import "JMPlayerMacro.h"

static const CGFloat OverlaySliderHeigt = 36.f;
static const CGFloat OverlayPlayButtonWidth = 40.f;
static const CGFloat OverlayControlMargin = 4.f;

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

@property (nonatomic) UILabel *timeLabel;                   ///< Played time label

@property (nonatomic) UILabel *durationLabel;               ///< Total time label

@property (nonatomic) UISlider *slider;                     ///< Played time progress slider

@property (nonatomic) UIProgressView *progressView;         ///< Loaded time progress view

@property (nonatomic) JMPlayerPlayButton *playButton;       ///< Play & pause button

@property (nonatomic) JMPlayerRotateButton *rotateButton;   ///< Manually rotate screen button

@end

@implementation JMPlayerOverlay

#pragma mark - Lifecycle

- (instancetype)init {
    if (self = [super init]) {
        [self _setupSubviews];
//        [self _addGesture];
    }

    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self _setupSubviews];
//        [self _addGesture];
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

#pragma mark - Public

- (void)show {
    if (self.hidden) {
        NSLog(@"I'm hidden now, I want to show!!!");
    }
}

#pragma mark - Override

//- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
//    if ([_slider pointInside:[_slider convertPoint:point fromView:self] withEvent:event]) {
//        return _slider;
//    }
//    if ([_playButton pointInside:[_playButton convertPoint:point fromView:self] withEvent:event]) {
//        return _playButton;
//    }
//    if ([_rotateButton pointInside:[_rotateButton convertPoint:point fromView:self] withEvent:event]) {
//        return _rotateButton;
//    }
//
//    return [super hitTest:point withEvent:event];
//}

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
        _slider.minimumTrackTintColor = OverlayProgressLightColor;

        [_slider setMaximumTrackImage:[UIImage imageWithColor:OverlayBackgroundColor size:(CGSize){1.f, OverlaySliderHeigt}] forState:UIControlStateNormal];

        [_slider setThumbImage:[UIImage imageWithColor:OverlayProgressColor size:(CGSize){2.f, OverlaySliderHeigt}] forState:UIControlStateNormal];

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
        _progressView.progressTintColor = OverlayForegroundColor;
    }

    return _progressView;
}

- (UILabel *)timeLabel {
    if (!_timeLabel) {
        _timeLabel = [[UILabel alloc] initWithFrame:(CGRect){CGPointZero, (CGSize){61.f, 17.f}}];
        _timeLabel.font = [UIFont systemFontOfSize:14.f];
        _timeLabel.textColor = OverlayForegroundColor;
        _timeLabel.text = @"00:00";
    }

    return _timeLabel;
}

- (UILabel *)durationLabel {
    if (!_durationLabel) {
        _durationLabel = [[UILabel alloc] initWithFrame:(CGRect){CGPointZero, (CGSize){61.f, 17.f}}];
        _durationLabel.font = [UIFont systemFontOfSize:14.f];
        _durationLabel.textColor = OverlayForegroundColor;
        _durationLabel.textAlignment = NSTextAlignmentRight;
        _durationLabel.text = @"00:00";
    }

    return _durationLabel;
}

- (JMPlayerPlayButton *)playButton {
    if (!_playButton) {
        _playButton = [[JMPlayerPlayButton alloc] initWithFrame:(CGRect){CGPointZero, (CGSize){OverlayPlayButtonWidth, OverlayPlayButtonWidth}}];
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

- (JMPlayerRotateButton *)rotateButton {
    if (!_rotateButton) {
        _rotateButton = [[JMPlayerRotateButton alloc] initWithFrame:(CGRect){CGPointZero, (CGSize){OverlaySliderHeigt, OverlaySliderHeigt}}];
        _rotateButton.backgroundColor = OverlayBackgroundColor;

        @weakify(self)
        [_rotateButton setBlockForControlEvents:UIControlEventTouchUpInside
                                          block:^(JMPlayerRotateButton *button)
         {
             @strongify(self)
             !self.rotateButtonDidTapped ? : self.rotateButtonDidTapped();
         }];
    }

    return _rotateButton;
}

#pragma mark - Private

- (void)_setupSubviews {
    [self addSubview:self.timeLabel];
    [self addSubview:self.durationLabel];
    [self addSubview:self.progressView];
    [self addSubview:self.slider];
    [self addSubview:self.playButton];
    [self addSubview:self.rotateButton];
}

- (void)_layoutSubviews {
    _slider.width = self.width - OverlaySliderHeigt + OverlayControlMargin;
    _slider.height = OverlaySliderHeigt;
    _slider.bottom = self.height;
    _slider.left = self.left - OverlayControlMargin / 2.f;

    _progressView.width = self.width - OverlaySliderHeigt;
    _progressView.height = _slider.height;
    _progressView.center = _slider.center;

    _timeLabel.bottom = self.height;
    _timeLabel.left = _slider.left + OverlayControlMargin;

    _durationLabel.bottom = self.height;
    _durationLabel.right = _slider.right - OverlayControlMargin;

    _rotateButton.bottom = self.height;
    _rotateButton.right = self.right;

    _playButton.center = self.center;

    // update orientation status
    [_rotateButton setNeedsDisplay];
}

- (void)_addGesture {
    @weakify(self)
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithActionBlock:^(id  _Nonnull sender) {
        @strongify(self)
        [self _hide];
    }];

    [self addGestureRecognizer:tapGesture];
}

- (void)_hide {
    if (!self.hidden) {
        NSLog(@"I'm show off, let me alone.");
    }
}

@end
