//
//  AppDelegate.m
//  notifi
//
//  Created by Max Mitchell on 20/10/2016.
//  Copyright © 2016 max mitchell. All rights reserved.
//


#import "AppDelegate.h"

// ----- notification view interface -----
@interface MyNotificationView: NSView
@property (nonatomic) int theid;
@property (atomic, weak) AppDelegate* thisapp;
@end

@implementation MyNotificationView
- (void) rightMouseDown:(NSEvent *)event {
    NSMenu *theMenu = [[NSMenu alloc] initWithTitle:@"Contextual Menu"];
    if([_thisapp notificationRead:_theid]){
        [theMenu insertItemWithTitle:@"Mark notification as unread" action:@selector(markUnread) keyEquivalent:@"" atIndex:0];
    }else{
        [theMenu insertItemWithTitle:@"Mark notification as read" action:@selector(markRead) keyEquivalent:@"" atIndex:0];
    }
    
    [theMenu insertItemWithTitle:@"Delete notification" action:@selector(deleteNoti) keyEquivalent:@"" atIndex:1];
    
    NSString* url = [_thisapp notificationLink:_theid];
    if(![url  isEqual: @" "] && url != nil){
        [theMenu addItem:[NSMenuItem separatorItem]];
        [theMenu insertItemWithTitle:@"Open Link" action:@selector(openLink) keyEquivalent:@"" atIndex:1];
    }
    
    [NSMenu popUpContextMenu:theMenu withEvent:event forView:(id)self];
}
- (void)mouseDown:(NSEvent *)event
{
    //needs to be here for some reason to pass on the mouseup event to the label
}

- (void)markRead {
    [_thisapp markAsRead:true index:_theid];
}

- (void)markUnread {
    [_thisapp markAsRead:false index:_theid];
}

- (void)deleteNoti {
    [_thisapp deleteNotification:_theid];
}

- (void)openLink{
    [self markRead];
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:[_thisapp notificationLink:_theid]]];
}
@end


// ----- label interface -----
@interface MyLabel: NSTextField
@property (nonatomic) NSString* link;
@property (nonatomic) NSDate* time;
@property (nonatomic) NSString* str_time;
@end

@implementation MyLabel

- (void) rightMouseDown:(NSEvent *)event {
    [self.superview rightMouseDown:event];
}

@end

// ----- notification view interface -----
@interface MyTitleLabel: MyLabel
@end

@implementation MyTitleLabel
-(void)viewDidAppear {
    [self setSelectable:NO];
}
- (void)resetCursorRects
{
    if(![super.link  isEqual: @" "]){
        [super resetCursorRects];
        [self addCursorRect:self.bounds cursor:[NSCursor pointingHandCursor]];
    }
}
- (void)mouseUp:(NSEvent *)event
{
    if(![super.link  isEqual: @" "] && super.link != nil){
        [(MyNotificationView*)self.superview openLink];
    }
}
@end


// ----- window interface ----- 
@interface MyWindow: NSWindow <NSWindowDelegate>
{
}
- (BOOL) canBecomeKeyWindow;
@end

@implementation MyWindow
- (BOOL) canBecomeKeyWindow
{
    return YES;
}
@end

@interface AppDelegate ()
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    [self onlyOneInstanceOfApp];
    NSString* credentials = [[NSUserDefaults standardUserDefaults] objectForKey:@"credentials"];
    if([credentials length] != 25){
        [self newCredentials];
    }
    [self openSocket];
    [self createStatusBarItem];
    
    [NSTimer scheduledTimerWithTimeInterval:2.0f target:self selector:@selector(check) userInfo:nil repeats:YES];
    [NSTimer scheduledTimerWithTimeInterval:30.0f target:self selector:@selector(sendPing) userInfo:nil repeats:YES];
    [NSTimer scheduledTimerWithTimeInterval:60.0f target:self selector:@selector(updateTimes) userInfo:nil repeats:YES];
    
    //mark menu item
    int shouldOpenOnStartup = (int)[[NSUserDefaults standardUserDefaults] integerForKey:@"openOnStartup"];
    if (shouldOpenOnStartup == 0) {
        [self openOnStartup];
    }else if(shouldOpenOnStartup == 2){
        [_showOnStartupItem setState:NSOnState];
    }
    
    [self createWindow];
}

#pragma mark - window
float window_height;
float window_width;

-(NSRect)positionWindow{
    NSRect frame = [[_statusItem valueForKey:@"window"] frame];
    float screen_width = [[NSScreen mainScreen] frame].size.width;
    
    float x = frame.origin.x - window_width/2 + frame.size.width/2;
    float y = frame.origin.y - window_height;
    if(window_width + x > screen_width){
        int padding = 10;
        x = screen_width - window_width - padding;
        [window_up_arrow_view setFrame:NSMakeRect(frame.origin.x + frame.size.width/2 - x - padding,
                                                 window_up_arrow_view.frame.origin.y,
                                                 window_up_arrow_view.frame.size.width,
                                                  window_up_arrow_view.frame.size.height)];
    }else{
        //centre arrow
        [window_up_arrow_view setFrame:NSMakeRect(window_width/2 - 10, window_height-20, 20, 20)];
    }
    return NSMakeRect(x, y, window_width, window_height);
}

NSImageView *window_up_arrow_view;
-(void)createWindow{
    window_height = [[NSScreen mainScreen] frame].size.height * 0.7;
    window_width = 350;
    
    NSUInteger windowStyleMask = 0;
    
    _window = [[MyWindow alloc] initWithContentRect:[self positionWindow] styleMask:windowStyleMask backing:NSBackingStoreBuffered defer:YES];
    [_window setIdentifier:@"default"];
    [_window setOpaque:NO];
    [_window setBackgroundColor: [NSColor clearColor]];
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
    _view = [[self window] contentView];
    [_view setWantsLayer:YES];
    _view.layer.backgroundColor = [NSColor clearColor].CGColor;
    _view.layer.cornerRadius = 2;
    
    //fill background
    NSTextField* bg = [[NSTextField alloc] initWithFrame:CGRectMake(0, 0, window_width, window_height-15)];
    bg.backgroundColor = [NSColor colorWithRed:1.00 green:1.00 blue:1.00 alpha:1.0];
    bg.editable = false;
    bg.bordered = false;
    bg.wantsLayer = YES;
    bg.layer.cornerRadius = 10.0f;
    [_view addSubview:bg];
    
    NSImage* window_up_arrow = [NSImage imageNamed:@"up_arrow.png"];
    window_up_arrow_view = [[NSImageView alloc] initWithFrame:NSMakeRect(window_width/2 - 10, window_height-20, 20, 20)];
    [window_up_arrow_view setImage:window_up_arrow];
    [_view addSubview:window_up_arrow_view];
    
    [self positionWindow]; //horrible but had to be done ;)
    
    [self createBodyWindow];
}

