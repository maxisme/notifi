//
//  AppDelegate.m
//  notifi
//
//  Created by Max Mitchell on 20/10/2016.
//  Copyright © 2016 max mitchell. All rights reserved.
//

#import "AppDelegate.h"

#import <Security/Security.h>
#import <QuartzCore/QuartzCore.h>

#import <SDWebImage/UIImageView+WebCache.h>
#import <STHTTPRequest/STHTTPRequest.h>
#import <Sparkle/Sparkle.h>

#import "Window.h"
#import "Notification.h"
#import "NotificationLabel.h"
#import "NotificationTable.h"
#import "CustomVars.h"
#import "ControllButton.h"
#import "Cog.h"
#import "NSImage+Rotated.h"
#import "SettingsMenu.h"
#import "Keys.h"
#import "Socket.h"
#import "CustomFunctions.h"
#import "Log.h"

@implementation AppDelegate
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    Log* l __unused = [[Log alloc] init]; // l is never used as uses NSNotification to communicate

    [CustomFunctions onlyOneInstanceOfApp];
    
    //initiate keychain
    _keychain = [[Keys alloc] init];
    
    NSString* credentials = [[NSUserDefaults standardUserDefaults] objectForKey:@"credentials"];
    if([credentials length] != 25){
        //new user
        [self newCredentials];
        [CustomFunctions openOnStartup];
        
        [[NSUserDefaults standardUserDefaults] setBool:true forKey:@"sticky_notification"];
    }
    
    [self createSocket];
    
    [self createStatusBarItem];
    
    // update notification times
    [NSTimer scheduledTimerWithTimeInterval:60.0f target:self selector:@selector(updateNotificationTimes) userInfo:nil repeats:YES];
    
    // scroll call back
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onScroll) name:NSViewBoundsDidChangeNotification object:_scroll_view];
    
    [self createWindow];
    
    [CustomFunctions checkForUpdate:false];
    
    // EVENT LISTENERS
    //update menu icon
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateMBIcon:) name:@"update-menu-icon" object:nil];
    
    //delete notification
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deleteNote:) name:@"delete-notification" object:nil];
    
    //create new credentials
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(newCredentials) name:@"create-credentials" object:nil];
}

-(void)createSocket{
    if(_s) [_s close];
    _s = [[Socket alloc] initWithURL:@"wss://s.notifi.it"];
    
    __weak typeof(self) weakSelf = self;
    
    [_s setOnConnectBlock:^{
        [_s send:[weakSelf authMessage]];
    }];
    
    [_s setOnCloseBlock:^{
        [weakSelf updateMenuBarIcon:false];
    }];
    
    [_s setOnMessageBlock:^(NSString *message) {
        [weakSelf handleSocketMessage:message];
    }];
}

#pragma mark - window
float screen_height; // used when opening new window to check if different screen
float screen_width;
int top_arrow_height;
-(void)createWindow{
    //position variables
    screen_width = [[NSScreen mainScreen] frame].size.width;
    screen_height = [[NSScreen mainScreen] frame].size.height;
    
    float window_height = screen_height * 0.7;
    int window_width = [CustomVars windowWidth];
    top_arrow_height = 20;
    
    int side_padding = 10;
    
    //position variables
    NSRect menu_icon_frame = [[_status_item valueForKey:@"window"] frame];
    float menu_icon_width = menu_icon_frame.size.width;
    float menu_icon_x = menu_icon_frame.origin.x;
    float menu_icon_y = menu_icon_frame.origin.y;
    
    //calculate positions
    float arrow_x = window_width/2 - (top_arrow_height/2);
    float arrow_y = window_height - top_arrow_height;
    float window_x = (menu_icon_x + menu_icon_width/2) - window_width / 2;
    float window_y = menu_icon_y - window_height;
    
    if(window_width + window_x > screen_width){ //window will fall out of screen
        window_x = screen_width - window_width - side_padding;
        arrow_x = menu_icon_x + menu_icon_width/2 - window_x - side_padding;
    }
    
    _window = nil; // no idea why you have to do this when creating a new window for different monitor size
    _window = [[Window alloc] initWithContentRect:NSMakeRect(window_x, window_y, window_width, window_height) styleMask:0 backing:NSBackingStoreBuffered defer:YES];
    [_window setIdentifier:@"main"];
    [_window setOpaque:NO];
    [_window setBackgroundColor:[NSColor clearColor]];
    [_window setReleasedWhenClosed: YES];
    [_window setDelegate:(id)self];
    [_window setHasShadow: YES];
    [_window setHidesOnDeactivate:YES];
    [_window setLevel:NSMainMenuWindowLevel];
    
    NSMenu *mm = [NSApp mainMenu];
    NSMenuItem *myBareMetalAppItem = [mm itemAtIndex:0];
    NSMenu *subMenu = [myBareMetalAppItem submenu];
    NSMenuItem *prefMenu = [subMenu itemWithTag:100];
    prefMenu.target = self;
    
    // Create a view
    _view = nil;
    _view = [[self window] contentView];
    [_view setWantsLayer:YES];
    _view.autoresizingMask = NSViewHeightSizable;
	[_view.layer setBackgroundColor:[NSColor clearColor].CGColor];
    
    NSImage* window_up_arrow = [NSImage imageNamed:@"up_arrow.png"];
    _window_up_arrow_view = [[NSImageView alloc] initWithFrame:NSMakeRect(arrow_x, arrow_y, top_arrow_height, top_arrow_height)];
    [_window_up_arrow_view setImage:window_up_arrow];
    [_view addSubview:_window_up_arrow_view];
    
    _vis_view = [[NSView alloc] initWithFrame:CGRectMake(0, 0, window_width, window_height - (top_arrow_height - 5))];
    [_vis_view setWantsLayer:YES];
    [_vis_view.layer setBackgroundColor:[CustomVars white].CGColor];
    _vis_view.layer.cornerRadius = 10;
    [_view addSubview:_vis_view];
    
    [self createBodyWindow];
}

