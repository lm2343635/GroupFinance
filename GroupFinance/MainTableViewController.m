//
//  MainTableViewController.m
//  GroupFinance
//
//  Created by lidaye on 09/01/2017.
//  Copyright © 2017 limeng. All rights reserved.
//

#import "MainTableViewController.h"
#import "NetManager.h"
#import "GroupManager.h"
#import "SendManager.h"
#import "ReceiveManager.h"
#import "DaoManager.h"
#import "CommonTool.h"
#import "MessageData.h"
#import "GroupFinance-Swift.h"
#import "UIImageView+Extension.h"
#import <MJRefresh/MJRefresh.h>

@interface MainTableViewController ()

@end

@implementation MainTableViewController {
    NetManager *net;
    DaoManager *dao;
    GroupManager *group;
    
    NSDateFormatter *dateFormatter;
    int accessedServers;
    
    NSMutableDictionary *loadingActivityIndicatorViews;
    NSMutableDictionary *stateImageViews;
    UIImageView *syncImageView;
    
    NSMutableArray *messages;
    Message *selectedMessage;
}

- (void)viewDidLoad {
    if (DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    [super viewDidLoad];
    
    net = [NetManager sharedInstance];
    group = [GroupManager sharedInstance];
    dao = [DaoManager sharedInstance];
    
    // Init date formatter.
    dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateStyle = NSDateFormatterMediumStyle;
    dateFormatter.timeStyle = NSDateFormatterShortStyle;
    
    loadingActivityIndicatorViews = [[NSMutableDictionary alloc] init];
    stateImageViews = [[NSMutableDictionary alloc] init];

    messages = [[NSMutableArray alloc] init];
    
    [self checkServerStateAndSync];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receivedNewObject:)
                                                 name:@"receivedNewObject"
                                               object:nil];

    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [self.tableView.mj_header endRefreshing];
        [self checkServerStateAndSync];
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    if (DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }

}

#pragma mark - Table view data source]
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    return 0.01;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    switch (section) {
        case 0:
            return group.defaults.initial == InitialFinished? group.defaults.serverCount: 1;
            break;
        case 1:
            return messages.count + 1;
            break;
        default:
            return 0;
            break;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    return @" ";
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 70;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    CGFloat width = self.tableView.frame.size.width;
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, 70)];
    view.backgroundColor = UIColorFromRGB(0xf5f5f5);
    UIImageView *logoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(width / 2 - 15, 8, 30, 30)];
    UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 40, width, 20)];
    nameLabel.textAlignment = NSTextAlignmentCenter;
    [view addSubview:logoImageView];
    [view addSubview:nameLabel];
    // Set logo icon and title name.
    switch (section) {
        case 0:
            logoImageView.image = [UIImage imageNamed:@"servers"];
            nameLabel.text = @"Untrusted Servers State";
            break;
        case 1:
            logoImageView.image = [UIImage imageNamed:@"sync"];
            nameLabel.text = @"Data Synchronization";
            syncImageView = logoImageView;
            break;
        default:
            break;
    }
    
    return view;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    UITableViewCell *cell = nil;
    if (indexPath.section == 0) {
        if (group.defaults.initial == InitialFinished) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"serverIdentifier" forIndexPath:indexPath];
            UILabel *serverAddressLabel = (UILabel *)[cell viewWithTag:1];
            serverAddressLabel.text = [group.defaults.servers.allKeys objectAtIndex:indexPath.row];
            
            [stateImageViews setObject:(UIImageView *)[cell viewWithTag:2]
                                forKey:serverAddressLabel.text];
            [loadingActivityIndicatorViews setObject:(UIActivityIndicatorView *)[cell viewWithTag:3]
                                              forKey:serverAddressLabel.text];
        } else {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"defaultCell"];
            cell.textLabel.text = @"Group is not initialized.";
            cell.textLabel.textAlignment = NSTextAlignmentCenter;
        }
    } else if (indexPath.section == 1) {
        // Show All Message button if it is last cell.
        if (indexPath.row == messages.count) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"allMessageIdentifier"
                                                   forIndexPath:indexPath];
        } else {
            MessageData *message = [messages objectAtIndex:indexPath.row];
            
            User *user = [dao.userDao getByUserId:message.sender];
            cell = [tableView dequeueReusableCellWithIdentifier:@"messageIdentifier"
                                                   forIndexPath:indexPath];
            UIImageView *avatarImageView = (UIImageView *)[cell viewWithTag:1];
            UILabel *sendInfoLabel = (UILabel *)[cell viewWithTag:2];
            avatarImageView.image = [UIImage imageWithData:user.picture];
            sendInfoLabel.text = [NSString stringWithFormat:@"%@ sent at %@", user.name, [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:message.sendtime / 1000.0]]];
            
            UILabel *receiveInfoLabel = (UILabel *)[cell viewWithTag:3];
            UILabel *typeLabel = (UILabel *)[cell viewWithTag:4];
            receiveInfoLabel.text = [NSString stringWithFormat:@"%@ received at %@", message.object, [dateFormatter stringFromDate:[NSDate date]]];
            typeLabel.text = message.type;
        }
    }

    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    if (indexPath.section == 1 && indexPath.row != messages.count) {
        selectedMessage = [messages objectAtIndex:indexPath.row];
        [self performSegueWithIdentifier:@"contentSegue" sender:self];
    }
}

