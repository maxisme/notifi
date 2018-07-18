//
//  Notification.m
//  notifi
//
//  Created by Max Mitchell on 21/01/2018.
//  Copyright © 2018 max mitchell. All rights reserved.
//
#import "Notification.h"
#import "CustomVars.h"
#import "CustomFunctions.h"
#import "Log.h"
#import "NotificationImage.h"
#import "NotificationLabel.h"
#import "NotificationLink.h"
#import "NSView+animate.h"

@implementation Notification

- (BOOL)acceptsFirstResponder {
    return YES;
}

NSString* EMPTY;
float one_row_title_height;
float one_row_info_height;
-(id)initWithTitle:(NSString *)title message:(NSString *)message link:(NSString*)link image_url:(NSString*)image_url time_string:(NSString*)time_string read:(bool)read ID:(unsigned long)ID {
    if (self != [super init]) return nil;
    
    int top_padding = 20;
    int side_padding = 15;
    int info_padding = 4;
    int time_height = 18;
    int image_hw = [CustomVars shrinkHeight:true] - top_padding;
    int width = [CustomVars windowWidth];
    EMPTY = [CustomVars default_empty];
    
    [self setWantsLayer:YES];
    
    //fonts
    _title_font = [NSFont fontWithName:@"Montserrat-SemiBold" size:17];
    _info_font = [NSFont fontWithName:@"Montserrat-Regular" size:12];
    NSFont* time_font = [NSFont fontWithName:@"Montserrat-Light" size:10];
    
    if(![image_url isEqual: EMPTY]){
        side_padding = image_hw + top_padding;
    }
    
    float text_width = width * 0.95 - side_padding;
    
    //------ height of title
    float title_height = [self calculateStringHeight:title font:_title_font width:text_width];
    
    //------- height of info
    float info_height = info_padding; // no info padding
    if(![message isEqual: EMPTY]){
        info_height = [self calculateStringHeight:message font:_info_font width:text_width];
    }
    
    //calculate total height of notification
    int notification_height = title_height + time_height + info_height + (top_padding * 2.4);
    
    if(![image_url isEqual: EMPTY]){ // handle extra heightNSColor if image
        int min_height = image_hw + top_padding * 4;
        if(notification_height < min_height){
            notification_height = min_height;
        }
    }
    
    //create view
    [self setFrame:CGRectMake(0, 0, 0, notification_height - (top_padding * 2))];
    [self.layer setBackgroundColor:[[CustomVars white] CGColor]];
    self.layer.borderColor = [[CustomVars boarder] CGColor];
    self.layer.borderWidth = 1;
    self.layer.cornerRadius = 7.0f;
    self.layer.masksToBounds = YES;
    self.autoresizingMask = NSViewHeightSizable;
    
    //body of notification
    //--      add image
    if(![image_url isEqual: EMPTY]){
        NSView* rounded_image_view = [[NSView alloc] initWithFrame:NSMakeRect(top_padding / 2, self.frame.size.height - image_hw - (top_padding / 2), image_hw, image_hw)];
        [rounded_image_view setWantsLayer:YES];
        rounded_image_view.layer.cornerRadius = 5; // circle
        rounded_image_view.layer.masksToBounds = YES;
        
        NotificationImage *image_view = [[NotificationImage alloc] initWithFrame:NSMakeRect(0, 0, image_hw, image_hw)];
        [image_view setImageFromURL:image_url];
        [image_view setUrl:image_url];
        [rounded_image_view addSubview:image_view];
        
        [self addSubview:rounded_image_view];
    }
    
    int link_hw = 0;
    if(![link isEqual: EMPTY]){
        //add link image
        link_hw = 15;
        int padding = 8;
        
        NotificationLink *image_view = [[NotificationLink alloc] initWithFrame:NSMakeRect(side_padding, self.frame.size.height - link_hw - padding - 2, link_hw, link_hw)];
        [image_view setUrl:link];
        [image_view setImageScaling:NSImageScaleProportionallyUpOrDown];
        [image_view setImage:[NSImage imageNamed:@"link.png"]];
        [self addSubview:image_view];
        text_width = text_width - 15;
    }
    
    
    //--    add title
    _title_label = [[NotificationLabel alloc] init];
    [_title_label setFrame:CGRectMake(side_padding + link_hw, self.frame.size.height - (title_height + 4), text_width, title_height)]; // 4 is dynamic to font
    [_title_label setFont:_title_font];
    [_title_label setDelegate:(id)self];
//    [_title_label setBackgroundColor: [CustomVars offwhite]];
    [_title_label setStringValue:title];
    [self addSubview:_title_label];
    
    //--   add time
    _time_label = [[NotificationLabel alloc] init];
    [_time_label setFrame:CGRectMake(
                                    side_padding,
                                    _title_label.frame.origin.y - time_height,
                                    text_width,
                                    time_height
                                    )
    ];
//    [_time_label setBackgroundColor: [CustomVars offwhite]];
    [_time_label setFont:time_font];
    [_time_label setTextColor: [CustomVars grey]];
    
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
    [_time_label setStringValue:timestr];
    [self addSubview:_time_label];
    
    //-- add info
    if(![message isEqual: EMPTY]){
        _info_label = [[NotificationLabel alloc] init];
//        [_info_label setBackgroundColor:[CustomVars offwhite]];
        [_info_label setFrame:CGRectMake(side_padding, _time_label.frame.origin.y - info_height, text_width, info_height)];
        [_info_label setFont:_info_font];
        [_info_label setTextColor: [CustomVars black]];
        [_info_label setPreferredMaxLayoutWidth:text_width];
        [_info_label setStringValue:message];
        [_info_label setDelegate:(id)self];
        [self addSubview:_info_label];
    }
    
    // store all notification variables
    self.ID = ID;
    self.title_string = title;
    self.message_string = message;
    self.link = link;
    self.image_url = image_url;
    self.time = convertedDate;
    self.str_time = formattedStringDate;
    self.expand_height = notification_height - (top_padding * 2);
    self.shrink_height = [CustomVars shrinkHeight:false];
    if(info_height != info_padding) self.shrink_height = [CustomVars shrinkHeight:true]; // (ie there is info text)
    self.text_width = text_width;
    
    //store for shrink and expand
    one_row_title_height = [self calculateStringHeight:@"⎷" font:_title_font width:_text_width];
    one_row_info_height = [self calculateStringHeight:@"⎷" font:_info_font width:_text_width];
    
    if(read){
        [self markRead];
    }else{
        [self markUnread];
    }
    
    self.expanded = true;
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
    if(self.expanded){
        [NSAnimationContext beginGrouping];
        if(animate) [[NSAnimationContext currentContext] setDuration:0.25];
        
        self.expanded = false;
        float title_height = [self calculateStringHeight:_title_string font:_title_font width:_text_width];
        float info_height = [self calculateStringHeight:_message_string font:_info_font width:_text_width];
        
        NSString* cat = @"...";
        
        // change the title of the notification to one row if it is not already
        if(title_height > one_row_title_height){
            int cnt = 0;
            NSString *str = @"";
            do{
                str = [NSString stringWithFormat:@"%@%@", [_title_string substringToIndex:cnt], cat];
                cnt++;
            }while([self calculateStringHeight:str font:_title_font width:_text_width] <= one_row_title_height);
            [_title_label setStringValue:[NSString stringWithFormat:@"%@%@", [_title_string substringToIndex:cnt - [cat length]], cat]]; //modify title label to concatted one.
            
            //move time and info relative to new height
            self.title_height_change = title_height - one_row_title_height;
            [self.time_label setFrame:NSMakeRect(self.time_label.frame.origin.x, self.time_label.frame.origin.y + self.title_height_change, self.time_label.frame.size.width, self.time_label.frame.size.height)];
            [self.info_label setFrame:NSMakeRect(self.info_label.frame.origin.x, self.info_label.frame.origin.y + self.title_height_change, self.info_label.frame.size.width, self.info_label.frame.size.height)];
        }
        
        // change the info of the notification to one row if it is not already
        if(info_height > one_row_info_height){
            int cnt = 0;
            NSString *str = @"";
            do{
                str = [NSString stringWithFormat:@"%@%@", [_message_string substringToIndex:cnt], cat];
                cnt++;
            }while([self calculateStringHeight:str font:_info_font width:_text_width] <= one_row_title_height);
            [_info_label setStringValue:[NSString stringWithFormat:@"%@%@", [_message_string substringToIndex:cnt - [cat length]], cat]];
        }
        
        for (NSView* subview in self.subviews) {
            [subview.animator setFrame:NSMakeRect(subview.frame.origin.x, subview.frame.origin.y - (self.expand_height - self.shrink_height), subview.frame.size.width, subview.frame.size.height)];
        }
        
        // no idea why you have to call before and after. Pretty sure this must be a bug.
        [self setFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, self.shrink_height)];
        [self resizeTableRow];
        [self setFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, self.shrink_height)];
        
        [NSAnimationContext endGrouping];
    }
    [self updateTrackingAreas];
}

