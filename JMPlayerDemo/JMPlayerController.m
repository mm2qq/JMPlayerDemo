//
//  JMPlayerController.m
//  JMPlayerDemo
//
//  Created by maocl023 on 16/4/25.
//  Copyright © 2016年 jjj2mdd. All rights reserved.
//

#import "JMPlayerController.h"
#import "JMPlayer.h"
#import "NSDictionary+JMAdd.h"

@interface JMPlayerController ()

@property (weak, nonatomic) IBOutlet UIView *playerWrapperView;
@property (nonatomic) JMPlayer *player;

@end

@implementation JMPlayerController

- (void)viewDidLoad {
    [super viewDidLoad];

//    NSURL *testUrl = [NSURL URLWithString:@"https://movielalavideos.blob.core.windows.net/videos/563cb51788b8c6db4b000376.mp4"];

    NSData *data = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"video" ofType:@"json"]];
    NSDictionary *dic = [NSDictionary dictionaryWithJson:data];
    NSArray *videoes = dic[@"videoList"];
    NSMutableArray *urls = [NSMutableArray arrayWithCapacity:videoes.count];

    for (NSDictionary *video in videoes) {
        NSURL *url = [NSURL URLWithString:video[@"playUrl"]];
        [urls addObject:url];
    }

    _player = [[JMPlayer alloc] initWithURLs:urls];
    [_playerWrapperView addSubview:_player];
}

@end