ControlButton* markAllAsReadBtn;
-(void)createBodyWindow{
    int bottom_buttons_height = 40;
    int top_bar_height = 90;
    
    // ----------------- top stuff -----------------
    int window_width = _window.frame.size.width;
    int window_height = _window.frame.size.height;
    int top_arrow_height = _window_up_arrow_view.frame.size.height;
    
    //bell
    NSImage *icon = [NSImage imageNamed:@"bell.png"];
    NSBitmapImageRep *rep = [NSBitmapImageRep imageRepWithData:[icon TIFFRepresentation]];
    NSSize size = NSMakeSize([rep pixelsWide], [rep pixelsHigh]);
    [icon setSize: size];
    int icon_height = 50;
    NSImageView *iconView = [[NSImageView alloc] initWithFrame:NSMakeRect(window_width/2 -(icon_height/2), window_height - top_bar_height + top_arrow_height - 5, icon_height, icon_height)];
    [iconView setImage:icon];
    [iconView setImageScaling:NSImageScaleProportionallyUpOrDown];
    [_view addSubview:iconView];
    
    //cog
    _sm = [[SettingsMenu alloc] init];
    NSImage *cog = [NSImage imageNamed:@"Anton Saputro.png"];
    NSBitmapImageRep *cog_rep = [NSBitmapImageRep imageRepWithData:[cog TIFFRepresentation]];
    NSSize cog_size = NSMakeSize([cog_rep pixelsWide], [cog_rep pixelsHigh]);
    [cog setSize: cog_size];
    int cog_height = 20;
    int cog_pad = 10;
    Cog *cogView = [[Cog alloc] initWithFrame:NSMakeRect(window_width - (cog_height + cog_pad), window_height-(cog_height + top_arrow_height + cog_pad), cog_height, cog_height)];
    [cogView setCustomMenu:_sm];
    [cogView setImage:cog];
    [cogView setImageScaling:NSImageScaleProportionallyUpOrDown];
    [cogView updateTrackingAreas];
    [_view addSubview:cogView];
    
    // network error message
    NSTextField* error_label = [[NSTextField alloc] init];
    [error_label setFrame:CGRectMake(0, iconView.frame.origin.y - 20, window_width, 20)];
    [error_label setWantsLayer:true];
    [error_label setRefusesFirstResponder:true];
    [error_label setEditable:false];
    [error_label setBordered:false];
    [error_label setSelectable:true];
    [error_label setDrawsBackground:false];
    [error_label setStringValue:@"Network Error!"];
    [error_label setFont:[NSFont fontWithName:@"OpenSans-Bold" size:8]];
    [error_label setAlignment:NSTextAlignmentCenter];
    [error_label setTextColor: [CustomVars red]];
    
    error_label.hidden = true;
    error_label.tag = 1;
    [_view addSubview:error_label];
    
    //top line boarder
    NSView *hor_bor_top = [[NSView alloc] initWithFrame:CGRectMake(0, window_height - top_bar_height, window_width, 1)];
    hor_bor_top.wantsLayer = TRUE;
    [hor_bor_top.layer setBackgroundColor:[[CustomVars boarder] CGColor]];
    [_view addSubview:hor_bor_top];
    
    
    //----------------- body -----------------
    
    //scroll view
    float scroll_height = (window_height - top_bar_height) - bottom_buttons_height;
    _scroll_view = [[NSScrollView alloc] initWithFrame:NSMakeRect(0, bottom_buttons_height, window_width, scroll_height)];
    [_scroll_view setNeedsLayout:YES];
    [_scroll_view setBackgroundColor:[CustomVars offwhite]];
    [_scroll_view setBorderType:NSNoBorder];
    [_scroll_view setHasVerticalScroller:YES];
    [_scroll_view setAutohidesScrollers:YES];
    [[_scroll_view contentView] setPostsBoundsChangedNotifications:YES];
    [[_scroll_view contentView] setCopiesOnScroll:NO];
    
    if((int)[[[NSUserDefaults standardUserDefaults] objectForKey:@"notifications"]  count] == 0){
        _scroll_view.documentView = [self noNotificationsView];
    }else{
        //INITIATE NSTABLE
        [self fillTable];
        int padding = 16;
        
        _notification_table = [[NotificationTable alloc] init];
        [_notification_table setIntercellSpacing:NSMakeSize(padding, padding / 2)];
        NSTableColumn *column = [[NSTableColumn alloc] initWithIdentifier:@"1"];
        [column setWidth:_scroll_view.frame.size.width - padding]; //I swear me needing to do this is a bug
        [_notification_table addTableColumn:column];
        [_notification_table setHeaderView:nil];
        [_notification_table setSelectionHighlightStyle:NSTableViewSelectionHighlightStyleNone];
        [_notification_table setDelegate:(id)self];
        [_notification_table setDataSource:(id)self];
        [_notification_table setBackgroundColor:[CustomVars offwhite]];
        
        _scroll_view.documentView = _notification_table;
    }
    [_view addSubview:_scroll_view];
    
    //----------------- bottom stuff -----------------
    int button_y = 7;
    float min_opac = 0.7;
    float button_size = 12;
    int p = 35;
    
    //horizontal border bottom
    NSView *hor_bor_bot = [[NSView alloc] initWithFrame:CGRectMake(0, bottom_buttons_height, window_width, 1)];
    hor_bor_bot.wantsLayer = TRUE;
    [hor_bor_bot.layer setBackgroundColor:[[CustomVars boarder] CGColor]];
    [_view addSubview:hor_bor_bot];
    
    //mark all as read button
    markAllAsReadBtn = [[ControlButton alloc] initWithFrame:CGRectMake(p / 2, button_y, (window_width / 2) - p, 25)];
    [markAllAsReadBtn setWantsLayer:YES];
    [markAllAsReadBtn setOpacity_min:min_opac];
    [markAllAsReadBtn setButtonType:NSMomentaryChangeButton];
    [markAllAsReadBtn setAlignment:NSTextAlignmentCenter];
    [markAllAsReadBtn setFont:[NSFont fontWithName:@"OpenSans-Bold" size:button_size]];
    markAllAsReadBtn.bordered = false;
    [markAllAsReadBtn setFocusRingType:NSFocusRingTypeNone];
    [markAllAsReadBtn setTitle:@"MARK ALL AS READ"];
    [markAllAsReadBtn setAction:@selector(markAllAsRead)];
    [markAllAsReadBtn updateTrackingAreas];
    [_view addSubview:markAllAsReadBtn];
    
    //vertical button splitter boarder
    NSView *vert_bor_top = [[NSView alloc] initWithFrame:CGRectMake((window_width / 2) -  1, 0, 1, bottom_buttons_height)];
    vert_bor_top.wantsLayer = TRUE;
    [vert_bor_top.layer setBackgroundColor:[[CustomVars boarder] CGColor]];
    [_view addSubview:vert_bor_top];
    
    //delete all button
    ControlButton *deleteNotifications = [[ControlButton alloc] initWithFrame:CGRectMake(window_width / 2 + (p /2), button_y, window_width /2 - p, 25)];
    [deleteNotifications setWantsLayer:YES];
    [deleteNotifications setOpacity_min:min_opac];
    [deleteNotifications setButtonType:NSMomentaryChangeButton];
    
    NSMutableParagraphStyle *centredStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    [centredStyle setAlignment:NSCenterTextAlignment];
    
    NSDictionary *attrs = [NSDictionary dictionaryWithObjectsAndKeys:centredStyle,
                           NSParagraphStyleAttributeName,
                           [NSFont fontWithName:@"OpenSans-Bold" size:button_size],
                           NSFontAttributeName,
                           [CustomVars red],
                           NSForegroundColorAttributeName,
                           nil];
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:@"DELETE ALL" attributes:attrs];
    [deleteNotifications setAttributedTitle:attributedString];
    [deleteNotifications setFocusRingType:NSFocusRingTypeNone];
    deleteNotifications.bordered =false;
    [deleteNotifications setAction:@selector(deleteAll)];
    [deleteNotifications updateTrackingAreas];
    
    [_view addSubview:deleteNotifications];
}

