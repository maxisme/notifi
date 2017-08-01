//
//  AppDelegate.m
//  notifi
//
//  Created by Max Mitchell on 20/10/2016.
//  Copyright © 2016 max mitchell. All rights reserved.
//

#import "AppDelegate.h"
#import <Security/Security.h>

#ifdef DEBUG
static const DDLogLevel ddLogLevel = DDLogLevelVerbose;
#else
static const DDLogLevel ddLogLevel = DDLogLevelWarning;
#endif


@interface MyTable: NSTableView
@end

@implementation MyTable
- (BOOL)selectionShouldChangeInTableView:(NSTableView *)aTableView
{
    return NO;
}
- (BOOL)tableView:(NSTableView *)aTableView shouldSelectRow:(NSInteger)rowIndex
{
    return NO;
}
@end
// ----- MyButton interface -----
@interface MyButton: NSButton
@property (strong) NSTrackingArea* trackingArea;
@property float opacity_min;
@end

@implementation MyButton
-(void)mouseEntered:(NSEvent *)theEvent {
    
    CABasicAnimation *flash = [CABasicAnimation animationWithKeyPath:@"opacity"];
    flash.fromValue = [NSNumber numberWithFloat:1];
    
    NSMutableArray *notifications = [[[NSUserDefaults standardUserDefaults] objectForKey:@"notifications"] mutableCopy];
    if((int)[notifications count] != 0){
        [super resetCursorRects];
        [self addCursorRect:self.bounds cursor:[NSCursor pointingHandCursor]];
        
        flash.toValue = [NSNumber numberWithFloat:self.opacity_min];
    }
    
    flash.duration = 0.2;
    [flash setFillMode:kCAFillModeForwards];
    [flash setRemovedOnCompletion:NO];
    flash.repeatCount = 1;
    [self.layer addAnimation:flash forKey:@"flashAnimation"];
}

-(void)mouseExited:(NSEvent *)theEvent{
    [super resetCursorRects];
    
    CABasicAnimation *flash = [CABasicAnimation animationWithKeyPath:@"opacity"];
    
    flash.fromValue = [NSNumber numberWithFloat:self.opacity_min];
    
    NSMutableArray *notifications = [[[NSUserDefaults standardUserDefaults] objectForKey:@"notifications"] mutableCopy];
    if((int)[notifications count] != 0){
        flash.toValue = [NSNumber numberWithFloat:1];
    }
    
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
    [super resetCursorRects];
    [self addCursorRect:self.bounds cursor:[NSCursor pointingHandCursor]];
    [self animate];
}

