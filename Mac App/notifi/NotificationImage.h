//
//  NotificationImage.h
//  notifi
//
//  Created by Max Mitchell on 21/01/2018.
//  Copyright © 2018 max mitchell. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NotificationImage: NSImageView
@property (strong) NSTrackingArea* trackingArea;
@property (strong) NSString* url;

-(void)setImageFromURL:(NSString*)url hw:(int)hw;
@end