-(void)positionWindow{
    //position variables relative to status item
    float window_height = self.window.frame.size.height;
    float window_width = self.window.frame.size.width;
    NSRect menu_icon_frame = [[_status_item valueForKey:@"window"] frame];
    float menu_icon_width = menu_icon_frame.size.width;
    float menu_icon_x = menu_icon_frame.origin.x;
    float menu_icon_y = menu_icon_frame.origin.y;
    
    //calculate positions of window on screen and arrow
    float arrow_x = window_width/2 - (top_arrow_height/2);
    float arrow_y = window_height - top_arrow_height;
    float window_x = (menu_icon_x + menu_icon_width/2) - window_width / 2;
    float window_y = menu_icon_y - window_height;
    
    // update positions
    [_window_up_arrow_view setFrame:NSMakeRect(arrow_x, arrow_y, top_arrow_height, top_arrow_height)];
    [_window setFrame:NSMakeRect(window_x, window_y, window_width, window_height) display:true];
    [_vis_view setFrame:CGRectMake(0, 0, window_width, window_height - (top_arrow_height - 5))];
}

-(void)onScroll{
    if([[_scroll_view.documentView className] isEqual: @"NotificationTable"]) [self animate:false];
}

NSTimer* animate_bell_timer;
int bell_image_cnt;
-(void)animateBell:(NSImage*)image{
    if(!animate_bell_timer){
        after_image = nil;
    }
    
    // cancel timer
    [animate_bell_timer invalidate];
    animate_bell_timer = nil;
    bell_image_cnt = 0;
    
    animate_bell_timer = [NSTimer scheduledTimerWithTimeInterval:0.015 target:self selector:@selector(updateBellImage) userInfo:nil repeats:YES];
}

