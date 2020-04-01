//
//  Notification.m
//  notifi
//
//  Created by Max Mitchell on 21/01/2018.
//  Copyright © 2018 max mitchell. All rights reserved.
//
#import "Notification.h"

#import <CocoaLumberjack/CocoaLumberjack.h>
static const DDLogLevel ddLogLevel = DDLogLevelVerbose;

#import "CustomVars.h"
#import "CustomFunctions.h"
#import "NotificationImage.h"
#import "NotificationLabel.h"
#import "NotificationLink.h"
#import "NSView+animate.h"

#define TOPPADDING 20
#define SIDEPADDING 10
#define MESSAGEPADDING 4
#define TIMEHEIGHT 18

#define LINKICONHEIGHT 15
#define LINKPADDING 10

#define EXPANDDURATION 0.25

#define TITLEHEIGHT 25 // [self calculateStringHeight:@"⎷" font:self.message_font width:self.text_width];
#define MESSAGEHEIGHT 19 // [self calculateStringHeight:@"⎷" font:self.title_font width:self.text_width];

#define TEXTWIDTH 300

#define MINNOTIFICATIONIMAGEHEIGHT 110

@implementation Notification

- (BOOL)acceptsFirstResponder {
    return YES;
}

-(id)initWithTitle:(NSString *)title message:(NSString *)message link:(NSString*)link image_url:(NSString*)image_url time_string:(NSString*)time_string read:(bool)read ID:(unsigned long)ID {
    if (self != [super init]) return nil;
    
    int side_padding = SIDEPADDING;
    int image_hw = [CustomVars shrinkHeight:true] - TOPPADDING;
    int width = [CustomVars windowWidth];
    
    [self setWantsLayer:YES];
    
    //fonts
    self.title_font = [NSFont fontWithName:@"Montserrat-SemiBold" size:17];
    self.message_font = [NSFont fontWithName:@"Montserrat-Regular" size:12];
    NSFont* time_font = [NSFont fontWithName:@"Montserrat-Light" size:10];
    
    NotificationImage *image;
    if([image_url length] != 0){
        image = [[NotificationImage alloc] initWithFrame:NSMakeRect(0, 0, image_hw, image_hw)];
        [image setImageFromURL:image_url hw:image_hw];
        if (image.image != nil){
            side_padding += image_hw;
        }else{
            image_url = @"";
        }
    }
    
    if([link length] != 0){
        // add link icon
        self.link_view = [[NotificationLink alloc] initWithFrame:NSMakeRect(
            side_padding,
            self.frame.size.height,
            LINKICONHEIGHT,
            LINKICONHEIGHT
        )];
        [self.link_view setUrl:link];
        NSImage *image = [NSImage imageNamed:@"link.png"];
        NSBitmapImageRep *rep = [NSBitmapImageRep imageRepWithData:[image TIFFRepresentation]];
        NSSize size = NSMakeSize([rep pixelsWide], [rep pixelsHigh]);
        [image setSize: size];
        [self.link_view setImage:image];
        [self addSubview:self.link_view];
        side_padding += LINKICONHEIGHT;
    }
    
    float text_width = TEXTWIDTH - side_padding;
    
    //------ height of title
    float title_height = [self calculateStringHeight:title font:self.title_font width:text_width];
    
    //------- height of info
    float message_height = MESSAGEPADDING; // no info padding
    if([message length] != 0){
        message_height = [self calculateStringHeight:message font:self.message_font width:text_width];
    }
    
    //calculate total height of notification
    int notification_height = title_height + TIMEHEIGHT + message_height + (TOPPADDING * 2.4);
    
    if([image_url length] != 0){ // handle extra heightNSColor if image
        if (notification_height < MINNOTIFICATIONIMAGEHEIGHT) {
            notification_height = MINNOTIFICATIONIMAGEHEIGHT;
        }
    }
    
    //create view
    [self setFrame:CGRectMake(0, 0, 0, notification_height - (TOPPADDING * 2))];
    self.layer.backgroundColor = [[CustomVars white] CGColor];
    self.layer.borderColor = [[CustomVars boarder] CGColor];
    self.layer.borderWidth = 1;
    self.layer.cornerRadius = 7.0f;
    self.layer.masksToBounds = YES;
    self.autoresizingMask = NSViewHeightSizable;
    
    //body of notification
    //--      add image
    if([image_url length] != 0){
        self.image_view = [[NSView alloc] initWithFrame:NSMakeRect(
           SIDEPADDING,
           self.title_label.frame.origin.y + 9,
           image_hw,
           image_hw
        )];
        self.image_view.layer.cornerRadius = 5;
        self.image_view.layer.masksToBounds = YES;
        
        [image setUrl:image_url];
        [self.image_view addSubview:image];
        
        [self addSubview:self.image_view];
    }
    
    //--    add title
    self.title_label = [[NotificationLabel alloc] init];
    [self.title_label setFrame:CGRectMake(side_padding, self.frame.size.height - (title_height + 4), text_width, title_height)]; // 4 is dynamic to font
    [self.title_label setFont:self.title_font];
    [self.title_label setDelegate:(id)self];
    [self.title_label setBackgroundColor: [CustomVars offwhite]];
    [self.title_label setTextColor: [CustomVars black]];
    [self.title_label setStringValue:title];
    [self addSubview:self.title_label];
    
    if([link length] != 0){
        // add link icon
        [self.link_view setFrame:NSMakeRect(
            self.link_view.frame.origin.x,
            self.title_label.frame.origin.y + self.title_label.frame.size.height - self.link_view.frame.size.height - 6,
            self.link_view.frame.size.width,
            self.link_view.frame.size.height
        )];
    }
    
    //--   add time
    self.time_label = [[NotificationLabel alloc] init];
    [self.time_label setFrame:CGRectMake(
        side_padding,
        self.title_label.frame.origin.y - TIMEHEIGHT,
        text_width,
        TIMEHEIGHT
    )];
    [self.time_label setFont:time_font];
    [self.time_label setTextColor: [CustomVars grey]];
    
    //get nsdate
    NSDateFormatter *serverFormat = [[NSDateFormatter alloc]init];
    [serverFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *date = [serverFormat dateFromString:time_string];
    
    //change to local time zone
    NSTimeZone *tz = [NSTimeZone systemTimeZone];
    NSInteger seconds = [tz secondsFromGMTForDate: date]; //server time zone `date +%Z`
    NSDate* convertedDate = [NSDate dateWithTimeInterval: seconds sinceDate:date];
    
    // create string from time in format
    NSDateFormatter *myFormat = [[NSDateFormatter alloc]init];
    [myFormat setDateFormat:@"MMM d, yyyy HH:mm"];
    NSString *formattedStringDate = [myFormat stringFromDate:convertedDate];
    NSString* timestr = [NSString stringWithFormat:@"%@ %@", formattedStringDate, [self dateDiff:convertedDate]];
    [self.time_label setStringValue:timestr];
    [self addSubview:self.time_label];
    
    // info part of message
    if([message length] != 0){
        self.message_label = [[NotificationLabel alloc] init];
        [self.message_label setBackgroundColor:[CustomVars offwhite]];
        
        [self.message_label setFrame:CGRectMake(side_padding, self.time_label.frame.origin.y - message_height, text_width, message_height)];
        self.message_label.expand_y = self.message_label.frame.origin.y;
        [self.message_label setFont:self.message_font];
        [self.message_label setTextColor: [CustomVars black]];
        [self.message_label setPreferredMaxLayoutWidth:text_width];
        [self.message_label setStringValue:message];
        [self.message_label setWantsLayer:TRUE];
        [self.message_label setDelegate:(id)self];
        [self addSubview:self.message_label];
    }
    
    // store all notification variables
    self.ID = ID;
    self.title_string = title;
    self.message_string = message;
    self.link = link;
    self.image_url = image_url;
    self.time = convertedDate;
    self.str_time = formattedStringDate;
    self.expand_height = notification_height - (TOPPADDING * 2);
    self.shrink_height = [CustomVars shrinkHeight:[message length] != 0 || self.image_view != nil];
    self.text_width = text_width;
    self.title_label.expand_y = self.title_label.frame.origin.y;
    self.message_label.expand_y = self.message_label.frame.origin.y;
    self.time_label.expand_y = self.time_label.frame.origin.y;
    
    if(read){
        [self markRead];
    }else{
        [self markUnread];
    }
    
    self.is_expanded = true;
    [self shrink:false];
    
    return self;
}

- (NSTableView*)getTableView{
    id view = [self superview];
    
    while (view && [view isKindOfClass:[NSTableView class]] == NO) {
        view = [view superview];
    }
    
    return (NSTableView *)view;
}

-(void)resizeTableRow{
    NSTableView* t = [self getTableView];
    
    //update table height
    NSInteger row = [t rowForView:self];
    [t noteHeightOfRowsWithIndexesChanged:[NSIndexSet indexSetWithIndex:row]];
    
    // scroll to expanded notification
    NSRect r = [t rectOfRow:row];
    [t scrollRectToVisible:r];
}

- (void)shrink:(bool)animate{
    if(self.is_expanded && self.frame.size.height != self.shrink_height){
        self.is_expanded = false;
        float title_height = [self calculateStringHeight:self.title_string font:self.title_font width:self.text_width];
        float message_height = [self calculateStringHeight:self.message_string font:self.message_font width:self.text_width];
        
        NSString* cat = @"...";

        float title_label_y = self.title_label.frame.origin.y;
        float time_label_y = self.time_label.frame.origin.y;
        float message_label_y = self.message_label.frame.origin.y;
        
        if(title_height > TITLEHEIGHT){
            // title string is more than one line
            float title_height_change = title_height - TITLEHEIGHT;
            NSLog(@"%f", title_height_change);

            // change the string title to one line if not previously calculated
            if ([self.concat_title_string length] == 0){
                int cnt = 0;
                NSString *str = @"";
                do{
                    str = [NSString stringWithFormat:@"%@%@", [self.title_string substringToIndex:cnt], cat];
                    cnt++;
                }while([self calculateStringHeight:str font:self.title_font width:self.text_width] <= TITLEHEIGHT);
                
                // store concatenated string in memory
                self.concat_title_string = [NSString stringWithFormat:@"%@%@", [self.title_string substringToIndex:cnt - [cat length]], cat];
            }
            [self.title_label setStringValue:self.concat_title_string];
            
            // set new title position
            title_label_y -= title_height_change;
        }
        
        if(message_height > MESSAGEHEIGHT){
            // message string is more than one line
            float message_height_change = message_height - MESSAGEHEIGHT;
            
            if ([self.concat_message_string length] == 0){
                // change the message of the notification to one row if it is not already
                int cnt = 0;
                NSString *str = @"";
                do{
                    str = [NSString stringWithFormat:@"%@%@", [self.message_string substringToIndex:cnt], cat];
                    cnt++;
                }while([self calculateStringHeight:str font:self.message_font width:self.text_width] <= MESSAGEHEIGHT);
                
                NSString* compressed_str = @"";
                if(cnt >= [cat length]){
                    compressed_str = [self.message_string substringToIndex:cnt - [cat length]];
                }else{
                    compressed_str = [self.message_string substringToIndex:cnt];
                }
                
                // store concatenated string in memory
                self.concat_message_string = [NSString stringWithFormat:@"%@%@", compressed_str, cat];
            }
            [self.message_label setStringValue:self.concat_message_string];
            
            
            // update positions
            title_label_y -= message_height_change;
            message_label_y -= message_height_change;
            time_label_y -= message_height_change;
        }
        
        if(self.image_view != nil && [self.message_string length] == 0){
            title_label_y += MESSAGEHEIGHT - 4;
            time_label_y += MESSAGEHEIGHT - 4;
        }
        
        // no idea why you have to call before and after. Pretty sure this must be a bug.
        [self setFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, self.shrink_height)];
        [self resizeTableRow];
        [self setFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, self.shrink_height)];
        
        [NSAnimationContext beginGrouping];
        [[NSAnimationContext currentContext] setDuration:[CustomVars notificationAnimationDuration]];
        
        if (title_label_y != self.title_label.frame.origin.y) {
            if (self.link_view != nil){
                [self.link_view setFrame:NSMakeRect(
                    self.link_view.frame.origin.x,
                    title_label_y + self.title_label.frame.size.height - self.link_view.frame.size.height - 6, // TODO where does this come from?!
                    self.link_view.frame.size.width,
                    self.link_view.frame.size.height
                )];
            }
            if (self.image_view != nil){
                [self.image_view setFrame:NSMakeRect(
                    self.image_view.frame.origin.x,
                    title_label_y + self.title_label.frame.size.height - self.image_view.frame.size.height - 5, // TODO where does this come from?!
                    self.image_view.frame.size.width,
                    self.image_view.frame.size.height
                )];
            }
            [self.title_label setFrame:NSMakeRect(
                self.title_label.frame.origin.x,
                title_label_y,
                self.title_label.frame.size.width,
                self.title_label.frame.size.height
            )];
        }
        
        if (message_label_y != self.message_label.frame.origin.y) {
            [self.message_label setFrame:NSMakeRect(
                self.message_label.frame.origin.x,
                message_label_y,
                self.message_label.frame.size.width,
                self.message_label.frame.size.height
            )];
        }
        
        if (time_label_y != self.time_label.frame.origin.y) {
            [self.time_label setFrame:NSMakeRect(
                self.time_label.frame.origin.x,
                time_label_y,
                self.time_label.frame.size.width,
                self.time_label.frame.size.height
            )];
        }
        
        [NSAnimationContext endGrouping];
        [self updateTrackingAreas];
    }
}

