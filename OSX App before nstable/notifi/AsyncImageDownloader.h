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
//  AsyncImageDownloader.h
//
//  Created by Kyle Banks on 2012-11-29.
//  Modified by Nicolas Schteinschraber 2013-05-30
//

#import <CoreData/CoreData.h>

#import <Foundation/Foundation.h>

@interface AsyncImageDownloader : NSObject <NSURLConnectionDelegate>
{
    NSMutableData *fileData;
    
    //Callback blocks
    void (^successCallbackFile)(NSData *data);
    void (^successCallback)(NSImage *image);
    void (^failCallback)(NSError *error);
}

@property NSString *mediaURL;
@property NSString *fileURL;

-(id)initWithMediaURL:(NSString *)theMediaURL successBlock:(void (^)(NSImage *image))success failBlock:(void(^)(NSError *error))fail;

-(id)initWithFileURL:(NSString *)theFileURL successBlock:(void (^)(NSData *data))success failBlock:(void(^)(NSError *error))fail;

-(void)startDownload;

@end
