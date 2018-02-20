//
//  User.h
//  notifi
//
//  Created by Maximilian Mitchell on 16/02/2018.
//  Copyright © 2018 max mitchell. All rights reserved.
//

#import <Foundation/Foundation.h>
@class Socket;
@class Keys;
@class MainWindow;
@class MenuBarClass;

@interface User : NSObject
@property (nonatomic, strong) Socket* s;
@property Keys *keychain;
@property MainWindow *window;
@property MenuBarClass *menu_bar;

-(id)initWithMenuBar:(MenuBarClass*)mb;
-(void)createSocket;
@end
