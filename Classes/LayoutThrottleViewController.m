//
//  LayoutTrottleViewController.m
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

#import "LayoutThrottleViewController.h"

@implementation LayoutThrottleViewController

@synthesize layoutAdapter = _layoutAdapter;
@synthesize layoutThrottle = _layoutThrottle;
@synthesize speedSlider = _speedSlider;
@synthesize directionControl = _directionControl;

// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil layoutAdapter:(AdapterLoconetOverTCP *)theLayoutAdapter {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        self.layoutAdapter = theLayoutAdapter;

        self.layoutThrottle = [self.layoutAdapter createThrottle];
    }
    return self;
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];

    // Release any cached data, images, etc that aren't in use.
}

- (void)dealloc {
    [_layoutAdapter release];

    [super dealloc];
}

- (IBAction) didChangeSpeed:(id) sender {
    self.layoutThrottle.locoSpeed = self.speedSlider.value;
}

- (IBAction) didChangeDirection:(id) sender {
    self.layoutThrottle.locoForward = self.directionControl.selectedSegmentIndex;
}

- (void) viewWillAppear:(BOOL) animated {
    [self.layoutThrottle addObserver:self forKeyPath:@"locoSpeed" options:0 context:nil];
    [self.layoutThrottle addObserver:self forKeyPath:@"locoDirection" options:0 context:nil];
}

- (void) viewWillDisappear:(BOOL)animated {
    [self.layoutThrottle removeObserver:self forKeyPath:@"locoSpeed"];
    [self.layoutThrottle removeObserver:self forKeyPath:@"locoDirection"];
}

- (void) viewDidAppear:(BOOL)animated {
    // Make sure the power switch is always accurate at first appearance.
    self.directionControl.selectedSegmentIndex = self.layoutThrottle.locoForward ? 1 : 0;
    [self.speedSlider setValue:self.layoutThrottle.locoSpeed animated:YES];

}

- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ( object == self.layoutThrottle ) {
        if ( keyPath == @"locoSpeed" ) {
            [self.speedSlider setValue:self.layoutThrottle.locoSpeed animated:YES];

        } else if ( keyPath == @"locoForward" ) {
            self.directionControl.selectedSegmentIndex = self.layoutThrottle.locoForward ? 1 : 0;

        }
    }
}

@end
