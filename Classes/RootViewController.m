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
#import "LayoutTabViewController.h"
#import "AddManualLayoutViewController.h"
#import "ManualLayout.h"

@interface RootViewController ()

@property (nonatomic, retain) NSMutableArray *servicesLocoNetArray;
@property (nonatomic, retain) NSNetServiceBrowser *serviceLocoNetBrowser;

@end

@implementation RootViewController

@synthesize layoutTableView = _layoutTableView;
@synthesize layoutAdapter = _layoutAdapter;

@synthesize servicesLocoNetArray = _servicesLocoNetArray;
@synthesize serviceLocoNetBrowser = _serviceLocoNetBrowser;

@synthesize fetchedResultsController = _fetchedResultsController;
@synthesize managedObjectContext = _managedObjectContext;

- (void)viewDidLoad {
    [super viewDidLoad];

    self.navigationItem.leftBarButtonItem = self.editButtonItem;
    self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addManualLayout:)] autorelease];

    self.title = @"Layouts";

    self.servicesLocoNetArray = [[NSMutableArray alloc] init];
    [self.servicesLocoNetArray release];

    self.navigationController.delegate = self;

    NSError *error = nil;
	if (![[self fetchedResultsController] performFetch:&error]) {
		/*
		 Replace this implementation with code to handle the error appropriately.

		 abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
		 */
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		abort();
	}
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];

	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release anything that can be recreated in viewDidLoad or on demand.
	// e.g. self.myOutlet = nil;
}

- (void)dealloc {
    [_fetchedResultsController release];
	[_managedObjectContext release];

    [_servicesLocoNetArray release];
    [_serviceLocoNetBrowser release];
    [_layoutAdapter release];
    [super dealloc];
}

- (void) connectAdapterToLayoutName:(NSString *)name hostName:(NSString *)hostName port:(NSUInteger) port {
    [self.layoutAdapter connectToLayoutName:name hostName:hostName port:port];

    LayoutTabViewController *layoutTabViewController = [[LayoutTabViewController alloc] initWithNibName:@"LayoutTabView" bundle:nil layoutAdapter:self.layoutAdapter];
    [self.navigationController pushViewController:layoutTabViewController animated:YES];
    [layoutTabViewController release];

    // Now stop the service browser while the other view is in use.
    [self.serviceLocoNetBrowser stop];
    self.serviceLocoNetBrowser = nil;
    [self.servicesLocoNetArray removeAllObjects];
    [self.layoutTableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
}

#pragma mark -
#pragma mark Net Service Browser methods

- (void) lookForLocoNetOverTCP {
    self.serviceLocoNetBrowser = [[NSNetServiceBrowser alloc] init];
    [self.serviceLocoNetBrowser release];
    [self.serviceLocoNetBrowser setDelegate:self];
    [self.serviceLocoNetBrowser searchForServicesOfType:@"_loconetovertcpserver._tcp" inDomain:@"local."];
}

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

#pragma mark -
#pragma mark Net Service mathods.

- (void)netServiceDidResolveAddress:(NSNetService *)netService {
    [self connectAdapterToLayoutName:[netService name] hostName:[netService hostName] port:[netService port]];
}

- (void)netService:(NSNetService *)netService didNotResolve:(NSDictionary *)errorDict {
    self.layoutAdapter = nil;

    UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"Connection Failed"
                                                         message:@"Could not get the connection information from the LocoNetOverTCP server."
                                                        delegate:self
                                               cancelButtonTitle:@"Dismiss"
                                               otherButtonTitles:nil];
    [errorAlert autorelease];
    [errorAlert show];
}

#pragma mark -
#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:0];
    if ( [sectionInfo numberOfObjects] > 0 ) {
        return 2;
    } else {
        return 1;
    }
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ( section == 0 ) {
        return [self.servicesLocoNetArray count];

    } else if ( section == 1 ) {
        id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:0];
        return [sectionInfo numberOfObjects];

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
        cell.detailTextLabel.text = @"";

    } else if ( indexPath.section == 1 ) {
        NSIndexPath *shiftedIndexPath = [NSIndexPath indexPathForRow:indexPath.row inSection:0];

        ManualLayout *manualLayout = (ManualLayout *)[self.fetchedResultsController objectAtIndexPath:shiftedIndexPath];

        cell.textLabel.text = manualLayout.Name;
        cell.detailTextLabel.text = manualLayout.HostName;
    }

    return cell;
}

