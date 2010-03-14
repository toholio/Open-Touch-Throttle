//
//  LayoutInfoViewController.m
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

#import "LayoutInfoViewController.h"

@implementation LayoutInfoViewController

@synthesize layoutAdapter = _layoutAdapter;

- (void) setLayoutAdapter:(AdapterLoconetOverTCP *)theAdapter {
    // Remove all observations on the previous adapter and dispose of it.
    if ( _layoutAdapter ) {
        [_layoutAdapter removeObserver:self forKeyPath:@"trackPower"];
        [_layoutAdapter removeObserver:self forKeyPath:@"layoutInfo"];
        [_layoutAdapter removeObserver:self forKeyPath:@"loconetOverTCPService"];

        [_layoutAdapter release];
        _layoutAdapter = nil;
    }

    // Assign and start observing the new adapter.
    _layoutAdapter = theAdapter;
    [_layoutAdapter retain];

    [_layoutAdapter addObserver:self forKeyPath:@"trackPower" options:0 context:nil];
    [_layoutAdapter addObserver:self forKeyPath:@"layoutInfo" options:0 context:nil];
    [_layoutAdapter addObserver:self forKeyPath:@"loconetOverTCPService" options:0 context:nil];
}

- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ( object == self.layoutAdapter ) {
        if ( [keyPath isEqualToString:@"trackPower"] ) {
            [powerSwitch setOn:self.layoutAdapter.trackPower animated:YES];

        } else if ( [keyPath isEqualToString:@"layoutInfo"] ) {
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];

        } else if ( [keyPath isEqualToString:@"loconetOverTCPService"] ) {
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
        }
    }
}

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}
*/

// Implement loadView to create a view hierarchy programmatically, without using a nib.
/*
- (void)loadView {
}
*/

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"Layout Details";
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];

	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}

- (void)dealloc {
    if ( _layoutAdapter ) {
        [_layoutAdapter removeObserver:self forKeyPath:@"trackPower"];
        [_layoutAdapter removeObserver:self forKeyPath:@"layoutInfo"];
        [_layoutAdapter removeObserver:self forKeyPath:@"loconetOverTCPService"];
        [_layoutAdapter release];
    }

    if ( powerSwitch ) {
        [powerSwitch release];
    }

    [super dealloc];
}

- (IBAction) powerSwitchChange:(id) sender {
    self.layoutAdapter.trackPower = [powerSwitch isOn];
}

#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ( section == 0 ) {
        return 2;
    } else {
        return 1;
    }
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    static NSString *CellIdentifier = @"Cell";

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }

    // Configure the cell.
    if ( indexPath.section == 0 ) {
        if ( indexPath.row == 0 ) {
            cell.textLabel.text = [self.layoutAdapter.loconetOverTCPService name];

        } else if ( indexPath.row == 1 ) {
            cell.textLabel.text = self.layoutAdapter.layoutInfo;
        }

    } else if ( indexPath.section == 1 ) {
        if ( indexPath.row == 0 ) {
            if ( !powerSwitch ) {
                powerSwitch = [[UISwitch alloc] initWithFrame:CGRectZero];
                [powerSwitch setOn:self.layoutAdapter.trackPower];
                [powerSwitch addTarget:self action:@selector(powerSwitchChange:) forControlEvents:UIControlEventValueChanged];
            }

            [cell addSubview:powerSwitch];
            cell.accessoryView = powerSwitch;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;

            cell.textLabel.text = @"Track Power";
        }
    }

    return cell;
}

@end
