//
//  ServersTableViewController.m
//  GroupFinance
//
//  Created by lidaye on 19/11/2016.
//  Copyright © 2016 limeng. All rights reserved.
//

#import "ServersTableViewController.h"
#import "GroupManager.h"
#import "AlertTool.h"
#import "CommonTool.h"

@interface ServersTableViewController ()

@end

@implementation ServersTableViewController {
    GroupManager *group;
    NSDictionary *servers;
}

- (void)viewDidLoad {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    [super viewDidLoad];
    group = [GroupManager sharedInstance];
}

- (void)viewWillAppear:(BOOL)animated {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    // Get servers from NSUserDefault.
    servers = group.defaults.servers;
    switch (group.defaults.initial) {
        case NotInitial:
            _noServerLabel.hidden = NO;
            _groupInformationView.hidden = YES;
            break;
        case RestoringServer:
            _addServerBarButtonItem.enabled = NO;
            _noServerLabel.hidden = YES;
            _initialGroupButton.hidden = NO;
            break;
        case AddingNewServer:
            _restoreServerBarButtonItem.enabled = NO;
            _noServerLabel.hidden = YES;
            _initialGroupButton.hidden = NO;
            break;
        case InitialFinished:
            _addServerBarButtonItem.enabled = NO;
            _restoreServerBarButtonItem.enabled = NO;
            break;
        default:
            break;
    }
    
    //Show group id and group name if group state is not uninitial.
    if (group.defaults.initial != NotInitial) {
        _groupInformationView.hidden = NO;
        _groupIdTextField.text = group.defaults.groupId;
        _groupNameTextField.text = group.defaults.groupName;
    }
    
    if (group.defaults.initial == InitialFinished || group.defaults.initial == RestoringServer) {
        _thresholdTextField.text = [NSString stringWithFormat:@"Threshold is %ld", (long)group.defaults.threshold];
        [_thresholdTextField setEnabled:NO];
    }
    
    //Set keyboard accessory for threshold text field
    [self setCloseKeyboardAccessoryForSender:_thresholdTextField];
    
    [self.tableView reloadData];
}

#pragma mark - Table view data source
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    return 0.1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    return servers.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"serverIdentifier"
                                                            forIndexPath:indexPath];
    UILabel *addressLabel = (UILabel *)[cell viewWithTag:1];
    UILabel *accessKeyLabel = (UILabel *)[cell viewWithTag:2];
    addressLabel.text = [[servers allKeys] objectAtIndex:indexPath.row];
    accessKeyLabel.text = [servers valueForKey:addressLabel.text];
    return cell;
}

#pragma mark - Action
- (IBAction)initialGroup:(id)sender {
    if (DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    int threshold = 0;
    // Check threshold if user is adding new servers.
    if (group.defaults.initial == AddingNewServer) {
        if ([_thresholdTextField.text isEqualToString:@""]) {
            [AlertTool showAlertWithTitle:@"Tip"
                               andContent:@"Recover threshold cannot be empty!"
                         inViewController:self];
            return;
        }
        if (![CommonTool isInteger:_thresholdTextField.text]) {
            [AlertTool showAlertWithTitle:@"Tip"
                               andContent:@"Recover threshold should be an integer!"
                         inViewController:self];
            return;
        }
        threshold = _thresholdTextField.text.intValue;
        
        if ([_thresholdTextField isFirstResponder]) {
            [_thresholdTextField resignFirstResponder];
        }
    }

    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Initialize Group"
                                                                   message:@"You cannot add more untrusted server after initializing your group. Are you sure to initialize?"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *initialize = [UIAlertAction actionWithTitle:@"Yes"
                                                         style:UIAlertActionStyleDestructive
                                                       handler:^(UIAlertAction * _Nonnull action) {
        // Disable intial group button when submitting.
        _initialGroupButton.enabled = NO;
                                                           
        // Initialize group.
        [group initializeGroup:threshold withCompletion:^(BOOL success, NSString *message) {
            if (success) {
                // Hide initial group button, disable add and store server bar button.
                _initialGroupButton.hidden = YES;
                _addServerBarButtonItem.enabled = NO;
                _restoreServerBarButtonItem.enabled = NO;
  
                // Change text of threshold text field and disabled it.
                _thresholdTextField.text = [NSString stringWithFormat:@"Threshold is %ld", (long)group.defaults.threshold];
                [_thresholdTextField setEnabled:NO];
            } else {
                // Enable initial group button if failed.
                _initialGroupButton.enabled = YES;
            }
            if (message != nil) {
                [AlertTool showAlertWithTitle:@"Tip"
                                   andContent:message
                             inViewController:self];
            }
        }];
    }];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel"
                                                     style:UIAlertActionStyleCancel
                                                   handler:nil];
    [alertController addAction:initialize];
    [alertController addAction:cancel];
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - Service

//Create done button for keyboard
- (void)setCloseKeyboardAccessoryForSender:(id)sender {
    if (DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    UIToolbar * topView = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.view.window.frame.size.width, 35)];
    [topView setBarStyle:UIBarStyleDefault];
    UIBarButtonItem* spaceButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                                     target:self
                                                                                     action:nil];
    UIBarButtonItem *doneButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                    target:self
                                                                                    action:@selector(editFinish)];
    doneButtonItem.tintColor = [UIColor colorWithRed:38/255.0 green:186/255.0 blue:152/255.0 alpha:1.0];
    NSArray * buttonsArray = [NSArray arrayWithObjects:spaceButtonItem, doneButtonItem, nil];
    [topView setItems:buttonsArray];
    [sender setInputAccessoryView:topView];
}

- (void)editFinish {
    if (DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    if ([_thresholdTextField isFirstResponder]) {
        [_thresholdTextField resignFirstResponder];
    }
}

@end