-(void)mouseExited:(NSEvent *)theEvent
{
    [super resetCursorRects];
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
    rotate.fillMode = kCAFillModeForwards;
    rotate.removedOnCompletion = NO;
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
@property (strong) NSTrackingArea* trackingArea;
@property (nonatomic) int notificationID;
@property (nonatomic) NSAttributedString* title_string;
@property (nonatomic) NSString* message_string;
@property (nonatomic) NSString* link;
@property (nonatomic) float real_height;
@property (nonatomic) float shrink_height;
@property (atomic, weak) AppDelegate* thisapp;
@end

@implementation MyNotificationView
- (void) rightMouseDown:(NSEvent *)event {
    if(self.notificationID){ // none when no notification
        NSMenu *theMenu = [[NSMenu alloc] initWithTitle:@"Contextual Menu"];
        
        if(self.frame.size.height != self.real_height){
            NSMenuItem *expandItem = [[NSMenuItem alloc] initWithTitle:@"Expand" action:@selector(expandNotification:) keyEquivalent:@""];
            [expandItem setRepresentedObject:self];
            [theMenu addItem:expandItem];
            [theMenu addItem:[NSMenuItem separatorItem]];
        }
        
        if([_thisapp notificationRead:self.notificationID]){
            [theMenu addItemWithTitle:@"Mark Unread" action:@selector(markUnread) keyEquivalent:@""];
        }else{
            [theMenu addItemWithTitle:@"Mark Read" action:@selector(markRead) keyEquivalent:@""];
        }
        
        [theMenu addItemWithTitle:@"Delete Notification" action:@selector(deleteNoti) keyEquivalent:@""];
        
        [theMenu addItem:[NSMenuItem separatorItem]];
        
        NSString* url = [_thisapp notificationLink:self.notificationID];
        if(![url  isEqual: @" "] && url != nil){
            NSMenuItem *menuItem = [[NSMenuItem alloc] initWithTitle:@"Open Link" action:@selector(openLink:) keyEquivalent:@""];
            [menuItem setRepresentedObject:url];
            [theMenu addItem:menuItem];
        }
        
        NSString* imageLink = [_thisapp imageLink:self.notificationID];
        if(![imageLink  isEqual: @" "] && imageLink != nil){
            NSMenuItem *menuItem = [[NSMenuItem alloc] initWithTitle:@"Open Image" action:@selector(openLink:) keyEquivalent:@""];
            [menuItem setRepresentedObject:imageLink];
            [theMenu addItem:menuItem];
        }
        
        [NSMenu popUpContextMenu:theMenu withEvent:event forView:(id)self];
    }
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

- (void)mouseDown:(NSEvent *)event
{
    // needs to be here for some reason to pass on the mouseup event to the label (LINK?)
    if(self.frame.size.height != self.real_height) [self expandNotification:self];
}

// events
- (void)expandNotification:(id)sender {
    if(![sender isKindOfClass:[self class]]){
        sender = [sender representedObject];
    }
    [_thisapp expandTableView:sender];
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

- (void)resetCursorRects
{
    [super resetCursorRects];
}

//- (void)mouseDown:(NSEvent *)theEvent{
//    [self.superview mouseDown:theEvent];
//}

- (BOOL)textView:(NSTextView *)textView clickedOnLink:(id)link atIndex:
(NSUInteger)charIndex{
    NSLog(@"test1 %@",link);
    return NO;
}

- (void)textViewDidChangeSelection:(NSNotification *)a{
    [self setNeedsDisplay:YES];
    [self setNeedsLayout:YES];
    [self setNeedsUpdateConstraints:YES];
    [self.superview setNeedsLayout:YES];
    [self.superview setNeedsDisplay:YES];
}

// prevent the default right click menu
- (NSMenu *)textView:(NSTextView *)view menu:(NSMenu *)menu forEvent:(NSEvent *)event atIndex:(NSUInteger)charIndex{
    return nil;
}

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

- (void)mouseUp:(NSEvent *)event
{
    if(super.link && ![super.link  isEqual: @" "]) [(MyNotificationView*)self.superview openLink:super.link];
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
@end

@implementation MyWindow
- (BOOL) canBecomeKeyWindow
{
    return YES;
}
@end

@interface AppDelegate ()
@property (strong) MyTable *notification_table;
@end

@implementation AppDelegate

NSString* how_to_url = @"https://github.com/maxisme/notifi#http-request-examples";

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    [self setupLogging];
    
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
    
    // scroll call back
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onScroll) name:NSViewBoundsDidChangeNotification object:_scroll_view];
    
    [self createWindow];
    
    [self checkUpdate:true];
}

#pragma mark - window
float screen_height; // used when opening new window to check if different screen
float screen_width;
int top_arrow_height;
-(void)createWindow{
    _black = [NSColor colorWithRed:0.13 green:0.13 blue:0.13 alpha:1.0];
    _white = [NSColor colorWithRed:1.00 green:1.00 blue:1.00 alpha:1.0];
    _red = [NSColor colorWithRed:0.74 green:0.13 blue:0.13 alpha:1.0];
    _grey = [NSColor colorWithRed:0.43 green:0.43 blue:0.43 alpha:1.0];
    _boarder = [NSColor colorWithRed:0.92 green:0.91 blue:0.91 alpha:1.0];
    _offwhite = [NSColor colorWithRed:0.96 green:0.96 blue:0.96 alpha:1.0];
    
    //position variables
    screen_width = [[NSScreen mainScreen] frame].size.width;
    screen_height = [[NSScreen mainScreen] frame].size.height;
    
    float window_height = screen_height * 0.7;
    int window_width = 350;
    top_arrow_height = 20;
    
    int side_padding = 10;
    
    //position variables
    NSRect menu_icon_frame = [[_statusItem valueForKey:@"window"] frame];
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
    _window = [[MyWindow alloc] initWithContentRect:NSMakeRect(window_x, window_y, window_width, window_height) styleMask:0 backing:NSBackingStoreBuffered defer:YES];
    [_window setIdentifier:@"default"];
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
    //    [vis_view setState:NSVisualEffectStateActive];
    //    [vis_view setBlendingMode:NSVisualEffectBlendingModeBehindWindow];
    [_vis_view.layer setBackgroundColor:_white.CGColor];
    _vis_view.layer.cornerRadius = 10;
    [_view addSubview:_vis_view];
    
    [self createBodyWindow];
}

MyButton* markAllAsReadBtn;
-(void)createBodyWindow{
    int bottom_buttons_height = 40;
    int top_bar_height = 90;
    
    //----------------- top stuff -----------------
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
    [cogView setCustomMenu:[self defaultStatusBarMenu]];
    [cogView setImage:cog];
    [cogView setImageScaling:NSImageScaleProportionallyUpOrDown];
    [cogView updateTrackingAreas];
    [_view addSubview:cogView];
    
    // network error message
    MyLabel* error_label = [[MyLabel alloc] initWithFrame:
                   CGRectMake(
                              0,
                              iconView.frame.origin.y - 20, // 20
                              window_width,
                              20
                              )
                            ];
    [error_label setWantsLayer:YES];
    [error_label setStringValue:@"Network Error!"];
    error_label.font = [NSFont fontWithName:@"OpenSans-Regular" size:8];
    error_label.backgroundColor = _white;
    [error_label setAlignment:NSTextAlignmentCenter];
    [error_label setTextColor:_grey];
    [error_label setSelectable:YES];
    error_label.editable = false;
    error_label.bordered = false;
    error_label.hidden = true;
    error_label.tag = 1;
    [_view addSubview:error_label];
    
    //top line boarder
    NSView *hor_bor_top = [[NSView alloc] initWithFrame:CGRectMake(0, window_height - top_bar_height, window_width, 1)];
    hor_bor_top.wantsLayer = TRUE;
    [hor_bor_top.layer setBackgroundColor:[_boarder CGColor]];
    [_view addSubview:hor_bor_top];
    
    
    //----------------- body -----------------
    
    //scroll view
    float scroll_height = (window_height - top_bar_height) - bottom_buttons_height;
    _scroll_view = [[NSScrollView alloc] initWithFrame:NSMakeRect(0, bottom_buttons_height, window_width, scroll_height)];
    [_scroll_view setWantsLayer:YES];
    [_scroll_view setBorderType:NSNoBorder];
    [_scroll_view setHasVerticalScroller:YES];
    [_scroll_view setPostsBoundsChangedNotifications:YES];
    [_scroll_view setDrawsBackground:NO];
    _scroll_view.backgroundColor = _offwhite;
    
    NSMutableArray *notifications = [[[NSUserDefaults standardUserDefaults] objectForKey:@"notifications"] mutableCopy];
    if((int)[notifications count] == 0){
        _scroll_view.documentView = [self noNotificationsView];
    }else{
        //INITIATE NSTABLE
        _notification_table = [[MyTable alloc] initWithFrame:_scroll_view.frame];
        NSTableColumn *column = [[NSTableColumn alloc] initWithIdentifier:@"1"];
        [column setWidth:_scroll_view.frame.size.width - 5]; //I swear me needing to do this is a bug
        [column setEditable:FALSE];
        [_notification_table addTableColumn:column];
        [_notification_table setHeaderView:nil];
        [_notification_table setSelectionHighlightStyle:NSTableViewSelectionHighlightStyleNone];
        [_notification_table setDelegate:(id)self];
        [_notification_table setDataSource:(id)self];
        [_notification_table setBackgroundColor:_offwhite];
        [[_notification_table enclosingScrollView] setDrawsBackground:NO];
        [self reloadData];
        
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
    [hor_bor_bot.layer setBackgroundColor:[_boarder CGColor]];
    [_view addSubview:hor_bor_bot];
    
    //mark all as read button
    markAllAsReadBtn = [[MyButton alloc] initWithFrame:CGRectMake(p / 2, button_y, (window_width / 2) - p, 25)];
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
    [vert_bor_top.layer setBackgroundColor:[_boarder CGColor]];
    [_view addSubview:vert_bor_top];
    
    //delete all button
    MyButton *deleteNotifications = [[MyButton alloc] initWithFrame:CGRectMake(window_width / 2 + (p /2), button_y, window_width /2 - p, 25)];
    [deleteNotifications setWantsLayer:YES];
    [deleteNotifications setOpacity_min:min_opac];
    [deleteNotifications setButtonType:NSMomentaryChangeButton];
    
    NSMutableParagraphStyle *centredStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    [centredStyle setAlignment:NSCenterTextAlignment];
    
    NSDictionary *attrs = [NSDictionary dictionaryWithObjectsAndKeys:centredStyle,
                           NSParagraphStyleAttributeName,
                           [NSFont fontWithName:@"OpenSans-Bold" size:button_size],
                           NSFontAttributeName,
                           _red,
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
    NSRect menu_icon_frame = [[_statusItem valueForKey:@"window"] frame];
    float menu_icon_width = menu_icon_frame.size.width;
    float menu_icon_x = menu_icon_frame.origin.x;
    float menu_icon_y = menu_icon_frame.origin.y;
    
    //calculate positions of window on screen and arrow
    float arrow_x = window_width/2 - (top_arrow_height/2);
    float arrow_y = window_height - top_arrow_height;
    float window_x = (menu_icon_x + menu_icon_width/2) - window_width / 2;
    float window_y = menu_icon_y - window_height;
    
    //
    
//    int side_padding = 5;
//    if(window_width + window_x > screen_width){ //window will fall out of screen
//        window_x = screen_width - window_width - side_padding;
//        arrow_x = menu_icon_x + menu_icon_width/2 - window_x - side_padding;
//    }
    
    // update positions
    [_window_up_arrow_view setFrame:NSMakeRect(arrow_x, arrow_y, top_arrow_height, top_arrow_height)];
    [_window setFrame:NSMakeRect(window_x, window_y, window_width, window_height) display:true];
    [_vis_view setFrame:CGRectMake(0, 0, window_width, window_height - (top_arrow_height - 5))];
}

-(void)onScroll{
    if([_notification_views count] > 0) [self animateNotifications:false];
}

NSTimer* animate_bell_timer;
int bell_image_cnt;
-(void)animateBell:(NSImage*)image{
    if(!animate_bell_timer){
        after_image = nil;
    }else{
        // cancel timer
        [animate_bell_timer invalidate];
        animate_bell_timer = nil;
    }
    
    bell_image_cnt = 0;
    animate_bell_timer = [NSTimer scheduledTimerWithTimeInterval:0.0015 target:self selector:@selector(updateBellImage) userInfo:nil repeats:YES];
}

NSImage* after_image;
- (void)updateBellImage
{
    NSImage* image = [NSImage imageNamed:@"alert_menu_bellicon.png" ];;
    NSArray *numbers = [@"-20,-15.1022,-10.5422,-6.32,-2.43556,1.11111,4.32,7.19111,9.72444,11.92,13.7778,15.2978,16.48,17.3244,17.8311,18,13.6178,9.53778,5.76,2.28444,-0.888889,-3.76,-6.32889,-8.59556,-10.56,-12.2222,-13.5822,-14.64,-15.3956,-15.8489,-16,-12.1333,-8.53333,-5.2,-2.13333,0.666667,3.2,5.46667,7.46667,9.2,10.6667,11.8667,12.8,13.4667,13.8667,14,10.52,7.28,4.28,1.52,-1,-3.28,-5.32,-7.12,-8.68,-10,-11.08,-11.92,-12.52,-12.88,-13,-9.77778,-6.77778,-4,-1.44444,0.888889,3,4.88889,6.55556,8,9.22222,10.2222,11,11.5556,11.8889,12,9.16444,6.52444,4.08,1.83111,-0.222222,-2.08,-3.74222,-5.20889,-6.48,-7.55556,-8.43556,-9.12,-9.60889,-9.90222,-10,-7.68,-5.52,-3.52,-1.68,-7.10543e-15,1.52,2.88,4.08,5.12,6,6.72,7.28,7.68,7.92,8,6.19556,4.51556,2.96,1.52889,0.222222,-0.96,-2.01778,-2.95111,-3.76,-4.44444,-5.00444,-5.44,-5.75111,-5.93778,-6,-4.71111,-3.51111,-2.4,-1.37778,-0.444444,0.4,1.15556,1.82222,2.4,2.88889,3.28889,3.6,3.82222,3.95556,4,3.22667,2.50667,1.84,1.22667,0.666667,0.16,-0.293333,-0.693333,-1.04,-1.33333,-1.57333,-1.76,-1.89333,-1.97333,-2,-1.74222,-1.50222,-1.28,-1.07556,-0.888889,-0.72,-0.568889,-0.435556,-0.32,-0.222222,-0.142222,-0.08,-0.0355556,-0.0088888" componentsSeparatedByString:@","];
    
    if(bell_image_cnt == [numbers count] - 1){
        if(!after_image) after_image = image;
        [_statusItem setImage:after_image];
        
        // cancel timer
        [animate_bell_timer invalidate];
        animate_bell_timer = nil;
    }else{
        NSString *i = numbers[bell_image_cnt];
        float x = [i floatValue];
        [_statusItem setImage:[image imageRotated:x]];
        bell_image_cnt++;
    }
}

-(NSView*)noNotificationsView{
    int window_width = _window.frame.size.width;
    
    MyNotificationView *view = [[MyNotificationView alloc] initWithFrame:_scroll_view.frame];
    view.wantsLayer = TRUE;
    
    
    //no notifications text
    NSMutableParagraphStyle *centredStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    [centredStyle setAlignment:NSTextAlignmentCenter];
    
    int title_height = 60;
    NSDictionary *noNotificationsAttrs = [NSDictionary dictionaryWithObjectsAndKeys:centredStyle,
                                          NSParagraphStyleAttributeName,
                                          [NSFont fontWithName:@"OpenSans-Bold" size:30],
                                          NSFontAttributeName,
                                          _grey,
                                          NSForegroundColorAttributeName,
                                          nil];
    NSMutableAttributedString *noNotificationsString =
    [[NSMutableAttributedString alloc] initWithString:@"No Notifications!"
                                           attributes:noNotificationsAttrs];
    
    MyLabel* title_field = [[MyLabel alloc] initWithFrame:
                                 CGRectMake(
                                            0,
                                            _scroll_view.frame.size.height/2 - title_height/2 - 20,
                                            window_width,
                                            title_height
                                            )
                                 ];
    [title_field setWantsLayer:true];
    [title_field setBackgroundColor:_offwhite];
    [title_field setSelectable:YES];
    [title_field setAllowsEditingTextAttributes:true];
    [title_field setAttributedStringValue:noNotificationsString];
    [title_field setEditable:false];
    [title_field setBordered:false];
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
                                   _grey,
                                   NSForegroundColorAttributeName,
                                   nil];
    NSMutableAttributedString *sendCurlString =
    [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"To receive notifications use simple HTTP requests along with your unique credentials: %@",[[NSUserDefaults standardUserDefaults] objectForKey:@"credentials"]] attributes:sendCurlAttrs];
    [sendCurlString applyFontTraits:NSBoldFontMask range:NSMakeRange(86, 25)];
    [sendCurlString addAttribute:NSLinkAttributeName value:how_to_url range:NSMakeRange(36,13)];
    
    MyLabel* curl_field = [[MyLabel alloc] initWithFrame:
                                CGRectMake(
                                           10,
                                           title_field.frame.origin.y - 70,
                                           window_width - 20,
                                           70
                                           )
                                ];
    curl_field.tag = 2;
    [curl_field setWantsLayer:true];
    [curl_field setBackgroundColor:_offwhite];
    [curl_field setSelectable:YES];
    [curl_field setAllowsEditingTextAttributes:true];
    [curl_field setAttributedStringValue:sendCurlString];
    [curl_field setEditable:false];
    [curl_field setBordered:false];
    [curl_field setBackgroundColor:_offwhite];
    
    [view addSubview:curl_field];
    
    return view;
}

#pragma mark - Table View Data Source

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    NSMutableArray *notifications = [[[NSUserDefaults standardUserDefaults] objectForKey:@"notifications"] mutableCopy];
    return notifications.count;
}

