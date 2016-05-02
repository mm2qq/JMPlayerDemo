# JMPlayerDemo
A simple video player demo based on AVFoundation

### Features
* Player rotate keep pace with device rotation.
* Both local resource and web resource video file are available.
* Left half of screen sliding for brightness control, the other part for volume control, sliding horizontally for playback control.
 
### Coming Soon
* Player skin configuration.
* Play list feature.
* Local storage for files and cache web resource.

### Support
* iOS 8 or later

### Samples
![](https://github.com/maocl023/JMPlayerDemo/blob/master/Samples/portrait.png)

![](https://github.com/maocl023/JMPlayerDemo/blob/master/Samples/landscape1.PNG)

![](https://github.com/maocl023/JMPlayerDemo/blob/master/Samples/landscape2.PNG)

### Usage

    #import "JMPlayer.h"
    ...
    NSURL *URL1 = [[NSBundle mainBundle] URLForResource:<#local resource#> withExtension:<#extension#>];
    NSURL *URL2 = [NSURL URLWithString:<#web resource#>];
    JMPlayer *player = [[JMPlayer alloc] initWithURLs:@[URL1, URL2]];
    ...
  
### Bug
A great deal #^_^#
