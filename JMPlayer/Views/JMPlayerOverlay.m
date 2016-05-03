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
#import "JMPlayerNextButton.h"
#import "JMPlayerRotateButton.h"
#import "NSTimer+JMAdd.h"
#import "UIControl+JMAdd.h"
#import "UIGestureRecognizer+JMAdd.h"
#import "UIImage+JMAdd.h"
#import "UIView+JMAdd.h"
#import "JMPlayerMacro.h"

static const CGFloat      OverlaySliderHeigt = 36.f;
static const CGFloat  OverlayPlayButtonWidth = 40.f;
static const CGFloat    OverlayControlMargin = 4.f;
static const CGFloat  OverlayAnimateDuration = .25f;
static const CGFloat OverlayAutoHideInterval = 5.f;

static inline NSString * _formatTimeSeconds(CGFloat time) {
    NSInteger   hours = (NSInteger)floor(time / 3600);
    NSInteger minutes = (NSInteger)floor(time / 60) % 60;
    NSInteger seconds = (NSInteger)time % 60;

    return hours > 0 ? [NSString stringWithFormat:@"%02ld:%02ld:%02ld", (long)hours, (long)minutes, (long)seconds] : [NSString stringWithFormat:@"%02ld:%02ld", (long)minutes, (long)seconds];
}

@interface JMPlayerOverlay () <JMPlayerPlaybackDelegate, UIGestureRecognizerDelegate>
{
@private
    __weak NSTimer *_autoHideTimer;                         ///< Overlay auto hide timer
}

@property (nonatomic) UILabel              *timeLabel;      ///< Played time label
@property (nonatomic) UILabel              *durationLabel;  ///< Total time label
@property (nonatomic) UISlider             *slider;         ///< Played time progress slider
@property (nonatomic) UIProgressView       *progressView;   ///< Loaded time progress view
@property (nonatomic) JMPlayerPlayButton   *playButton;     ///< Play & pause button
@property (nonatomic) JMPlayerNextButton   *nextButton;     ///< Advanced play next item button
@property (nonatomic) JMPlayerRotateButton *rotateButton;   ///< Manually rotate screen button

@end

@implementation JMPlayerOverlay

#pragma mark - Lifecycle

- (instancetype)init {
    if (self = [super init]) {
        [self _setupSubviews];
        [self _addGesture];
    }

    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self _setupSubviews];
        [self _addGesture];
    }

    return self;
}

- (void)dealloc {
    [self _removeGesture];
}

- (void)layoutSubviews {
    [self _layoutSubviews];
    [super layoutSubviews];
}

#pragma mark - Public

- (void)show {
    if (self.isHidden) {
        UIViewAnimationOptions options = UIViewAnimationOptionCurveLinear
        | UIViewAnimationOptionAllowAnimatedContent
        | UIViewAnimationOptionShowHideTransitionViews
        | UIViewAnimationOptionTransitionFlipFromBottom;

        [UIView animateWithDuration:OverlayAnimateDuration
                              delay:0
                            options:options
                         animations:^
         {
             self.alpha = 1.f;
         }
                         completion:^(BOOL finished)
         {
             if (finished) {
                 self.hidden = NO;
                 [self _autoHide];
             }
         }];
    }
}

- (void)hide {
    if (!self.isHidden) {
        [UIView animateWithDuration:OverlayAnimateDuration
                              delay:0
                            options:UIViewAnimationOptionCurveLinear
                         animations:^
         {
             self.alpha = 0.f;
         }
                         completion:^(BOOL finished)
         {
             if (finished) {
                 self.hidden = YES;
             }
         }];
    }
}

#pragma mark - Delegate

- (void)player:(JMPlayer *)player currentStatus:(JMPlayerStatus)status {
    // overlay should reset it's subviews
    if (JMPlayerStatusIdle == status) {
        [self _reset];
    } else {
        _playButton.playing = (JMPlayerStatusPlaying == status);
    }
}

- (void)player:(JMPlayer *)player currentTime:(CGFloat)time {
    self.slider.value   = time;
    self.timeLabel.text = _formatTimeSeconds(time);
}

- (void)player:(JMPlayer *)player itemDuration:(CGFloat)duration loadedTime:(CGFloat)time {
    self.slider.enabled        = (duration != 0.0);
    self.slider.maximumValue   = duration;
    self.durationLabel.text    = _formatTimeSeconds(duration);
    self.progressView.progress = time;
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    CGPoint point = [gestureRecognizer locationInView:self];

    if (CGRectContainsPoint(_slider.frame, point)
        || CGRectContainsPoint(_playButton.frame, point)
        || CGRectContainsPoint(_nextButton.frame, point)
        || CGRectContainsPoint(_rotateButton.frame, point)) {
        return NO;
    }

    return YES;
}

#pragma mark - Getters & Setters

- (UISlider *)slider {
    if (!_slider) {
        _slider                       = [UISlider new];
        _slider.minimumTrackTintColor = OverlayProgressLightColor;

        [_slider setMaximumTrackImage:[UIImage imageWithColor:OverlayBackgroundColor
                                                         size:(CGSize){1.f, OverlaySliderHeigt}]
                             forState:UIControlStateNormal];

        [_slider setThumbImage:[UIImage imageWithColor:OverlayProgressColor
                                                  size:(CGSize){2.f, OverlaySliderHeigt}]
                      forState:UIControlStateNormal];

        @weakify(self)
        [_slider setBlockForControlEvents:UIControlEventValueChanged
                                    block:^(UISlider *slider)
         {
             @strongify(self)
             !self.sliderValueChangedCallback ? : self.sliderValueChangedCallback(slider.value);
             [self _autoHide];
         }];
    }

    return _slider;
}