int table_row_padding = 10;
- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    // format cell view
    NSView* view = [[NSView alloc] init];
    [view setWantsLayer:YES];
    [view addSubview:[_notification_views objectAtIndex:([_notification_views count] - 1) - row]];
    return view;
}

- (CGFloat) tableView:(NSTableView *) tableView heightOfRow:(NSInteger) row {
    NSView* notification = [_notification_views objectAtIndex:([_notification_views count] - 1) - row];
    return notification.frame.size.height + table_row_padding;
}

bool reloaded_in_last_2 = false;
NSUInteger errorGeneration;
-(void)reloadData{
    NSLog(@"CALLED RELOAD TABLE");
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
        
        NSMutableArray *notifications = [[[NSUserDefaults standardUserDefaults] objectForKey:@"notifications"] mutableCopy];
        for(NSMutableDictionary* dic in notifications){
            MyNotificationView* notification = [self createNotificationView:[dic objectForKey:@"title"]
                                                        message:[dic objectForKey:@"message"]
                                                       imageURL:[dic objectForKey:@"image"]
                                                           link:[dic objectForKey:@"link"]
                                                           time:[dic objectForKey:@"time"]
                                                           read:[[dic objectForKey:@"read"] boolValue]
                                                 notificationID:[[dic objectForKey:@"id"] intValue]];
            [_notification_views addObject:notification];
        }
        
        [_notification_table reloadData];
        [self updateReadIcon:true];
    });
}

