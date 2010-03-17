//
//  RootViewController.m
//  Open-Touch-Throttle
//
//  Created by Tobin Richard on 13/03/10.
//
// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; version 3 of the License.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.

#import "RootViewController.h"
#import "LayoutInfoViewController.h"
#import "AddManualLayoutViewController.h"

@interface RootViewController ()

@property (nonatomic, retain) NSMutableArray *servicesLocoNetArray;
@property (nonatomic, retain) NSNetServiceBrowser *serviceLocoNetBrowser;

@end

@implementation RootViewController

@synthesize layoutTableView = _layoutTableView;
@synthesize layoutAdapter = _layoutAdapter;

@synthesize servicesLocoNetArray = _servicesLocoNetArray;
@synthesize serviceLocoNetBrowser = _serviceLocoNetBrowser;


- (void)viewDidLoad {
    [super viewDidLoad];

    self.navigationItem.leftBarButtonItem = self.editButtonItem;
    self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addManualLayout:)] autorelease];

    self.title = @"Layouts";

    self.servicesLocoNetArray = [[NSMutableArray alloc] init];
    [self.servicesLocoNetArray release];

    self.navigationController.delegate = self;
}

/*
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}
*/
/*
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
*/
/*
- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
}
*/
/*
- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
}
*/

/*
 // Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	// Return YES for supported orientations.
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
 */

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];

	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release anything that can be recreated in viewDidLoad or on demand.
	// e.g. self.myOutlet = nil;
}

- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ( object == self.layoutAdapter ) {
        if ( [keyPath isEqualToString:@"fatalError"] ) {
            if ( self.layoutAdapter.fatalError ) {
                [self.navigationController popToRootViewControllerAnimated:YES];
                UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"Connection Lost"
                                                                     message:@"The connection to the layout has been lost."
                                                                    delegate:nil
                                                           cancelButtonTitle:@"Dismiss"
                                                           otherButtonTitles:nil];
                [errorAlert show];
                [errorAlert autorelease];
            }
        }
    }
}

- (void)dealloc {
    [_servicesLocoNetArray release];
    [_serviceLocoNetBrowser release];
    [_layoutAdapter release];
    [super dealloc];
}

#pragma mark Net Service Browser methods

- (void) lookForLocoNetOverTCP {
    self.serviceLocoNetBrowser = [[NSNetServiceBrowser alloc] init];
    [self.serviceLocoNetBrowser release];
    [self.serviceLocoNetBrowser setDelegate:self];
    [self.serviceLocoNetBrowser searchForServicesOfType:@"_loconetovertcpserver._tcp" inDomain:@"local."];
}

/*
- (void)netServiceBrowserWillSearch:(NSNetServiceBrowser *)browser
{
}
*/

/*
- (void)netServiceBrowserDidStopSearch:(NSNetServiceBrowser *)browser
{
}
*/

- (void)netServiceBrowser:(NSNetServiceBrowser *)browse
             didNotSearch:(NSDictionary *)errorDict
{
    UIAlertView *failedAlert = [[UIAlertView alloc] initWithTitle:@"Layout Detection Failed"
                                                          message:@"A network error occured while looking for layouts."
                                                         delegate:self
                                                cancelButtonTitle:@""
                                                otherButtonTitles:@"Dismiss", nil];
    [failedAlert show];
    [failedAlert release];
}

- (void)netServiceBrowser:(NSNetServiceBrowser *)browser
           didFindService:(NSNetService *)aNetService
               moreComing:(BOOL)moreComing
{
    [self.servicesLocoNetArray addObject:aNetService];
    if ( !moreComing ) {
        [self.layoutTableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
    }
}

- (void)netServiceBrowser:(NSNetServiceBrowser *)browser
         didRemoveService:(NSNetService *)aNetService
               moreComing:(BOOL)moreComing
{
    [self.servicesLocoNetArray removeObject:aNetService];
    if ( !moreComing ) {
        [self.layoutTableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
    }
}

#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ( section == 0 ) {
        return [self.servicesLocoNetArray count];
    } else {
        return 0;
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
        cell.textLabel.text = [[self.servicesLocoNetArray objectAtIndex:indexPath.row] name];
    }

    return cell;
}

// Override to support row selection in the table view.
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    AdapterLoconetOverTCP *adapter;

    // Create a layout adapter of the needed type.
    if ( indexPath.section == 0 ) {
        adapter = [[AdapterLoconetOverTCP alloc] initWithLocoNetOverTCPService:[self.servicesLocoNetArray objectAtIndex:indexPath.row]];

        LayoutInfoViewController *layoutInfoViewController = [[LayoutInfoViewController alloc] initWithNibName:@"LayoutInfo" bundle:nil layoutAdapter:adapter];
        [self.navigationController pushViewController:layoutInfoViewController animated:YES];

        self.layoutAdapter = adapter;
        [adapter addObserver:self forKeyPath:@"fatalError" options:0 context:nil];

        [layoutInfoViewController release];
        [adapter release];

        // Now stop the service browser while the other view is in use.
        [self.serviceLocoNetBrowser stop];
        self.serviceLocoNetBrowser = nil;
        [self.servicesLocoNetArray removeAllObjects];
        [self.layoutTableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
    }
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    if ( indexPath.section == 0 ) {
        return NO;
    } else {
        return YES;
    }
}


/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {

    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source.
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }
}
*/


/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/


/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark Manual layout methods.

- (IBAction) addManualLayout:(id) sender {
    AddManualLayoutViewController *addManualLayoutViewController = [[AddManualLayoutViewController alloc] initWithNibName:@"AddManualLayoutView" bundle:nil];
    UINavigationController *modelNavController = [[UINavigationController alloc] initWithRootViewController:addManualLayoutViewController];

    [self.navigationController presentModalViewController:modelNavController animated:YES];
    [addManualLayoutViewController release];
    [modelNavController release];
}

#pragma mark Navigation Controller methods.

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if ( navigationController == self.navigationController ) {
        if ( viewController == self ) {
            // The layout adapter is no longer needed.
            [self.layoutAdapter removeObserver:self forKeyPath:@"fatalError"];
            self.layoutAdapter = nil;

            // We must have returned from the layout views. Start looking for layouts again.
            [self lookForLocoNetOverTCP];
        }
    }
}

@end

