//
//  Window.m
//  notifi
//
//  Created by Max Mitchell on 29/01/2018.
//  Copyright © 2018 max mitchell. All rights reserved.
//

#import "MainWindow.h"

#import <QuartzCore/QuartzCore.h>
#import <CocoaLumberjack/CocoaLumberjack.h>
static const DDLogLevel ddLogLevel = DDLogLevelVerbose;

#import "CustomVars.h"
#import "CustomFunctions.h"

#import "Notification.h"
#import "NotificationLabel.h"
#import "NotificationTable.h"
#import "ControllButton.h"
#import "Cog.h"
#import "SettingsMenu.h"

#import "NSView+Animate.h"
#import "NSImage+Rotate.h"



@implementation MainWindow

#define HEIGHTPERC 0.7

-(id)init{
    if (self != [super init]) return nil;
    
    // create window frame
    float window_height = [[NSScreen mainScreen] frame].size.height * HEIGHTPERC;
    self = [self initWithWidth:[CustomVars windowWidth] height:window_height colour:[CustomVars offwhite]];
    
    // create content of window
    [self setWindowBody];
    
    // scroll listener
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onScroll) name:NSViewBoundsDidChangeNotification object:[_scroll_view contentView]];
    
    //delete notification listener
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deleteNote:) name:@"delete-notification" object:nil];
    
    // update notification times
    [NSTimer scheduledTimerWithTimeInterval:60.0f target:self selector:@selector(updateAllNotificationTimes) userInfo:nil repeats:YES];
    
    return self;
}