NSImage* after_image;
- (void)updateBellImage
{
    NSImage* image = [NSImage imageNamed:@"alert_menu_bellicon.png" ];;
    NSArray *numbers = [@"-20,-15.1022,-10.5422,-6.32,-2.43556,1.11111,4.32,7.19111,9.72444,11.92,13.7778,15.2978,16.48,17.3244,17.8311,18,13.6178,9.53778,5.76,2.28444,-0.888889,-3.76,-6.32889,-8.59556,-10.56,-12.2222,-13.5822,-14.64,-15.3956,-15.8489,-16,-12.1333,-8.53333,-5.2,-2.13333,0.666667,3.2,5.46667,7.46667,9.2,10.6667,11.8667,12.8,13.4667,13.8667,14,10.52,7.28,4.28,1.52,-1,-3.28,-5.32,-7.12,-8.68,-10,-11.08,-11.92,-12.52,-12.88,-13,-9.77778,-6.77778,-4,-1.44444,0.888889,3,4.88889,6.55556,8,9.22222,10.2222,11,11.5556,11.8889,12,9.16444,6.52444,4.08,1.83111,-0.222222,-2.08,-3.74222,-5.20889,-6.48,-7.55556,-8.43556,-9.12,-9.60889,-9.90222,-10,-7.68,-5.52,-3.52,-1.68,-7.10543e-15,1.52,2.88,4.08,5.12,6,6.72,7.28,7.68,7.92,8,6.19556,4.51556,2.96,1.52889,0.222222,-0.96,-2.01778,-2.95111,-3.76,-4.44444,-5.00444,-5.44,-5.75111,-5.93778,-6,-4.71111,-3.51111,-2.4,-1.37778,-0.444444,0.4,1.15556,1.82222,2.4,2.88889,3.28889,3.6,3.82222,3.95556,4,3.22667,2.50667,1.84,1.22667,0.666667,0.16,-0.293333,-0.693333,-1.04,-1.33333,-1.57333,-1.76,-1.89333,-1.97333,-2,-1.74222,-1.50222,-1.28,-1.07556,-0.888889,-0.72,-0.568889,-0.435556,-0.32,-0.222222,-0.142222,-0.08,-0.0355556,-0.0088888" componentsSeparatedByString:@","];
    
    if(bell_image_cnt == [numbers count] - 1){
        if(!after_image) after_image = image;
        [_status_item setImage:after_image];
        
        // cancel timer
        [animate_bell_timer invalidate];
        animate_bell_timer = nil;
    }else{
        NSString *i = numbers[bell_image_cnt];
        float x = [i floatValue];
        [_status_item setImage:[image imageRotated:x]];
        bell_image_cnt++;
    }
}

