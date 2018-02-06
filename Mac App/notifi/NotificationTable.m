//
//  NotificationTable.m
//  notifi
//
//  Created by Max Mitchell on 21/01/2018.
//  Copyright © 2018 max mitchell. All rights reserved.
//

#import "NotificationTable.h"
#import "Notification.h"
#import "NotificationLabel.h"

@implementation NotificationTable
- (BOOL)selectionShouldChangeInTableView:(NSTableView *)aTableView
{
    return NO;
}

- (BOOL)tableView:(NSTableView *)aTableView shouldSelectRow:(NSInteger)rowIndex
{
    return NO;
}
@end