-(void)setWindowBody{
    // ----------------- positioning variables -----------------
    int window_width = self.frame.size.width;
    int window_height = self.frame.size.height;
    int bottom_buttons_height = 40;
    int top_bar_height = 90;
    int icon_height = 50;
    int cog_height = 20;
    int cog_padding = 10;
    int scroll_height = (window_height - top_bar_height) - bottom_buttons_height;
    
    int button_y = 7;
    int button_size = 12;
    int button_padding = 35;
    float min_button_opacity = 0.5;
    
    int table_padding = 16;
    // ----------------- top bar -----------------
    
    //bell
    NSImage *icon = [CustomFunctions setImgOriginalSize:[NSImage imageNamed:@"bell.png"]];
    NSImageView *iconView = [[NSImageView alloc] initWithFrame:NSMakeRect(window_width/2 -(icon_height/2), window_height - top_bar_height + 12, icon_height, icon_height)];
    [iconView setImage:icon];
    [iconView setImageScaling:NSImageScaleProportionallyUpOrDown];
    [self.view addSubview:iconView];
    
    //cog
    _settings_menu = [[SettingsMenu alloc] init];
    NSImage *cog = [CustomFunctions setImgOriginalSize:[NSImage imageNamed:@"cog.png"]];
    Cog *cogView = [[Cog alloc] initWithFrame:NSMakeRect(window_width - (cog_height + cog_padding), window_height-(self.WINDOWTOMENUHEIGHT+ cog_height + cog_padding), cog_height, cog_height)];
    [cogView setCustomMenu:_settings_menu];
    [cogView setImage:cog];
    [cogView setImageScaling:NSImageScaleProportionallyUpOrDown];
    [cogView updateTrackingAreas];
    [self.view addSubview:cogView];
    
    // network error message
    _error_label = [[NSTextField alloc] init];
    [_error_label setFrame:CGRectMake(0, iconView.frame.origin.y - self.WINDOWTOMENUHEIGHT, window_width, self.WINDOWTOMENUHEIGHT)];
    [_error_label setWantsLayer:true];
    [_error_label setRefusesFirstResponder:true];
    [_error_label setEditable:false];
    [_error_label setBordered:false];
    [_error_label setSelectable:true];
    [_error_label setDrawsBackground:false];
    [_error_label setStringValue:@"Network Error!"];
    [_error_label setFont:[NSFont fontWithName:@"Montserrat-Regular" size:8]];
    [_error_label setAlignment:NSTextAlignmentCenter];
    [_error_label setTextColor: [CustomVars red]];
    
    [_error_label setHidden:true];
    [self.view addSubview:_error_label];
    
    //top line boarder
    NSView *hor_bor_top = [[NSView alloc] initWithFrame:CGRectMake(0, window_height - top_bar_height, window_width, 1)];
    hor_bor_top.wantsLayer = TRUE;
    [hor_bor_top.layer setBackgroundColor:[[CustomVars boarder] CGColor]];
    [self.view addSubview:hor_bor_top];
    
    
    //----------------- body -----------------
    
    //scroll view
    _scroll_view = [[NSScrollView alloc] initWithFrame:NSMakeRect(0, bottom_buttons_height, window_width, scroll_height)];
    [_scroll_view setNeedsLayout:YES];
    [_scroll_view setBackgroundColor:[CustomVars offwhite]];
    [_scroll_view setBorderType:NSNoBorder];
    [_scroll_view setHasVerticalScroller:YES];
    [_scroll_view setAutohidesScrollers:YES];
    [[_scroll_view contentView] setPostsBoundsChangedNotifications:YES];
    [[_scroll_view contentView] setCopiesOnScroll:NO];
    
    if((int)[[[NSUserDefaults standardUserDefaults] objectForKey:@"notifications"]  count] == 0){
        _scroll_view.documentView = [self noNotificationsScrollView:_scroll_view.frame];
    }else{
        //INITIATE NSTABLE
        [self fillTable];
        
        _notification_table = [[NotificationTable alloc] init];
        [_notification_table setIntercellSpacing:NSMakeSize(table_padding, table_padding / 2)];
        NSTableColumn *column = [[NSTableColumn alloc] initWithIdentifier:@"1"];
        [column setWidth:_scroll_view.frame.size.width - table_padding]; //I swear me needing to do this is a bug
        [_notification_table addTableColumn:column];
        [_notification_table setHeaderView:nil];
        [_notification_table setSelectionHighlightStyle:NSTableViewSelectionHighlightStyleNone];
        [_notification_table setDelegate:(id)self];
        [_notification_table setDataSource:(id)self];
        [_notification_table setBackgroundColor:[NSColor clearColor]];
        
        _scroll_view.documentView = _notification_table;
    }
    [self.view addSubview:_scroll_view];
    
    //----------------- bottom bar -----------------
    
    //mark all as read button
    ControlButton* markAllAsReadBtn = [[ControlButton alloc] initWithFrame:CGRectMake(button_padding / 2, button_y, (window_width / 2) - button_padding, 25)];
    [markAllAsReadBtn setWantsLayer:YES];
    [markAllAsReadBtn setOpacity_min:min_button_opacity];
    [markAllAsReadBtn setButtonType:NSMomentaryChangeButton];
    markAllAsReadBtn.bordered = false;
    [markAllAsReadBtn setFocusRingType:NSFocusRingTypeNone];
    [markAllAsReadBtn setImage:[NSImage imageNamed:@"mark-all-read.png"]];
    [markAllAsReadBtn setImageScaling:NSImageScaleProportionallyUpOrDown];
    [markAllAsReadBtn setAction:@selector(markAllAsRead)];
    [markAllAsReadBtn updateTrackingAreas];
    [self.view addSubview:markAllAsReadBtn];
    
    //horizontal border bottom
    NSView *hor_bor_bot = [[NSView alloc] initWithFrame:CGRectMake(0, bottom_buttons_height, window_width, 1)];
    hor_bor_bot.wantsLayer = TRUE;
    [hor_bor_bot.layer setBackgroundColor:[[CustomVars boarder] CGColor]];
    [self.view addSubview:hor_bor_bot];
    
    //vertical button splitter boarder
    NSView *vert_bor_top = [[NSView alloc] initWithFrame:CGRectMake((window_width / 2) -  1, 0, 1, bottom_buttons_height)];
    vert_bor_top.wantsLayer = TRUE;
    [vert_bor_top.layer setBackgroundColor:[[CustomVars boarder] CGColor]];
    [self.view addSubview:vert_bor_top];
    
    //delete all button
    ControlButton *deleteNotifications = [[ControlButton alloc] initWithFrame:CGRectMake(window_width / 2 + (button_padding /2), button_y, window_width /2 - button_padding, 25)];
    [deleteNotifications setWantsLayer:YES];
    [deleteNotifications setOpacity_min:min_button_opacity];
    [deleteNotifications setButtonType:NSMomentaryChangeButton];
    [deleteNotifications setImage:[NSImage imageNamed:@"delete-all.png"]];
    [deleteNotifications setImageScaling:NSImageScaleProportionallyUpOrDown];
    [deleteNotifications setFocusRingType:NSFocusRingTypeNone];
    deleteNotifications.bordered = false;
    [deleteNotifications setAction:@selector(deleteAll)];
    [deleteNotifications updateTrackingAreas];
    
    [self.view addSubview:deleteNotifications];
}