-(NSView*)noNotificationsView{
    int window_width = _window.frame.size.width;
    
    AnimateView *view = [[AnimateView alloc] initWithFrame:_scroll_view.frame];
    view.wantsLayer = TRUE;
    
    //no notifications text
    NSMutableParagraphStyle *centredStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    [centredStyle setAlignment:NSTextAlignmentCenter];
    
    int title_height = 60;
    NSDictionary *noNotificationsAttrs = [NSDictionary dictionaryWithObjectsAndKeys:centredStyle,
                                          NSParagraphStyleAttributeName,
                                          [NSFont fontWithName:@"OpenSans-Bold" size:30],
                                          NSFontAttributeName,
                                          [CustomVars grey],
                                          NSForegroundColorAttributeName,
                                          nil];
    NSMutableAttributedString *noNotificationsString =
    [[NSMutableAttributedString alloc] initWithString:@"No Notifications!"
                                           attributes:noNotificationsAttrs];
    
    NotificationLabel* title_field = [[NotificationLabel alloc] init];
    [title_field setFrame:CGRectMake(0, _scroll_view.frame.size.height/2 - title_height/2 - 20, window_width, title_height)];
    [title_field setAllowsEditingTextAttributes:true];
    [title_field setAttributedStringValue:noNotificationsString];
    [title_field setBackgroundColor:[CustomVars offwhite]];
    title_field.tag = 1;
    
    [view addSubview:title_field];
    
    // SAD ICON IMAGE
    int image_hw = 150;
    NSImageView *image_view = [[NSImageView alloc] initWithFrame:NSMakeRect((window_width / 2) - image_hw / 2, title_field.frame.origin.y + (image_hw /2), image_hw, image_hw)];
    [image_view setImageScaling:NSImageScaleProportionallyUpOrDown];
    [image_view setImage:[NSImage imageNamed:@"sad.png"]];
    image_view.tag = 3;
    [view addSubview:image_view];
    
    //send curls
    NSDictionary *sendCurlAttrs = [NSDictionary dictionaryWithObjectsAndKeys:centredStyle,
                                   NSParagraphStyleAttributeName,
                                   [NSFont fontWithName:@"OpenSans-Regular" size:13],
                                   NSFontAttributeName,
                                   [CustomVars grey],
                                   NSForegroundColorAttributeName,
                                   nil];
    NSMutableAttributedString *sendCurlString =
    [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"To receive notifications use HTTP requests\nalong with your personal credentials: %@",[[NSUserDefaults standardUserDefaults] objectForKey:@"credentials"]] attributes:sendCurlAttrs];
    [sendCurlString addAttribute:NSLinkAttributeName value:[CustomVars how_to] range:NSMakeRange(29,13)];
    [sendCurlString applyFontTraits:NSBoldFontMask range:NSMakeRange(81, 25)];
    
    NotificationLabel* curl_field = [[NotificationLabel alloc] init];
    [curl_field setBackgroundColor:[CustomVars offwhite]];
    [curl_field setFrame:CGRectMake(10, title_field.frame.origin.y - 60, window_width - 20, 70)];
    curl_field.tag = 2;
    [curl_field setAllowsEditingTextAttributes:true];
    [curl_field setAttributedStringValue:sendCurlString];
    NSTextView* textEditor2 = (NSTextView *)[[[NSApplication sharedApplication] keyWindow] fieldEditor:YES forObject:curl_field];
    [textEditor2 setSelectedTextAttributes:sendCurlAttrs];
    [view addSubview:curl_field];
    
    return view;
}

#pragma mark - Table View Data Source

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

// get all data stored in NSUserDefaults and create actual notification views
-(void) fillTable{
    _notifications = [[NSMutableArray alloc] init];
    for(NSMutableDictionary* dic in [[[NSUserDefaults standardUserDefaults] objectForKey:@"notifications"] mutableCopy]){
        [_notifications insertObject:[self createNotificationFromDic:dic] atIndex:0];
    }
    
    [_notification_table reloadData];
    
    [self updateMenuBarIcon:true];
}

#pragma mark - notification
-(void)animate:(bool)should_delay{
    [self animate:should_delay scroll:false];
}

