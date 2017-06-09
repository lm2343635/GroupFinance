//
//  AddMemberViewController.m
//  GroupFinance
//
//  Created by lidaye on 22/11/2016.
//  Copyright © 2016 limeng. All rights reserved.
//

#import "AddMemberViewController.h"
#import "AlertTool.h"
#import "Grouper.h"

@interface AddMemberViewController ()

@end

@implementation AddMemberViewController {
    GroupManager *group;
}

- (void)viewDidLoad {
    if (DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    group = [GroupManager sharedInstance];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveJoinGroupMessage:)
                                                 name:DidReceiveJoinGroupMessage
                                               object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    if (DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    // Update devices table.
    [_devicesTableView reloadData];
}

#pragma mark - UITableViewDataSource
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    return 0.1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    return group.connectedPeers.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"deviceIdentifier"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"deviceIdentifier"];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.text = [[group.connectedPeers objectAtIndex:indexPath.row] displayName];
    cell.detailTextLabel.text = @"Invite";
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    MCPeerID *invitePeer = [group.connectedPeers objectAtIndex:indexPath.row];
    NSString *message = [NSString stringWithFormat:@"Invite %@ to your group.", invitePeer.displayName];
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Invite"
                                                                             message:message
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel"
                                                     style:UIAlertActionStyleCancel
                                                   handler:nil];
    UIAlertAction *invite = [UIAlertAction actionWithTitle:@"Yes"
                                                     style:UIAlertActionStyleDestructive
                                                   handler:^(UIAlertAction * _Nonnull action) {
                                                       // Send invite message.
                                                       [group sendInviteMessageTo:invitePeer];
                                                   }];
    [alertController addAction:cancel];
    [alertController addAction:invite];
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - Action
- (IBAction)browseForDevices:(id)sender {
    if (DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    [group openDeviceBroswerIn:self];
}

#pragma mark - Notification 
- (void)didReceiveJoinGroupMessage:(NSNotification *)notification {
    if (DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    if ([[notification.userInfo valueForKey:@"invite"] boolValue]) {
        [AlertTool showAlertWithTitle:@"Tip"
                           andContent:[NSString stringWithFormat:@"Invite user %@ successfully!", [notification.userInfo valueForKey:@"joiner"]]
                     inViewController:self];
    }
    
}

@end
