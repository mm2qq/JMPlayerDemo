//
//  JMPlayerController.m
//  JMPlayerDemo
//
//  Created by maocl023 on 16/4/25.
//  Copyright © 2016年 jjj2mdd. All rights reserved.
//

#import "JMPlayerController.h"
#import "JMPlayer.h"

@interface JMPlayerController ()

@property (weak, nonatomic) IBOutlet UIView *playerWrapperView;
@property (nonatomic) JMPlayerView *playerView;

@end

@implementation JMPlayerController

- (void)viewDidLoad {
    [super viewDidLoad];

    NSURL *URL1 = [[NSBundle mainBundle] URLForResource:@"ElephantSeals" withExtension:@"mov"];
    NSURL *URL2 = [NSURL URLWithString:@"https://movielalavideos.blob.core.windows.net/videos/563cb51788b8c6db4b000376.mp4"];
    _playerView = [[JMPlayerView alloc] initWithURLs:@[URL1, URL2]];
    [_playerWrapperView addSubview:_playerView];
}

@end
