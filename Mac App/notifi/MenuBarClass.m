//
//  MenuBar.m
//  notifi
//
//  Created by Maximilian Mitchell on 16/02/2018.
//  Copyright © 2018 max mitchell. All rights reserved.
//

#import "MenuBarClass.h"
#import "MainWindow.h"
#import "NSImage+Rotate.h"

@implementation MenuBarClass
-(id)initWithStatusItem:(NSStatusItem *)statusItem window:(MainWindow*)window{
    if (self != [super init]) return nil;
    
    _window = window;
    _statusItem = statusItem;
    _statusItem.image = [NSImage imageNamed:@"menu_bellicon.png"];
    [_statusItem setAction:@selector(iconClick)];
    [_statusItem setTarget:self];
    
    return self;
}

#pragma mark - actions

- (void)iconClick{
    if([_window isKeyWindow]){
        [_window orderOut:self];
    }else{
        [[NSUserNotificationCenter defaultUserNotificationCenter] removeAllDeliveredNotifications];
        _window.notifications_animated = [NSMutableArray array];
        [_window animate:true];
        [_window showWindowAtMenuBarRect:[[_statusItem valueForKey:@"window"] frame] afterAnimation:nil];
    }
}

#pragma mark - bell animation

-(void)animateBell{
    NSLog(@"animate");
    if(!_animate_bell_timer){
        _after_image = nil;
    }else{
        // cancel timer if it exists
        [_animate_bell_timer invalidate];
        _animate_bell_timer = nil;
    }
    
    _animate_bell_timer = [NSTimer scheduledTimerWithTimeInterval:0.015 target:self selector:@selector(updateBellImage) userInfo:nil repeats:YES];
}

- (void)updateBellImage
{
    NSImage* image = [NSImage imageNamed:@"alert_menu_bellicon.png" ];
    
    // list of angles to animate the bell icon (`image`) to
    NSArray *angles = [@"-20,-15.1022,-10.5422,-6.32,-2.43556,1.11111,4.32,7.19111,9.72444,11.92,13.7778,15.2978,16.48,17.3244,17.8311,18,13.6178,9.53778,5.76,2.28444,-0.888889,-3.76,-6.32889,-8.59556,-10.56,-12.2222,-13.5822,-14.64,-15.3956,-15.8489,-16,-12.1333,-8.53333,-5.2,-2.13333,0.666667,3.2,5.46667,7.46667,9.2,10.6667,11.8667,12.8,13.4667,13.8667,14,10.52,7.28,4.28,1.52,-1,-3.28,-5.32,-7.12,-8.68,-10,-11.08,-11.92,-12.52,-12.88,-13,-9.77778,-6.77778,-4,-1.44444,0.888889,3,4.88889,6.55556,8,9.22222,10.2222,11,11.5556,11.8889,12,9.16444,6.52444,4.08,1.83111,-0.222222,-2.08,-3.74222,-5.20889,-6.48,-7.55556,-8.43556,-9.12,-9.60889,-9.90222,-10,-7.68,-5.52,-3.52,-1.68,-7.10543e-15,1.52,2.88,4.08,5.12,6,6.72,7.28,7.68,7.92,8,6.19556,4.51556,2.96,1.52889,0.222222,-0.96,-2.01778,-2.95111,-3.76,-4.44444,-5.00444,-5.44,-5.75111,-5.93778,-6,-4.71111,-3.51111,-2.4,-1.37778,-0.444444,0.4,1.15556,1.82222,2.4,2.88889,3.28889,3.6,3.82222,3.95556,4,3.22667,2.50667,1.84,1.22667,0.666667,0.16,-0.293333,-0.693333,-1.04,-1.33333,-1.57333,-1.76,-1.89333,-1.97333,-2,-1.74222,-1.50222,-1.28,-1.07556,-0.888889,-0.72,-0.568889,-0.435556,-0.32,-0.222222,-0.142222,-0.08,-0.0355556,-0.0088888" componentsSeparatedByString:@","];
    
    if(_bell_image_cnt == [angles count] - 1){
        // end timer when external counter (bell_image_cnt) finishes the animation angles.
        if(!_after_image) _after_image = image;
        [_statusItem setImage:_after_image];
        
        // cancel timer
        [_animate_bell_timer invalidate];
        _animate_bell_timer = nil;
        _bell_image_cnt = 1;
    }else{
        NSString *i = angles[_bell_image_cnt];
        float x = [i floatValue];
        [_statusItem setImage:[image rotate:x]];
        _bell_image_cnt++;
    }
}

-(NSImage*)getImage{
    return _statusItem.image;
}

-(void)setImage:(NSImage*)image{
    [_statusItem setImage:image];
}
@end
