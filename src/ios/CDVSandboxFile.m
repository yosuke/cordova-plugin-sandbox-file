/*
 Licensed to the Apache Software Foundation (ASF) under one
 or more contributor license agreements.  See the NOTICE file
 distributed with this work for additional information
 regarding copyright ownership.  The ASF licenses this file
 to you under the Apache License, Version 2.0 (the
 "License"); you may not use this file except in compliance
 with the License.  You may obtain a copy of the License at

 http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing,
 software distributed under the License is distributed on an
 "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 KIND, either express or implied.  See the License for the
 specific language governing permissions and limitations
 under the License.
 */

/*
 Written by Yosuke Matsusaka

 Most of the code are from:
  https://github.com/apache/cordova-plugin-file/blob/master/src/ios/CDVFile.m
 */

#import <Cordova/CDV.h>
#import "CDVSandboxFile.h"
#import <objc/message.h>

CDVSandboxFile *sandboxFilePlugin = nil;

static NSString* toBase64(NSData* data) {
    SEL s1 = NSSelectorFromString(@"base64EncodedString");
    SEL s2 = NSSelectorFromString(@"base64EncodedStringWithOptions:");
    
    if ([data respondsToSelector:s1]) {
        NSString* (*func)(id, SEL) = (void *)[data methodForSelector:s1];
        return func(data, s1);
    } else if ([data respondsToSelector:s2]) {
        NSString* (*func)(id, SEL, NSUInteger) = (void *)[data methodForSelector:s2];
        return func(data, s2, 0);
    } else {
        return nil;
    }
}

@implementation CDVSandboxFile

- (void)pluginInitialize
{
    sandboxFilePlugin = self;
}

/* read and return file data
 * IN:
 * NSArray* arguments
 *	0 - NSString* fullPath
 *	1 - NSString* encoding
 */
- (void)readAsText:(CDVInvokedUrlCommand*)command
{
    // arguments
    NSURL *decodedURL = [NSURL URLWithString:command.arguments[0]];
    NSString* encoding = [command argumentAtIndex:1];

    // TODO: implement
    if ([@"UTF-8" caseInsensitiveCompare : encoding] != NSOrderedSame) {
        NSLog(@"Only UTF-8 encodings are currently supported by readAsText");
        CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_IO_EXCEPTION];
        [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
        return;
    }

    __weak CDVSandboxFile* weakSelf = self;
    [self.commandDelegate runInBackground:^ {
        CDVPluginResult* result = nil;
        NSData* data;
        if ([decodedURL startAccessingSecurityScopedResource]) {
            NSFileHandle* file = [NSFileHandle fileHandleForReadingFromURL:decodedURL error:nil];
            data = [file readDataToEndOfFile];
            [file closeFile];
            [decodedURL stopAccessingSecurityScopedResource];
            if (data != nil) {
                NSString* str = [[NSString alloc] initWithBytesNoCopy:(void*)[data bytes] length:[data length] encoding:NSUTF8StringEncoding freeWhenDone:NO];
                // Check that UTF8 conversion did not fail.
                if (str != nil) {
                    result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:str];
                    result.associatedObject = data;
                }
            }
            if (result == nil) {
                result = [CDVPluginResult resultWithStatus:CDVCommandStatus_IO_EXCEPTION];
            }

            [weakSelf.commandDelegate sendPluginResult:result callbackId:command.callbackId];
        }
    }];
}

/* Read content of text file and return as base64 encoded data url.
 * IN:
 * NSArray* arguments
 *	0 - NSString* fullPath
 */

- (void)readAsDataURL:(CDVInvokedUrlCommand*)command
{
    NSURL *decodedURL = [NSURL URLWithString:command.arguments[0]];

    __weak CDVSandboxFile* weakSelf = self;
    [self.commandDelegate runInBackground:^ {
        CDVPluginResult* result = nil;
        NSData* data;
        if ([decodedURL startAccessingSecurityScopedResource]) {
            NSFileHandle* file = [NSFileHandle fileHandleForReadingFromURL:decodedURL error:nil];
            data = [file readDataToEndOfFile];
            [file closeFile];
            [decodedURL stopAccessingSecurityScopedResource];
        }
        if (data != nil) {
            NSString* b64Str = toBase64(data);
            NSString* output = [NSString stringWithFormat:@"data:application/octet-stream;base64,%@", b64Str];
            result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:output];
        } else {
            result = [CDVPluginResult resultWithStatus:CDVCommandStatus_IO_EXCEPTION];
        }

        [weakSelf.commandDelegate sendPluginResult:result callbackId:command.callbackId];
    }];
}

/* Read content of text file and return as an arraybuffer
 * IN:
 * NSArray* arguments
 *	0 - NSString* fullPath
 */

- (void)readAsArrayBuffer:(CDVInvokedUrlCommand*)command
{
    NSURL *decodedURL = [NSURL URLWithString:command.arguments[0]];

    __weak CDVSandboxFile* weakSelf = self;
    [self.commandDelegate runInBackground:^ {
        CDVPluginResult* result = nil;
        NSData* data;
        if ([decodedURL startAccessingSecurityScopedResource]) {
            NSFileHandle* file = [NSFileHandle fileHandleForReadingFromURL:decodedURL error:nil];
            data = [file readDataToEndOfFile];
            [file closeFile];
            [decodedURL stopAccessingSecurityScopedResource];
        }
        if (data != nil) {
            result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsArrayBuffer:data];
        } else {
            result = [CDVPluginResult resultWithStatus:CDVCommandStatus_IO_EXCEPTION];
        }

        [weakSelf.commandDelegate sendPluginResult:result callbackId:command.callbackId];
    }];
}

@end