#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if (DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    if ([segue.identifier isEqualToString:@"contentSegue"]) {
        [segue.destinationViewController setValue:selectedMessage forKey:@"message"];
    }
}

#pragma mark - Service
- (void)checkServerStateAndSync {
    if (DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    self.checkState = 0;
    [self addObserver:self
           forKeyPath:@"checkState"
              options:NSKeyValueObservingOptionNew
              context:nil];

    for (NSString *address in net.managers.allKeys) {
        [net.managers[address] GET:[NetManager createUrl:@"user/state" withServerAddress:address]
                    parameters:nil
                      progress:nil
                       success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                           InternetResponse *response = [[InternetResponse alloc] initWithResponseObject:responseObject];
                           if ([response statusOK]) {
                               BOOL state = [[[response getResponseResult] valueForKey:@"ok"] boolValue];
                               if (state) {
                                   accessedServers ++;
                               }
                               [self showState:state forServer:address];
                               self.checkState ++;
                           }
                       }
                       failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                           [self showState:NO forServer:address];
                           self.checkState ++;
                       }];
    }
}

- (void)showState:(BOOL)state forServer:(NSString *)address {
    if (DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    UIImageView *stateImageView = [stateImageViews objectForKey:address];
    UIActivityIndicatorView *loadingActivityIndicatorView = [loadingActivityIndicatorViews objectForKey:address];
    stateImageView.highlighted = !state;
    stateImageView.hidden = NO;
    [loadingActivityIndicatorView stopAnimating];
}

- (void)dataSync {
    if (DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    [syncImageView startRotate:2 withClockwise:NO];
    [[ReceiveManager sharedInstance] receiveWithCompletion:^{
        [syncImageView stopRotate];
    }];
}

#pragma mark - Key Value Observe
- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary<NSKeyValueChangeKey,id> *)change
                       context:(void *)context {
    if (DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    if ([keyPath isEqualToString:@"checkState"]) {
        if (self.checkState == group.defaults.serverCount) {
            if (DEBUG) {
                NSLog(@"All servers' state have been checked.");
            }
            [self removeObserver:self forKeyPath:@"checkState"];
            // If threshold is k in a secret sharing scheme f(k, n),
            // sync method can be invoked after accessing more than k untrusted servers.
            if (DEBUG) {
                NSLog(@"Grouper access to %d untrusted servers.", accessedServers);
            }
            if (accessedServers >= group.defaults.threshold && group.defaults.initial == InitialFinished) {
                if (DEBUG) {
                    NSLog(@"Accessed %d servers, call sync method.", accessedServers);
                }
                // Refresh members list before data sync
                [group refreshMemberListWithCompletion:^(BOOL success) {
                    [self dataSync];
                }];
            }
            // If client can get access to all untrusted server(therdhold is n),
            // send a confirm message to unstrusted servers.
            long now = (long)[[NSDate date] timeIntervalSince1970];
            // If client sent control message before 3600s, send control message again
            if (now - group.defaults.controlMessageSendTime > 1 * 3600) {
                [[SendManager sharedInstance] confirm];
                // Update control message sene time.
                group.defaults.controlMessageSendTime = now;
            }
            
        }
    }
}

#pragma mark - Notification
- (void)receivedNewObject:(NSNotification *)notification {
    if (DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    [messages insertObject:(Message *)notification.object atIndex:0];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:1];
    [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                          withRowAnimation:UITableViewRowAnimationAutomatic];
}

@end