-(void)createBodyWindow{
    
    //----------------- initial variables -----------------
    unread_notifications = 0;
    prevheight = notification_view_padding;
    
    _black = [NSColor colorWithRed:0.13 green:0.13 blue:0.13 alpha:1.0];
    _white = [NSColor colorWithRed:1.00 green:1.00 blue:1.00 alpha:1.0];
    _red = [NSColor colorWithRed:0.74 green:0.13 blue:0.13 alpha:1.0];
    _grey = [NSColor colorWithRed:0.43 green:0.43 blue:0.43 alpha:1.0];
    _offwhite = [NSColor colorWithRed:0.88 green:0.88 blue:0.88 alpha:0.7];
    
    //----------------- top stuff -----------------
    int top_bar_height = 90;
    
    NSImage *icon = [self resizeImage:[NSImage imageNamed:@"bell.png"] size:NSMakeSize(50, 50)];
    
    NSImageView *iconView = [[NSImageView alloc] initWithFrame:NSMakeRect(window_width/2 -(80/2), window_height-top_bar_height, 80, 80)];
    [iconView setImage:icon];
    [_view addSubview:iconView];
    
    NSView *hor_bor_top = [[NSView alloc] initWithFrame:CGRectMake(0, window_height - top_bar_height, window_width, 1)];
    hor_bor_top.wantsLayer = TRUE;
    [hor_bor_top.layer setBackgroundColor:[_black CGColor]];
    [_view addSubview:hor_bor_top];
    
    int bottom_buttons_height = 40;
    //----------------- body -----------------
    
    //scroll view
    float scroll_height = (window_height - top_bar_height) - bottom_buttons_height;
    
    _scroll_view = [[NSScrollView alloc] initWithFrame:NSMakeRect(0, bottom_buttons_height, window_width, scroll_height)];
    
    [_scroll_view setBorderType:NSNoBorder];
    [_scroll_view setHasVerticalScroller:YES];
    
    NSMutableArray *arrayofdics = [[[NSUserDefaults standardUserDefaults] objectForKey:@"arrayofdics"] mutableCopy];
    if((int)[arrayofdics count] == 0){
        _scroll_view.documentView = [self noNotificationsView];
    }else{
        //INITIATE NSTABLE
        _notification_table = [[NSTableView alloc] initWithFrame:_scroll_view.frame];
        NSTableColumn *column =[[NSTableColumn alloc]initWithIdentifier:@"1"];
        [column setWidth:_scroll_view.frame.size.width - 5]; //I swear me needing to do this is a bug
        [_notification_table addTableColumn:column];
        [_notification_table setHeaderView:nil];
        [_notification_table setSelectionHighlightStyle:NSTableViewSelectionHighlightStyleNone];
        [_notification_table setDelegate:(id)self];
        [_notification_table setDataSource:(id)self];
        [self reloadData];
        
        _scroll_view.documentView = _notification_table;
    }
    [_view addSubview:_scroll_view];
    
    
    //----------------- bottom stuff -----------------
    //mark all as read button
    NSButton* markAllAsReadBtn = [[NSButton alloc] initWithFrame:CGRectMake(0, 10, window_width / 2, 20)];
    [markAllAsReadBtn setAlignment:NSTextAlignmentCenter];
    [markAllAsReadBtn setFont:[NSFont fontWithName:@"Raleway-SemiBold" size:14]];
    markAllAsReadBtn.bordered =false;
    [markAllAsReadBtn setTitle:@"Mark all as read"];
    [markAllAsReadBtn setAction:@selector(markAllAsRead)];
    [_view addSubview:markAllAsReadBtn];
    
    //delete all button
    NSButton *deleteNotifications = [[NSButton alloc] initWithFrame:CGRectMake(window_width / 2, 10, window_width /2, 20)];
    
    NSMutableParagraphStyle *centredStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    [centredStyle setAlignment:NSCenterTextAlignment];
    
    NSDictionary *attrs = [NSDictionary dictionaryWithObjectsAndKeys:centredStyle,
                           NSParagraphStyleAttributeName,
                           [NSFont fontWithName:@"Raleway-SemiBold" size:14],
                           NSFontAttributeName,
                           _red,
                           NSForegroundColorAttributeName,
                           nil];
    NSMutableAttributedString *attributedString =
    [[NSMutableAttributedString alloc] initWithString:@"Delete All"
                                           attributes:attrs];
    
    [deleteNotifications setAttributedTitle:attributedString];
    deleteNotifications.bordered =false;
    [deleteNotifications setAction:@selector(deleteAll)];
    [_view addSubview:deleteNotifications];
    
    //horizontal border bottom
    NSView *hor_bor_bot = [[NSView alloc] initWithFrame:CGRectMake(0, bottom_buttons_height, window_width, 1)];
    hor_bor_bot.wantsLayer = TRUE;
    [hor_bor_bot.layer setBackgroundColor:[_black CGColor]];
    [_view addSubview:hor_bor_bot];
    
    //vertical border
    NSView *ver_bor = [[NSView alloc] initWithFrame:CGRectMake(window_width/2, 0, 1, bottom_buttons_height)];
    ver_bor.wantsLayer = TRUE;
    [ver_bor.layer setBackgroundColor:[_black CGColor]];
    [_view addSubview:ver_bor];
    
    [self setNotificationMenuBar];
}

