//
//  AddManualLayoutViewController.h
//  Created by Tobin Richard on 17/03/10.
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
#import "ManualLayout.h"

@interface AddManualLayoutViewController : UITableViewController {
@private
    NSManagedObjectContext *_context;

    UITextField *_nameField;
    UITextField *_hostField;
    UITextField *_portField;
}

- (id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil context:(NSManagedObjectContext *)theContext;

- (IBAction) save:(id) sender;
- (IBAction) cancel:(id) sender;

@end