- (void)expand{
    if(!self.expanded){
        [NSAnimationContext beginGrouping];
        [[NSAnimationContext currentContext] setDuration:0.25];
        self.expanded = true;
        
        //change time and info labels position if needs
        if(self.title_height_change != 0){
            [self.time_label setFrame:NSMakeRect(self.time_label.frame.origin.x, self.time_label.frame.origin.y - self.title_height_change, self.time_label.frame.size.width, self.time_label.frame.size.height)];
            [self.info_label setFrame:NSMakeRect(self.info_label.frame.origin.x, self.info_label.frame.origin.y - self.title_height_change, self.info_label.frame.size.width, self.info_label.frame.size.height)];
        }
        
        [_title_label setStringValue:_title_string];
        [_info_label setStringValue:_message_string];
        
        for (NSView* subview in self.subviews) {
            [subview.animator setFrame:NSMakeRect(subview.frame.origin.x, subview.frame.origin.y + (self.expand_height - self.shrink_height), subview.frame.size.width, subview.frame.size.height)];
        }
        
        // no idea why you have to call before and after. Pretty sure this must be a bug.
        [self setFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, self.expand_height)];
        [self resizeTableRow];
        [self setFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, self.expand_height)];
        
        [NSAnimationContext endGrouping];
        [self markRead];
    }
    NSLog(@"%f",self.expand_height); //uncomment this when adding new fonts to test shrink height (with and without info)
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

