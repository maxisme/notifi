//
//  MenuBar.h
//  notifi
//
//  Created by Maximilian Mitchell on 16/02/2018.
//  Copyright © 2018 max mitchell. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class MainWindow;
@interface MenuBarClass : NSObject

@property (nonatomic, readonly) NSStatusItem *statusItem;
@property (weak) MainWindow* window;
@property NSTimer* animate_bell_timer;
@property NSImage* after_image;
@property int bell_image_cnt;

-(id)initWithStatusItem:(NSStatusItem *)statusItem window:(MainWindow*)window;
-(void)animateBell;
-(NSImage*)getImage;
-(void)setImage:(NSImage*)image;
@end