-(NSView*)noNotificationsView{
    NSView *view = [[NSView alloc] initWithFrame:NSMakeRect(0, 0, window_width, _scroll_view.frame.size.height)];
    view.wantsLayer = TRUE;
    
    //attributed text
    NSMutableParagraphStyle *centredStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    [centredStyle setAlignment:NSTextAlignmentCenter];
    NSDictionary *attrs = [NSDictionary dictionaryWithObjectsAndKeys:centredStyle,
                           NSParagraphStyleAttributeName,
                           [NSFont fontWithName:@"Raleway-SemiBold" size:15],
                           NSFontAttributeName,
                           _grey,
                           NSForegroundColorAttributeName,
                           nil];
    NSMutableAttributedString *attributedString =
    [[NSMutableAttributedString alloc] initWithString:@"You have no notifications!\nSend curl requests to receive them."
                                           attributes:attrs];
    
    NSRange range = NSMakeRange(32, 4);
    [attributedString beginEditing];
    [attributedString addAttribute:NSLinkAttributeName value: @"https://github.com/maxisme/notifi#http-request-examples" range:range];
    [attributedString endEditing];
    
    //nstextfield
    int title_height = 100;
    MyTitleLabel* title_field = [[MyTitleLabel alloc] initWithFrame:
                                 CGRectMake(
                                            0,
                                            _scroll_view.frame.size.height/2 - title_height/2,
                                            window_width,
                                            title_height
                                            )
                                 ];
    title_field.editable = false;
    title_field.bordered = false;
    title_field.backgroundColor = [NSColor clearColor];
    [title_field setAlignment:NSTextAlignmentCenter];
    title_field.attributedStringValue = attributedString;
    [title_field setWantsLayer:true];
    [title_field setAllowsEditingTextAttributes:YES];
    [title_field setSelectable:YES];
    [view addSubview:title_field];
    
    return view;
}

#pragma mark - Table View Data Source

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    NSMutableArray *arrayofdics = [[[NSUserDefaults standardUserDefaults] objectForKey:@"arrayofdics"] mutableCopy];
    return arrayofdics.count;
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    NSView* view = [[NSView alloc] init];
    [view addSubview:[_notification_views objectAtIndex:row]];
    return view;
}

- (CGFloat) tableView:(NSTableView *) tableView heightOfRow:(NSInteger) row {
    int row_padding = 15;
    NSMutableArray *arrayofdics = [[[NSUserDefaults standardUserDefaults] objectForKey:@"arrayofdics"] mutableCopy];
    NSMutableDictionary *dic = arrayofdics[([arrayofdics count] - 1) - row];
    return [self createNotificationView:[dic objectForKey:@"title"]
                                message:[dic objectForKey:@"message"]
                               imageURL:[dic objectForKey:@"image"]
                                   link:[dic objectForKey:@"link"]
                                   time:[dic objectForKey:@"time"]
                                   read:[[dic objectForKey:@"read"] boolValue]
                                  rowid:(int)row
            ].frame.size.height + row_padding;
}

- (void)tableView:(NSTableView *)tableView setObjectValue:(id)anObject forTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex {
    NSMutableArray *arrayofdics = [[[NSUserDefaults standardUserDefaults] objectForKey:@"arrayofdics"] mutableCopy];
    [arrayofdics replaceObjectAtIndex:([arrayofdics count] - 1) - rowIndex withObject:anObject];
}

bool reloaded_in_last_2 = false;
-(void)reloadData{
    if(!reloaded_in_last_2){ // every 2 seconds reload_count is set to 0
        [self reload];
    }else{
        //attempt to reload in two seconds
        //TODO kill previous thread
        dispatch_async(dispatch_get_global_queue(0,0), ^{
            [NSThread sleepForTimeInterval:2.0f];
            [self postReload];
        });
    }
}

-(void)postReload{
    if(!reloaded_in_last_2){
        [self reload];
    }
}

-(void)reload{
    dispatch_async(dispatch_get_main_queue(), ^{
        reloaded_in_last_2 = true;
        _time_labels = [[NSMutableArray alloc] init];
        _notification_views = [[NSMutableArray alloc] init];
        
        unread_notifications = 0;
        [_notification_table reloadData];
        
        [self setNotificationMenuBar];
    });
}

int unread_notifications;
float prevheight;
int notification_view_padding = 20;

