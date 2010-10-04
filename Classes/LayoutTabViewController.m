//
//  LayoutTabViewController.m
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

#import "LayoutTabViewController.h"

@implementation LayoutTabViewController

@synthesize tabBar = _tabBar;
@synthesize selectedViewController = _selectedViewController;
@synthesize layoutAdapter = _layoutAdapter;
@synthesize layoutInfoViewController = _layoutInfoViewController;
@synthesize layoutThrottleViewController = _layoutThrottleViewController;
@synthesize layoutInfoViewTabBarItem = _layoutInfoViewTabBarItem;
@synthesize layoutThrottleViewTabBarItem = _layoutThrottleViewTabBarItem;

// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil layoutAdapter:(AdapterLoconetOverTCP *)theLayoutAdapter {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {

        self.layoutAdapter = theLayoutAdapter;
        self.title = self.layoutAdapter.name;

        // Info view.
        self.layoutInfoViewController = [[LayoutInfoViewController alloc] initWithNibName:@"LayoutInfo" bundle:nil layoutAdapter:self.layoutAdapter];
        [self.layoutInfoViewController release];

        self.layoutInfoViewTabBarItem = [[UITabBarItem alloc] initWithTitle:@"Info" image:nil tag:0];
        [self.layoutInfoViewTabBarItem release];

        // Throttle view.
        self.layoutThrottleViewController = [[LayoutThrottleViewController alloc] initWithNibName:@"LayoutThrottleView" bundle:nil layoutAdapter:self.layoutAdapter];
        [self.layoutThrottleViewController release];

        self.layoutThrottleViewTabBarItem = [[UITabBarItem alloc] initWithTitle:@"Throttle" image:nil tag:0];
        [self.layoutThrottleViewTabBarItem release];
    }
    return self;
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];

    [self.tabBar setItems:[[[NSArray alloc] initWithObjects:self.layoutInfoViewTabBarItem, self.layoutThrottleViewTabBarItem, nil] autorelease] animated:NO];
    self.tabBar.selectedItem = self.layoutInfoViewTabBarItem;

    // The first time around we need to make sure the selection handler ran as expected.
    [self tabBar:self.tabBar didSelectItem:self.layoutInfoViewTabBarItem];
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];

    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void) viewDidAppear:(BOOL)animated {
    // Start watching for fatal errors.
    [self.layoutAdapter addObserver:self forKeyPath:@"fatalError" options:0 context:nil];

    // Check if one has already happened.
    if ( self.layoutAdapter.fatalError ) {
        // We need to make sure this is called so observers are removed correctly.
        [self viewWillDisappear:animated];

        // Actually do something.
        [self handleFatalErrorWithInitialConnection:YES];
    }
}

- (void) viewWillDisappear:(BOOL)animated {
    [self.layoutAdapter removeObserver:self forKeyPath:@"fatalError"];

    // Subviews don't seem to get this automatically under version 3.0 of the SDK but they _do_ get it when
    // the applications closes. The only way to tell which is happening seems to be the animation.
    if ( self.selectedViewController && animated ) {
        [self.selectedViewController viewWillDisappear:animated];
    }
}

- (void) viewDidDisappear:(BOOL)animated {
    [self.selectedViewController viewDidDisappear:animated];
    [self.layoutAdapter cleanUp];
}

- (void)dealloc {
    [_layoutInfoViewController release];
    [_selectedViewController release];
    [_tabBar release];
    [_layoutInfoViewTabBarItem release];
    [_layoutThrottleViewTabBarItem release];
    [_layoutThrottleViewController release];

    [_layoutAdapter release];

    [super dealloc];
}

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item
{
    UIViewController *nextViewController = nil;

    if ( item == self.layoutInfoViewTabBarItem ) {
        nextViewController = self.layoutInfoViewController;

    } else if ( item == self.layoutThrottleViewTabBarItem) {
        nextViewController = self.layoutThrottleViewController;
    }

    // Make sure the user has selected a valid and different item.
    if ( nextViewController && self.selectedViewController != nextViewController ) {
        if ( self.selectedViewController ) {
            [self.selectedViewController viewWillDisappear:NO];
            [self.selectedViewController.view removeFromSuperview];
            [self.selectedViewController viewDidDisappear:NO];
        }

        [nextViewController viewWillAppear:NO];
        [self.view addSubview:nextViewController.view];
        [nextViewController viewDidAppear:NO];

        self.selectedViewController = nextViewController;
    }
}

#pragma mark -
#pragma mark Special layout adapter handling

- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ( object == self.layoutAdapter ) {
        if ( [keyPath isEqualToString:@"fatalError"] ) {
            [self handleFatalErrorWithInitialConnection:NO];
        }
    }
}

- (void) handleFatalErrorWithInitialConnection:(BOOL) initialConnection {
    UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"Connection Error" message:@"" delegate:self cancelButtonTitle:nil otherButtonTitles:@"Dismiss", nil];

    if ( initialConnection ) {
        errorAlert.message = @"A connection could not be established with the server.";

    } else {
        errorAlert.message = @"The connection to the server was lost.";
    }

    [errorAlert show];
    [errorAlert autorelease];

    [self.navigationController popToRootViewControllerAnimated:YES];
}

@end
