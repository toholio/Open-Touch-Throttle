//
//  RootViewController.h
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

#import "AdapterLoconetOverTCP.h"

@interface RootViewController : UITableViewController <UINavigationControllerDelegate,NSFetchedResultsControllerDelegate> {
@private
    IBOutlet UITableView *_layoutTableView;

    AdapterLoconetOverTCP *_layoutAdapter;

    NSMutableArray *_servicesLocoNetArray;
    NSNetServiceBrowser *_serviceLocoNetBrowser;

    NSFetchedResultsController *_fetchedResultsController;
    NSManagedObjectContext *_managedObjectContext;
}

@property (nonatomic, retain) IBOutlet UITableView *layoutTableView;
@property (nonatomic, retain) AdapterLoconetOverTCP *layoutAdapter;

@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

- (void) lookForLocoNetOverTCP;

- (void) netServiceBrowser:(NSNetServiceBrowser *)browser
              didNotSearch:(NSDictionary *)errorDict;
- (void) netServiceBrowser:(NSNetServiceBrowser *)browser
            didFindService:(NSNetService *)aNetService
                moreComing:(BOOL) moreComing;
- (void) netServiceBrowser:(NSNetServiceBrowser *)browser
          didRemoveService:(NSNetService *)aNetService
                moreComing:(BOOL) moreComing;

- (void) netServiceDidResolveAddress:(NSNetService *)netService;
- (void) netService:(NSNetService *)netService didNotResolve:(NSDictionary *)errorDict;

- (IBAction) addManualLayout:(id) sender;

- (void) connectAdapterToLayoutName:(NSString *)name hostName:(NSString *)hostName port:(NSUInteger) port;

@end