-(NSView*)createNotificationView:(NSString*)title_string message:(NSString*)mes imageURL:(NSString*)imgURL link:(NSString*)url time:(NSString*)time_string read:(bool)read rowid:(int)rowid
{
    float width_perc = 0.9;
    int notification_width = _scroll_view.frame.size.width * width_perc;
    float x = window_width * (1 - width_perc)/2;
    int y = 5;
    
    int image_width = 70;
    int image_height = 70;
    int time_height = 20;
    
    MyNotificationView *view = [[MyNotificationView alloc] init];
    view.wantsLayer = TRUE;
    
    //check if image variable
    int padding_right = 5;
    if(![imgURL isEqual: @" "]){
        padding_right = 80;
    }
    
    float text_width = notification_width*0.98 - padding_right;
    
    //calculate height of view by height of title text area
    NSMutableParagraphStyle *centredStyle_title = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    NSDictionary *attrs_title = [NSDictionary dictionaryWithObjectsAndKeys:centredStyle_title,
                           NSParagraphStyleAttributeName,
                           [NSFont fontWithName:@"Raleway-ExtraBold" size:15],
                           NSFontAttributeName,
                           _black,
                           NSForegroundColorAttributeName,
                           nil];
    
    NSMutableAttributedString *attributedString_title = [[NSMutableAttributedString alloc] initWithString:title_string attributes:attrs_title];
    if(![url  isEqual: @" "]){
        NSRange range = NSMakeRange(0, attributedString_title.length);
        [attributedString_title addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInt:NSUnderlineStyleSingle] range:range];
    }
    CGRect rect_title = [attributedString_title boundingRectWithSize:CGSizeMake(text_width, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading context:nil];
    
    float title_height = rect_title.size.height; //calculated height of dynamic title
    
    float info_height = 0.0;
    if(![mes  isEqual: @" "]){
        //calculate height of view by height of info text area
        NSMutableParagraphStyle *centredStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
        NSDictionary *attrs = [NSDictionary dictionaryWithObjectsAndKeys:centredStyle,
                               NSParagraphStyleAttributeName,
                               [NSFont fontWithName:@"Raleway-SemiBold" size:12],
                               NSFontAttributeName,
                               _red,
                               NSForegroundColorAttributeName,
                               nil];
        NSMutableAttributedString *attributedString =
        [[NSMutableAttributedString alloc] initWithString:mes
                                               attributes:attrs];
        CGRect rect = [attributedString boundingRectWithSize:CGSizeMake(text_width, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading context:nil];
        
        info_height = rect.size.height;  //calculated height of dynamic info
    }
    
    int extra_padding = 10;
    int notification_height = title_height + time_height + info_height + notification_view_padding*2 + extra_padding;
    
    if(![imgURL isEqual: @" "]){ // handle extra height if image
        int min_height = image_height + time_height + notification_view_padding*2;
        if(notification_height < min_height){
            notification_height = min_height;
        }
    }
    
    //set view frame
    [view setFrame:CGRectMake(x, y, notification_width, notification_height - 45)];
    
    NSMutableArray *arrayofdics = [[[NSUserDefaults standardUserDefaults] objectForKey:@"arrayofdics"] mutableCopy];
    view.theid = (int)[arrayofdics count] - rowid - 1;
    view.thisapp = self;
    [view.layer setBackgroundColor:[_red CGColor]];
    if(read){
        [view.layer setBackgroundColor:[_grey CGColor]];
    }else{
        unread_notifications++;
        [self setNotificationMenuBar];
    }
    
    NSShadow *dropShadow = [[NSShadow alloc] init];
    [dropShadow setShadowColor:_black];
    [dropShadow setShadowOffset:NSMakeSize(0, 0)];
    [dropShadow setShadowBlurRadius:3.0];
    [view setShadow:dropShadow];
    view.layer.cornerRadius = 10.0f;
    
    
    //body of notification
    
    //--      add image
    if(![imgURL isEqual: @" "]){
        [[[AsyncImageDownloader alloc] initWithMediaURL:imgURL successBlock:^(NSImage *image){
            NSRect imageRect = NSMakeRect(7,view.frame.size.height - image_height - 7,image_width,image_height);
            NSSize size = NSMakeSize(image_width, image_height);
            NSImage *newImg = [self resizeImage:image size:size];
            
            NSImageView *image_view = [[NSImageView alloc] initWithFrame:imageRect];
            image_view.bounds = imageRect;
            image_view.image  = newImg;
            [view addSubview:image_view];
        } failBlock:^(NSError *error) {
            NSLog(@"Failed to download image due to %@!", error);
        }] startDownload];
    }
    
    //--    add title
    MyTitleLabel* title_field = [[MyTitleLabel alloc] initWithFrame:
                         CGRectMake(
                                    padding_right,
                                    view.frame.size.height - title_height,
                                    text_width,
                                    title_height
                                    )
                                 ];
    [title_field setSelectable:YES];
    if(![url  isEqual: @" "]){
        title_field.link = url;
        [title_field setSelectable:NO];
    }
    title_field.font = [NSFont fontWithName:@"Raleway-ExtraBold" size:15];
    title_field.preferredMaxLayoutWidth = text_width;
    title_field.backgroundColor = [NSColor clearColor];
    [title_field setAlignment:NSTextAlignmentLeft];
    [title_field setTextColor:_black];
    title_field.editable = false;
    title_field.bordered = false;
    title_field.attributedStringValue = attributedString_title;
    [title_field setWantsLayer:true];
    
    [view addSubview:title_field];
    
    //--   add time
    MyLabel* time_label = [[MyLabel alloc] initWithFrame:
                               CGRectMake(
                                          padding_right,
                                          title_field.frame.origin.y - time_height,
                                          text_width,
                                          time_height
                                          )
                               ];
    time_label.font = [NSFont fontWithName:@"Raleway-Medium" size:10];
    time_label.backgroundColor = [NSColor clearColor];
    [time_label setAlignment:NSTextAlignmentLeft];
    [time_label setTextColor:_offwhite];
    [time_label setSelectable:YES];
    time_label.editable = false;
    time_label.bordered =false;
    
    //get nsdate
    NSDateFormatter *serverFormat = [[NSDateFormatter alloc]init];
    [serverFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    [serverFormat setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"EST"]]; //server time zone `date +%Z`
    NSDate *date = [serverFormat dateFromString:time_string];
    
    //change to local time zone
    NSTimeZone *tz = [NSTimeZone defaultTimeZone];
    NSInteger seconds = [tz secondsFromGMTForDate: date];
    NSDate* convertedDate = [NSDate dateWithTimeInterval: seconds sinceDate:date];
    
    //convert to desired format
    NSDateFormatter *myFormat = [[NSDateFormatter alloc]init];
    [myFormat setDateFormat:@"MMM d, yyyy HH:mm"];
    NSString *stringDate = [myFormat stringFromDate:convertedDate];
    
    NSString* timestr = [NSString stringWithFormat:@"%@ %@",stringDate, [self dateDiff:convertedDate]];
    
    //dynamic time
    time_label.time = convertedDate;
    time_label.str_time = stringDate;
    [_time_labels addObject:time_label];
    
    [time_label setStringValue:timestr];
    [view addSubview:time_label];
    
    //-- add info
    if(![mes  isEqual: @" "]){
        MyLabel* info = [[MyLabel alloc] initWithFrame:
                             CGRectMake(
                                        padding_right,
                                        time_label.frame.origin.y - info_height + 5,
                                        text_width,
                                        info_height
                                        )
                             ];
        [view layoutSubtreeIfNeeded];
        info.font = [NSFont fontWithName:@"Raleway-Medium" size:12];
        info.preferredMaxLayoutWidth = text_width;
        info.backgroundColor = [NSColor clearColor];
        [info setAlignment:NSTextAlignmentLeft];
        [info setTextColor:_white];
        [info setSelectable:YES];
        info.editable = false;
        info.bordered = false;
        [info setStringValue:mes];
        [view addSubview:info];
    }
    
    [_notification_views addObject:view];
    
    return view;
}

-(void)updateTimes{
    for(MyLabel* time_label in _time_labels){
        NSString* timestr = [NSString stringWithFormat:@"%@ %@", time_label.str_time, [self dateDiff:time_label.time]];
        [time_label setStringValue:timestr];
    }
}

-(void)showWindow{
    [[NSUserNotificationCenter defaultUserNotificationCenter] removeAllDeliveredNotifications];
    [NSApp activateIgnoringOtherApps:YES];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [_window setFrame:[self positionWindow] display:true];
        [_window makeKeyAndOrderFront:_view];
    });
}
 
