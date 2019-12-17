//
//  NotificationLabel.h
//  notifi
//
//  Created by Max Mitchell on 21/01/2018.
//  Copyright © 2018 max mitchell. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@protocol Notification <NSObject>
@optional
- (void) expand;
@end

@interface NotificationLabel: NSTextField
@property (nonatomic, assign) id<Notification> delegate;
@end
