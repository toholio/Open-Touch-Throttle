//
//  LayoutTrottleViewController.h
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

@interface LayoutThrottleViewController : UIViewController {
@private
    AdapterLoconetOverTCP *_layoutAdapter;
}

@property (nonatomic, retain) AdapterLoconetOverTCP *layoutAdapter;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil layoutAdapter:(AdapterLoconetOverTCP *)theLayoutAdapter;

@end
