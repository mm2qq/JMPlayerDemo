//
//  JMPlayerOverlay.m
//  JMPlayerDemo
//
//  Created by maocl023 on 16/4/30.
//  Copyright © 2016年 jjj2mdd. All rights reserved.
//

#import "JMPlayerOverlay.h"
#import "JMPlayer.h"
#import "JMPlayerCloseButton.h"
#import "JMPlayerListButton.h"
#import "JMPlayerPlayButton.h"
#import "JMPlayerNextButton.h"
#import "JMPlayerRotateButton.h"
#import "JMPlayerPlaylistCell.h"
#import "NSTimer+JMAdd.h"
#import "UIControl+JMAdd.h"
#import "UIGestureRecognizer+JMAdd.h"
#import "UIImage+JMAdd.h"
#import "UIView+JMAdd.h"
#import "JMPlayerMacro.h"

static const CGFloat      OverlayBannerHeigt = 36.f;
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

@interface JMPlayerOverlay () <JMPlayerPlaybackDelegate, UIGestureRecognizerDelegate, UITableViewDataSource, UITableViewDelegate>
{
@private
    NSUInteger     _itemIndex;         ///< Video item's index
    __weak NSTimer *_autoHideTimer;    ///< Overlay auto hide timer
}

@property (nonatomic) UILabel              *titleLabel;     ///< Video title label
@property (nonatomic) UILabel              *timeLabel;      ///< Played time label
@property (nonatomic) UILabel              *durationLabel;  ///< Total time label
@property (nonatomic) UISlider             *slider;         ///< Played time progress slider
@property (nonatomic) UIProgressView       *progressView;   ///< Loaded time progress view
@property (nonatomic) UITableView          *playlist;       ///< Playlist table
@property (nonatomic) JMPlayerCloseButton  *closeButton;    ///< Close button
@property (nonatomic) JMPlayerListButton   *listButton;     ///< List button
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

                 // if exist play list, remove it
                 if (_playlist) {
                     [_playlist removeFromSuperview];
                     _playlist = nil;
                 }
             }
         }];
    }
}

#pragma mark - Delegate

- (void)player:(JMPlayer *)player currentStatus:(JMPlayerStatus)status {
    _playButton.playing = (JMPlayerStatusPlaying == status);

    // reset overlay while one item or all items finished
    if (JMPlayerStatusBuffering == status
        && self.slider.value >= self.slider.maximumValue) {
        [self _resetPlayer:player];
    }
}

- (void)player:(JMPlayer *)player currentTime:(CGFloat)time {
    self.slider.value   = time;
    self.timeLabel.text = _formatTimeSeconds(time);
}

- (void)player:(JMPlayer *)player itemDuration:(CGFloat)duration loadedTime:(CGFloat)time {
    self.slider.enabled        = (duration != 0.f);
    self.slider.maximumValue   = duration;
    self.titleLabel.text       = [player.items[_itemIndex] itemTitle];
    self.durationLabel.text    = _formatTimeSeconds(duration);
    self.progressView.progress = time;
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    CGPoint point = [gestureRecognizer locationInView:self];

    if (CGRectContainsPoint(_slider.frame, point)
        || CGRectContainsPoint(_titleLabel.frame, point)
        || CGRectContainsPoint(_closeButton.frame, point)
        || CGRectContainsPoint(_listButton.frame, point)
        || CGRectContainsPoint(_playlist.frame, point)
        || CGRectContainsPoint(_playButton.frame, point)
        || CGRectContainsPoint(_nextButton.frame, point)
        || CGRectContainsPoint(_rotateButton.frame, point)) {
        return NO;
    }

    return YES;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    _itemIndex   = indexPath.row;
    [tableView reloadData];
}

#pragma mark - DataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    JMPlayer *player = (JMPlayer *)self.superview;
    return  player.items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    JMPlayerPlaylistCell *cell = [tableView dequeueReusableCellWithIdentifier:[JMPlayerPlaylistCell cellId] forIndexPath:indexPath];
    cell.itemTitle             = [((JMPlayer *)self.superview).items[indexPath.row] itemTitle];
    cell.choosed               = (_itemIndex == indexPath.row);

    return cell;
}

#pragma mark - Getters & Setters

