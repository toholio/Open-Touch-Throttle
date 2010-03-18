//
//  AddManualLayoutViewController.m
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

#import "AddManualLayoutViewController.h"

@interface AddManualLayoutViewController ()

@property (nonatomic, retain) NSManagedObjectContext *context;

@property (nonatomic, retain) UITextField *nameField;
@property (nonatomic, retain) UITextField *hostField;
@property (nonatomic, retain) UITextField *portField;

@end

@implementation AddManualLayoutViewController

@synthesize context = _context;

@synthesize nameField = _nameField;
@synthesize hostField = _hostField;
@synthesize portField = _portField;

- (id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil context:(NSManagedObjectContext *)theContext {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];

    if ( self ) {
        self.context = theContext;
    }

    return self;
}

- (IBAction) save:(id) sender {
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"ManualLayout" inManagedObjectContext:self.context];
    ManualLayout *manualLayout = (ManualLayout *)[NSEntityDescription insertNewObjectForEntityForName:[entity name] inManagedObjectContext:self.context];

    manualLayout.Name = self.nameField.text;
    manualLayout.HostName = self.hostField.text;
    manualLayout.Port = [NSNumber numberWithInt:[self.portField.text intValue]];

    // Save the context.
    NSError *error = nil;
    if (![self.context save:&error]) {
        UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"Could not save layout."
                                                             message:@"You must complete all fields."
                                                            delegate:nil
                                                   cancelButtonTitle:@"Dismiss"
                                                   otherButtonTitles:nil];
        [errorAlert show];
        [errorAlert autorelease];

        [self.context deleteObject:manualLayout];

    } else {
        [self.navigationController dismissModalViewControllerAnimated:YES];
    }
}

- (IBAction) cancel:(id) sender {
    [self.navigationController dismissModalViewControllerAnimated:YES];
}

- (void) viewDidAppear:(BOOL)animated {
    [self.nameField becomeFirstResponder];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"Add Layout";

    self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel:)] autorelease];
    self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(save:)] autorelease];
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];

	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    self.nameField = nil;
    self.hostField = nil;
    self.portField = nil;
}

- (void)dealloc {
    [_context release];

    [_nameField release];
    [_hostField release];
    [_portField release];

    [super dealloc];
}

#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    static NSString *CellIdentifier = @"Cell";

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }

    if ( indexPath.row == 0 ) {
        if ( self.nameField == nil ) {
            self.nameField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 200, 28)];
            [self.nameField release];
        }

        [cell addSubview:self.nameField];
        cell.textLabel.text = @"Name";
        cell.accessoryView = self.nameField;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;

    } else if ( indexPath.row == 1 ) {
        if ( self.hostField == nil ) {
            self.hostField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 200, 28)];
            [self.hostField release];
        }

        [cell addSubview:self.hostField];
        cell.textLabel.text = @"Host";
        cell.accessoryView = self.hostField;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;

    } else if ( indexPath.row == 2 ) {
        if ( self.portField == nil ) {
            self.portField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 200, 28)];
            [self.portField release];
            self.portField.keyboardType = UIKeyboardTypeNumberPad;
        }

        [cell addSubview:self.portField];
        cell.textLabel.text = @"Port";
        cell.accessoryView = self.portField;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Force the start of editing.
    if ( indexPath.row == 0 ) {
        [self.nameField becomeFirstResponder];

    } else if ( indexPath.row == 1 ) {
        [self.hostField becomeFirstResponder];

    } else if ( indexPath.row == 2 ) {
        [self.portField becomeFirstResponder];

    }
}

@end

