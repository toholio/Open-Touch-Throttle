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
#import "AdapterLoconetOverTCP.h"
#import "LayoutInfoViewController.h"

@implementation RootViewController

@synthesize layoutTableView;

- (void)viewDidLoad {
    [super viewDidLoad];

    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;

    _servicesLocoNetArray = [[NSMutableArray alloc] init];

    _serviceLocoNetBrowser = [[NSNetServiceBrowser alloc] init];
    [_serviceLocoNetBrowser setDelegate:self];
    [_serviceLocoNetBrowser searchForServicesOfType:@"_loconetovertcpserver._tcp" inDomain:@"local."];
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

#pragma mark Net Service Browser methods
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
    [_servicesLocoNetArray addObject:aNetService];
    if ( !moreComing ) {
        [layoutTableView reloadData];
    }
}

- (void)netServiceBrowser:(NSNetServiceBrowser *)browser
         didRemoveService:(NSNetService *)aNetService
               moreComing:(BOOL)moreComing
{
    [_servicesLocoNetArray removeObject:aNetService];
    if ( !moreComing ) {
        [layoutTableView reloadData];
    }
}

#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ( section == 0 ) {
        return [_servicesLocoNetArray count];
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
        cell.textLabel.text = [[_servicesLocoNetArray objectAtIndex:indexPath.row] name];
    }

    return cell;
}

// Override to support row selection in the table view.
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    AdapterLoconetOverTCP *adapter;

    // Create a layout adapter of the needed type.
    if ( indexPath.section == 0 ) {
        adapter = [[AdapterLoconetOverTCP alloc] initWithLocoNetOverTCPService:[_servicesLocoNetArray objectAtIndex:indexPath.row]];

        LayoutInfoViewController *layoutInfoViewController = [[LayoutInfoViewController alloc] initWithNibName:@"LayoutInfo" bundle:nil];
        layoutInfoViewController.layoutAdapter = adapter;
        [self.navigationController pushViewController:layoutInfoViewController animated:YES];

        [layoutInfoViewController release];
        [adapter release];
    }
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/


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


- (void)dealloc {
    [_servicesLocoNetArray release];
    [_serviceLocoNetBrowser release];
    [super dealloc];
}


@end

