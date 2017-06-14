//
//  AppDelegate.m
//  notifi
//
//  Created by Max Mitchell on 20/10/2016.
//  Copyright © 2016 max mitchell. All rights reserved.
//

#import "AppDelegate.h"

// ----- MyButton interface -----
@interface MyButton: NSButton
@property (strong) NSTrackingArea* trackingArea;
@end

@implementation MyButton
-(void)mouseEntered:(NSEvent *)theEvent {
    [super resetCursorRects];
    [self addCursorRect:self.bounds cursor:[NSCursor pointingHandCursor]];
    
    CABasicAnimation *flash = [CABasicAnimation animationWithKeyPath:@"opacity"];
    flash.fromValue = [NSNumber numberWithFloat:1.0];
    flash.toValue = [NSNumber numberWithFloat:0.7];
    flash.duration = 0.2;
    [flash setFillMode:kCAFillModeForwards];
    [flash setRemovedOnCompletion:NO];
    flash.repeatCount = 1;
    [self.layer addAnimation:flash forKey:@"flashAnimation"];
}

-(void)mouseExited:(NSEvent *)theEvent{
    [super resetCursorRects];
    
    CABasicAnimation *flash = [CABasicAnimation animationWithKeyPath:@"opacity"];
    flash.fromValue = [NSNumber numberWithFloat:0.7];
    flash.toValue = [NSNumber numberWithFloat:1.0];
    flash.duration = 0.2;
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
    
    [theMenu insertItemWithTitle:@"Delete Notification" action:@selector(deleteNoti) keyEquivalent:@"" atIndex:1];
    
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

// animation params
- (void)animateWithDuration:(NSTimeInterval)duration
                  animation:(void (^)(void))animationBlock
{
    [self animateWithDuration:duration animation:animationBlock completion:nil];
}
- (void)animateWithDuration:(NSTimeInterval)duration
                  animation:(void (^)(void))animationBlock
                 completion:(void (^)(void))completionBlock
{
    [NSAnimationContext beginGrouping];
    [[NSAnimationContext currentContext] setDuration:duration];
    animationBlock();
    [NSAnimationContext endGrouping];
    
    if(completionBlock)
    {
        id completionBlockCopy = [completionBlock copy];
        [self performSelector:@selector(runEndBlock:) withObject:completionBlockCopy afterDelay:duration];
    }
}

- (void)runEndBlock:(void (^)(void))completionBlock
{
    completionBlock();
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

// animation params
- (void)animateWithDuration:(NSTimeInterval)duration
                  animation:(void (^)(void))animationBlock
{
    [self animateWithDuration:duration animation:animationBlock completion:nil];
}
- (void)animateWithDuration:(NSTimeInterval)duration
                  animation:(void (^)(void))animationBlock
                 completion:(void (^)(void))completionBlock
{
    [NSAnimationContext beginGrouping];
    [[NSAnimationContext currentContext] setDuration:duration];
    animationBlock();
    [NSAnimationContext endGrouping];
    
    if(completionBlock)
    {
        id completionBlockCopy = [completionBlock copy];
        [self performSelector:@selector(runEndBlock:) withObject:completionBlockCopy afterDelay:duration];
    }
}

- (void)runEndBlock:(void (^)(void))completionBlock
{
    completionBlock();
}
@end

// ----- notification view interface -----
@interface MyTitleLabel: MyLabel
@end

@implementation MyTitleLabel

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

// ----- image interface -----
@interface NSImage (Rotated)
@end

@implementation NSImage (Rotated)

-  (NSImage *)imageRotated:(float)degrees {
    
    degrees = fmod(degrees, 360.);
    if (0 == degrees) {
        return self;
    }
    NSSize size = [self size];
    NSSize maxSize;
    if (90. == degrees || 270. == degrees || -90. == degrees || -270. == degrees) {
        maxSize = NSMakeSize(size.height, size.width);
    } else if (180. == degrees || -180. == degrees) {
        maxSize = size;
    } else {
        maxSize = NSMakeSize(20+MAX(size.width, size.height), 20+MAX(size.width, size.height));
    }
    NSAffineTransform *rot = [self transformRotatingAroundPoint:NSMakePoint(2, size.width/2) byDegrees:degrees];
    NSAffineTransform *center = [NSAffineTransform transform];
    [center translateXBy:maxSize.width / 2. yBy:maxSize.height / 2.];
    [rot appendTransform:center];
    NSImage *image = [[NSImage alloc] initWithSize:maxSize];
    [image lockFocus];
    [rot concat];
    NSRect rect = NSMakeRect(0, 0, size.width, size.height);
    NSPoint corner = NSMakePoint(-size.width / 2., -size.height / 2.);
    [self drawAtPoint:corner fromRect:rect operation:NSCompositeCopy fraction:1.0];
    [image unlockFocus];
    return image;
}

-(NSAffineTransform *)transformRotatingAroundPoint:(NSPoint) p byDegrees:(CGFloat) deg
{
    NSAffineTransform * transform = [NSAffineTransform transform];
    [transform translateXBy: p.x yBy: p.y];
    [transform rotateByDegrees:deg];
    [transform translateXBy: -p.x yBy: -p.y];
    return transform;
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
        
        [[NSUserDefaults standardUserDefaults] setBool:true forKey:@"sticky_notification"];
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
    float window_width = self.window.frame.size.width;
    
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
    NSLog(@"x:%f y:%f w:%f h:%f indow_w: %f", window_x, window_y, window_width, window_height, screen_width);
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
    bg.backgroundColor = _white;
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
    
    int bottom_buttons_height = 40;
    //----------------- body -----------------
    
    //scroll view
    float scroll_height = (window_height - top_bar_height) - bottom_buttons_height;
    
    _scroll_view = [[NSScrollView alloc] initWithFrame:NSMakeRect(0, bottom_buttons_height, window_width, scroll_height)];
    
    [_scroll_view setBorderType:NSNoBorder];
    [_scroll_view setHasVerticalScroller:YES];
    _scroll_view.backgroundColor = _offwhite;
    NSShadow *dropShadow = [[NSShadow alloc] init];
    [dropShadow setShadowColor:[NSColor colorWithRed:0.13 green:0.13 blue:0.13 alpha:0.5]];
    [dropShadow setShadowOffset:NSMakeSize(0, 0)];
    [dropShadow setShadowBlurRadius:3.0];
    [_scroll_view setShadow:dropShadow];
    
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
    int p = 40;
    //mark all as read button
    MyButton* markAllAsReadBtn = [[MyButton alloc] initWithFrame:CGRectMake(p / 2, 5, (window_width / 2) - p, 30)];
    [markAllAsReadBtn setButtonType:NSMomentaryChangeButton];
    [markAllAsReadBtn setAlignment:NSTextAlignmentCenter];
    [markAllAsReadBtn setFont:[NSFont fontWithName:@"Raleway-SemiBold" size:12]];
    markAllAsReadBtn.bordered =false;
    [markAllAsReadBtn setTitle:@"MARK ALL AS READ"];
    [markAllAsReadBtn setAction:@selector(markAllAsRead)];
    [markAllAsReadBtn updateTrackingAreas];
    [_view addSubview:markAllAsReadBtn];
    
    //delete all button
    MyButton *deleteNotifications = [[MyButton alloc] initWithFrame:CGRectMake(window_width / 2 + (p /2), 5, window_width /2 - p, 30)];
    [deleteNotifications setButtonType:NSMomentaryChangeButton];
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
    [deleteNotifications updateTrackingAreas];
    deleteNotifications.layer.borderWidth = 3;
    deleteNotifications.layer.borderColor = _red.CGColor;
    deleteNotifications.layer.cornerRadius = 8;
    deleteNotifications.wantsLayer = YES;
    [_view addSubview:deleteNotifications];
}

bool animating = false;
-(void)animateBell:(NSImage*)image{
    // get these data points by making every point a keyframe on after effects copying and then copying and pasting them into a file
    NSArray *numbers = [@"-20,-15.1022,-10.5422,-6.32,-2.43556,1.11111,4.32,7.19111,9.72444,11.92,13.7778,15.2978,16.48,17.3244,17.8311,18,13.6178,9.53778,5.76,2.28444,-0.888889,-3.76,-6.32889,-8.59556,-10.56,-12.2222,-13.5822,-14.64,-15.3956,-15.8489,-16,-12.1333,-8.53333,-5.2,-2.13333,0.666667,3.2,5.46667,7.46667,9.2,10.6667,11.8667,12.8,13.4667,13.8667,14,10.52,7.28,4.28,1.52,-1,-3.28,-5.32,-7.12,-8.68,-10,-11.08,-11.92,-12.52,-12.88,-13,-9.77778,-6.77778,-4,-1.44444,0.888889,3,4.88889,6.55556,8,9.22222,10.2222,11,11.5556,11.8889,12,9.16444,6.52444,4.08,1.83111,-0.222222,-2.08,-3.74222,-5.20889,-6.48,-7.55556,-8.43556,-9.12,-9.60889,-9.90222,-10,-7.68,-5.52,-3.52,-1.68,-7.10543e-15,1.52,2.88,4.08,5.12,6,6.72,7.28,7.68,7.92,8,6.19556,4.51556,2.96,1.52889,0.222222,-0.96,-2.01778,-2.95111,-3.76,-4.44444,-5.00444,-5.44,-5.75111,-5.93778,-6,-4.71111,-3.51111,-2.4,-1.37778,-0.444444,0.4,1.15556,1.82222,2.4,2.88889,3.28889,3.6,3.82222,3.95556,4,3.22667,2.50667,1.84,1.22667,0.666667,0.16,-0.293333,-0.693333,-1.04,-1.33333,-1.57333,-1.76,-1.89333,-1.97333,-2,-1.74222,-1.50222,-1.28,-1.07556,-0.888889,-0.72,-0.568889,-0.435556,-0.32,-0.222222,-0.142222,-0.08,-0.0355556,-0.0088888" componentsSeparatedByString:@","];
    if(!animating){
        animating = true;
        dispatch_async(dispatch_get_global_queue(0,0), ^{
            for (NSString *i in numbers) {
                float x = [i floatValue];
                [NSThread sleepForTimeInterval:0.012];
                _statusItem.image = [image imageRotated:x];
            }
            _statusItem.image = image;
            animating = false;
        });
    }
}

-(NSView*)noNotificationsView{
    int window_width = _window.frame.size.width;
    
    MyNotificationView *view = [[MyNotificationView alloc] initWithFrame:_scroll_view.frame];
    view.wantsLayer = TRUE;
    
    NSMutableParagraphStyle *centredStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    [centredStyle setAlignment:NSTextAlignmentCenter];
    
    //no notifications text
    int title_height = 60;
    NSDictionary *noNotificationsAttrs = [NSDictionary dictionaryWithObjectsAndKeys:centredStyle,
                           NSParagraphStyleAttributeName,
                           [NSFont fontWithName:@"Raleway-SemiBold" size:25],
                           NSFontAttributeName,
                           _grey,
                           NSForegroundColorAttributeName,
                           nil];
    NSMutableAttributedString *noNotificationsString =
    [[NSMutableAttributedString alloc] initWithString:@"No Notifications"
                                           attributes:noNotificationsAttrs];
    MyTitleLabel* title_field = [[MyTitleLabel alloc] initWithFrame:
                                 CGRectMake(
                                            0,
                                            _scroll_view.frame.size.height/2 - title_height/2 + 30,
                                            window_width,
                                            title_height
                                            )
                                 ];
    title_field.editable = false;
    title_field.bordered = false;
    title_field.backgroundColor = [NSColor clearColor];
    [title_field setAlignment:NSTextAlignmentCenter];
    title_field.attributedStringValue = noNotificationsString;
    [title_field setWantsLayer:true];
    [title_field setAllowsEditingTextAttributes:YES];
    [title_field setSelectable:YES];
    [view addSubview:title_field];
    
    //send curls
    NSDictionary *sendCurlAttrs = [NSDictionary dictionaryWithObjectsAndKeys:centredStyle,
                                          NSParagraphStyleAttributeName,
                                          [NSFont fontWithName:@"Raleway-Medium" size:13],
                                          NSFontAttributeName,
                                          _grey,
                                          NSForegroundColorAttributeName,
                                          nil];
    NSMutableAttributedString *sendCurlString =
    [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"Send HTTP requests with your credentials\n%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"credentials"]]
                                           attributes:sendCurlAttrs];
    [sendCurlString beginEditing];
//    [sendCurlString applyFontTraits:NSBoldFontMask
//                              range:NSMakeRange(5,4)];
    [sendCurlString applyFontTraits:NSItalicFontMask
                              range:NSMakeRange(41, 25)];
    [sendCurlString addAttribute:NSLinkAttributeName value: @"https://github.com/maxisme/notifi#http-request-examples" range:NSMakeRange(5,4)];
    [sendCurlString endEditing];
    
    MyTitleLabel* curl_field = [[MyTitleLabel alloc] initWithFrame:
                                 CGRectMake(
                                            0,
                                            title_field.frame.origin.y - 50,
                                            window_width,
                                            60
                                            )
                                 ];
    curl_field.editable = false;
    curl_field.bordered = false;
    curl_field.backgroundColor = [NSColor clearColor];
    [curl_field setAlignment:NSTextAlignmentCenter];
    curl_field.attributedStringValue = sendCurlString;
    [curl_field setWantsLayer:true];
    [curl_field setAllowsEditingTextAttributes:YES];
    [curl_field setSelectable:YES];
    
    [view addSubview:curl_field];
    
    return view;
}

#pragma mark - Table View Data Source

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    NSMutableArray *notifications = [[[NSUserDefaults standardUserDefaults] objectForKey:@"notifications"] mutableCopy];
    return notifications.count;
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    // format cell view
    NSView* view = [[NSView alloc] init];
    [view addSubview:[_notification_views objectAtIndex:row]];
    return view;
}

- (CGFloat) tableView:(NSTableView *) tableView heightOfRow:(NSInteger) row {
    int row_padding = 15;
    NSMutableArray *notifications = [[[NSUserDefaults standardUserDefaults] objectForKey:@"notifications"] mutableCopy];
    NSMutableDictionary *dic = notifications[([notifications count] - 1) - row]; // backwards
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
        [self updateReadIcon:true];
    });
}

