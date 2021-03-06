//
//  LayoutInfoViewController.h
//  Open-Touch-Throttle
//
//  Created by Tobin Richard on 14/03/10.
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

@interface LayoutInfoViewController : UITableViewController {
@private
    UISwitch *_powerSwitch;

    AdapterLoconetOverTCP *_layoutAdapter;
}

@property (nonatomic, readonly, retain) AdapterLoconetOverTCP *layoutAdapter;
@property (nonatomic, retain) UISwitch *powerSwitch;

- (IBAction) powerSwitchChange:(id) sender;
- (id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil layoutAdapter:(AdapterLoconetOverTCP *)adapter;

@end
