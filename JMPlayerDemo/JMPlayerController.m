//
//  JMPlayerController.m
//  JMPlayerDemo
//
//  Created by maocl023 on 16/4/25.
//  Copyright © 2016年 jjj2mdd. All rights reserved.
//

#import "JMPlayerController.h"
#import "JMPlayerView.h"

@interface JMPlayerController ()

@property (nonatomic) JMPlayerView *playerView;

@end

@implementation JMPlayerController

- (void)viewDidLoad {
    [super viewDidLoad];

    NSURL *URL1 = [[NSBundle mainBundle] URLForResource:@"ElephantSeals" withExtension:@"mov"];
    NSURL *URL2 = [NSURL URLWithString:@"https://movielalavideos.blob.core.windows.net/videos/563cb51788b8c6db4b000376.mp4"];
    _playerView = [[JMPlayerView alloc] initWithFrame:self.view.frame andURLs:@[URL2, URL1]];
    [self.view addSubview:_playerView];

    [_playerView play];
}

@end
