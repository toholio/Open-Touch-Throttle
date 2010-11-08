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
#import "AdapterThrottleLoconetOverTCP.h"

@interface LayoutThrottleViewController : UIViewController {
@private
    AdapterLoconetOverTCP *_layoutAdapter;
    AdapterThrottleLoconetOverTCP *_layoutThrottle;
    UISlider *_speedSlider;
    UISegmentedControl *_directionControl;
}

@property (nonatomic, retain) AdapterLoconetOverTCP *layoutAdapter;
@property (nonatomic, retain) AdapterThrottleLoconetOverTCP *layoutThrottle;
@property (nonatomic, retain) IBOutlet UISlider *speedSlider;
@property (nonatomic, retain) IBOutlet UISegmentedControl *directionControl;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil layoutAdapter:(AdapterLoconetOverTCP *)theLayoutAdapter;
- (IBAction) didChangeSpeed:(id) sender;
- (IBAction) didChangeDirection:(id) sender;

- (void) reportError;

@end