NSMutableArray *animatedNotifications;
-(void)animate:(bool)should_delay scroll:(bool)should_scroll{
    NSScrollView* scrollView = [_notification_table enclosingScrollView];
    CGRect visibleRect = scrollView.contentView.visibleRect;
    NSRange range = [_notification_table rowsInRect:visibleRect];
    
    int num_notifications = (int)[_notifications count];
    
    int right =  - _window.frame.size.width; // start position of animation
    
    int start = (int)range.location;
    if(start > 1) start -= 1;
    int end = start + (int)range.length + 1;
    if(end >= num_notifications) end = num_notifications; // end is the last notification
    
    if(num_notifications > 0){ // there are notifications
        for(int x = start; x < end; x++){
            Notification* n = [_notifications objectAtIndex:x];
            NSNumber *num = [[NSNumber alloc] initWithUnsignedLong:n.ID];
            if(![animatedNotifications containsObject:num]){ // not already animated
                [animatedNotifications addObject:num];
                
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
                [_window makeKeyAndOrderFront: info];
            }];
        }];
    }
}

-(BOOL)hasNotifications{
    NSMutableArray *notifications = [[[NSUserDefaults standardUserDefaults] objectForKey:@"notifications"] mutableCopy];
    return (int)[notifications count] != 0;
}

- (void)createStatusBarItem {
    _status_item = [[NSStatusBar systemStatusBar] statusItemWithLength:NSSquareStatusItemLength];
    _status_item.image = [NSImage imageNamed:@"menu_bellicon.png"];
    [_status_item setAction:@selector(iconClick)];
    [_status_item setTarget:self];
}

// for nsnotification
-(void)updateMBIcon:(NSNotification*)obj{
    bool ani = (bool)obj.userInfo;
    [self updateMenuBarIcon:ani];
}

-(void)updateMenuBarIcon:(bool)ani{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSImage* error_icon = [NSImage imageNamed:@"menu_error_bellicon.png" ];
        NSImage* alert_icon = [NSImage imageNamed:@"alert_menu_bellicon.png" ];
        NSImage* menu_icon = [NSImage imageNamed:@"menu_bellicon.png" ];
        
        if(!_s.authed){
            if(_status_item.image != error_icon){
                _status_item.image = error_icon;
                after_image = error_icon;
            }
        }else if([self numUnreadNotifications] > 0){
            if(ani){
                [self animateBell:alert_icon];
            }else{
                _status_item.image = alert_icon;
            }
        }else{
            if(_status_item.image != menu_icon){
                _status_item.image = menu_icon;
                after_image = menu_icon;
            }
        }
    });
}

-(int)numUnreadNotifications{
    int n = 0;
    for(Notification* notification in _notifications){
        if(!notification.read) n++;
    }
    return n;
}

-(void)updateNotificationTimes{
    for(Notification* n in _notifications) [n reloadTime];
}

-(void)showWindow{
    [Log log:@"showwindow"];
    [[NSUserNotificationCenter defaultUserNotificationCenter] removeAllDeliveredNotifications];
    
    _window.alphaValue = 0;
    _window.animator.alphaValue = 0.0f;
    
    [self positionWindow];
    [NSApp activateIgnoringOtherApps:YES];
    [_window makeKeyAndOrderFront: nil];
    [_view.window makeFirstResponder:nil]; //remove any selections
    
    //fade in
    [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context) {
        context.duration = 0.4;
        _window.animator.alphaValue = 1.0f;
        
        //animate
        animatedNotifications = [NSMutableArray array];
        [self animate:true];
    }
    completionHandler:^{
        [_view setNeedsDisplay:YES];
        [_view setNeedsLayout:YES];
        [_view setNeedsUpdateConstraints:YES];
        [_view layoutSubtreeIfNeeded];
    }];
}

//when clicking icon
- (void)iconClick{
    if([_window isKeyWindow]){
        [_window orderOut:self];
    }else{
        [self showWindow];
    }
}


