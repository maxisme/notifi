//
//  ControllButton.h
//  notifi
//
//  Created by Max Mitchell on 21/01/2018.
//  Copyright © 2018 max mitchell. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface ControlButton: NSButton
@property (strong) NSTrackingArea* trackingArea;
@property float opacity_min;
@end