- (UIProgressView *)progressView {
    if (!_progressView) {
        _progressView                   = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleBar];
        _progressView.progressTintColor = OverlayForegroundColor;
    }

    return _progressView;
}

- (UILabel *)timeLabel {
    if (!_timeLabel) {
        _timeLabel           = [[UILabel alloc] initWithFrame:(CGRect){CGPointZero, (CGSize){61.f, 17.f}}];
        _timeLabel.font      = [UIFont systemFontOfSize:14.f];
        _timeLabel.textColor = OverlayForegroundColor;
        _timeLabel.text      = @"00:00";
    }

    return _timeLabel;
}

- (UILabel *)durationLabel {
    if (!_durationLabel) {
        _durationLabel               = [[UILabel alloc] initWithFrame:(CGRect){CGPointZero, (CGSize){61.f, 17.f}}];
        _durationLabel.font          = [UIFont systemFontOfSize:14.f];
        _durationLabel.textColor     = OverlayForegroundColor;
        _durationLabel.textAlignment = NSTextAlignmentRight;
        _durationLabel.text          = @"00:00";
    }

    return _durationLabel;
}

- (JMPlayerPlayButton *)playButton {
    if (!_playButton) {
        _playButton                 = [[JMPlayerPlayButton alloc] initWithFrame:(CGRect){CGPointZero, (CGSize){OverlayPlayButtonWidth, OverlayPlayButtonWidth}}];
        _playButton.backgroundColor = [UIColor clearColor];

        @weakify(self)
        [_playButton setBlockForControlEvents:UIControlEventTouchUpInside
                                        block:^(JMPlayerPlayButton *button)
         {
             @strongify(self)
             !self.playButtonDidTapped ? : self.playButtonDidTapped(button.isPlaying);

             // ready to hide overlay
             [self _autoHide];
         }];
    }

    return _playButton;
}

- (JMPlayerNextButton *)nextButton {
    if (!_nextButton) {
        _nextButton                 = [[JMPlayerNextButton alloc] initWithFrame:(CGRect){CGPointZero, (CGSize){OverlaySliderHeigt, OverlaySliderHeigt}}];
        _nextButton.backgroundColor = OverlayBackgroundColor;

        @weakify(self)
        [_nextButton setBlockForControlEvents:UIControlEventTouchUpInside
                                          block:^(JMPlayerNextButton *button)
         {
             @strongify(self)
             !self.nextButtonDidTapped ? : self.nextButtonDidTapped();
         }];
    }

    return _nextButton;
}

- (JMPlayerRotateButton *)rotateButton {
    if (!_rotateButton) {
        _rotateButton                 = [[JMPlayerRotateButton alloc] initWithFrame:(CGRect){CGPointZero, (CGSize){OverlaySliderHeigt, OverlaySliderHeigt}}];
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
    [self addSubview:self.nextButton];
    [self addSubview:self.rotateButton];
}

- (void)_layoutSubviews {
    _nextButton.bottom    = self.height;
    _nextButton.left      = self.left;

    _rotateButton.bottom  = self.height;
    _rotateButton.right   = self.right;

    _slider.width         = self.width - _nextButton.width - _rotateButton.width + OverlayControlMargin;
    _slider.height        = _nextButton.height;
    _slider.bottom        = self.height;
    _slider.left          = _nextButton.right - OverlayControlMargin / 2.f;

    _progressView.width   = self.width - _nextButton.width - _rotateButton.width;
    _progressView.height  = _slider.height;
    _progressView.center  = _slider.center;

    _timeLabel.bottom     = self.height;
    _timeLabel.left       = _slider.left + OverlayControlMargin;

    _durationLabel.bottom = self.height;
    _durationLabel.right  = _slider.right - OverlayControlMargin;

    _playButton.center    = self.center;

    // update orientation status
    [_rotateButton setNeedsDisplay];
}

- (void)_addGesture {
    @weakify(self)
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithActionBlock:^(id  _Nonnull sender) {
        @strongify(self)
        [self hide];
    }];

    tapGesture.delegate = self;
    [self addGestureRecognizer:tapGesture];
}

- (void)_removeGesture {
    [self.gestureRecognizers makeObjectsPerformSelector:@selector(removeAllActionBlocks)];
}

- (void)_autoHide {
    // avoid timer execute hide while is hidden
    if (_autoHideTimer.isValid) {
        [_autoHideTimer invalidate];
    }

    @weakify(self)
    _autoHideTimer = [NSTimer scheduledTimerWithTimeInterval:OverlayAutoHideInterval
                                                       block:^(NSTimer * _Nonnull timer) {
                                                           @strongify(self)
                                                           [self hide];
                                                       }
                                                     repeats:NO];
}

- (void)_reset {
    self.slider.enabled        = NO;
    self.slider.maximumValue   = 1.f;
    self.slider.value          = 0.f;
    self.progressView.progress = 0.f;
    self.durationLabel.text    = _formatTimeSeconds(0.f);
    self.timeLabel.text        = _formatTimeSeconds(0.f);
    self.playButton.playing    = NO;
}

@end
