//
//  main.m
//  notify
//
//  Created by Max Mitchell on 20/10/2016.
//  Copyright © 2016 max mitchell. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "AppDelegate.h"
#import "MyApplication.h"

int main(int argc, const char * argv[]) {
    NSArray *tl;
    MyApplication *application = [MyApplication sharedApplication];
    [[NSBundle mainBundle] loadNibNamed:@"mainWindow" owner:application topLevelObjects:&tl];
    
    AppDelegate *applicationDelegate = [[AppDelegate alloc] init];      // Instantiate App  delegate
    [application setDelegate:applicationDelegate];                      // Assign delegate to the NSApplication
    [application run];                                                  // Call the Apps Run method
    
    return 0;       // App Never gets here.
}
