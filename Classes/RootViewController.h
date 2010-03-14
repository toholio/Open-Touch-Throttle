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

@interface RootViewController : UITableViewController {
  NSMutableArray *_servicesLocoNetArray;
  NSNetServiceBrowser *_serviceLocoNetBrowser;

  IBOutlet UITableView *layoutTableView;

  AdapterLoconetOverTCP *_layoutAdapter;
}

@property (nonatomic, retain) IBOutlet UITableView *layoutTableView;
@property (nonatomic, retain) AdapterLoconetOverTCP *layoutAdapter;

- (void) netServiceBrowser:(NSNetServiceBrowser *)browser
              didNotSearch:(NSDictionary *)errorDict;
- (void) netServiceBrowser:(NSNetServiceBrowser *)browser
            didFindService:(NSNetService *)aNetService
                moreComing:(BOOL) moreComing;
- (void) netServiceBrowser:(NSNetServiceBrowser *)browser
          didRemoveService:(NSNetService *)aNetService
                moreComing:(BOOL) moreComing;

- (IBAction) addManualLayout:(id) sender;

@end
