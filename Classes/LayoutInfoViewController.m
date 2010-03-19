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

// Make the layoutAdapter property readwrite.
@interface LayoutInfoViewController ()

@property (nonatomic, retain) AdapterLoconetOverTCP *layoutAdapter;

@end

@implementation LayoutInfoViewController

@synthesize layoutAdapter = _layoutAdapter;
@synthesize powerSwitch = _powerSwitch;

- (id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil layoutAdapter:(AdapterLoconetOverTCP *)adapter {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];

    if ( self ) {
        self.layoutAdapter = adapter;
    }

    return self;
}


- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ( object == self.layoutAdapter ) {
        if ( [keyPath isEqualToString:@"trackPower"] ) {
            [self.powerSwitch setOn:self.layoutAdapter.trackPower animated:YES];

        } else if ( [keyPath isEqualToString:@"layoutInfo"] ) {
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];

        } else if ( [keyPath isEqualToString:@"loconetOverTCPService"] ) {
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];

        } else if ( [keyPath isEqualToString:@"fatalError"] ) {
            [self handleFatalErrorWithInitialConnection:NO];
        }
    }
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"Layout Details";
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

- (void)dealloc {
    [_layoutAdapter release];
    [_powerSwitch release];

    [super dealloc];
}

- (IBAction) powerSwitchChange:(id) sender {
    self.layoutAdapter.trackPower = [self.powerSwitch isOn];
}

- (void) viewDidAppear:(BOOL)animated {
    // Start watching for fatal errors.
    [self.layoutAdapter addObserver:self forKeyPath:@"fatalError" options:0 context:nil];

    // Check if one has already happened.
    if ( self.layoutAdapter.fatalError ) {
        [self handleFatalErrorWithInitialConnection:YES];
    }
}

- (void) viewWillAppear:(BOOL) animated {
    [self.layoutAdapter addObserver:self forKeyPath:@"trackPower" options:0 context:nil];
    [self.layoutAdapter addObserver:self forKeyPath:@"layoutInfo" options:0 context:nil];
    [self.layoutAdapter addObserver:self forKeyPath:@"loconetOverTCPService" options:0 context:nil];
}

- (void) viewWillDisappear:(BOOL)animated {
    [self.layoutAdapter removeObserver:self forKeyPath:@"fatalError"];

    [self.layoutAdapter removeObserver:self forKeyPath:@"trackPower"];
    [self.layoutAdapter removeObserver:self forKeyPath:@"layoutInfo"];
    [self.layoutAdapter removeObserver:self forKeyPath:@"loconetOverTCPService"];
}

#pragma mark -
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
            cell.textLabel.text = self.layoutAdapter.name;

        } else if ( indexPath.row == 1 ) {
            cell.textLabel.text = self.layoutAdapter.layoutInfo;
        }

    } else if ( indexPath.section == 1 ) {
        if ( indexPath.row == 0 ) {
            if ( !self.powerSwitch ) {
                self.powerSwitch = [[UISwitch alloc] initWithFrame:CGRectZero];
                [self.powerSwitch release];
                [self.powerSwitch setOn:self.layoutAdapter.trackPower];
                [self.powerSwitch addTarget:self action:@selector(powerSwitchChange:) forControlEvents:UIControlEventValueChanged];
            }

            [cell addSubview:self.powerSwitch];
            cell.accessoryView = self.powerSwitch;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;

            cell.textLabel.text = @"Track Power";
        }
    }

    return cell;
}

#pragma mark -
#pragma mark Special layout adapter handling

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
