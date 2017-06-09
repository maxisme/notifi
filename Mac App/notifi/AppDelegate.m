//
//  AppDelegate.m
//  notifi
//
//  Created by Max Mitchell on 20/10/2016.
//  Copyright © 2016 max mitchell. All rights reserved.
//

#import "AppDelegate.h"
// ----- NotificationImage interface -----
@interface NotificationImage: KPCScaleToFillNSImageView
@property (strong) NSTrackingArea* trackingArea;
@property (strong) NSString* image_url;
@end

@implementation NotificationImage

- (void)mouseDown:(NSEvent *)event {
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:self.image_url]];
}

-(void)mouseEntered:(NSEvent *)theEvent {
    //use link cursor
    [super resetCursorRects];
    [self addCursorRect:self.bounds cursor:[NSCursor pointingHandCursor]];
    
    CABasicAnimation *flash = [CABasicAnimation animationWithKeyPath:@"opacity"];
    flash.fromValue = [NSNumber numberWithFloat:1.0];
    flash.toValue = [NSNumber numberWithFloat:0.8];
    flash.duration = 0.5;
    [flash setFillMode:kCAFillModeForwards];
    [flash setRemovedOnCompletion:NO];
    flash.repeatCount = 1;
    [self.layer addAnimation:flash forKey:@"flashAnimation"];
}

-(void)mouseExited:(NSEvent *)theEvent
{
    [super resetCursorRects];
    
    CABasicAnimation *flash = [CABasicAnimation animationWithKeyPath:@"opacity"];
    flash.fromValue = [NSNumber numberWithFloat:0.8];
    flash.toValue = [NSNumber numberWithFloat:1.0];
    flash.duration = 0.5;
    [flash setFillMode:kCAFillModeForwards];
    [flash setRemovedOnCompletion:NO];
    flash.repeatCount = 1;
    [self.layer addAnimation:flash forKey:@"flashAnimation"];
}

-(void)updateTrackingAreas
{
    if(self.trackingArea != nil) {
        [self removeTrackingArea:self.trackingArea];
    }
    
    int opts = (NSTrackingMouseEnteredAndExited | NSTrackingActiveAlways);
    self.trackingArea = [[NSTrackingArea alloc] initWithRect:[self bounds]
                                                     options:opts
                                                       owner:self
                                                    userInfo:nil];
    
    [self addTrackingArea:self.trackingArea];
}

@end

// ----- cog interface -----
@interface MyCog: NSImageView
@property (strong) NSTrackingArea* trackingArea;
@property (strong) NSMenu* customMenu;
@end

@implementation MyCog

- (void)mouseDown:(NSEvent *)event {
    [NSMenu popUpContextMenu:_customMenu withEvent:event forView:(id)self];
}

-(void)mouseEntered:(NSEvent *)theEvent {
    [self animate];
}

-(void)mouseExited:(NSEvent *)theEvent
{
    [self.layer removeAllAnimations];
}

-(void)updateTrackingAreas
{
    if(self.trackingArea != nil) {
        [self removeTrackingArea:self.trackingArea];
    }
    
    int opts = (NSTrackingMouseEnteredAndExited | NSTrackingActiveAlways);
    self.trackingArea = [[NSTrackingArea alloc] initWithRect:[self bounds]
                                                     options:opts
                                                       owner:self
                                                    userInfo:nil];
    
    [self addTrackingArea:self.trackingArea];
}

#define DEGREES_RADIANS(angle) ((angle) / 180.0 * M_PI)
-(void)animate{
    CGRect old = self.layer.frame;
    self.layer.anchorPoint = CGPointMake(0.5, 0.5);
    self.layer.frame = old;
    CABasicAnimation *rotate = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotate.removedOnCompletion = NO;
    rotate.fillMode = kCAFillModeForwards;
    rotate.fromValue = [NSNumber numberWithFloat:0.0f];
    rotate.toValue = [NSNumber numberWithFloat: - M_PI * 2.0f];
    rotate.duration = 3.0f;
    rotate.cumulative = YES;
    rotate.repeatCount = 1000;
    [self.layer addAnimation:rotate forKey:@"rotationAnimation"];
}

@end

// ----- notification view interface -----
@interface MyNotificationView: NSView
@property (nonatomic) int notificationID;
@property (nonatomic) NSString* link;
@property (atomic, weak) AppDelegate* thisapp;
@end