//when clicking icon
- (void)menuWillOpen:(NSMenu *)menu
{
    if(_window && [_window isVisible]){
        [_window orderOut:self];
    }
}

- (void)setNotificationMenuBar{
    [_errorItem setHidden:true];
    if(unread_notifications > 0){
        if(unread_notifications == 1){
            _window_item.title = @"View 1 Unread Notification";
        }else if(unread_notifications < 1000){
            _window_item.title = [NSString stringWithFormat:@"Open %d Unread Notifications", unread_notifications];
        }else{
            _window_item.title = @"View 999+ Unread Notifications";
        }
        _statusItem.image = [NSImage imageNamed:@"alert_menu_bellicon.png" ];
    }else{
        _window_item.title = @"View Notifications";
        _statusItem.image = [NSImage imageNamed:@"menu_bellicon.png"];
    }
    
    if(!streamOpen){
        if(_statusItem.image != [NSImage imageNamed:@"menu_error_bellicon.png" ]){
            _statusItem.image = [NSImage imageNamed:@"menu_error_bellicon.png" ];
            [_errorItem setHidden:false];
        }
    }
}


#pragma mark - set key
-(void)createNewCredentials{
    NSAlert *alert = [[NSAlert alloc] init];
    [alert setMessageText:@"Are you sure?"];
    [alert setInformativeText:@"You won't be able to receive messages using the previous credentials ever again."];
    [alert addButtonWithTitle:@"Ok"];
    [alert addButtonWithTitle:@"Cancel"];
    
    NSInteger button = [alert runModal];
    if (button == NSAlertFirstButtonReturn) {
        [self newCredentials];
    }
}

-(void)newCredentials{
    if(![_credentialsItem.title isEqual: @"Fetching credentials..."]){
        [_credentialsItem setTitle:@"Fetching credentials..."];
        [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"arrayofdics"];
        dispatch_async(dispatch_get_global_queue(0,0), ^{
            NSString *alphabet = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXZY0123456789";
            NSMutableString *credential_key = [NSMutableString stringWithCapacity:25];
            for (NSUInteger i = 0U; i < 25; i++) {
                u_int32_t r = arc4random() % [alphabet length];
                unichar c = [alphabet characterAtIndex:r];
                [credential_key appendFormat:@"%C", c];
            }
            
            NSString *urlString = [NSString stringWithFormat:@"https://notifi.it/getCode.php?credentials=%@",credential_key];
            urlString = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            NSURL *url = [NSURL URLWithString:urlString];
            NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url
                                                        cachePolicy:NSURLRequestReturnCacheDataElseLoad
                                                    timeoutInterval:30];
            NSData *urlData;
            NSURLResponse *response;
            NSError *error;
            urlData = [NSURLConnection sendSynchronousRequest:urlRequest
                                            returningResponse:&response
                                                        error:&error];
            NSString* content = [[NSString alloc] initWithData:urlData encoding:NSUTF8StringEncoding];
            
            if([content length] != 100){
                NSAlert *alert = [[NSAlert alloc] init];
                [alert setMessageText:@"Error Fetching credentials!"];
                [alert setInformativeText:[NSString stringWithFormat:@"Error message: %@",content]];
                [alert addButtonWithTitle:@"Ok"];
                [alert runModal];
            }else if([content  isEqual: @"0"]){
                [_credentialsItem setTitle:@"Please click 'Create New Credentials'!"];
                NSAlert *alert = [[NSAlert alloc] init];
                [alert setMessageText:@"Error credentials already registered!"];
                [alert setInformativeText:@"Please try again."];
                [alert addButtonWithTitle:@"Ok"];
                [alert runModal];
            }else if(error){
                [_credentialsItem setTitle:@"Error Fetching credentials!"];
                NSAlert *alert = [[NSAlert alloc] init];
                [alert setMessageText:@"Error Fetching credentials!"];
                [alert setInformativeText:[NSString stringWithFormat:@"Error message: %@",error]];
                [alert addButtonWithTitle:@"Ok"];
                [alert runModal];
            }else{
                [[NSUserDefaults standardUserDefaults] setObject:content forKey:@"key"];
                [[NSUserDefaults standardUserDefaults] setObject:credential_key forKey:@"credentials"];
                [_credentialsItem setTitle:credential_key];
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self closeSocket];
            });
        });
    }
}

#pragma mark - handle icoming notification
bool serverReplied = false;
-(void)check{
    if(!streamOpen){
        [self openSocket];
    }else if(!serverReplied){
        [self sendCode];
    }
    
    //reset reload count (prevents recursive call) maximum 1 reload ever 2 seconds
    reloaded_in_last_2 = false;
}

-(void)handleIncomingNotification:(NSString*)message{
    serverReplied = true;
    if([message  isEqual: @"Invalid Credentials"]){
        dispatch_async(dispatch_get_main_queue(), ^{
            NSAlert *alert = [[NSAlert alloc] init];
            [alert setMessageText:@"Invalid Credentials!"];
            [alert setInformativeText:@"For some suspicious reason your credentials have been altered. You will now be assigned new ones."];
            [alert addButtonWithTitle:@"Ok"];
            [alert runModal];
            
            [self newCredentials];
        });
    }else{
        NSData* data = [message dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary* json_dic = [NSJSONSerialization
                              JSONObjectWithData:data
                              options:kNilOptions
                              error:nil];
        
        NSMutableArray *arrayofdics = [[[NSUserDefaults standardUserDefaults] objectForKey:@"arrayofdics"] mutableCopy];
        BOOL refresh = false;
        NSMutableArray* notifications = [[NSMutableArray alloc] init];
        
        for (NSDictionary* notification in json_dic) {
            NSString* firstval = [NSString stringWithFormat:@"%@", notification];;
            if([[firstval substringToIndex:3]  isEqual: @"id:"]){
                //TELL SERVER TO DELETE THIS MESSAGE
                if(streamOpen){
                    [_webSocket send:firstval];
                }
            }else{
                [self storeNotification:notification];
                refresh = true;
                [notifications addObject:notification];
            }
        }
        
        if(refresh){
            if([notifications count] <= 5){
                for (NSDictionary* notification in notifications){
                    [self sendLocalNotification:[notification objectForKey:@"title"]
                                        message:[notification objectForKey:@"message"]
                                       imageURL:[notification objectForKey:@"image"]
                                           link:[notification objectForKey:@"link"]
                                            _id:[arrayofdics count] + [notifications count]
                    ];
                }
            }else{
                //send notification with ammount of notifications.
                NSUserNotification *note = [[NSUserNotification alloc] init];
                [note setHasActionButton:false];
                [note setTitle:[NSString stringWithFormat:@"You have %d new notifications!",(int)[notifications count]]];
                [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:note];
                [[NSUserNotificationCenter defaultUserNotificationCenter] setDelegate:(id)self];
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if([arrayofdics count] == 0){
                    [self createBodyWindow];
                }else{
                    [self reloadData];
                }
            });
        }
    }
}