-(NSView*)noNotificationsScrollView:(NSRect)scroll_frame{
    // ----------------- positioning variables -----------------
    int scroll_width = scroll_frame.size.width;
    int title_height = 60;
    int top_padding = 20;
    
    // ----------------- view -----------------
    NSView *view = [[NSView alloc] initWithFrame:scroll_frame];
    view.wantsLayer = TRUE;
    
    //no notifications text
    NSMutableParagraphStyle *centredStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    [centredStyle setAlignment:NSTextAlignmentCenter];
    
    NSDictionary *noNotificationsAttrs = [NSDictionary dictionaryWithObjectsAndKeys:centredStyle,
                                          NSParagraphStyleAttributeName,
                                          [NSFont fontWithName:@"Montserrat-SemiBold" size:30],
                                          NSFontAttributeName,
                                          [CustomVars grey],
                                          NSForegroundColorAttributeName,
                                          nil];
    NSMutableAttributedString *noNotificationsString =
    [[NSMutableAttributedString alloc] initWithString:@"No Notifications!"
                                           attributes:noNotificationsAttrs];
    
    NotificationLabel* title_field = [[NotificationLabel alloc] init];
    [title_field setFrame:CGRectMake(0, _scroll_view.frame.size.height/2 - title_height/2 - top_padding, scroll_width, title_height)];
    [title_field setAllowsEditingTextAttributes:true];
    [title_field setAttributedStringValue:noNotificationsString];
    [title_field setBackgroundColor:[CustomVars offwhite]];
    title_field.tag = 1;
    
    [view addSubview:title_field];
    
    // sad icon image
    int image_hw = 150;
    NSImageView *image_view = [[NSImageView alloc] initWithFrame:NSMakeRect((scroll_width / 2) - image_hw / 2, title_field.frame.origin.y + (image_hw /2), image_hw, image_hw)];
    [image_view setImageScaling:NSImageScaleProportionallyUpOrDown];
    [image_view setImage:[NSImage imageNamed:@"sad.png"]];
    image_view.tag = 3;
    [view addSubview:image_view];
    
    //send curls message
    NSDictionary *sendCurlAttrs = [NSDictionary dictionaryWithObjectsAndKeys:centredStyle,
                                   NSParagraphStyleAttributeName,
                                   [NSFont fontWithName:@"Montserrat-Regular" size:13],
                                   NSFontAttributeName,
                                   [CustomVars grey],
                                   NSForegroundColorAttributeName,
                                   nil];
    NSMutableAttributedString *sendCurlString =
    [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"To receive notifications use HTTP requests\nalong with your personal credentials: %@",[[NSUserDefaults standardUserDefaults] objectForKey:@"credentials"]] attributes:sendCurlAttrs];
    [sendCurlString addAttribute:NSLinkAttributeName value:[CustomVars how_to:[[NSUserDefaults standardUserDefaults] objectForKey:@"credentials"]] range:NSMakeRange(29,13)];
    [sendCurlString applyFontTraits:NSBoldFontMask range:NSMakeRange(81, 25)];
    
    NotificationLabel* curl_field = [[NotificationLabel alloc] init];
    [curl_field setBackgroundColor:[CustomVars offwhite]];
    [curl_field setFrame:CGRectMake(10, title_field.frame.origin.y - 60, scroll_width - top_padding, 70)];
    curl_field.tag = 2;
    [curl_field setAllowsEditingTextAttributes:true];
    [curl_field setAttributedStringValue:sendCurlString];
    NSTextView* textEditor2 = (NSTextView *)[[[NSApplication sharedApplication] keyWindow] fieldEditor:YES forObject:curl_field];
    [textEditor2 setSelectedTextAttributes:sendCurlAttrs];
    [view addSubview:curl_field];
    
    return view;
}