- (void)expand{
    if(!self.is_expanded){
        self.is_expanded = true;
        [NSAnimationContext beginGrouping];
        [[NSAnimationContext currentContext] setDuration:[CustomVars notificationAnimationDuration]];
        
        [self.title_label setStringValue:self.title_string];
        [self.message_label setStringValue:self.message_string];
        
        float top_y = self.title_label.frame.size.height + self.time_label.frame.size.height + self.message_label.frame.size.height;
        
        if (self.image_view != nil){
            [self.image_view setFrame:NSMakeRect(
                self.image_view.frame.origin.x,
                top_y - self.image_view.frame.size.height,
                self.image_view.frame.size.width,
                self.image_view.frame.size.height
            )];
        }
        
        if (self.link_view != nil){
            [self.link_view setFrame:NSMakeRect(
                self.link_view.frame.origin.x,
                top_y - self.link_view.frame.size.height,
                self.link_view.frame.size.width,
                self.link_view.frame.size.height
            )];
            
        }
        
        for (id subview in self.subviews) {
            if ([subview isMemberOfClass:[NotificationLabel class]]){
                NotificationLabel* n = (NotificationLabel*)subview;
                NSLog(@"%@", n.stringValue);
                [n setFrame:NSMakeRect(n.frame.origin.x, n.expand_y, n.frame.size.width, n.frame.size.height)];
            }
        }
        
        // no idea why you have to call before and after. Pretty sure this is a bug.
        [self setFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, self.expand_height)];
        [self resizeTableRow];
        [self setFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, self.expand_height)];
        
        [NSAnimationContext endGrouping];
        [self markRead];
    }
    [self updateTrackingAreas];
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
            return @"- 1 hour ago";
        }
        return[NSString stringWithFormat:@"- %d hours ago", diff];
    } else if (ti < 2629743) {
        int diff = round(ti / 60 / 60 / 24);
        if (diff == 1){
            return @"- 1 day ago";
        }
        return[NSString stringWithFormat:@"- %d days ago", diff];
    }
    
    //failed
    return @"";
}