#pragma mark - notification storage

-(void)storeNotification:(NSDictionary*)dict{
    NSMutableDictionary *dic = [dict mutableCopy];
    //add read object to dic
    [dic setObject:[NSNumber numberWithBool:0] forKey:@"read"];
    
    //get stored arrayofdics
    NSMutableArray *arrayofdics = [[[NSUserDefaults standardUserDefaults] objectForKey:@"arrayofdics"] mutableCopy];
    if([arrayofdics count] == 0){
        arrayofdics = [[NSMutableArray alloc] init];
    }
    
    //add dic to arrayofdics
    [arrayofdics addObject:dic];
    
    //store arrayofdics
    [[NSUserDefaults standardUserDefaults] setObject:arrayofdics forKey:@"arrayofdics"];
}

-(bool)notificationRead:(int)index{
    NSMutableArray *arrayofdics = [[[NSUserDefaults standardUserDefaults] objectForKey:@"arrayofdics"] mutableCopy];
    NSMutableDictionary *dic = [[arrayofdics objectAtIndex:index] mutableCopy];
    return [[dic objectForKey:@"read"] boolValue];
}

-(NSString*)notificationLink:(int)index{
    NSMutableArray *arrayofdics = [[[NSUserDefaults standardUserDefaults] objectForKey:@"arrayofdics"] mutableCopy];
    NSMutableDictionary *dic = [[arrayofdics objectAtIndex:index] mutableCopy];
    return [dic objectForKey:@"link"];
}

-(void)markAsRead:(bool)read index:(int)index{
    //update storage
    NSMutableArray *arrayofdics = [[[NSUserDefaults standardUserDefaults] objectForKey:@"arrayofdics"] mutableCopy];
    NSMutableDictionary *dic = [[arrayofdics objectAtIndex:index] mutableCopy];
    [dic setObject:[NSNumber numberWithBool:read] forKey:@"read"];
    [arrayofdics replaceObjectAtIndex:index withObject:dic];
    [[NSUserDefaults standardUserDefaults] setObject:arrayofdics forKey:@"arrayofdics"];
    
    //update view
    NSView* view = [_notification_views objectAtIndex:(int)[arrayofdics count] - index - 1]; //as shown backwards
    [view.layer setBackgroundColor:[_red CGColor]];
    if(read){
        [view.layer setBackgroundColor:[_grey CGColor]];
        unread_notifications--;
    }else{
        unread_notifications++;
    }
    [self setNotificationMenuBar];
    [self reloadData];
}

-(void)markAllAsRead{
    NSMutableArray *arrayofdics = [[[NSUserDefaults standardUserDefaults] objectForKey:@"arrayofdics"] mutableCopy];
    for(int index = 0; index < [arrayofdics count]; index++){
        [self markAsRead:true index:index];
    }
}

-(void)deleteNotification:(int)index{
    NSMutableArray *arrayofdics = [[[NSUserDefaults standardUserDefaults] objectForKey:@"arrayofdics"] mutableCopy];
    int notification_count = (int)[arrayofdics count];
    
    if(notification_count == 1){
        _scroll_view.documentView = [self noNotificationsView];
    }else{
        [arrayofdics removeObjectAtIndex:index];
        [[NSUserDefaults standardUserDefaults] setObject:arrayofdics forKey:@"arrayofdics"];
        [_notification_views removeObjectAtIndex:notification_count - index - 1];
    }
    
    [self reloadData];
}

-(void)deleteAll{
    NSMutableArray *arrayofdics = [[[NSUserDefaults standardUserDefaults] objectForKey:@"arrayofdics"] mutableCopy];
    
    if([arrayofdics count] > 0){
        //close window
        if(_window && [_window isVisible]){
            [_window orderOut:self];
        }
        //ask if sure
        NSAlert *alert = [[NSAlert alloc] init];
        [alert addButtonWithTitle:@"OK"];
        [alert addButtonWithTitle:@"Cancel"];
        [alert setMessageText:[NSString stringWithFormat:@"Delete all %d notifications?", (int)[arrayofdics count]]];
        [alert setInformativeText:@"Notifications cannot be restored."];
        [alert setAlertStyle:NSWarningAlertStyle];
        
        if ([alert runModal] == NSAlertFirstButtonReturn) {
            _notification_views = nil;
            [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"arrayofdics"];
            [self createBodyWindow];
        }
    }
}

#pragma mark - notifications
-(void)sendLocalNotification:(NSString*)title message:(NSString*)mes imageURL:(NSString*)imgURL link:(NSString*)url _id:(int)_id{
    NSUserNotification *notification = [[NSUserNotification alloc] init];
    
    //pass variables through notification
    notification.userInfo = @{
        @"id" : [NSString stringWithFormat:@"%d",_id],
        @"url" : url
    };
    
    [notification setTitle:title];
    
    if(![mes  isEqual: @" "])
        [notification setInformativeText:mes];
    
    if(![imgURL  isEqual: @" "]){
        NSImage* image;
        @try {
            image = [[NSImage alloc] initWithContentsOfURL:[NSURL URLWithString:imgURL]];
        }
        @catch (NSException * e) {
            NSLog(@"ERROR loading image from URL: %@",imgURL);
        }
        
        if (image)
            [notification setContentImage:image];
    }
    
    [notification setActionButtonTitle:@"Open Link"];
    if(![url  isEqual: @" "]){
        [notification setHasActionButton:true];
    }else{
        [notification setHasActionButton:false];
    }
    
    [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];
    [[NSUserNotificationCenter defaultUserNotificationCenter] setDelegate:(id)self];
    
}