#pragma mark - Table View
- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return _notifications.count;
}

- (BOOL)tableView:(NSTableView *)aTableView shouldEditTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)row {
    return NO;
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    Notification* n = [_notifications objectAtIndex:row];
    return n;
}

- (CGFloat)tableView:(NSTableView *) tableView heightOfRow:(NSInteger) row {
    Notification* n = [_notifications objectAtIndex:row];
    return n.frame.size.height;
}


#pragma mark - Notifications
-(Notification*)createNotificationFromDic:(NSDictionary*)dic{
    return [[Notification alloc] initWithTitle:[dic objectForKey:@"title"]
                                       message:[dic objectForKey:@"message"]
                                          link:[dic objectForKey:@"link"]
                                     image_url:[dic objectForKey:@"image"]
                                   time_string:[dic objectForKey:@"time"]
                                          read:[[dic objectForKey:@"read"] boolValue]
                                            ID:[[dic objectForKey:@"id"] integerValue]];
}

// get all data stored in NSUserDefaults and create notifications
-(void) fillTable{
    _notifications = [[NSMutableArray alloc] init];
    for(NSMutableDictionary* dic in [[[NSUserDefaults standardUserDefaults] objectForKey:@"notifications"] mutableCopy]){
        [_notifications insertObject:[self createNotificationFromDic:dic] atIndex:0];
    }
    
    [_notification_table reloadData];
    
//    [self updateMenuBarIcon:true];
}

-(Notification*)notificationFromID:(unsigned long)ID{
    for(Notification* n in _notifications) if(n.ID == ID) return n;
    return nil;
}

-(int)numUnreadNotifications{
    int n = 0;
    for(Notification* notification in _notifications){
        if(!notification.read) n++;
    }
    return n;
}

-(void)markAllAsRead{
    for(Notification* n in _notifications) [n markRead:true];
}

-(void)updateAllNotificationTimes{
    for(Notification* n in _notifications) [n reloadTime];
}

-(void)deleteNote:(NSNotification*)obj{
    NSNumber* num = (NSNumber*)obj.userInfo;
    unsigned long ID = [num unsignedLongValue];
    [self deleteNotification:ID];
}