-(void)updateTrackingAreas{
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

- (void)markRead{
    if(!self.read){
        [self.layer setBackgroundColor:[[NSColor clearColor] CGColor]];
        self.title_label.textColor = [CustomVars grey];
        self.read = true;
        [self storeRead:true];
    }
}

- (void)markUnread {
    if(self.read){
        [self.layer setBackgroundColor:[[CustomVars white] CGColor]];
        self.title_label.textColor = [CustomVars black];
        self.read = false;
        [self storeRead:false];
    }
}

- (void)openLink{
    if([self.link length] != 0){
        [self markRead];
        [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:self.link]];
    }
}

- (void)openImage{
    if([self.image_url length] != 0){
        [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:self.image_url]];
    }
}

-(void) reloadTime{
    NSString* timestr = [NSString stringWithFormat:@"%@ %@", self.str_time, [self dateDiff:self.time]];
    [self.time_label setStringValue:timestr];
}

#pragma mark - external events
- (void)mouseUp:(NSEvent *)event {
    [self expand];
}

- (void) rightMouseDown:(NSEvent *)event {
    NSMenu *m = [[NSMenu alloc] initWithTitle:@"Right Cick Menu"];

    if(self.expand_height != self.shrink_height){
        NSMenuItem *expandItem;
        if(!self.is_expanded){
            expandItem = [[NSMenuItem alloc] initWithTitle:@"Expand" action:@selector(expand) keyEquivalent:@""];
        }else{
            expandItem = [[NSMenuItem alloc] initWithTitle:@"Shrink" action:@selector(shrink:) keyEquivalent:@""];
        }
        [expandItem setRepresentedObject:self];
        [m addItem:expandItem];
        
        [m addItem:[NSMenuItem separatorItem]];
    }

    if(self.read){
        [m addItemWithTitle:@"Mark Unread" action:@selector(markUnread) keyEquivalent:@""];
    }else{
        [m addItemWithTitle:@"Mark Read" action:@selector(markRead) keyEquivalent:@""];
    }

    [m addItemWithTitle:@"Delete Notification" action:@selector(deleteNotification) keyEquivalent:@""];

    [m addItem:[NSMenuItem separatorItem]];

    if(![self.link isEqual: @" "] && self.link != nil){
        NSMenuItem *menuItem = [[NSMenuItem alloc] initWithTitle:@"Open Link" action:@selector(openLink) keyEquivalent:@""];
        [m addItem:menuItem];
    }

    if(![self.image_url isEqual: @" "] && self.image_url != nil){
        NSMenuItem *menuItem = [[NSMenuItem alloc] initWithTitle:@"Open Image" action:@selector(openImage) keyEquivalent:@""];
        [m addItem:menuItem];
    }

    [NSMenu popUpContextMenu:m withEvent:event forView:(id)self];
}