- (UISlider *)slider {
    if (!_slider) {
        _slider                       = [UISlider new];
        _slider.minimumTrackTintColor = OverlayProgressLightColor;

        [_slider setMaximumTrackImage:[UIImage imageWithColor:OverlayBackgroundColor
                                                         size:(CGSize){1.f, OverlayBannerHeigt}]
                             forState:UIControlStateNormal];

        [_slider setThumbImage:[UIImage imageWithColor:OverlayProgressColor
                                                  size:(CGSize){2.f, OverlayBannerHeigt}]
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

- (UITableView *)playlist {
    if (!_playlist) {
        _playlist                 = [[UITableView alloc] initWithFrame:(CGRect){self.width, OverlayBannerHeigt, self.width / 2.5f, self.height - OverlayBannerHeigt * 2.f}];
        _playlist.dataSource      = self;
        _playlist.delegate        = self;
        _playlist.rowHeight       = OverlayBannerHeigt;
        _playlist.separatorStyle  = UITableViewCellSeparatorStyleNone;
        _playlist.backgroundColor = OverlayBackgroundColor;

        // register cell
        [_playlist registerClass:JMPlayerPlaylistCell.class forCellReuseIdentifier:[JMPlayerPlaylistCell cellId]];
    }

    return _playlist;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:(CGRect){CGPointZero, 1.f, OverlayBannerHeigt}];
        _titleLabel.font            = [UIFont boldSystemFontOfSize:PlayerNormalFontSize];
        _titleLabel.textColor       = OverlayForegroundColor;
        _titleLabel.backgroundColor = OverlayBackgroundColor;
    }

    return _titleLabel;
}

- (UILabel *)timeLabel {
    if (!_timeLabel) {
        _timeLabel           = [[UILabel alloc] initWithFrame:(CGRect){CGPointZero, 61.f, 17.f}];
        _timeLabel.font      = [UIFont systemFontOfSize:PlayerSmallFontSize];
        _timeLabel.textColor = OverlayForegroundColor;
        _timeLabel.text      = @"00:00";
    }

    return _timeLabel;
}

- (UILabel *)durationLabel {
    if (!_durationLabel) {
        _durationLabel               = [[UILabel alloc] initWithFrame:(CGRect){CGPointZero, 61.f, 17.f}];
        _durationLabel.font          = [UIFont systemFontOfSize:PlayerSmallFontSize];
        _durationLabel.textColor     = OverlayForegroundColor;
        _durationLabel.textAlignment = NSTextAlignmentRight;
        _durationLabel.text          = @"00:00";
    }

    return _durationLabel;
}

- (JMPlayerCloseButton *)closeButton {
    if (!_closeButton) {
        _closeButton                 = [[JMPlayerCloseButton alloc] initWithFrame:(CGRect){CGPointZero, OverlayBannerHeigt, OverlayBannerHeigt}];
        _closeButton.backgroundColor = OverlayBackgroundColor;

        // @weakify(self)
        [_closeButton setBlockForControlEvents:UIControlEventTouchUpInside
                                         block:^(JMPlayerCloseButton *button)
         {
             // @strongify(self)
             NSLog(@"Close button tapped.");
         }];
    }

    return _closeButton;
}

- (JMPlayerListButton *)listButton {
    if (!_listButton) {
        _listButton                 = [[JMPlayerListButton alloc] initWithFrame:(CGRect){CGPointZero, OverlayBannerHeigt, OverlayBannerHeigt}];
        _listButton.backgroundColor = OverlayBackgroundColor;

        @weakify(self)
        [_listButton setBlockForControlEvents:UIControlEventTouchUpInside
                                        block:^(JMPlayerCloseButton *button)
         {
             @strongify(self)
             [self _togglePlaylist];
         }];
    }

    return _listButton;
}

- (JMPlayerPlayButton *)playButton {
    if (!_playButton) {
        _playButton                 = [[JMPlayerPlayButton alloc] initWithFrame:(CGRect){CGPointZero, OverlayPlayButtonWidth, OverlayPlayButtonWidth}];
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
        _nextButton                 = [[JMPlayerNextButton alloc] initWithFrame:(CGRect){CGPointZero, OverlayBannerHeigt, OverlayBannerHeigt}];
        _nextButton.backgroundColor = OverlayBackgroundColor;

        @weakify(self)
        [_nextButton setBlockForControlEvents:UIControlEventTouchUpInside
                                        block:^(JMPlayerNextButton *button)
         {
             @strongify(self)
             [self _resetPlayer:(JMPlayer *)self.superview];
             !self.nextButtonDidTapped ? : self.nextButtonDidTapped();
         }];
    }

    return _nextButton;
}

- (JMPlayerRotateButton *)rotateButton {
    if (!_rotateButton) {
        _rotateButton                 = [[JMPlayerRotateButton alloc] initWithFrame:(CGRect){CGPointZero, OverlayBannerHeigt, OverlayBannerHeigt}];
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
    [self addSubview:self.titleLabel];
    [self addSubview:self.closeButton];
    [self addSubview:self.listButton];
    [self addSubview:self.timeLabel];
    [self addSubview:self.durationLabel];
    [self addSubview:self.progressView];
    [self addSubview:self.slider];
    [self addSubview:self.playButton];
    [self addSubview:self.nextButton];
    [self addSubview:self.rotateButton];
}

- (void)_layoutSubviews {
    _closeButton.top      = self.top;
    _closeButton.left     = self.left;

    _listButton.top       = self.top;
    _listButton.right     = self.right;

    _titleLabel.width     = self.width - _closeButton.width
                            - (OrientationIsPortrait ? 0.f : _listButton.width);
    _titleLabel.top       = self.top;
    _titleLabel.left      = _closeButton.right;

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

    // update by orientation status
    [_rotateButton setNeedsDisplay];
    _listButton.hidden    = OrientationIsPortrait;

    if (OrientationIsPortrait && _playlist) {
        [_playlist removeFromSuperview];
        _playlist = nil;
    }
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

- (void)_togglePlaylist {
    if (!self.playlist.superview) {
        [self addSubview:_playlist];
    }

    // auto hide timer control
    BOOL isHidden = (_playlist.left == self.right);
    isHidden ? [_autoHideTimer invalidate] : [self _autoHide];

    [UIView animateWithDuration:OverlayAnimateDuration
                     animations:^
     {
         if (isHidden) {
             _playlist.right = self.right;
         } else {
             _playlist.left  = self.right;
         }
     }];
}

- (void)_resetPlayer:(JMPlayer *)player {
    if (++_itemIndex == player.items.count) _itemIndex = 0;

    self.titleLabel.text       = @"";
    self.slider.enabled        = NO;
    self.slider.value          = 0.f;
    self.progressView.progress = 0.f;
    self.timeLabel.text        = @"00:00";
    self.durationLabel.text    = @"00:00";
    self.playButton.playing    = NO;
}

@end