-(void)deleteNotification:(unsigned long)ID{
    NSMutableArray *notifications = [[[NSUserDefaults standardUserDefaults] objectForKey:@"notifications"] mutableCopy];
    
    Notification* n = [self notificationFromID:ID];
    
    //remove notification from stored notifications
    [notifications removeObjectAtIndex:[n defaultsIndex]];
    [[NSUserDefaults standardUserDefaults] setObject:notifications forKey:@"notifications"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    //update GUI
    [_notifications removeObject:n];
    [_notification_table removeRowsAtIndexes:[NSIndexSet indexSetWithIndex:[_notification_table rowForView:n]] withAnimation:NSTableViewAnimationEffectFade];
    
    [CustomFunctions sendNotificationCenter:false name:@"update-menu-icon"];
    
    if([notifications count] == 0){
        [self setWindowBody];
    }
}


#pragma mark - actions

-(void)deleteAll{
    NSMutableArray *notifications = [[[NSUserDefaults standardUserDefaults] objectForKey:@"notifications"] mutableCopy];
    
    if([notifications count] > 0){
        //close window
        if(self && [self isVisible]){
            [self orderOut:self];
        }
        
        //ask if user is sure they want to delete all
        NSAlert *alert = [[NSAlert alloc] init];
        [alert addButtonWithTitle:@"OK"];
        [alert addButtonWithTitle:@"Cancel"];
        [alert setMessageText:[NSString stringWithFormat:@"Delete %d Notifications?", (int)[notifications count]]];
        [alert setInformativeText:@"Warning: Notifications cannot be restored without some sort of wizardry."];
        [alert setAlertStyle:NSWarningAlertStyle];
        
        if ([alert runModal] == NSAlertFirstButtonReturn) { // user agreed
            //delete the stored notifications
            [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"notifications"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            _notifications = nil;
            
            [CustomFunctions sendNotificationCenter:false name:@"update-menu-icon"];
            [self setWindowBody];
        }
    }
}

-(void)onScroll{
//    if([[_scroll_view.documentView className] isEqual: @"NotificationTable"]) [self animate:false];
}

-(void)animate:(bool)should_delay{
    [self animate:should_delay scroll:false];
}

-(void)animate:(bool)should_delay scroll:(bool)should_scroll{
    NSScrollView* scrollView = [_notification_table enclosingScrollView];
    CGRect visibleRect = scrollView.contentView.visibleRect;
    NSRange range = [_notification_table rowsInRect:visibleRect];
    int right =  - self.frame.size.width; // start position of animation
    
    NSUInteger num_notifications = [_notifications count];
    
    NSUInteger start = range.location;
    if(start > 1) start -= 1;
    NSUInteger end = start + range.length + 1;
    if(end >= num_notifications) end = num_notifications; // end is the last notification
    if(num_notifications > 0){ // there are notifications
        for(NSUInteger x = start; x < end; x++){
            Notification* n = [_notifications objectAtIndex:x];
            NSNumber *num = [[NSNumber alloc] initWithUnsignedLongLong:n.ID];
            if(![_notifications_animated containsObject:num]){ // not already animated
                [_notifications_animated addObject:num];
                
                //handle delay
                float delay = 0;
                if (should_delay) delay = (x - start) * 0.07; // on first show
                
                //original positions
                int or_x = n.frame.origin.x;
                int or_y = n.frame.origin.y;
                
                [n animateWithDuration:delay animation:^{
                    NSPoint startPoint = NSMakePoint(or_x + right, or_y);
                    [n setFrameOrigin:startPoint];
                } completion:^{
                    [n animateWithDuration:1 animation:^{
                        NSPoint endPoint = NSMakePoint(or_x, or_y);
                        [[NSAnimationContext currentContext] setTimingFunction:[CAMediaTimingFunction functionWithControlPoints:0.5 :0.5 :0 :1]];
                        [[n animator] setFrameOrigin:endPoint];
                    }];
                    if(should_scroll){
                        [NSAnimationContext beginGrouping];
                        [[NSAnimationContext currentContext] setDuration:0.5];
                        NSClipView* clipView = [_scroll_view contentView];
                        NSPoint newOrigin = [clipView bounds].origin;
                        newOrigin.y = 0;
                        [[clipView animator] setBoundsOrigin:newOrigin];
                        [NSAnimationContext endGrouping];
                    }
                }];
            }
        }
    }else if(![[_scroll_view.documentView className] isEqual: @"NotificationTable"]){
        //animate no notifications label
        NotificationLabel* no_notifications = (NotificationLabel*)[_scroll_view.documentView viewWithTag:1];
        int nn_or_x = no_notifications.frame.origin.x;
        int nn_or_y = no_notifications.frame.origin.y;
        
        NotificationLabel* info = (NotificationLabel*)[_scroll_view.documentView viewWithTag:2];
        int i_or_x = info.frame.origin.x;
        int i_or_y = info.frame.origin.y;
        
        [_scroll_view.documentView animateWithDuration:0 animation:^{
            [no_notifications setFrameOrigin:NSMakePoint(nn_or_x + right, nn_or_y)];
            [info setFrameOrigin:NSMakePoint(i_or_x - right, i_or_y)];
        } completion:^{
            [_scroll_view.documentView animateWithDuration:0.7 animation:^{
                [[NSAnimationContext currentContext] setTimingFunction:[CAMediaTimingFunction functionWithControlPoints:0.5 :0.5 :0 :1]];
                [[no_notifications animator] setFrameOrigin:NSMakePoint(nn_or_x, nn_or_y)];
                [[info animator] setFrameOrigin:NSMakePoint(i_or_x, i_or_y)];
                [self makeKeyAndOrderFront: info];
            }];
        }];
    }
}

@end