@implementation MyNotificationView
- (void) rightMouseDown:(NSEvent *)event {
    NSMenu *theMenu = [[NSMenu alloc] initWithTitle:@"Contextual Menu"];
    if([_thisapp notificationRead:self.notificationID]){
        [theMenu insertItemWithTitle:@"Mark Unread" action:@selector(markUnread) keyEquivalent:@"" atIndex:0];
    }else{
        [theMenu insertItemWithTitle:@"Mark Read" action:@selector(markRead) keyEquivalent:@"" atIndex:0];
    }
    
    [theMenu insertItemWithTitle:@"Delete" action:@selector(deleteNoti) keyEquivalent:@"" atIndex:1];
    
    [theMenu addItem:[NSMenuItem separatorItem]];
    NSString* url = [_thisapp notificationLink:self.notificationID];
    if(![url  isEqual: @" "] && url != nil){
        NSMenuItem *menuItem = [[NSMenuItem alloc] initWithTitle:@"Open Link" action:@selector(openLink:) keyEquivalent:@""];
        [menuItem setRepresentedObject:url];
        [theMenu addItem:menuItem];
    }
    
    NSString* imageLink = [_thisapp imageLink:self.notificationID];
    if(![imageLink  isEqual: @" "] && imageLink != nil){
        NSMenuItem *menuItem = [[NSMenuItem alloc] initWithTitle:@"Open Image URL" action:@selector(openLink:) keyEquivalent:@""];
        [menuItem setRepresentedObject:imageLink];
        [theMenu addItem:menuItem];
    }
    
    [NSMenu popUpContextMenu:theMenu withEvent:event forView:(id)self];
}
- (void)mouseDown:(NSEvent *)event
{
    //needs to be here for some reason to pass on the mouseup event to the label
}

- (void)markRead {
    [_thisapp markAsRead:true notificationID:self.notificationID];
}

- (void)markUnread {
    [_thisapp markAsRead:false notificationID:self.notificationID];
}

- (void)deleteNoti {
    [_thisapp deleteNotification:self.notificationID];
}

- (void)openLink:(id)sender{
    NSString* url = @"";
    if([sender isKindOfClass:[NSString class]]){
        //passed string param
        url = sender;
    }else{
        url = [sender representedObject];
    }
    
    if(![url  isEqual: @""]){
        [self markRead];
        [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:url]];
    }
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
        NSView* v = self.superview;
        [(MyNotificationView*)v.superview openLink:super.link];
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
    
    //initiate keychain
    _keychainQuery = [[SAMKeychainQuery alloc] init];
    _keychainQuery.account = @"notifi.it";
    
    NSString* credentials = [[NSUserDefaults standardUserDefaults] objectForKey:@"credentials"];
    if([credentials length] != 25){
        //new user
        [self newCredentials];
        [self openOnStartup];
    }
    [self openSocket];
    [self createStatusBarItem];
    
    [NSTimer scheduledTimerWithTimeInterval:2.0f target:self selector:@selector(check) userInfo:nil repeats:YES];
    [NSTimer scheduledTimerWithTimeInterval:30.0f target:self selector:@selector(sendPing) userInfo:nil repeats:YES];
    [NSTimer scheduledTimerWithTimeInterval:60.0f target:self selector:@selector(updateTimes) userInfo:nil repeats:YES];
    
    [self createWindow];
}

#pragma mark - window

-(void)positionWindow{
    //position variables
    float screen_width = [[NSScreen mainScreen] frame].size.width;
    
    float window_height = self.window.frame.size.height;
    int window_width = self.window.frame.size.width;
    
    int top_arrow_height = 20;
    
    NSRect menu_icon_frame = [[_statusItem valueForKey:@"window"] frame];
    float menu_icon_width = menu_icon_frame.size.width;
    float menu_icon_x = menu_icon_frame.origin.x;
    float menu_icon_y = menu_icon_frame.origin.y;
    
    //calculate positions
    float arrow_x = window_width/2 - (top_arrow_height/2);
    float arrow_y = window_height - top_arrow_height;
    
    float window_x = menu_icon_x - window_width/2 + menu_icon_width/2;
    float window_y = menu_icon_y - window_height;
    
    if(window_width + window_x > screen_width){ //window is far right
        int side_padding = 10;
        window_x = screen_width - window_width - side_padding;
        arrow_x = menu_icon_x + menu_icon_width/2 - window_x - side_padding;
    }
    
    //update
    [_window_up_arrow_view setFrame:NSMakeRect(arrow_x, arrow_y, top_arrow_height, top_arrow_height)];
    [_window setFrame:NSMakeRect(window_x, window_y, window_width, window_height) display:true];
}

