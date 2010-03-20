//
//  LayoutTabViewController.h
//  Open-Touch-Throttle
//
//  Created by Tobin Richard on 20/03/10.
//
// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; version 3 of the License.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.

#import <UIKit/UIKit.h>
#import "AdapterLoconetOverTCP.h"
#import "LayoutInfoViewController.h"
#import "LayoutThrottleViewController.h"

@interface LayoutTabViewController : UIViewController <UITabBarDelegate> {
@private
    UITabBar *_tabBar;
    UIViewController *_selectedViewController;
    AdapterLoconetOverTCP *_layoutAdapter;
    LayoutInfoViewController *_layoutInfoViewController;
    LayoutThrottleViewController *_layoutThrottleViewController;
    UITabBarItem *_layoutInfoViewTabBarItem;
    UITabBarItem *_layoutThrottleViewTabBarItem;
}

@property (nonatomic, retain) IBOutlet UITabBar *tabBar;
@property (nonatomic, retain) UIViewController *selectedViewController;
@property (nonatomic, retain) AdapterLoconetOverTCP *layoutAdapter;
@property (nonatomic, retain) LayoutInfoViewController *layoutInfoViewController;
@property (nonatomic, retain) LayoutThrottleViewController *layoutThrottleViewController;
@property (nonatomic, retain) UITabBarItem *layoutInfoViewTabBarItem;
@property (nonatomic, retain) UITabBarItem *layoutThrottleViewTabBarItem;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil layoutAdapter:(AdapterLoconetOverTCP *)theLayoutAdapter;
- (void) handleFatalErrorWithInitialConnection:(BOOL) initialConnection;

@end