#pragma mark - notification
-(void)animateNotifications:(bool)should_delay{
    [self animateNotifications:should_delay scroll:false];
}

NSMutableArray *animatedNotifications;
-(void)animateNotifications:(bool)should_delay scroll:(bool)should_scroll{
    NSScrollView* scrollView = [_notification_table enclosingScrollView];
    CGRect visibleRect = scrollView.contentView.visibleRect;
    NSRange range = [_notification_table rowsInRect:visibleRect];
    
    NSMutableArray *notifications = [[[NSUserDefaults standardUserDefaults] objectForKey:@"notifications"] mutableCopy];
    int num_notifications = (int)[notifications count];
    
    int right =  - _window.frame.size.width; // start position of animation
    
    int start = (int)range.location;
    if(start > 1) start -= 1;
    int end = start + (int)range.length;
    if(end >= num_notifications) end = num_notifications - 1; // end is the last notification
    
    if(num_notifications > 0){ // there are notifications
        for(int j = end; j >= start; j--){
            int x = (num_notifications - 1) - j; // flip order
            NSString* ex = [NSString stringWithFormat:@"%d", x];
            if(![animatedNotifications containsObject:ex]){ // not already animated
                [animatedNotifications addObject:ex];
                MyNotificationView* notification = [_notification_views objectAtIndex:x];
                
                //handle delay
                float delay = 0;
                if (should_delay) delay = (j - start) * 0.07; // on first show
                
                //original positions
                int or_x = notification.frame.origin.x;
                int or_y = notification.frame.origin.y;
                
                [notification animateWithDuration:delay animation:^{
                    NSPoint startPoint = NSMakePoint(or_x + right, or_y);
                    [notification setFrameOrigin:startPoint];
                } completion:^{
                    [notification animateWithDuration:1 animation:^{
                        NSPoint endPoint = NSMakePoint(or_x, or_y);
                        [[NSAnimationContext currentContext] setTimingFunction:[CAMediaTimingFunction functionWithControlPoints:0.5 :0.5 :0 :1]];
                        [[notification animator] setFrameOrigin:endPoint];
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
    }else{
        MyNotificationView* notification = _scroll_view.documentView;
        
        //animate no notifications label
        MyTitleLabel* no_notifications = (MyTitleLabel*)[notification viewWithTag:1];
        int nn_or_x = no_notifications.frame.origin.x;
        int nn_or_y = no_notifications.frame.origin.y;
        
        MyTitleLabel* info = (MyTitleLabel*)[notification viewWithTag:2];
        int i_or_x = info.frame.origin.x;
        int i_or_y = info.frame.origin.y;
        
        [notification animateWithDuration:0 animation:^{
            [no_notifications setFrameOrigin:NSMakePoint(nn_or_x + right, nn_or_y)];
            [info setFrameOrigin:NSMakePoint(i_or_x - right, i_or_y)];
        } completion:^{
            [notification animateWithDuration:0.7 animation:^{
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

int notification_view_padding = 20;
int unread_notification_count = 0;

//TODO: CALCULATE THESE DYNAMICALLY
int one_row_title_height = 25;
int one_row_info_height = 21;

-(MyNotificationView*)createNotificationView:(NSString*)title_string message:(NSString*)message_string imageURL:(NSString*)imgURL link:(NSString*)url time:(NSString*)time_string read:(bool)read notificationID:(int)notificationID
{
    float width_perc = 0.9;
    int notification_width = _scroll_view.frame.size.width * width_perc;
    int x = _scroll_view.frame.size.width * ((1 - width_perc) / 2);
    int y = table_row_padding / 2;
    
    //fonts
    NSFont* title_font = [NSFont fontWithName:@"Roboto-Medium" size:17];
    NSFont* info_font = [NSFont fontWithName:@"OpenSans-Regular" size:12];
    NSFont* time_font = [NSFont fontWithName:@"OpenSans-Regular" size:10];
    
    int image_hw = 50;
    
    int time_height = 18;
    
    MyNotificationView *view = [[MyNotificationView alloc] init];
    [view setWantsLayer:YES];
    view.notificationID = notificationID;
    view.thisapp = self;
    
    //check if image variable
    int top_padding = 15;
    int side_padding = 15;
    if(![imgURL isEqual: @" "]){
        side_padding = image_hw + top_padding * 2;
    }
    
    float text_width = notification_width * 0.95 - side_padding;
    
    //check if title has link
    if(![url  isEqual: @" "]) title_string = [@"🔗 " stringByAppendingString:title_string];
    
    //------ height of title
    float title_height =[self calculateStringHeight:title_string font:title_font width:text_width];
    
    //------- height of info
    float info_height = 0.0;
    if(![message_string isEqual: @" "]){
        info_height = [self calculateStringHeight:message_string font:info_font width:text_width];
    }
    
    //calculate total height of notification
    int notification_height = title_height + time_height + info_height + (top_padding * 3);
    
    if(![imgURL isEqual: @" "]){ // handle extra heightNSColor if image
        int min_height = image_hw + top_padding * 4;
        if(notification_height < min_height){
            notification_height = min_height;
        }
    }
    
    //create view
    [view setFrame:CGRectMake(x, y, notification_width, notification_height - (top_padding * 2))];
    [view.layer setBackgroundColor:[_white CGColor]];
    view.layer.borderColor = [_boarder CGColor];
    view.layer.borderWidth = 1;
    view.layer.cornerRadius = 7.0f;
    view.layer.masksToBounds = YES;
    
    //body of notification
    //--      add image
    if(![imgURL isEqual: @" "]){
        NSView* rounded_image_view = [[NSView alloc] initWithFrame:NSMakeRect(top_padding, view.frame.size.height - image_hw - top_padding, image_hw, image_hw)];
        [rounded_image_view setWantsLayer:YES];
        rounded_image_view.layer.cornerRadius = 5; // circle
        rounded_image_view.layer.masksToBounds = YES;
        
        NotificationImage *image_view = [[NotificationImage alloc] initWithFrame:NSMakeRect(0, 0, image_hw + 5, image_hw + 5)];
        [image_view setImageScaling:NSImageScaleProportionallyUpOrDown];
        [image_view sd_setImageWithURL:[NSURL URLWithString:imgURL]];
        image_view.image_url = imgURL;
        [rounded_image_view addSubview:image_view];
        
        [view addSubview:rounded_image_view];
    }
    
    //--    add title
    MyTitleLabel* title_field = [[MyTitleLabel alloc] initWithFrame:
                                 CGRectMake(
                                            side_padding,
                                            view.frame.size.height - title_height - (top_padding / 1.9),
                                            text_width,
                                            title_height
                                            )
                                 ];
    [title_field setEditable:false];
    [title_field setFont:title_font];
    [title_field setBordered:false];
    [title_field setSelectable:true];
    [title_field setBezeled:false];
    [title_field setDrawsBackground:false];
    title_field.tag = notificationID;
    [title_field setTextColor:_grey];
    if(!read){
        [title_field setTextColor:_red];
        unread_notification_count++;
    }
    
    if(![url  isEqual: @" "]) title_field.link = url;
    
    [title_field setStringValue:title_string];
    
    [view addSubview:title_field];
    
    //--   add time
    MyLabel* time_label = [[MyLabel alloc] initWithFrame:
                           CGRectMake(
                                      side_padding,
                                      title_field.frame.origin.y - time_height,
                                      text_width,
                                      time_height
                                      )
                           ];
    NSLog(@"create");
    [time_label setFont:time_font];
    [time_label setTextColor:_grey];
    [time_label setEditable:false];
    [time_label setBordered:false];
    [time_label setSelectable:true];
    [time_label setBezeled:false];
    [time_label setDrawsBackground:false];
    
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
    MyLabel* info;
    if(![message_string isEqual: @" "]){
        info = [[MyLabel alloc] initWithFrame:
                         CGRectMake(
                                    side_padding,
                                    time_label.frame.origin.y - info_height,
                                    text_width,
                                    info_height
                                    )
                         ];
        [info setFont:info_font];
        [info setBackgroundColor:_white];
        [info setTextColor:_black];
//        [info setPreferredMaxLayoutWidth:text_width];
        [info setEditable:false];
        [info setSelectable:true];
        [info setBordered:false];
        [info setBezeled:false];
        [info setDrawsBackground:false];
        [view addSubview:info];
    }
    
    // RESET HEIGHT OF NOTIFICATION TO SHRUNK DOWN SIZE
    
    //change strings
    if(title_height > one_row_title_height){
        int cnt = 1;
        NSString *str = @"";
        do{
            str = [NSString stringWithFormat:@"%@...", [title_string substringToIndex:cnt]];
            cnt++;
        }while([self calculateStringHeight:str font:title_font width:text_width] <= one_row_title_height);
        str = [NSString stringWithFormat:@"%@...", [title_string substringToIndex:cnt - 1]];
        
        [title_field setStringValue:str];
    }
    
    if(info_height > one_row_info_height){
        int cnt = 1;
        NSString *str = @"";
        int height = 0;
        do{
            str = [NSString stringWithFormat:@"%@...", [message_string substringToIndex:cnt]];
            cnt++;
            height = [self calculateStringHeight:str font:info_font width:text_width];
            NSLog(@"height: %d",height);
        }while(height <= one_row_title_height);
        str = [NSString stringWithFormat:@"%@...", [message_string substringToIndex:cnt - 2]];
        
        NSMutableAttributedString* attributed_string = [[NSMutableAttributedString alloc] initWithString:str];
        [attributed_string addAttribute:NSLinkAttributeName value:how_to_url range:NSMakeRange(cnt - 2,3)];
        [info setAttributedStringValue:attributed_string];
        [info resetCursorRects];
    }else{
        [info setStringValue:message_string];
    }
    
    view.message_string = message_string;
    view.title_string = title_string;
    view.real_height = notification_height - (top_padding * 2);
    view.shrink_height = pre_shrink_height;
    if(view.real_height < pre_shrink_height){
        view.shrink_height = view.real_height;
    }
    
    [view setFrame:CGRectMake(x, y, notification_width, view.shrink_height)];
    for (NSView* subview in view.subviews) {
        [subview.animator setFrame:NSMakeRect(subview.frame.origin.x, subview.frame.origin.y - (view.real_height - view.shrink_height), subview.frame.size.width, subview.frame.size.height)];
    }
    
    [view updateTrackingAreas];
    
    return view;
}

-(int)calculateStringHeight:(NSString*)string font:(NSFont*)font width:(int)width{
    NSMutableParagraphStyle *style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    NSDictionary *attrs = [NSDictionary dictionaryWithObjectsAndKeys:style,
                                 NSParagraphStyleAttributeName,
                                 font,
                                 NSFontAttributeName,
                                 nil];
    
    NSMutableAttributedString *attributed_string = [[NSMutableAttributedString alloc] initWithString:string attributes:attrs];
    CGRect rect = [attributed_string boundingRectWithSize:CGSizeMake(width, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading context:nil];
    return rect.size.height; //calculated height of dynamic title
}

-(void)expandTableView:(MyNotificationView*)view{
    [NSAnimationContext beginGrouping];
    [[NSAnimationContext currentContext] setDuration:0.25];
    
    //change the views height and all sub views
    for (id subview in view.subviews) {
        if([subview isKindOfClass:[MyTitleLabel class]]){
            MyTitleLabel* title = subview;
            [title setAttributedStringValue:view.title_string];
        }else if([subview isKindOfClass:[MyLabel class]]){
            MyLabel* info = subview;
            if(!info.str_time) [info setStringValue:view.message_string];
        }
        
        if(view.frame.size.height != view.real_height){
            NSView *s = subview;
            [s.animator setFrame:NSMakeRect(s.frame.origin.x, s.frame.origin.y + (view.real_height - view.shrink_height), s.frame.size.width, s.frame.size.height )];
        }
    }
    [view.animator setFrame:NSMakeRect(view.frame.origin.x,view.frame.origin.y,view.frame.size.width, view.real_height)];
    
    //update table
    NSInteger row = [_notification_table rowForView:view]; // find row
    [_notification_table noteHeightOfRowsWithIndexesChanged:[NSIndexSet indexSetWithIndex:row]];
    NSRect r = [_notification_table rectOfRow:row];
    [_notification_table scrollRectToVisible:r];
    
    [NSAnimationContext endGrouping];
}

int pre_shrink_height = 79;
-(void)shrinkTableView:(MyNotificationView*)view{
    [self shrinkTableView:view animate:YES];
}

-(void)shrinkTableView:(MyNotificationView*)view animate:(bool)should_animate{
    
    [NSAnimationContext beginGrouping];
    if(should_animate) [[NSAnimationContext currentContext] setDuration:0.25];
    
    //change the views height and all sub views
    [view.animator setFrame:NSMakeRect(view.frame.origin.x,view.frame.origin.y,view.frame.size.width, view.shrink_height)];
    
    //update table
    NSInteger row = [_notification_table rowForView:view]; // find row
    [_notification_table noteHeightOfRowsWithIndexesChanged:[NSIndexSet indexSetWithIndex:row]];
    NSRect r = [_notification_table rectOfRow:row];
    [_notification_table scrollRectToVisible:r];
    
    [NSAnimationContext endGrouping];
}

-(void)updateTimes{
    for(MyLabel* time_label in _time_labels){
        NSString* timestr = [NSString stringWithFormat:@"%@ %@", time_label.str_time, [self dateDiff:time_label.time]];
        [time_label setStringValue:timestr];
    }
}

-(void)showWindow{
    DDLogVerbose(@"showwindow");
    [[NSUserNotificationCenter defaultUserNotificationCenter] removeAllDeliveredNotifications];
    
    _window.alphaValue = 0;
    _window.animator.alphaValue = 0.0f;
    
    [self positionWindow];
    [NSApp activateIgnoringOtherApps:YES];
    [_window makeKeyAndOrderFront: nil];
    
    //remove potential selection
    [_view.window makeFirstResponder:nil];
    
    //fade in
    [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context) {
        context.duration = 0.4;
        _window.animator.alphaValue = 1.0f;
        
        //animate
        animatedNotifications = [NSMutableArray array];
        [self animateNotifications:true];
    }
    completionHandler:^{
        
        //remove potential selection
        [_view.window makeFirstResponder:nil];
        
        [_view setNeedsDisplay:YES];
        [_notification_table setNeedsDisplay:YES];
        [_scroll_view setNeedsDisplay:YES];
        
        [_window makeKeyAndOrderFront: _scroll_view];
        [_scroll_view becomeFirstResponder];
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
        
        STHTTPRequest *r = [STHTTPRequest requestWithURLString:@"https://notifi.it/getCode.php"];
        r.POSTDictionary = @{ @"UUID":[self getSystemUUID]};
        NSError *error = nil;
        NSString *content = [r startSynchronousWithError:&error];
        
        NSString* key = [self jsonToVal:content key:@"key"];
        NSString* credentials = [self jsonToVal:content key:@"credentials"];
        
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
bool userAuthed = false;
-(void)check{
    if(!failedCredentials){
        if(!streamOpen){
            [self openSocket];
        }else if(!userAuthed){
            DDLogVerbose(@"Requesting User Auth");
            [self authUser];
        }
    }
    //reset reload count (prevents recursive call of table reload) maximum 1 reload ever 2 seconds
    reloaded_in_last_2 = false;
}

-(void)handleIncomingNotification:(NSString*)message{
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
        DDLogVerbose(@"Received User Auth");
        userAuthed = true;
        [self updateReadIcon:false];
        
        NSError* error = nil;
        NSData* data = [message dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary* json_dic = [NSJSONSerialization
                                  JSONObjectWithData:data
                                  options:kNilOptions
                                  error:&error];
        if(!error){
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
                //update ui and add notifications
                dispatch_async(dispatch_get_main_queue(), ^{
                    if(_scroll_view.documentView != _notification_table){
                        [self reloadData];
                        _scroll_view.documentView = _notification_table;
                    }
                    
                    for (NSDictionary* notification in incoming_notifications){
                         MyNotificationView* n = [self createNotificationView:[notification objectForKey:@"title"]
                                                         message:[notification objectForKey:@"message"]
                                                        imageURL:[notification objectForKey:@"image"]
                                                            link:[notification objectForKey:@"link"]
                                                            time:[notification objectForKey:@"time"]
                                                            read:[[notification objectForKey:@"read"] boolValue]
                                                  notificationID:[[notification objectForKey:@"id"] intValue]];
                        [_notification_views addObject:n];
                        [_notification_table insertRowsAtIndexes:[NSIndexSet indexSetWithIndex:0] withAnimation:NSTableViewAnimationEffectGap];
                    }
                    
                    [self animateNotifications:NO scroll:true];
                    
                    [self updateReadIcon:true];
                });
                
                //send notification
                if([incoming_notifications count] <= 5){
                    for (NSDictionary* notification in incoming_notifications){
                        if(![_window isKeyWindow]){
                            [self sendLocalNotification:[notification objectForKey:@"title"]
                                                message:[notification objectForKey:@"message"]
                                               imageURL:[notification objectForKey:@"image"]
                                                   link:[notification objectForKey:@"link"]
                                         notificationID:[[notification objectForKey:@"id"] intValue]
                             ];
                        }
                    }
                }else{
                    //send notification with the amount of notifications rather than each individual notifications
                    NSUserNotification *note = [[NSUserNotification alloc] init];
                    [note setHasActionButton:false];
                    [note setTitle:[NSString stringWithFormat:@"You have %d new notifications!",(int)[incoming_notifications count]]];
                    [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:note];
                    [[NSUserNotificationCenter defaultUserNotificationCenter] setDelegate:(id)self];
                }
            }
        }else if(![message isEqualToString:@"1"]){
            DDLogError(@"Unrecognised message from socket: %@", message);
        }
    }
}

#pragma mark - notification storage

-(void)storeNotification:(NSDictionary*)notificationDic{
    // get all notifications
    NSMutableArray *notifications = [[[NSUserDefaults standardUserDefaults] objectForKey:@"notifications"] mutableCopy];
    if([notifications count] == 0){
        notifications = [[NSMutableArray alloc] init];
    }
    
    // make sure no duplicate notifications
    bool duplicate = false;
    for (id object in notifications) {
        if ([[object valueForKey:@"id"] isEqual:[notificationDic valueForKey:@"id"]]) {
            // already have a stored notification with this id
            duplicate = true;
        }
    }
    
    if(!duplicate){
        // add read variable to dic
        NSMutableDictionary *notification = [notificationDic mutableCopy];
        [notification setObject:[NSNumber numberWithBool:0] forKey:@"read"];
        
        // add notification to notifications
        [notifications addObject:notification];
        
        // store updated notifications
        [[NSUserDefaults standardUserDefaults] setObject:notifications forKey:@"notifications"];
    }
}

-(bool)notificationRead:(int)notificationID{
    NSMutableArray *notifications = [[[NSUserDefaults standardUserDefaults] objectForKey:@"notifications"] mutableCopy];
    int index = ((int)[notifications count] - 1) - [self rowFromNotification:notificationID];
    NSMutableDictionary *dic = [[notifications objectAtIndex:index] mutableCopy];
    return [[dic objectForKey:@"read"] boolValue];
}

-(NSString*)notificationLink:(int)notificationID{
    NSMutableArray *notifications = [[[NSUserDefaults standardUserDefaults] objectForKey:@"notifications"] mutableCopy];
    int index = ((int)[notifications count] - 1) - [self rowFromNotification:notificationID];
    NSMutableDictionary *dic = [[notifications objectAtIndex:index] mutableCopy];
    return [dic objectForKey:@"link"];
}

-(NSString*)imageLink:(int)notificationID{
    NSMutableArray *notifications = [[[NSUserDefaults standardUserDefaults] objectForKey:@"notifications"] mutableCopy];
    int index = ((int)[notifications count] - 1) - [self rowFromNotification:notificationID];
    NSMutableDictionary *dic = [[notifications objectAtIndex:index] mutableCopy];
    return [dic objectForKey:@"image"];
}

-(void)markAsRead:(bool)read notificationID:(int)notificationID{
    //update stored notification
    NSMutableArray *notifications = [[[NSUserDefaults standardUserDefaults] objectForKey:@"notifications"] mutableCopy];
    
    int index = ((int)[notifications count] - 1) - [self rowFromNotification:notificationID];
    
    NSMutableDictionary *dic = [[notifications objectAtIndex:index] mutableCopy];
    [dic setObject:[NSNumber numberWithBool:read] forKey:@"read"];
    [notifications replaceObjectAtIndex:index withObject:dic];
    [[NSUserDefaults standardUserDefaults] setObject:notifications forKey:@"notifications"];
    
    MyNotificationView* notification = [_notification_views objectAtIndex:index];
    MyTitleLabel* title = (MyTitleLabel*)[notification viewWithTag:notification.notificationID];
    
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
        [title animateWithDuration:0.4 animation:^{
            [[NSAnimationContext currentContext] setTimingFunction:[CAMediaTimingFunction functionWithControlPoints:0.80 :0.27 :0.00 :1.00]];
            NSPoint endPoint = NSMakePoint(or_x, or_y);
            [[title animator] setFrameOrigin:endPoint];
        }];
    }];
    NSLog(@"unread notifications :%d", unread_notification_count);
    [self updateReadIcon:false];
    
    // TODO
    // update button opacity
//    if(unread_notification_count <= 0){
//        [markAllAsReadBtn.layer setOpacity:markAllAsReadBtn.opacity_min];
//    }
}

-(void)markAllAsRead{
    if(unread_notification_count > 0){
        for(MyNotificationView* notification in _notification_views){
            [self markAsRead:true notificationID:notification.notificationID];
        }
    }
}

-(void)deleteNotification:(int)notificationID{
    NSMutableArray *notifications = [[[NSUserDefaults standardUserDefaults] objectForKey:@"notifications"] mutableCopy];
    
    int row =  [self rowFromNotification:notificationID];
    int index = ((int)[notifications count] - 1) - row;
    
    //reduce notification count if notification was read
    if([[notifications objectAtIndex:index][@"read"] isEqualToNumber:[NSNumber numberWithBool:NO]]){
        unread_notification_count--;
    }
    
    //remove notification from stored notifications
    [notifications removeObjectAtIndex:index]; // as rows are presented backwards
    [[NSUserDefaults standardUserDefaults] setObject:notifications forKey:@"notifications"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    //update GUI
    [_notification_views removeObjectAtIndex:index];
    [_time_labels removeObjectAtIndex:index];
    [_notification_table removeRowsAtIndexes:[NSIndexSet indexSetWithIndex:row] withAnimation:NSTableViewAnimationEffectFade];
    
    [self updateReadIcon:false];
    
    if([notifications count] == 0){
        _scroll_view.documentView = [self noNotificationsView];
        [self animateNotifications:true];
    }
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
        [alert setMessageText:[NSString stringWithFormat:@"Delete %d Notifications?", (int)[notifications count]]];
        [alert setInformativeText:@"Warning: Notifications cannot be restored without some sort of wizardry."];
        [alert setAlertStyle:NSWarningAlertStyle];
        
        if ([alert runModal] == NSAlertFirstButtonReturn) {
            [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"notifications"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            [self reloadData];
            [self createWindow];
        }
    }
}

-(int)rowFromNotification:(int)notificationID{
    for(int x = (int)[_notification_views count] - 1; x >= 0 ; x--){
        MyNotificationView* notification_view = [_notification_views objectAtIndex:x];
        if(notification_view.notificationID == notificationID) return ((int)[_notification_views count] - 1) - x;
    }
    [NSException raise:@"Invalid notificationID value" format:@"notificationID - %d is out of bounds", notificationID];
    return -1;
}

-(void)updateReadIcon:(bool)ani{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSImage* error_icon = [NSImage imageNamed:@"menu_error_bellicon.png" ];
        NSImage* alert_icon = [NSImage imageNamed:@"alert_menu_bellicon.png" ];
        NSImage* menu_icon = [NSImage imageNamed:@"menu_bellicon.png" ];
        
        MyLabel* title = (MyLabel*)[_view viewWithTag:1];
        title.hidden = true;
        if(!userAuthed){
            title.hidden = false;
            if(_statusItem.image != error_icon){
                _statusItem.image = error_icon;
                after_image = error_icon;
            }
        }else if(unread_notification_count > 0){
            if(ani){
                [self animateBell:alert_icon];
            }else{
                _statusItem.image = alert_icon;
            }
        }else{
            if(_statusItem.image != menu_icon){
                _statusItem.image = menu_icon;
                after_image = menu_icon;
            }
        }
    });
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
            DDLogError(@"Problem loading image from URL: %@", imgURL);
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
                DDLogError(@"problem with link url - %@", url_string);
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
bool connecting_socket = false;
- (void)openSocket
{
    if(!connecting_socket){
        DDLogVerbose(@"Attempting to connect to socket");
        connecting_socket = true;
        streamOpen = false;
        
        _webSocket.delegate = nil;
        [_webSocket close];
        
        _webSocket = [[SRWebSocket alloc] initWithURL:[NSURL URLWithString:@"wss://s.notifi.it"]];
        _webSocket.delegate = (id)self;
        
        [_webSocket open];
    }
}

bool receivedPong = false;
- (void)sendPing;
{
    if(streamOpen){
        receivedPong = false;
        [_webSocket sendPing:nil];
        //check for pong in last 2 seconds
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2* NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if(!receivedPong){
                [self closeSocket];
            }
        });
    }
}

- (void)webSocketDidOpen:(SRWebSocket *)webSocket;
{
    DDLogVerbose(@"WebSocket open");
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
    DDLogVerbose(@"WebSocket closed");
    [self closeSocket];
}

- (void)webSocket:(SRWebSocket *)webSocket didReceivePong:(NSData *)pongPayload;
{
    receivedPong = true;
}


BOOL streamOpen = false;
- (void)authUser{
    NSString* credentials = [[NSUserDefaults standardUserDefaults] objectForKey:@"credentials"];
    NSString* key = [self getKey:@"credential_key"];
    
    NSString* message = [NSString stringWithFormat:@"%@|%@|%@|%@", credentials, key, [self getSystemUUID], [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"]];
    if(streamOpen){
        [_webSocket send:message];
    }
}

-(void)closeSocket{
    if(streamOpen){
        DDLogVerbose(@"Terminated socket connection!");
    }
    connecting_socket = false;
    userAuthed = false;
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
    
    _stickyNotifications = [[NSMenuItem alloc] initWithTitle:@"Sticky Notifications" action:@selector(shouldMakeSticky) keyEquivalent:@""];
    [_stickyNotifications setTarget:self];
    if([[NSUserDefaults standardUserDefaults] boolForKey:@"sticky_notification"]) [_stickyNotifications setState:NSOnState];
    [mainMenu addItem:_stickyNotifications];
    
    _showOnStartupItem = [[NSMenuItem alloc] initWithTitle:@"Open notifi At Login" action:@selector(openOnStartup) keyEquivalent:@""];
    [_showOnStartupItem setTarget:self];
    if([self loginItemExistsWithLoginItemReference]){
        [_showOnStartupItem setState:NSOnState];
    }else{
        [_showOnStartupItem setState:NSOffState];
    }
    [mainMenu addItem:_showOnStartupItem];
    
    [mainMenu addItem:[NSMenuItem separatorItem]];
    
    NSMenuItem* rec = [[NSMenuItem alloc] initWithTitle:@"How To Receive Notifications..." action:@selector(howToRec) keyEquivalent:@""];
    [rec setTarget:self];
    [mainMenu addItem:rec];
    
    NSMenuItem* updates = [[NSMenuItem alloc] initWithTitle:@"Check For Updates..." action:@selector(checkUpdate) keyEquivalent:@""];
    [updates setTarget:self];
    [mainMenu addItem:updates];
    
    NSMenuItem* view_log = [[NSMenuItem alloc] initWithTitle:@"View Log..." action:@selector(showLoggingFile) keyEquivalent:@""];
    [view_log setTarget:self];
    [mainMenu addItem:view_log];
    
    [mainMenu addItemWithTitle:@"About..." action:@selector(showAbout) keyEquivalent:@""];
    
    [mainMenu addItem:[NSMenuItem separatorItem]];
    
    NSMenuItem* quit = [[NSMenuItem alloc] initWithTitle:@"Quit notifi" action:@selector(quit) keyEquivalent:@"q"];
    [quit setTarget:self];
    [mainMenu addItem:quit];
    
    // Disable auto enable
    [mainMenu setAutoenablesItems:NO];
    [mainMenu setDelegate:(id)self];
    return mainMenu;
}

-(void)howToRec{
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:how_to_url]];
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
        [_stickyNotifications setState:NSOffState];
    }else{
        [_stickyNotifications setState:NSOnState];
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
        DDLogVerbose(@"already running app so terminated");
        [self quit];
    }
    
}

#pragma mark - sparkle
-(void)checkUpdate{
    [self checkUpdate:false];
}
-(void)checkUpdate:(BOOL)background{
    if(!background){
        if(_window && [_window isVisible]){
            [_window orderOut:self];
        }
        
        [[SUUpdater updaterForBundle:[NSBundle bundleForClass:[self class]]] checkForUpdates:NULL];
    }else{
        [[SUUpdater updaterForBundle:[NSBundle bundleForClass:[self class]]] checkForUpdatesInBackground];
    }
}

#pragma mark - logging
NSString *log_file_path;
-(void)setupLogging{
    DDFileLogger *fileLogger = [[DDFileLogger alloc] init];
    fileLogger.rollingFrequency = 60 * 60 * 24; // 24 hour rolling
    fileLogger.logFileManager.maximumNumberOfLogFiles = 7;
    [DDLog addLogger:fileLogger];
    [DDLog addLogger:[DDTTYLogger sharedInstance]];
    log_file_path = [[fileLogger currentLogFileInfo] filePath];
}

-(void)showLoggingFile{
    [[NSWorkspace sharedWorkspace] openFile:log_file_path];
}


#pragma mark - about

-(void)showAbout{
    if(_window && [_window isVisible]){
        [_window orderOut:self];
    }
    [[NSApplication sharedApplication] orderFrontStandardAboutPanel:self];
}

@end
