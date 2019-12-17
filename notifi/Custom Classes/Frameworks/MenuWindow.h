//
//  MenuWindow.h
//  notifi
//
//  Created by Maximilian Mitchell on 16/02/2018.
//  Copyright © 2018 max mitchell. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface MenuWindow : NSWindow
@property int WINDOWTOMENUHEIGHT;
@property NSView* view;
@property NSImageView *window_to_menu_img;

- (id)initWithWidth:(int)width height:(int)height colour:(NSColor*)colour;
- (void)showWindowAtMenuBarRect:(NSRect)pos afterAnimation:(void(^)(void))afterAnimation;
- (void)closeWindow;
@end