- (void) userNotificationCenter:(NSUserNotificationCenter *)center didActivateNotification:(NSUserNotification *)notification
{
    bool openWindow = true;
    if(notification.userInfo[@"id"]){
        int theid = [notification.userInfo[@"id"] intValue];
        NSString* url_string = notification.userInfo[@"url"];
        
        NSURL* url;
        if(![url_string  isEqual: @" "]){
            @try {
                url = [NSURL URLWithString:url_string];
                openWindow = false;
            } @catch (NSException *exception) {
                NSLog(@"error with link url");
            }
        }
        
        if(url)
            [[NSWorkspace sharedWorkspace] openURL:url];
        
        [self markAsRead:true index:theid - 1];
    }
    if (openWindow)
        [self showWindow];
    [center removeDeliveredNotification: notification];
}

- (BOOL)userNotificationCenter:(NSUserNotificationCenter *)center shouldPresentNotification:(NSUserNotification *)notification {
    return YES;
}

#pragma mark - socketRocket

- (void)openSocket
{
    serverReplied = false;
    streamOpen = false;
    
    _webSocket.delegate = nil;
    [_webSocket close];
    
    _webSocket = [[SRWebSocket alloc] initWithURL:[NSURL URLWithString:@"wss://s.notifi.it"]];
    _webSocket.delegate = (id)self;
    
    [_webSocket open];
}

bool receivedPong = false;
- (void)sendPing;
{
    if(streamOpen){
        receivedPong = false;
        [_webSocket sendPing:nil];
        dispatch_async(dispatch_get_global_queue(0,0), ^{
            [NSThread sleepForTimeInterval:2.0f];
            if(!receivedPong){
                [self closeSocket];
            }
        });
    }
}

- (void)webSocketDidOpen:(SRWebSocket *)webSocket;
{
    streamOpen = true;
    [self setNotificationMenuBar];
}

- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error;
{
    [self closeSocket];
    webSocket = nil;
}

- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(nonnull NSString *)string
{
    dispatch_async(dispatch_get_global_queue(0,0), ^{
        [self handleIncomingNotification:string];
    });
}