#pragma mark - notification

-(void)animateNotifications{
    int right = _window.frame.size.width / 2;
    
    //notifications
    for(int x = (int)[_notification_views count] - 1; x >= 0 ; x--){
        MyNotificationView* notification = [_notification_views objectAtIndex:x];
        int or_x = notification.frame.origin.x;
        int or_y = notification.frame.origin.y;
        float dt = x * 0.07;
    
        [notification animateWithDuration:dt animation:^{
            NSPoint startPoint = NSMakePoint(or_x + right, or_y);
            [notification setFrameOrigin:startPoint];
        } completion:^{
            [notification animateWithDuration:1 animation:^{
                NSPoint endPoint = NSMakePoint(or_x, or_y);
                [[NSAnimationContext currentContext] setTimingFunction:[CAMediaTimingFunction functionWithControlPoints:0.1 :0.7 :0.2 :1]];
                [[notification animator] setFrameOrigin:endPoint];
            }];
        }];
    }
    
//    MyNotificationView* view = _scroll_view.documentView;
//    view.wantsLayer = YES;
//    int or_x = _scroll_view.documentView.frame.origin.x;
//    int or_y = _scroll_view.documentView.frame.origin.y;
//    
//    //no notifications
//    [view animateWithDuration:0 animation:^{
//        NSPoint startPoint = NSMakePoint(or_x + right, or_y);
//        [view setFrameOrigin:startPoint];
//    } completion:^{
//        [view animateWithDuration:1 animation:^{
//            NSPoint endPoint = NSMakePoint(or_x, or_y);
//            [[NSAnimationContext currentContext] setTimingFunction:[CAMediaTimingFunction functionWithControlPoints:0.1 :0.7 :0.2 :1]];
//            [[view animator] setFrameOrigin:endPoint];
//        }];
//    }];
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
    int extra_padding = 8;
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
    [title_field setWantsLayer:YES];
    [title_field setSelectable:YES];
    if(![url  isEqual: @" "]){
        title_field.link = url;
        [title_field setSelectable:NO];
    }
    title_field.font = [NSFont fontWithName:@"Raleway-ExtraBold" size:title_font_size];
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
    
    [self animateNotifications];
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
        
        NSURL *url = [NSURL URLWithString:@""];
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
        
        STHTTPRequest *r = [STHTTPRequest requestWithURLString:@"https://notifi.it/getCode.php"];
        r.POSTDictionary = @{ @"UUID":[self getSystemUUID]};
        NSString *body = [r startSynchronousWithError:nil];
        
        NSString* key = [self jsonToVal:body key:@"key"];
        NSString* credentials = [self jsonToVal:body key:@"credentials"];
        
        if(![key isEqual: @""] && ![credentials isEqual: @""]){
            failedCredentials = false;
            [self storeKey:@"credential_key" withPassword:key];
            [[NSUserDefaults standardUserDefaults] setObject:credentials forKey:@"credentials"];
            [_credentialsItem setTitle:credentials];
            [self createWindow];
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
    if(!serverReplied){
        serverReplied = true;
        [self updateReadIcon:false];
    }
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
            NSString* firstval = [NSString stringWithFormat:@"%@", notification];
            if([[firstval substringToIndex:3]  isEqual: @"id:"]){
                // TELL SERVER TO REMOVE THIS MESSAGE
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
    [title setWantsLayer:true];
    int or_x = title.frame.origin.x;
    int or_y = title.frame.origin.y;
    int top = title.frame.size.height;
    
    
    
    [title animateWithDuration:0 animation:^{
        if(read){
            unread_notification_count--;
            title.textColor = _grey;
        }else{
            unread_notification_count++;
            title.textColor = _red;
        }
        NSPoint startPoint = NSMakePoint(or_x, or_y + top);
        [title setFrameOrigin:startPoint];
    }completion:^{
        [title animateWithDuration:0.8 animation:^{
            [[NSAnimationContext currentContext] setTimingFunction:[CAMediaTimingFunction functionWithControlPoints:0.5 :0.5 :0 :1]];
            NSPoint endPoint = NSMakePoint(or_x, or_y);
            [[title animator] setFrameOrigin:endPoint];
        }];
    }];
    [self updateReadIcon:false];
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
    
    [self updateReadIcon:false];
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
        [alert setMessageText:[NSString stringWithFormat:@"Permanently delete %d notifications?", (int)[notifications count]]];
        [alert setInformativeText:@"Notifications cannot be restored without some sort of wizardry."];
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

-(void)updateReadIcon:(bool)animate{
    NSImage* error_icon = [NSImage imageNamed:@"menu_error_bellicon.png" ];
    NSImage* alert_icon = [NSImage imageNamed:@"alert_menu_bellicon.png" ];
    NSImage* menu_icon = [NSImage imageNamed:@"menu_bellicon.png" ];
    
    if(!serverReplied){
        if(_statusItem.image != error_icon) _statusItem.image = error_icon;
    }else if(unread_notification_count > 0){
        if(animate){
            [self animateBell:alert_icon];
        }else if(_statusItem.image != alert_icon){
            _statusItem.image = alert_icon;
        }
    }else{
        if(_statusItem.image != menu_icon) _statusItem.image = menu_icon;
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
    
    if(![mes isEqual: @" "]) [notification setInformativeText:mes];
    
    if(![imgURL isEqual: @" "]){
        NSImage* image;
        @try {
            image = [[NSImage alloc] initWithContentsOfURL:[NSURL URLWithString:imgURL]];
            [notification setContentImage:image];
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
}

- (void)webSocket:(SRWebSocket *)webSocket didReceivePong:(NSData *)pongPayload;
{
    receivedPong = true;
}


BOOL streamOpen = false;
- (void)sendCode{
    NSString* credentials = [[NSUserDefaults standardUserDefaults] objectForKey:@"credentials"];
    NSString* key = [self getKey:@"credential_key"];
    
    NSString* message = [NSString stringWithFormat:@"%@|%@|%@|%@", credentials, key, [self getSystemUUID], [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"]];
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
    _webSocket = nil;
    [self updateReadIcon:false];
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
    
    _credentialsItem = [[NSMenuItem alloc] initWithTitle:[[NSUserDefaults standardUserDefaults] objectForKey:@"credentials"] action:nil keyEquivalent:@""];
    [_credentialsItem setTarget:self];
    [_credentialsItem setEnabled:false];
    [mainMenu addItem:_credentialsItem];
    
    NSMenuItem* copy = [[NSMenuItem alloc] initWithTitle:@"Copy Credentials" action:@selector(copyCredentials) keyEquivalent:@"c"];
    [copy setTarget:self];
    [copy setEnabled:true];
    [mainMenu addItem:copy];
    
    NSMenuItem* newCredentials = [[NSMenuItem alloc] initWithTitle:@"Create New Credentials" action:@selector(createNewCredentials) keyEquivalent:@""];
    [newCredentials setTarget:self];
    [mainMenu addItem:newCredentials];
    
    [mainMenu addItem:[NSMenuItem separatorItem]];
    
    _remNotification = [[NSMenuItem alloc] initWithTitle:@"Sticky Notifications" action:@selector(shouldMakeSticky) keyEquivalent:@""];
    [_remNotification setTarget:self];
    if([[NSUserDefaults standardUserDefaults] boolForKey:@"sticky_notification"]) [_remNotification setState:NSOnState];
    [mainMenu addItem:_remNotification];
    
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

- (void)shouldMakeSticky{
    bool sticky_notification = ![[NSUserDefaults standardUserDefaults] boolForKey:@"sticky_notification"];
    if(!sticky_notification){
        [_remNotification setState:NSOffState];
    }else{
        [_remNotification setState:NSOnState];
    }
    [[NSUserDefaults standardUserDefaults] setBool:sticky_notification forKey:@"sticky_notification"];
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

- (CGFloat)widthOfString:(NSString *)string withFont:(NSFont *)font {
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:font, NSFontAttributeName, nil];
    return [[[NSAttributedString alloc] initWithString:string attributes:attributes] size].width;
}

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

- (NSString *)getSystemUUID {
    io_service_t platformExpert = IOServiceGetMatchingService(kIOMasterPortDefault,IOServiceMatching("IOPlatformExpertDevice"));
    if (!platformExpert)
        return nil;
    
    CFTypeRef serialNumberAsCFString = IORegistryEntryCreateCFProperty(platformExpert,CFSTR(kIOPlatformUUIDKey),kCFAllocatorDefault, 0);
    IOObjectRelease(platformExpert);
    if (!serialNumberAsCFString)
        return nil;
    
    return (__bridge NSString *)(serialNumberAsCFString);;
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
