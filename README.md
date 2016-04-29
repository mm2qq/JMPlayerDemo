# JMPlayerDemo
A simple video player demo based on AVFoundation

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