#pragma mark - set key
-(NSString*)authMessage{
    NSString* credentials = [[NSUserDefaults standardUserDefaults] objectForKey:@"credentials"];
    NSString* key = [_keychain getKey:@"credential_key"];
    
    return [NSString stringWithFormat:@"%@|%@|%@|%@", credentials, key, [CustomFunctions getSystemUUID], [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"]];
}

-(void)newCredentials{
    if(![_sm.credentials isEqual: @"Fetching credentials..."]){
        [_sm.credentials setTitle:@"Fetching credentials..."];
        [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"notifications"]; // delete all stored notifications
        
        STHTTPRequest *r = [STHTTPRequest requestWithURLString:@"https://notifi.it/getCode.php"];
        r.POSTDictionary = @{ @"UUID":[CustomFunctions getSystemUUID]};
        NSError *error = nil;
        NSString *content = [r startSynchronousWithError:&error];
        
        NSString* key = [CustomFunctions jsonToVal:content key:@"key"];
        NSString* credentials = [CustomFunctions jsonToVal:content key:@"credentials"];
        
        if(![key isEqual: @""] && ![credentials isEqual: @""]){
            [_keychain setKey:@"credential_key" withPassword:key];
            [[NSUserDefaults standardUserDefaults] setObject:credentials forKey:@"credentials"];
            [_sm.credentials setTitle:credentials];
            
            //close window
            if(_window && [_window isVisible]){
                [_window orderOut:self];
            }
            
            [self createWindow];
        }else{
            NSAlert *alert = [[NSAlert alloc] init];
            [alert setInformativeText:@"Please try again."];
            [alert addButtonWithTitle:@"Ok"];
            if([content  isEqual: @"0"]){
                [_sm.credentials setTitle:@"Please click 'Create New Credentials'!"];
                [alert setMessageText:@"Credentials already registered!"];
            }else{
                [_sm.credentials setTitle:@"Error Fetching credentials!"];
                [alert setMessageText:@"Error Fetching credentials!"];
                if(error){
                    [alert setInformativeText:[NSString stringWithFormat:@"Error message: %@",error]];
                }else{
                    [alert setInformativeText:[NSString stringWithFormat:@"Error message: %@",content]];
                }
            }
            [alert runModal];
        }
        
        [self createSocket];
    }
}

-(void)handleSocketMessage:(NSString*)message{
    if([message isEqual: @"Invalid Credentials"]){
        dispatch_async(dispatch_get_main_queue(), ^{
            NSAlert *alert = [[NSAlert alloc] init];
            [alert setMessageText:@"Invalid Credentials!"];
            [alert setInformativeText:@"For some suspicious reason your credentials have been altered. You will be assigned new ones."];
            [alert addButtonWithTitle:@"Ok"];
            [alert runModal];
            
            [self newCredentials];
        });
    }else{
        _s.authed = true;
        [self updateMenuBarIcon:false];
        
        NSError* error = nil;
        NSData* data = [message dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary* json_dic = [NSJSONSerialization
                                  JSONObjectWithData:data
                                  options:kNilOptions
                                  error:&error];
        if(!error){
            BOOL shouldRefresh = false;
            NSMutableArray* incoming_notifications = [[NSMutableArray alloc] init];
            
            // get all the notifications from json_dic and tell the server
            // that they have been received.
            // each notification comes with an encrypted unique "id:" tag
            for (NSDictionary* notification in json_dic) {
                NSString* firstval = [NSString stringWithFormat:@"%@", notification];
                if([[firstval substringToIndex:3]  isEqual: @"id:"]){
                    // TELL SERVER TO REMOVE STORED MESSAGE
                    if(_s.authed){
                        [_s send:firstval];
                    }
                }else{
                    [Notification storeNotificationDic:notification];
                    [incoming_notifications addObject:notification];
                    shouldRefresh = true;
                }
            }
            
            if(shouldRefresh){
                //update ui and add notifications
                dispatch_async(dispatch_get_main_queue(), ^{
                    BOOL has_created_new_table = false;
                    if(!_notification_table || _notifications == nil){
                        has_created_new_table = true;
                        [self createBodyWindow];
                    }else if(_notification_table && _scroll_view.documentView != _notification_table){
                        // showing original notification table rather than creating it 
                        _scroll_view.documentView = _notification_table;
                    }
                    
                    if(!has_created_new_table){
                        for (NSDictionary* dic in incoming_notifications){
                            [_notifications insertObject:[self createNotificationFromDic:dic] atIndex:0];
                            [_notification_table insertRowsAtIndexes:[NSIndexSet indexSetWithIndex:0] withAnimation:NSTableViewAnimationEffectGap];
                        }
                        [self animate:NO scroll:true];
                    }
                    
                    [self updateMenuBarIcon:true];
                });
                
                //send notification
                if([incoming_notifications count] <= 5){
                    for (NSDictionary* notification in incoming_notifications){
                        if(![_window isKeyWindow]){
                            [self sendLocalNotification:[notification objectForKey:@"title"]
                                                message:[notification objectForKey:@"message"]
                                               imageURL:[notification objectForKey:@"image"]
                                                   link:[notification objectForKey:@"link"]
                                                    ID:[[notification objectForKey:@"id"] intValue]
                             ];
                        }
                    }
                }else{
                    //send notification with the amount of notifications rather than each individual notifications
                    NSUserNotification *note = [[NSUserNotification alloc] init];
                    [note setHasActionButton:false];
                    [note setTitle:@"notifi"];
                    [note setInformativeText:[NSString stringWithFormat:@"You have %d new notifications!",(int)[incoming_notifications count]]];
                    [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:note];
                    [[NSUserNotificationCenter defaultUserNotificationCenter] setDelegate:(id)self];
                }
            }
        }else if(![message isEqualToString:@"1"]){
            [Log log:[NSString stringWithFormat:@"Unrecognised message from socket: %@", message]];
        }
    }
}

-(Notification*)createNotificationFromDic:(NSDictionary*)dic{
    return [[Notification alloc] initWithTitle:[dic objectForKey:@"title"]
                                                  message:[dic objectForKey:@"message"]
                                                     link:[dic objectForKey:@"link"]
                                                image_url:[dic objectForKey:@"image"]
                                              time_string:[dic objectForKey:@"time"]
                                                     read:[[dic objectForKey:@"read"] boolValue]
                                                      ID:[[dic objectForKey:@"id"] intValue]];
}



//used to get Notification class object
-(Notification*)notificationFromID:(unsigned long)ID{
    for(Notification* n in _notifications){
        if(n.ID == ID) return n;
    }
    return nil;
}


-(void)markAllAsRead{
    for(Notification* n in _notifications) [n markRead];
}

// from nsnotification
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
    
    [self updateMenuBarIcon:false];
    
    if([notifications count] == 0){
        [self createBodyWindow];
    }
}

-(void)deleteAll{
    NSMutableArray *notifications = [[[NSUserDefaults standardUserDefaults] objectForKey:@"notifications"] mutableCopy];
    
    if([notifications count] > 0){
        //close window
        if(_window && [_window isVisible]){
            [_window orderOut:self];
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
            
            [self updateMenuBarIcon:false];
            
            [self createWindow];
        }
    }
}


#pragma mark - notifications
-(void)sendLocalNotification:(NSString*)title message:(NSString*)mes imageURL:(NSString*)imgURL link:(NSString*)url ID:(unsigned long)ID{
    NSUserNotification *notification = [[NSUserNotification alloc] init];
    
    //pass variables through notification
    notification.userInfo = @{
                              @"ID" : [NSString stringWithFormat:@"%lu", ID],
                              @"url" : url
                              };
    
    [notification setTitle:title];
    
    if(![mes isEqual: [CustomVars default_empty]]) [notification setInformativeText:mes];
    
    if(![imgURL isEqual: [CustomVars default_empty]]){
        NSImage* image;
        @try {
            image = [[NSImage alloc] initWithContentsOfURL:[NSURL URLWithString:imgURL]];
            [notification setContentImage:image];
        }
        @catch (NSException * e) {
            [Log log:[NSString stringWithFormat:@"Problem loading image from URL: %@", imgURL]];
        }
    }
    
    [notification setActionButtonTitle:@"Open Link"];
    if(![url  isEqual: [CustomVars default_empty]]){
        [notification setHasActionButton:true];
    }else{
        [notification setHasActionButton:false];
    }
    
    [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];
    [[NSUserNotificationCenter defaultUserNotificationCenter] setDelegate:(id)self];
    
    // remove notification after ceratain amount of time depending
    if(![[NSUserDefaults standardUserDefaults] boolForKey:@"sticky_notification"]){
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 10 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            [[NSUserNotificationCenter defaultUserNotificationCenter] removeDeliveredNotification: notification];
        });
    }
}

- (void) userNotificationCenter:(NSUserNotificationCenter *)center didActivateNotification:(NSUserNotification *)notification
{
    bool openWindow = true;
    if(notification.userInfo[@"ID"]){
        int ID = [notification.userInfo[@"ID"] intValue];
        NSString* url_string = notification.userInfo[@"url"];
        
        NSURL* url;
        if(![url_string isEqual: [CustomVars default_empty]]){
            @try {
                url = [NSURL URLWithString:url_string];
                openWindow = false;
            } @catch (NSException *exception) {
                [Log log:[NSString stringWithFormat:@"Not a valid link url - %@", url_string]];
            }
        }
        
        if(url) [[NSWorkspace sharedWorkspace] openURL:url];
        [[self notificationFromID:ID] markRead];
    }
    
    if(notification.activationType == NSUserNotificationActivationTypeContentsClicked){
        [self showWindow];
    }else{
        [_window orderOut:self];
    }
    
    [center removeDeliveredNotification: notification];
}

- (BOOL)userNotificationCenter:(NSUserNotificationCenter *)center shouldPresentNotification:(NSUserNotification *)notification {
    return YES;
}
@end
