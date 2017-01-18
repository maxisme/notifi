/*
 * Copyright (c) 2013 Kyle W. Banks
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *  http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

//
//  AsyncImageDownloader.m
//
//  Created by Kyle Banks on 2012-11-29.
//  Modified by Nicolas Schteinschraber 2013-05-30
//

#ifdef __OBJC__
#import <AppKit/AppKit.h>
#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#endif

#import "AsyncImageDownloader.h"

@implementation AsyncImageDownloader

@synthesize mediaURL, fileURL;

-(id)initWithMediaURL:(NSString *)theMediaURL successBlock:(void (^)(NSImage *image))success failBlock:(void(^)(NSError *error))fail
{
    self = [super init];
    
    if(self)
    {
        [self setMediaURL:theMediaURL];
        [self setFileURL:nil];
        successCallback = success;
        failCallback = fail;
    }
    
    return self;
}
-(id)initWithFileURL:(NSString *)theFileURL successBlock:(void (^)(NSData *data))success failBlock:(void(^)(NSError *error))fail
{
    self = [super init];
    
    if(self)
    {
        [self setMediaURL:nil];
        [self setFileURL:theFileURL];
        successCallbackFile = success;
        failCallback = fail;
    }
    
    return self;
}

//Perform the actual download
-(void)startDownload
{
    fileData = [[NSMutableData alloc] init];
    
    NSURLRequest *request = nil;
    if (fileURL)
        request = [NSURLRequest requestWithURL:[NSURL URLWithString:fileURL]];
    else
        request = [NSURLRequest requestWithURL:[NSURL URLWithString:mediaURL]];

    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES];
    if(!connection)
    {
        failCallback([NSError errorWithDomain:@"Failed to create connection" code:0 userInfo:nil]);
    }
}

#pragma mark NSURLConnection Delegate
-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    failCallback(error);
}
-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    if([response respondsToSelector:@selector(statusCode)])
    {
        long statusCode = [((NSHTTPURLResponse *)response) statusCode];
        if (statusCode >= 400)
        {
            [connection cancel];
            failCallback([NSError errorWithDomain:@"Image download failed due to bad server response" code:0 userInfo:nil]);
        }
    }
}
-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [fileData appendData:data];
}
-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{

    if(fileData == nil)
    {
        failCallback([NSError errorWithDomain:@"No data received" code:0 userInfo:nil]);
    }
    else
    {
        if (fileURL) {
            successCallbackFile(fileData);
        } else {
            NSImage *image = [[NSImage alloc] initWithData:fileData];
            successCallback(image);
        }
    }    
}

@end
