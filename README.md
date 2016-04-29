# JMPlayerDemo
A simple video player demo based on AVFoundation

### Support
* iOS 8 or later

### Samples
![portrait](https://github.com/maocl023/JMPlayerDemo/blob/master/Samples/portrait.png)

![landscape](https://github.com/maocl023/JMPlayerDemo/blob/master/Samples/landscape.png)

### Usage

    #import "JMPlayer.h"
    ...
    NSURL *URL1 = [[NSBundle mainBundle] URLForResource:<#local resource#> withExtension:<#extension#>];
    NSURL *URL2 = [NSURL URLWithString:<#web resource#>];
    JMPlayerView *playerView = [[JMPlayerView alloc] initWithURLs:@[URL1, URL2]];
    ...
  
### Bug
A great deal #^_^#