- (void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean;
{
    NSLog(@"WebSocket closed");
    [self closeSocket];
    webSocket = nil;
}

- (void)webSocket:(SRWebSocket *)webSocket didReceivePong:(NSData *)pongPayload;
{
    receivedPong = true;
}


BOOL streamOpen = false;
- (void)sendCode{
    NSString* credentials = [[NSUserDefaults standardUserDefaults] objectForKey:@"credentials"];
    NSString* key = [[NSUserDefaults standardUserDefaults] objectForKey:@"key"];
    NSString* message = [NSString stringWithFormat:@"%@|%@", credentials, key];
    if(streamOpen){
        [_webSocket send:message];
    }
}

-(void)closeSocket{
    if(streamOpen){
        NSLog(@"Terminated connection!");
    }
    serverReplied = false;
    streamOpen = false;
    [self setNotificationMenuBar];
}

#pragma mark - menu bar
- (void)createStatusBarItem {
    NSStatusBar *statusBar = [NSStatusBar systemStatusBar];
    _statusItem = [statusBar statusItemWithLength:NSSquareStatusItemLength];
    _statusItem.image = [NSImage imageNamed:@"menu_bellicon.png" ];
    _statusItem.highlightMode = YES;
    _statusItem.menu = [self defaultStatusBarMenu];
    [_statusItem setTarget:self];
}

- (NSMenu *)defaultStatusBarMenu {
    NSMenu* mainMenu = [[NSMenu alloc] init];
    
    _errorItem = [[NSMenuItem alloc] initWithTitle:@"Network Error!" action:nil keyEquivalent:@""];
    [_errorItem setTarget:self];
    [_errorItem setEnabled:false];
    [_errorItem setHidden:true];
    [mainMenu addItem:_errorItem];
    
    [mainMenu addItem:[NSMenuItem separatorItem]];
    
    _window_item = [[NSMenuItem alloc] initWithTitle:@"View Notifications" action:@selector(showWindow) keyEquivalent:@""];
    [_window_item setTarget:self];
    [mainMenu addItem:_window_item];
    
    [mainMenu addItem:[NSMenuItem separatorItem]];
    
    _credentialsItem = [[NSMenuItem alloc] initWithTitle:[[NSUserDefaults standardUserDefaults] objectForKey:@"credentials"] action:nil keyEquivalent:@""];
    [_credentialsItem setTarget:self];
    [_credentialsItem setEnabled:false];
    [mainMenu addItem:_credentialsItem];
    
    NSMenuItem* copy = [[NSMenuItem alloc] initWithTitle:@"Copy Credentials" action:@selector(copyCredentials) keyEquivalent:@"c"];
    [copy setTarget:self];
    [copy setEnabled:true];
    [mainMenu addItem:copy];
    
    [mainMenu addItem:[NSMenuItem separatorItem]];
    
    NSMenuItem* newCredentials = [[NSMenuItem alloc] initWithTitle:@"Create New Credentials" action:@selector(createNewCredentials) keyEquivalent:@"n"];
    [newCredentials setTarget:self];
    [mainMenu addItem:newCredentials];
    
    [mainMenu addItem:[NSMenuItem separatorItem]];
    
    _showOnStartupItem = [[NSMenuItem alloc] initWithTitle:@"Open Notifi at login" action:@selector(openOnStartup) keyEquivalent:@""];
    [_showOnStartupItem setTarget:self];
    [mainMenu addItem:_showOnStartupItem];
    
    NSMenuItem* quit = [[NSMenuItem alloc] initWithTitle:@"Quit Notifi" action:@selector(quit) keyEquivalent:@""];
    [quit setTarget:self];
    [mainMenu addItem:quit];
    
    // Disable auto enable
    [mainMenu setAutoenablesItems:NO];
    [mainMenu setDelegate:(id)self];
    return mainMenu;
}

-(void)copyCredentials{
    NSString* credentials = [[NSUserDefaults standardUserDefaults] objectForKey:@"credentials"];
    
    NSPasteboard *pasteBoard = [NSPasteboard generalPasteboard];
    [pasteBoard declareTypes:[NSArray arrayWithObjects:NSStringPboardType, nil] owner:nil];
    [pasteBoard setString:credentials forType:NSStringPboardType];
}

#pragma mark - open on startup

-(void)openOnStartup{
    int shouldOpenOnStartup;
    if(![self loginItemExistsWithLoginItemReference]){
        [self enableLoginItemWithURL];
        [_showOnStartupItem setState:NSOnState];
        shouldOpenOnStartup = 2;
    }else{
        [self removeLoginItemWithURL];
        [_showOnStartupItem setState:NSOffState];
        shouldOpenOnStartup = 1;
    }
    [[NSUserDefaults standardUserDefaults] setInteger:shouldOpenOnStartup forKey:@"openOnStartup"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (BOOL)loginItemExistsWithLoginItemReference{
    BOOL found = NO;
    UInt32 seedValue;
    CFURLRef thePath = NULL;
    LSSharedFileListRef theLoginItemsRefs = LSSharedFileListCreate(NULL, kLSSharedFileListSessionLoginItems, NULL);
    
    NSString * appPath = [[NSBundle mainBundle] bundlePath];
    // We're going to grab the contents of the shared file list (LSSharedFileListItemRef objects)
    // and pop it in an array so we can iterate through it to find our item.
    CFArrayRef loginItemsArray = LSSharedFileListCopySnapshot(theLoginItemsRefs, &seedValue);
    for (id item in (__bridge NSArray *)loginItemsArray) {
        LSSharedFileListItemRef itemRef = (__bridge LSSharedFileListItemRef)item;
        if (LSSharedFileListItemResolve(itemRef, 0, (CFURLRef*) &thePath, NULL) == noErr) {
            if ([[(__bridge NSURL *)thePath path] hasPrefix:appPath]) {
                found = YES;
                break;
            }
            // Docs for LSSharedFileListItemResolve say we're responsible
            // for releasing the CFURLRef that is returned
            if (thePath != NULL) CFRelease(thePath);
        }
    }
    if (loginItemsArray != NULL) CFRelease(loginItemsArray);
    
    return found;
}

- (void)enableLoginItemWithURL
{
    if(![self loginItemExistsWithLoginItemReference]){
        LSSharedFileListRef loginListRef = LSSharedFileListCreate(NULL, kLSSharedFileListSessionLoginItems, NULL);
        
        if (loginListRef) {
            // Insert the item at the bottom of Login Items list.
            LSSharedFileListItemRef loginItemRef = LSSharedFileListInsertItemURL(loginListRef,
                                                                                 kLSSharedFileListItemBeforeFirst,
                                                                                 NULL,
                                                                                 NULL,
                                                                                 (__bridge CFURLRef)[NSURL fileURLWithPath:[[NSBundle mainBundle] bundlePath]],
                                                                                 NULL,
                                                                                 NULL);
            if (loginItemRef) {
                CFRelease(loginItemRef);
            }
            CFRelease(loginListRef);
        }
    }
}

- (void)removeLoginItemWithURL
{
    if([self loginItemExistsWithLoginItemReference]){
        LSSharedFileListRef loginListRef = LSSharedFileListCreate(NULL, kLSSharedFileListSessionLoginItems, NULL);
        
        LSSharedFileListItemRef loginItemRef = LSSharedFileListInsertItemURL(loginListRef,
                                                                             kLSSharedFileListItemBeforeFirst,
                                                                             NULL,
                                                                             NULL,
                                                                             (__bridge CFURLRef)[NSURL fileURLWithPath:[[NSBundle mainBundle] bundlePath]],
                                                                             NULL,
                                                                             NULL);
        
        // Insert the item at the bottom of Login Items list.
        LSSharedFileListItemRemove(loginListRef, loginItemRef);
    }
}

#pragma mark - special functions

-(NSString *)dateDiff:(NSDate *)convertedDate {
    
    NSDate *todayDate = [NSDate date];
    double ti = [convertedDate timeIntervalSinceDate:todayDate];
    ti = ti * -1;
    if (ti < 60) {
        return @"- less than a minute ago";
    } else if (ti < 3600) {
        int diff = round(ti / 60);
        return [NSString stringWithFormat:@"- %d minutes ago", diff];
    } else if (ti < 86400) {
        int diff = round(ti / 60 / 60);
        if(diff == 1){
            return[NSString stringWithFormat:@"- %d hour ago", diff];
        }else{
            return[NSString stringWithFormat:@"- %d hours ago", diff];
        }
    } else if (ti < 2629743) {
        int diff = round(ti / 60 / 60 / 24);
        return[NSString stringWithFormat:@"- %d days ago", diff];
    }
    
    //failed
    return @"";
}

- (NSImage*) resizeImage:(NSImage*)sourceImage size:(NSSize)size{
    
    NSRect targetFrame = NSMakeRect(0, 0, size.width, size.height);
    NSImage*  targetImage = [[NSImage alloc] initWithSize:size];
    
    NSSize sourceSize = [sourceImage size];
    
    float ratioH = size.height/ sourceSize.height;
    float ratioW = size.width / sourceSize.width;
    
    NSRect cropRect = NSZeroRect;
    if (ratioH >= ratioW) {
        cropRect.size.width = floor (size.width / ratioH);
        cropRect.size.height = sourceSize.height;
    } else {
        cropRect.size.width = sourceSize.width;
        cropRect.size.height = floor(size.height / ratioW);
    }
    
    cropRect.origin.x = floor( (sourceSize.width - cropRect.size.width)/2 );
    cropRect.origin.y = floor( (sourceSize.height - cropRect.size.height)/2 );
    
    
    
    [targetImage lockFocus];
    
    [sourceImage drawInRect:targetFrame
                   fromRect:cropRect       //portion of source image to draw
                  operation:NSCompositeCopy  //compositing operation
                   fraction:1.0              //alpha (transparency) value
             respectFlipped:YES              //coordinate system
                      hints:@{NSImageHintInterpolation:
                                  [NSNumber numberWithInt:NSImageInterpolationLow]}];
    
    [targetImage unlockFocus];
    
    return targetImage;
}

#pragma mark - quit

-(void)quit{
    [NSApp terminate:self];
}

- (void)onlyOneInstanceOfApp {
    if ([[NSRunningApplication runningApplicationsWithBundleIdentifier:[[NSBundle mainBundle] bundleIdentifier]] count] > 1) {
        NSLog(@"already running");
        [self quit];
    }
    
}


@end