// Override to support row selection in the table view.
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    // Create a layout adapter of the needed type.
    AdapterLoconetOverTCP *adapter = [[AdapterLoconetOverTCP alloc] init];
    self.layoutAdapter = adapter;
    [adapter release];

    if ( indexPath.section == 0 ) {
        NSNetService *service = [self.servicesLocoNetArray objectAtIndex:indexPath.row];
        [service setDelegate:self];
        [service resolveWithTimeout:5.0];

    } else if ( indexPath.section == 1 ) {
        ManualLayout *manualLayout = [self.fetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row inSection:0]];
        [self connectAdapterToLayoutName:manualLayout.Name hostName:manualLayout.HostName port:[manualLayout.Port unsignedIntValue]];
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

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if ( section == 0 ) {
        return @"Rendezvous";
    } else if ( section == 1 ) {
        return @"Manually entered";
    } else {
        // Should not happen.
        return @"";
    }
}

- (void) tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if ( editingStyle == UITableViewCellEditingStyleDelete ) {
        if ( indexPath.section == 1 ) {
            // Delete the managed object for the given index path
            NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
            NSIndexPath *shiftedIndexPath  = [NSIndexPath indexPathForRow:indexPath.row inSection:0];
            [context deleteObject:[self.fetchedResultsController objectAtIndexPath:shiftedIndexPath]];

            // Save the context.
            NSError *error = nil;
            if ( ![context save:&error] ) {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Could not delete."
                                                                    message:@"The layout could not be deleted. Please close the application by pressing the home button."
                                                                   delegate:self
                                                          cancelButtonTitle:@""
                                                          otherButtonTitles:@"Dismiss", nil];
                [alertView autorelease];
                [alertView show];
            }
        }
	}
}

#pragma mark -
#pragma mark Manual layout methods.

- (IBAction) addManualLayout:(id) sender {
    AddManualLayoutViewController *addManualLayoutViewController = [[AddManualLayoutViewController alloc] initWithNibName:@"AddManualLayoutView" bundle:nil context:[self.fetchedResultsController managedObjectContext]];

    UINavigationController *modelNavController = [[UINavigationController alloc] initWithRootViewController:addManualLayoutViewController];

    [self.navigationController presentModalViewController:modelNavController animated:YES];
    [addManualLayoutViewController release];
    [modelNavController release];
}

#pragma mark -
#pragma mark Navigation Controller methods.

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if ( navigationController == self.navigationController ) {
        if ( viewController == self ) {
            // The layout adapter is no longer needed.
            self.layoutAdapter = nil;

            // We must have returned from the layout views. Start looking for layouts again.
            [self lookForLocoNetOverTCP];

            // Ensure there is no lingering selection.
            NSIndexPath *indexPath = [self.layoutTableView indexPathForSelectedRow];
            if ( indexPath ) {
                [self.layoutTableView deselectRowAtIndexPath:indexPath animated:YES];
            }
        }
    }
}

#pragma mark -
#pragma mark Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController {

    if ( _fetchedResultsController != nil ) {
        return _fetchedResultsController;
    }

	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];

	NSEntityDescription *entity = [NSEntityDescription entityForName:@"ManualLayout" inManagedObjectContext:self.managedObjectContext];
	[fetchRequest setEntity:entity];

	[fetchRequest setFetchBatchSize:20];

	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"Name" ascending:NO];
	NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];

	[fetchRequest setSortDescriptors:sortDescriptors];

	NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:@"Root"];
    aFetchedResultsController.delegate = self;
	self.fetchedResultsController = aFetchedResultsController;

	[aFetchedResultsController release];
	[fetchRequest release];
	[sortDescriptor release];
	[sortDescriptors release];

	return _fetchedResultsController;
}


// NSFetchedResultsControllerDelegate method to notify the delegate that all section and object changes have been processed.
- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
	// In the simplest, most efficient, case, reload the table view.
	[self.layoutTableView reloadData];
}

@end