- (void)markRead {
    if(!_read){
        [self.layer setBackgroundColor:[[NSColor clearColor] CGColor]];
        _title_label.textColor = [CustomVars grey];
        _read = true;
        [self storeRead:true];
    }
}

- (void)markUnread {
    if(_read){
        [self.layer setBackgroundColor:[[CustomVars white] CGColor]];
        _title_label.textColor = [CustomVars black];
        _read = false;
        [self storeRead:false];
    }
}

- (void)openLink{
    if(![_link  isEqual: EMPTY]){
        [self markRead];
        [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:_link]];
    }
}

- (void)openImage{
    if(![_image_url  isEqual: EMPTY]){
        [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:_image_url]];
    }
}

-(void) reloadTime{
    NSString* timestr = [NSString stringWithFormat:@"%@ %@", self.str_time, [self dateDiff:self.time]];
    [_time_label setStringValue:timestr];
}

#pragma mark - external events
- (void)mouseUp:(NSEvent *)event {
    [Log log:@"md"];
    [self expand];
}

- (void) rightMouseDown:(NSEvent *)event {
    NSMenu *m = [[NSMenu alloc] initWithTitle:@"Right Cick Menu"];

    if(self.expand_height != self.shrink_height){
        NSMenuItem *expandItem;
        if(!self.expanded){
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

    if(![_link isEqual: @" "] && _link != nil){
        NSMenuItem *menuItem = [[NSMenuItem alloc] initWithTitle:@"Open Link" action:@selector(openLink) keyEquivalent:@""];
        [m addItem:menuItem];
    }

    if(![_image_url isEqual: @" "] && _image_url != nil){
        NSMenuItem *menuItem = [[NSMenuItem alloc] initWithTitle:@"Open Image" action:@selector(openImage) keyEquivalent:@""];
        [m addItem:menuItem];
    }

    [NSMenu popUpContextMenu:m withEvent:event forView:(id)self];
}

#pragma mark - NSUserDefaults
+(void)storeNotificationDic:(NSDictionary*)dic{
    // get all notifications
    NSMutableArray *notifications = [[[NSUserDefaults standardUserDefaults] objectForKey:@"notifications"] mutableCopy];
    if([notifications count] == 0) notifications = [[NSMutableArray alloc] init];
    
    // make sure no duplicate notifications
    bool duplicate = false;
    for (id object in notifications) {
        if ([[object valueForKey:@"id"] isEqual:[dic valueForKey:@"id"]]) {
            // already have a stored notification with this id
            duplicate = true;
            break;
        }
    }
    
    if(!duplicate){
        // add read variable to dic
        NSMutableDictionary *notification = [dic mutableCopy];
        [notification setObject:[NSNumber numberWithBool:false] forKey:@"read"];
        
        // add notification to notifications
        [notifications addObject:notification];
        
        // store updated notifications
        [[NSUserDefaults standardUserDefaults] setObject:notifications forKey:@"notifications"];
    }
}

-(void)deleteNotification{
    NSNumber *num = [[NSNumber alloc] initWithUnsignedLong:self.ID];
    [CustomFunctions sendNotificationCenter:num name:@"delete-notification"];
}

- (void)storeRead:(bool)read{
    unsigned long dic_index = [self defaultsIndex];
    NSMutableArray *notifications = [[[NSUserDefaults standardUserDefaults] objectForKey:@"notifications"] mutableCopy];
    NSMutableDictionary* dic = [[notifications objectAtIndex:dic_index] mutableCopy];
    [dic setObject:[NSNumber numberWithBool:read] forKey:@"read"];
    [notifications replaceObjectAtIndex:dic_index withObject:dic];
    [[NSUserDefaults standardUserDefaults] setObject:notifications forKey:@"notifications"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [CustomFunctions sendNotificationCenter:false name:@"update-menu-icon"];
}

- (unsigned long)defaultsIndex{
    unsigned long index = 0;
    NSMutableArray *notifications = [[[NSUserDefaults standardUserDefaults] objectForKey:@"notifications"] mutableCopy];
    for (NSMutableDictionary* dic in notifications) {
        if ([CustomFunctions stringToUL:[dic valueForKey:@"id"]] == self.ID) return index;
        index++;
    }
    [Log log:@"failed"];
    return -1;
}

@end