#pragma mark - NSUserDefaults
+(void)storeNotificationDic:(NSMutableDictionary*)notification{
    // get all notifications
    NSMutableArray *notifications = [[[NSUserDefaults standardUserDefaults] objectForKey:@"notifications"] mutableCopy];
    if([notifications count] == 0) notifications = [[NSMutableArray alloc] init];
    
    // add read variable to dic
    notification = [notification mutableCopy];
    [notification setObject:[NSNumber numberWithBool:false] forKey:@"read"];
    
    // add notification to notifications
    [notifications addObject:notification];
    
    // store updated notifications
    [[NSUserDefaults standardUserDefaults] setObject:notifications forKey:@"notifications"];
}

-(void)deleteNotification{
    NSNumber *num = [[NSNumber alloc] initWithUnsignedLong:self.ID];
    [CustomFunctions sendNotificationCenter:num name:@"delete-notification"];
}

- (void)storeRead:(bool)read{
    NSMutableArray *notifications = [[[NSUserDefaults standardUserDefaults] objectForKey:@"notifications"] mutableCopy];
    unsigned long dic_index = [self defaultsIndex:notifications];
    NSMutableDictionary* notification = [[notifications objectAtIndex:dic_index] mutableCopy];
    [notification setObject:[NSNumber numberWithBool:read] forKey:@"read"];
    [notifications replaceObjectAtIndex:dic_index withObject:notification];
    [[NSUserDefaults standardUserDefaults] setObject:notifications forKey:@"notifications"];
    [CustomFunctions sendNotificationCenter:false name:@"update-menu-icon"];
}

- (unsigned long)defaultsIndex:(NSArray *)notifications{
    unsigned long index = 0;
    for (NSDictionary* dic in notifications) {
        if ([[dic valueForKey:@"id"] unsignedLongValue] == self.ID) return index;
        index++;
    }
    return -1;
}

@end
