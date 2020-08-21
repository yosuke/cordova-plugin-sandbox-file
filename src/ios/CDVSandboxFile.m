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
 https://github.com/apache/cordova-ios/blob/master/CordovaLib/Classes/Private/Plugins/CDVHandleOpenURL/CDVHandleOpenURL.m
 and:
 https://github.com/apache/cordova-plugin-file/blob/master/src/ios/CDVFile.m
 */

#import <Cordova/CDV.h>
#import "CDVSandboxFile.h"

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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationLaunchedWithUrl:) name:CDVPluginHandleOpenURLNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationPageDidLoad:) name:CDVPageDidLoadNotification object:nil];
}

- (void)applicationLaunchedWithUrl:(NSNotification*)notification
{
    NSURL* url = [notification object];

    BOOL success = [url startAccessingSecurityScopedResource];
    self.data = [NSData dataWithContentsOfURL:url];
    if (success) {
        [url stopAccessingSecurityScopedResource];
    }

    // warm-start handler
    if (self.pageLoaded) {
        [self processOpenUrl:self.data pageLoaded:YES];
        self.data = nil;
    }
}

- (void)applicationPageDidLoad:(NSNotification*)notification
{
    // cold-start handler

    self.pageLoaded = YES;

    if (self.data) {
        [self processOpenUrl:self.data pageLoaded:YES];
        self.data = nil;
    }
}

- (void)processOpenUrl:(NSData*)data pageLoaded:(BOOL)pageLoaded
{
    __weak __typeof(self) weakSelf = self;

    dispatch_block_t handleSandboxFile = ^(void) {
        // calls into javascript global function 'handleOpenURL'
        NSString* jsString = [NSString stringWithFormat:@"document.addEventListener('deviceready',function(){if (typeof handleSandboxFile === 'function') { handleSandboxFile(window.atob(\"%@\"));}});", toBase64(data)];

        [weakSelf.webViewEngine evaluateJavaScript:jsString completionHandler:nil];
    };

    if (!pageLoaded) {
        NSString* jsString = @"document.readystate";
        [self.webViewEngine evaluateJavaScript:jsString
                             completionHandler:^(id object, NSError* error) {
            if ((error == nil) && [object isKindOfClass:[NSString class]]) {
                NSString* readyState = (NSString*)object;
                BOOL ready = [readyState isEqualToString:@"loaded"] || [readyState isEqualToString:@"complete"];
                if (ready) {
                    handleSandboxFile();
                } else {
                    self.data = data;
                }
            }
        }];
    } else {
        handleSandboxFile();
    }
}

@end
