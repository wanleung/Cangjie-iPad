//
//  CangjieAppDelegate.h
//  Cangjie
//
//  Created by Wong Wan Leung on 31/08/2010.
/*
   Copyright 2010 Wan Leung Wong (wanleungwong at gmail dot com)
   http://www.wanleung.com

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
*/

#import <UIKit/UIKit.h>

@class CangjieViewController;

@interface CangjieAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    CangjieViewController *viewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet CangjieViewController *viewController;

@end

