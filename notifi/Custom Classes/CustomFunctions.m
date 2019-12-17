//
//  CustomFunctions.m
//  notifi
//
//  Created by Max Mitchell on 24/01/2018.
//  Copyright © 2018 max mitchell. All rights reserved.
//

#import "CustomFunctions.h"
#import <Sparkle/Sparkle.h>
#import <CocoaLumberjack/CocoaLumberjack.h>
static const DDLogLevel ddLogLevel = DDLogLevelVerbose;

@implementation CustomFunctions

#pragma mark - app
+ (bool)toggleOpenOnStartup{
    if(![self doesAlreadyOpenOnStartup]){
        [self openOnStartup];
        return true;
    }else{
        [self dontOpenOnStartup];
        return false;
    }
}

+ (bool)doesAlreadyOpenOnStartup{
    bool found = NO;
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

+ (void)openOnStartup{
    if(![self doesAlreadyOpenOnStartup]){
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

+ (void)dontOpenOnStartup{
    if([self doesAlreadyOpenOnStartup]){
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

+ (void)onlyOneInstanceOfApp {
    if ([[NSRunningApplication runningApplicationsWithBundleIdentifier:[[NSBundle mainBundle] bundleIdentifier]] count] > 1) {
        DDLogDebug(@"already open app");
        [self quit];
    }
}

+ (void)quit{
    [NSApp terminate:self];
}

#pragma mark - extras
+ (CGFloat)widthOfString:(NSString *)string withFont:(NSFont *)font {
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:font, NSFontAttributeName, nil];
    return [[[NSAttributedString alloc] initWithString:string attributes:attributes] size].width;
}

+ (NSString*)jsonToVal:(NSString*)json key:(NSString*)key{
    NSMutableDictionary* dic = [NSJSONSerialization JSONObjectWithData:[json dataUsingEncoding:NSUTF8StringEncoding] options:0 error:NULL];
    if([dic objectForKey:key]) return [dic objectForKey:key];
    return @"";
}

+ (NSString*)dicToJsonString:(NSDictionary*)dic{
    NSError* error;
    NSData *jd = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:&error];
    if (error) return @"";
    return [[NSString alloc] initWithData:jd encoding:NSUTF8StringEncoding];
}

+ (NSString *)getSystemUUID {
    io_service_t platformExpert = IOServiceGetMatchingService(kIOMasterPortDefault,IOServiceMatching("IOPlatformExpertDevice"));
    if (!platformExpert)
        return nil;
    
    CFTypeRef serialNumberAsCFString = IORegistryEntryCreateCFProperty(platformExpert,CFSTR(kIOPlatformUUIDKey),kCFAllocatorDefault, 0);
    IOObjectRelease(platformExpert);
    if (!serialNumberAsCFString)
        return nil;
    
    return (__bridge NSString *)(serialNumberAsCFString);;
}

+ (void)sendNotificationCenter:(id)message name:(NSString*)name{
    [[NSNotificationCenter defaultCenter] postNotificationName:name object:nil userInfo:message];
}

+ (unsigned long)stringToUL:(NSString*)str{
    return [[[[NSNumberFormatter alloc] init] numberFromString:str] unsignedLongValue];
}

+ (void)copyText:(NSString*)text{
    NSPasteboard *pasteBoard = [NSPasteboard generalPasteboard];
    [pasteBoard declareTypes:[NSArray arrayWithObjects:NSStringPboardType, nil] owner:nil];
    [pasteBoard setString:text forType:NSStringPboardType];
}

+ (NSImage*)setImgOriginalSize:(NSImage*)image{
    NSBitmapImageRep *rep = [NSBitmapImageRep imageRepWithData:[image TIFFRepresentation]];
    NSSize size = NSMakeSize([rep pixelsWide], [rep pixelsHigh]);
    [image setSize:size];
    return image;
}

+ (void)checkForUpdate:(bool)fg{
    if(fg){
        [[SUUpdater sharedUpdater] checkForUpdates:self];
    }else{
        [[SUUpdater sharedUpdater] checkForUpdatesInBackground];
    }
}

@end