-(void)createWindow{
    
    _black = [NSColor colorWithRed:0.13 green:0.13 blue:0.13 alpha:1.0];
    _white = [NSColor colorWithRed:1.00 green:1.00 blue:1.00 alpha:1.0];
    _red = [NSColor colorWithRed:0.74 green:0.13 blue:0.13 alpha:1.0];
    _grey = [NSColor colorWithRed:0.43 green:0.43 blue:0.43 alpha:1.0];
    _offwhite = [NSColor colorWithRed:0.98 green:0.98 blue:0.98 alpha:1.0];
    
    //position variables
    float screen_width = [[NSScreen mainScreen] frame].size.width;
    float screen_height = [[NSScreen mainScreen] frame].size.height;
    
    float window_height = screen_height * 0.7;
    int window_width = 350;
    
    int top_arrow_height = 20;
    
    NSRect menu_icon_frame = [[_statusItem valueForKey:@"window"] frame];
    float menu_icon_x = menu_icon_frame.origin.x;
    float menu_icon_height = menu_icon_frame.size.height;
    
    
    //calculate positions
    float arrow_x = window_width/2 - (top_arrow_height/2);
    float arrow_y = window_height - top_arrow_height;
    
    float window_x = menu_icon_x - window_width/2 + menu_icon_frame.size.width/2;
    float window_y = screen_height - menu_icon_height - window_height;
    
    if(window_width + window_x > screen_width){ //window is far right
        int side_padding = 10;
        window_x = screen_width - window_width - side_padding;
        arrow_x = menu_icon_frame.origin.x + menu_icon_frame.size.width/2 - window_x - side_padding;
    }
    
    _window = [[MyWindow alloc] initWithContentRect:NSMakeRect(window_x, window_y, window_width, window_height) styleMask:0 backing:NSBackingStoreBuffered defer:YES];
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
    _view.layer.backgroundColor = [NSColor clearColor].CGColor;
    _view.layer.cornerRadius = 2;
    [_view setWantsLayer:YES];
    
    NSTextField* bg = [[NSTextField alloc] initWithFrame:CGRectMake(0, 0, window_width, window_height - (top_arrow_height - 5)  )];
    bg.backgroundColor = _offwhite;
    bg.editable = false;
    bg.bordered = false;
    bg.wantsLayer = YES;
    bg.layer.cornerRadius = 10.0f;
    [_view addSubview:bg];
    
    NSImage* window_up_arrow = [NSImage imageNamed:@"up_arrow.png"];
    _window_up_arrow_view = [[NSImageView alloc] initWithFrame:NSMakeRect(arrow_x, arrow_y, top_arrow_height, top_arrow_height)];
    [_window_up_arrow_view setImage:window_up_arrow];
    [_view addSubview:_window_up_arrow_view];
    
    [self createBodyWindow];
}

-(void)createBodyWindow{
    
    //----------------- initial variables -----------------
    prevheight = notification_view_padding;
    
    //----------------- top stuff -----------------
    int top_bar_height = 90;
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
    NSImage *cog = [NSImage imageNamed:@"Anton Saputro.png"];
    NSBitmapImageRep *cog_rep = [NSBitmapImageRep imageRepWithData:[cog TIFFRepresentation]];
    NSSize cog_size = NSMakeSize([cog_rep pixelsWide], [cog_rep pixelsHigh]);
    [cog setSize: cog_size];
    int cog_height = 20;
    int cog_pad = 10;
    MyCog *cogView = [[MyCog alloc] initWithFrame:NSMakeRect(window_width - (cog_height + cog_pad), window_height-(cog_height + top_arrow_height + cog_pad), cog_height, cog_height)];
    //settings menu
    [cogView setCustomMenu:[self defaultStatusBarMenu]];
    [cogView setImage:cog];
    [cogView setImageScaling:NSImageScaleProportionallyUpOrDown];
    [cogView updateTrackingAreas];
    [_view addSubview:cogView];
    
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
    _scroll_view.backgroundColor = _offwhite;
    
    NSMutableArray *notifications = [[[NSUserDefaults standardUserDefaults] objectForKey:@"notifications"] mutableCopy];
    if((int)[notifications count] == 0){
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
        _notification_table.backgroundColor = _offwhite;
        [self reloadData];
        
        _scroll_view.documentView = _notification_table;
    }
    [_view addSubview:_scroll_view];
    
    //----------------- bottom stuff -----------------
    //mark all as read button
    NSButton* markAllAsReadBtn = [[NSButton alloc] initWithFrame:CGRectMake(0, 10, window_width / 2, 20)];
    [markAllAsReadBtn setAlignment:NSTextAlignmentCenter];
    [markAllAsReadBtn setFont:[NSFont fontWithName:@"Raleway-SemiBold" size:12]];
    markAllAsReadBtn.bordered =false;
    [markAllAsReadBtn setTitle:@"MARK ALL AS READ"];
    [markAllAsReadBtn setAction:@selector(markAllAsRead)];
    [_view addSubview:markAllAsReadBtn];
    
    //delete all button
    NSButton *deleteNotifications = [[NSButton alloc] initWithFrame:CGRectMake(window_width / 2, 10, window_width /2, 20)];
    
    NSMutableParagraphStyle *centredStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    [centredStyle setAlignment:NSCenterTextAlignment];
    
    NSDictionary *attrs = [NSDictionary dictionaryWithObjectsAndKeys:centredStyle,
                           NSParagraphStyleAttributeName,
                           [NSFont fontWithName:@"Raleway-SemiBold" size:12],
                           NSFontAttributeName,
                           _red,
                           NSForegroundColorAttributeName,
                           nil];
    NSMutableAttributedString *attributedString =
    [[NSMutableAttributedString alloc] initWithString:@"DELETE ALL"
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
}

-(NSView*)noNotificationsView{
    int window_width = _window.frame.size.width;
    
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
    NSMutableArray *notifications = [[[NSUserDefaults standardUserDefaults] objectForKey:@"notifications"] mutableCopy];
    return notifications.count;
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    NSView* view = [[NSView alloc] init];
    [view addSubview:[_notification_views objectAtIndex:row]];
    return view;
}

- (CGFloat) tableView:(NSTableView *) tableView heightOfRow:(NSInteger) row {
    int row_padding = 15;
    NSMutableArray *notifications = [[[NSUserDefaults standardUserDefaults] objectForKey:@"notifications"] mutableCopy];
    NSMutableDictionary *dic = notifications[([notifications count] - 1) - row];
    return [self createNotificationView:[dic objectForKey:@"title"]
                                message:[dic objectForKey:@"message"]
                               imageURL:[dic objectForKey:@"image"]
                                   link:[dic objectForKey:@"link"]
                                   time:[dic objectForKey:@"time"]
                                   read:[[dic objectForKey:@"read"] boolValue]
                         notificationID:[[dic objectForKey:@"id"] intValue]] . frame.size.height + row_padding;
}

- (void)tableView:(NSTableView *)tableView setObjectValue:(id)anObject forTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex {
    NSMutableArray *notifications = [[[NSUserDefaults standardUserDefaults] objectForKey:@"notifications"] mutableCopy];
    [notifications replaceObjectAtIndex:([notifications count] - 1) - rowIndex withObject:anObject];
}

bool reloaded_in_last_2 = false;
NSUInteger errorGeneration;
-(void)reloadData{
    if(!reloaded_in_last_2){ // every 2 seconds set to false
        [self reload];
    }else{
        errorGeneration++;
        NSUInteger capturedGeneration = errorGeneration;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2* NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if (errorGeneration == capturedGeneration) [self postReload];
        });
    }
}

-(void) postReload{
    if(!reloaded_in_last_2){
        [self reload];
    }
}

-(void) reload{
    dispatch_async(dispatch_get_main_queue(), ^{
        unread_notification_count = 0;
        reloaded_in_last_2 = true;
        _time_labels = nil;
        _notification_views = nil;
        _time_labels = [[NSMutableArray alloc] init];
        _notification_views = [[NSMutableArray alloc] init];
        
        [_notification_table reloadData];
        [_notification_table setWantsLayer:YES];
        if(unread_notification_count > 0){
            _statusItem.image = [NSImage imageNamed:@"alert_menu_bellicon.png" ];
        }else if(serverReplied){
            _statusItem.image = [NSImage imageNamed:@"menu_bellicon.png" ];
        }
    });
}

float prevheight;
int notification_view_padding = 20;
int unread_notification_count = 0;
-(NSView*)createNotificationView:(NSString*)title_string message:(NSString*)mes imageURL:(NSString*)imgURL link:(NSString*)url time:(NSString*)time_string read:(bool)read notificationID:(int)notificationID
{
    float width_perc = 0.9;
    int notification_width = _scroll_view.frame.size.width * width_perc;
    float x = _scroll_view.frame.size.width * (1 - width_perc)/2;
    int y = 5;
    
    int title_font_size = 17;
    int info_font_size = 12;
    
    int image_width = 70;
    int image_height = 70;
    
    int time_height = 20;
    
    NSView *view = [[NSView alloc] init];
    view.wantsLayer = TRUE;
    
    //check if image variable
    int padding_right = 5;
    if(![imgURL isEqual: @" "]){
        padding_right = 80;
    }
    
    float text_width = notification_width*0.98 - padding_right;
    
    //height of title
    NSMutableParagraphStyle *centredStyle_title = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    NSDictionary *attrs_title = [NSDictionary dictionaryWithObjectsAndKeys:centredStyle_title,
                           NSParagraphStyleAttributeName,
                           [NSFont fontWithName:@"Raleway-ExtraBold" size:title_font_size],
                           NSFontAttributeName,
                           nil];
    
    NSMutableAttributedString *attributedString_title = [[NSMutableAttributedString alloc] initWithString:title_string attributes:attrs_title];
    if(![url  isEqual: @" "]){
        NSRange range = NSMakeRange(0, attributedString_title.length);
        [attributedString_title addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInt:NSUnderlineStyleSingle] range:range];
    }
    CGRect rect_title = [attributedString_title boundingRectWithSize:CGSizeMake(text_width, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading context:nil];
    
    float title_height = rect_title.size.height; //calculated height of dynamic title
    
    //height of info
    float info_height = 0.0;
    if(![mes  isEqual: @" "]){
        //calculate height of view by height of info text area
        NSMutableParagraphStyle *centredStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
        NSDictionary *attrs = [NSDictionary dictionaryWithObjectsAndKeys:centredStyle,
                               NSParagraphStyleAttributeName,
                               [NSFont fontWithName:@"Raleway-SemiBold" size:info_font_size],
                               NSFontAttributeName,
                               nil];
        NSMutableAttributedString *attributedString =
        [[NSMutableAttributedString alloc] initWithString:mes
                                               attributes:attrs];
        CGRect rect = [attributedString boundingRectWithSize:CGSizeMake(text_width, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading context:nil];
        
        info_height = rect.size.height;
    }
    
    //calculate total height of notification
    int extra_padding = 10;
    int notification_height = title_height + time_height + info_height + (notification_view_padding * 2) + extra_padding;
    
    if(![imgURL isEqual: @" "]){ // handle extra height if image
        int min_height = image_height + time_height + notification_view_padding;
        if(notification_height < min_height){
            notification_height = min_height;
        }
    }
    
    //create view
    [view setFrame:CGRectMake(x, y, notification_width, notification_height - 45)];
    [view.layer setBackgroundColor:[_white CGColor]];
    
    view.layer.cornerRadius = 7.0f;
    view.layer.masksToBounds = YES;
    
    //body of notification
    //--      add image
    if(![imgURL isEqual: @" "]){
        NSRect imageRect = NSMakeRect(0, view.frame.size.height - image_height, image_width, image_height);
        NotificationImage *image_view = [[NotificationImage alloc] initWithFrame:imageRect];
        [image_view setImageScaling:NSImageScaleProportionallyUpOrDown];
        [image_view sd_setImageWithURL:[NSURL URLWithString:imgURL]];
        image_view.image_url = imgURL;
        [view addSubview:image_view];
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
    title_field.font = [NSFont fontWithName:@"Raleway-ExtraBold" size:title_font_size];
    title_field.preferredMaxLayoutWidth = text_width;
    title_field.backgroundColor = [NSColor clearColor];
    [title_field setAlignment:NSTextAlignmentLeft];
    title_field.tag = notificationID;
    [title_field setTextColor:_grey];
    if(!read){
        [title_field setTextColor:_red];
        unread_notification_count++;
    }
    title_field.editable = false;
    title_field.bordered = false;
    title_field.attributedStringValue = attributedString_title;
    
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
    [time_label setTextColor:_grey];
    [time_label setSelectable:YES];
    time_label.editable = false;
    time_label.bordered =false;
    
    //get nsdate
    NSDateFormatter *serverFormat = [[NSDateFormatter alloc]init];
    [serverFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *date = [serverFormat dateFromString:time_string];
    
    //change to local time zone
    NSTimeZone *tz = [NSTimeZone systemTimeZone];
    NSInteger seconds = [tz secondsFromGMTForDate: date]; //server time zone `date +%Z`
    NSDate* convertedDate = [NSDate dateWithTimeInterval: seconds sinceDate:date];
    
    //convert to desired format
    NSDateFormatter *myFormat = [[NSDateFormatter alloc]init];
    [myFormat setDateFormat:@"MMM d, yyyy HH:mm"];
    NSString *formattedStringDate = [myFormat stringFromDate:convertedDate];
    
    NSString* timestr = [NSString stringWithFormat:@"%@ %@",formattedStringDate, [self dateDiff:convertedDate]];
    
    //dynamic time
    time_label.time = convertedDate;
    time_label.str_time = formattedStringDate;
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
        info.font = [NSFont fontWithName:@"Raleway-Medium" size:info_font_size];
        info.preferredMaxLayoutWidth = text_width;
        info.backgroundColor = [NSColor clearColor];
        [info setAlignment:NSTextAlignmentLeft];
        [info setTextColor:_black];
        [info setSelectable:YES];
        info.editable = false;
        info.bordered = false;
        [info setStringValue:mes];
        [view addSubview:info];
    }
    
    MyNotificationView *view1 = [[MyNotificationView alloc] initWithFrame:view.frame];
    view1.notificationID = notificationID;
    view1.thisapp = self;
    
    //create shadow
    NSShadow *dropShadow = [[NSShadow alloc] init];
    [dropShadow setShadowColor:[NSColor colorWithRed:0.13 green:0.13 blue:0.13 alpha:0.5]];
    [dropShadow setShadowOffset:NSMakeSize(0, 0)];
    [dropShadow setShadowBlurRadius:2.0];
    [view1 setShadow:dropShadow];
    [view setFrame:NSMakeRect(0, 0, view.frame.size.width, view.frame.size.height)];
    [view1 addSubview:view];
    [_notification_views addObject:view1];
    
    return view1;
}

-(void)updateTimes{
    for(MyLabel* time_label in _time_labels){
        NSString* timestr = [NSString stringWithFormat:@"%@ %@", time_label.str_time, [self dateDiff:time_label.time]];
        [time_label setStringValue:timestr];
    }
}

-(void)showWindow{
    [[NSUserNotificationCenter defaultUserNotificationCenter] removeAllDeliveredNotifications];
    
    [self positionWindow];
    [NSApp activateIgnoringOtherApps:YES];
    [_window makeKeyAndOrderFront:_view];
    [_window makeFirstResponder:_scroll_view.documentView];
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
-(void)createNewCredentials{
    if(_window && [_window isVisible]){
        [_window orderOut:self];
    }
    
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

bool failedCredentials = false;
-(void)newCredentials{
    if(![_credentialsItem.title isEqual: @"Fetching credentials..."]){
        [_credentialsItem setTitle:@"Fetching credentials..."];
        [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"notifications"];
        NSURL *url = [NSURL URLWithString:@"https://notifi.it/getCode.php"];
        NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url
                                                    cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                                timeoutInterval:3];
        NSData *urlData;
        NSURLResponse *response;
        NSError *error;
        urlData = [NSURLConnection sendSynchronousRequest:urlRequest
                                        returningResponse:&response
                                                    error:&error];
        NSString* content = [[NSString alloc] initWithData:urlData encoding:NSUTF8StringEncoding];
        
        NSString* key = [self jsonToVal:content key:@"key"];
        NSString* credentials = [self jsonToVal:content key:@"credentials"];
        
        if(![key isEqual: @""] && ![credentials isEqual: @""]){
            failedCredentials = false;
            [self storeKey:@"credential_key" withPassword:key];
            [[NSUserDefaults standardUserDefaults] setObject:credentials forKey:@"credentials"];
            [_credentialsItem setTitle:credentials];
        }else{
            failedCredentials = true;
            NSAlert *alert = [[NSAlert alloc] init];
            [alert setInformativeText:@"Please try again."];
            [alert addButtonWithTitle:@"Ok"];
            if([content  isEqual: @"0"]){
                [_credentialsItem setTitle:@"Please click 'Create New Credentials'!"];
                [alert setMessageText:@"Credentials already registered!"];
            }else{
                [_credentialsItem setTitle:@"Error Fetching credentials!"];
                [alert setMessageText:@"Error Fetching credentials!"];
                if(error){
                    [alert setInformativeText:[NSString stringWithFormat:@"Error message: %@",error]];
                }else{
                    [alert setInformativeText:[NSString stringWithFormat:@"Error message: %@",content]];
                }
            }
            [alert runModal];
        }
    
        [self closeSocket];
    }
}

#pragma mark - handle icoming notification
bool serverReplied = false;
-(void)check{
    if(!failedCredentials){
        if(!streamOpen){
            [self openSocket];
        }else if(!serverReplied){
            [self sendCode];
        }
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
        
        NSMutableArray *notifications = [[[NSUserDefaults standardUserDefaults] objectForKey:@"notifications"] mutableCopy];
        
        BOOL shouldRefresh = false;
        NSMutableArray* incoming_notifications = [[NSMutableArray alloc] init];
        
        for (NSDictionary* notification in json_dic) {
            NSString* firstval = [NSString stringWithFormat:@"%@", notification];;
            if([[firstval substringToIndex:3]  isEqual: @"id:"]){
                //TELL SERVER TO DELETE THIS MESSAGE AS RECEIVED
                if(streamOpen){
                    [_webSocket send:firstval];
                }
            }else{
                [self storeNotification:notification];
                shouldRefresh = true;
                [incoming_notifications addObject:notification];
            }
        }
        
        if(shouldRefresh){
            if([incoming_notifications count] <= 5){
                for (NSDictionary* notification in incoming_notifications){
                    [self sendLocalNotification:[notification objectForKey:@"title"]
                                        message:[notification objectForKey:@"message"]
                                       imageURL:[notification objectForKey:@"image"]
                                           link:[notification objectForKey:@"link"]
                                 notificationID:[[notification objectForKey:@"id"] intValue]
                    ];
                }
            }else{
                //send notification with the amount of notifications rather than individual notifications
                NSUserNotification *note = [[NSUserNotification alloc] init];
                [note setHasActionButton:false];
                [note setTitle:[NSString stringWithFormat:@"You have %d new notifications!",(int)[incoming_notifications count]]];
                [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:note];
                [[NSUserNotificationCenter defaultUserNotificationCenter] setDelegate:(id)self];
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if([notifications count] == 0){
                    [self createBodyWindow];
                }else{
                    [self reloadData];
                }
            });
        }
    }
}

#pragma mark - notification storage

-(void)storeNotification:(NSDictionary*)notificationDic{
    NSMutableDictionary *dic = [notificationDic mutableCopy];
    //add read object to dic
    [dic setObject:[NSNumber numberWithBool:0] forKey:@"read"];
    
    //get stored notifications
    NSMutableArray *notifications = [[[NSUserDefaults standardUserDefaults] objectForKey:@"notifications"] mutableCopy];
    if([notifications count] == 0){
        notifications = [[NSMutableArray alloc] init];
    }
    
    //add dic to notifications
    [notifications addObject:dic];
    
    //store notifications
    [[NSUserDefaults standardUserDefaults] setObject:notifications forKey:@"notifications"];
}

-(bool)notificationRead:(int)notificationID{
    NSMutableArray *notifications = [[[NSUserDefaults standardUserDefaults] objectForKey:@"notifications"] mutableCopy];
    int index = [self indexFromNotification:notificationID notifications:notifications];
    NSMutableDictionary *dic = [[notifications objectAtIndex:index] mutableCopy];
    return [[dic objectForKey:@"read"] boolValue];
}

-(NSString*)notificationLink:(int)notificationID{
    NSMutableArray *notifications = [[[NSUserDefaults standardUserDefaults] objectForKey:@"notifications"] mutableCopy];
    int index = [self indexFromNotification:notificationID notifications:notifications];
    NSMutableDictionary *dic = [[notifications objectAtIndex:index] mutableCopy];
    return [dic objectForKey:@"link"];
}

-(NSString*)imageLink:(int)notificationID{
    NSMutableArray *notifications = [[[NSUserDefaults standardUserDefaults] objectForKey:@"notifications"] mutableCopy];
    int index = [self indexFromNotification:notificationID notifications:notifications];
    NSMutableDictionary *dic = [[notifications objectAtIndex:index] mutableCopy];
    return [dic objectForKey:@"image"];
}

-(void)markAsRead:(bool)read notificationID:(int)notificationID{
    //update stored notification
    NSMutableArray *notifications = [[[NSUserDefaults standardUserDefaults] objectForKey:@"notifications"] mutableCopy];
    
    int index = [self indexFromNotification:notificationID notifications:notifications];
    
    NSMutableDictionary *dic = [[notifications objectAtIndex:index] mutableCopy];
    [dic setObject:[NSNumber numberWithBool:read] forKey:@"read"];
    [notifications replaceObjectAtIndex:index withObject:dic];
    [[NSUserDefaults standardUserDefaults] setObject:notifications forKey:@"notifications"];
    
    //update view
    int row = [self rowFromNotification:notificationID];
    MyNotificationView* notification = [_notification_views objectAtIndex:row];
    MyTitleLabel* title = (MyTitleLabel*)[notification viewWithTag:notification.notificationID];
    if(read){
        unread_notification_count--;
        title.textColor = _grey;
    }else{
        unread_notification_count++;
        title.textColor = _red;
    }
    
    [self updateReadIcon];
}

-(void)markAllAsRead{
    for(int x = (int)[_notification_views count] - 1; x >= 0 ; x--){
        MyNotificationView* notification = [_notification_views objectAtIndex:x];
        [self markAsRead:true notificationID:notification.notificationID];
    }
}

-(void)deleteNotification:(int)notificationID{
    NSMutableArray *notifications = [[[NSUserDefaults standardUserDefaults] objectForKey:@"notifications"] mutableCopy];
    int notification_count = (int)[notifications count];
    
    if(notification_count <= 1){
        _scroll_view.documentView = [self noNotificationsView];
    }
    
    int index = [self indexFromNotification:notificationID notifications:notifications];
    
    //check if notification was read or unread
    if([[notifications objectAtIndex:index][@"read"] isEqualToNumber:[NSNumber numberWithBool:NO]]) unread_notification_count--;
    
    //update stored notifications
    [notifications removeObjectAtIndex:index]; // as rows are presented backwards
    [[NSUserDefaults standardUserDefaults] setObject:notifications forKey:@"notifications"];
    
    //update GUI
    int row = [self rowFromNotification:notificationID];
    [_notification_views removeObjectAtIndex:row];
    [_time_labels removeObjectAtIndex:row];
    [_notification_table removeRowsAtIndexes:[NSIndexSet indexSetWithIndex:row] withAnimation:NSTableViewAnimationEffectFade];
    
    [self updateReadIcon];
}

-(void)deleteAll{
    NSMutableArray *notifications = [[[NSUserDefaults standardUserDefaults] objectForKey:@"notifications"] mutableCopy];
    
    if([notifications count] > 0){
        //close window
        if(_window && [_window isVisible]){
            [_window orderOut:self];
        }
        
        //ask if sure
        NSAlert *alert = [[NSAlert alloc] init];
        [alert addButtonWithTitle:@"OK"];
        [alert addButtonWithTitle:@"Cancel"];
        [alert setMessageText:[NSString stringWithFormat:@"Delete all %d notifications?", (int)[notifications count]]];
        [alert setInformativeText:@"Notifications cannot be restored."];
        [alert setAlertStyle:NSWarningAlertStyle];
        
        if ([alert runModal] == NSAlertFirstButtonReturn) {
            [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"notifications"];
            [self reloadData];
            [self createBodyWindow];
        }
    }
}

-(int)rowFromNotification:(int)notificationID{
    for(int x = (int)[_notification_views count] - 1; x >= 0 ; x--){
        MyNotificationView* notification_view = [_notification_views objectAtIndex:x];
        if(notification_view.notificationID == notificationID) return x;
    }
    [NSException raise:@"Invalid notificationID value" format:@"notificationID - %d is out of bounds", notificationID];
    return -1;
}

-(int)indexFromNotification:(int)notificationID notifications:(NSMutableArray *)notifications{
    return ((int)[_notification_views count] - 1) - [self rowFromNotification:notificationID];
}

-(void)updateReadIcon{
    if(unread_notification_count > 0){
        _statusItem.image = [NSImage imageNamed:@"alert_menu_bellicon.png" ];
    }else if(serverReplied){
        _statusItem.image = [NSImage imageNamed:@"menu_bellicon.png" ];
    }
}

#pragma mark - notifications
-(void)sendLocalNotification:(NSString*)title message:(NSString*)mes imageURL:(NSString*)imgURL link:(NSString*)url notificationID:(unsigned long)notificationID{
    NSUserNotification *notification = [[NSUserNotification alloc] init];
    
    //pass variables through notification
    notification.userInfo = @{
        @"notificationID" : [NSString stringWithFormat:@"%lu", notificationID],
        @"url" : url
    };
    
    [notification setTitle:title];
    
    if(![mes isEqual: @" "])
        [notification setInformativeText:mes];
    
    if(![imgURL isEqual: @" "]){
        NSImage* image;
        @try {
            image = [[NSImage alloc] initWithContentsOfURL:[NSURL URLWithString:imgURL]];
            [notification setValue:image forKey:@"_identityImage"];
        }
        @catch (NSException * e) {
            NSLog(@"ERROR loading image from URL: %@",imgURL);
        }
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
    if(notification.userInfo[@"notificationID"]){
        int notificationID = [notification.userInfo[@"notificationID"] intValue];
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
        
        if(url) [[NSWorkspace sharedWorkspace] openURL:url];
        
        [self markAsRead:true notificationID:notificationID];
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
    NSString* key = [self getKey:@"credential_key"];
    
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
}

#pragma mark - menu bar

- (void)createStatusBarItem {
    NSStatusBar *statusBar = [NSStatusBar systemStatusBar];
    _statusItem = [statusBar statusItemWithLength:NSSquareStatusItemLength];
    _statusItem.image = [NSImage imageNamed:@"menu_bellicon.png" ];
    //_statusItem.highlightMode = YES;
    [_statusItem setAction:@selector(iconClick)];
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
    
    NSMenuItem* copy = [[NSMenuItem alloc] initWithTitle:@"Copy Credentials" action:@selector(copyCredentials) keyEquivalent:@"c"];
    [copy setTarget:self];
    [copy setEnabled:true];
    [mainMenu addItem:copy];
    
    NSMenuItem* newCredentials = [[NSMenuItem alloc] initWithTitle:@"Create New Credentials" action:@selector(createNewCredentials) keyEquivalent:@""];
    [newCredentials setTarget:self];
    [mainMenu addItem:newCredentials];
    
    _credentialsItem = [[NSMenuItem alloc] initWithTitle:[[NSUserDefaults standardUserDefaults] objectForKey:@"credentials"] action:nil keyEquivalent:@""];
    [_credentialsItem setTarget:self];
    [_credentialsItem setEnabled:false];
    [mainMenu addItem:_credentialsItem];
    
    [mainMenu addItem:[NSMenuItem separatorItem]];
    
    NSMenuItem* updates = [[NSMenuItem alloc] initWithTitle:@"Check For Updates..." action:@selector(checkUpdate) keyEquivalent:@""];
    [updates setTarget:self];
    [mainMenu addItem:updates];
    
    _showOnStartupItem = [[NSMenuItem alloc] initWithTitle:@"Open notifi At Login" action:@selector(openOnStartup) keyEquivalent:@""];
    [_showOnStartupItem setTarget:self];
    if([self loginItemExistsWithLoginItemReference]){
        [_showOnStartupItem setState:NSOnState];
    }else{
        [_showOnStartupItem setState:NSOffState];
    }
    [mainMenu addItem:_showOnStartupItem];
    
    [mainMenu addItem:[NSMenuItem separatorItem]];
    
    NSMenuItem* quit = [[NSMenuItem alloc] initWithTitle:@"Quit notifi" action:@selector(quit) keyEquivalent:@"q"];
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
    if(![self loginItemExistsWithLoginItemReference]){
        [self enableLoginItemWithURL];
        [_showOnStartupItem setState:NSOnState];
    }else{
        [self removeLoginItemWithURL];
        [_showOnStartupItem setState:NSOffState];
    }
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

-(NSString*)jsonToVal:(NSString*)json key:(NSString*)key{
    NSMutableDictionary* dic = [NSJSONSerialization JSONObjectWithData:[json dataUsingEncoding:NSUTF8StringEncoding] options:0 error:NULL];
    if([dic objectForKey:key]) return [dic objectForKey:key];
    return @"";
}

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

#pragma mark - keychain
-(BOOL)storeKey:(NSString*)service withPassword:(NSString*)pass{
    NSError* error = nil;
    
    _keychainQuery.service = service;
    [_keychainQuery setPassword:pass];
    [_keychainQuery save:&error];
    
    if(!error) return TRUE;
    return FALSE;
}

-(NSString*)getKey:(NSString*)service{
    NSError* error;
    
    _keychainQuery.service = service;
    [_keychainQuery fetch:&error];
    
    if(error){
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:@"Error fetching your Key!"];
        [alert setInformativeText:[NSString stringWithFormat:@"There was an error fetching your key. Please contact hello@notifi.it.\r %@",error]];
        [alert addButtonWithTitle:@"Ok"];
        return @" ";
    }
    
    return [_keychainQuery password];
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

#pragma mark - sparkle

-(void)checkUpdate{
    if(_window && [_window isVisible]){
        [_window orderOut:self];
    }
    
    [[SUUpdater updaterForBundle:[NSBundle bundleForClass:[self class]]] checkForUpdates:NULL];
}

@end
