//
//  AppDelegate.m
//  GroupFinance
//
//  Created by lidaye on 4/23/16.
//  Copyright © 2016 limeng. All rights reserved.
//

#import "AppDelegate.h"
#import "Grouper-Bridging-Header.h"
#import "Grouper-Swift.h"
#import "Grouper.h"

@interface AppDelegate ()

@end

@implementation AppDelegate {
    GroupManager *group;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    
    //Register Remote Notification, support iOS version after 8.0
    [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
    [[UIApplication sharedApplication] registerForRemoteNotifications];
    
    group = [GroupManager sharedInstance];
    
    if (DEBUG) {
        NSLog(@"Number of group members is %ld, threshold is %ld, deletion interval time is %ldm", (long)group.members, (long)group.defaults.threshold, (long)group.defaults.interval);
        NSLog(@"Group id is %@, group name is %@, group owner is %@", group.defaults.groupId, group.defaults.groupName, group.defaults.owner);
        for (NSString *address in group.defaults.servers.allKeys) {
            NSLog(@"Untrusted server %@, access key is %@", address, group.defaults.servers[address]);
        }
    }
    
    // Indicate to the system that your app wishes to perform background fetch.
    [[UIApplication sharedApplication] setMinimumBackgroundFetchInterval:1800];

    // Use storyboard by init state.
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:group.defaults.initial != InitialFinished ? @"Init" : @"Main"
                                                         bundle:nil];
    // Set root view controller and make windows visible
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController = [storyboard instantiateInitialViewController];
    [self.window makeKeyAndVisible];
    
    return YES;
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    NSString *token = [[[[deviceToken description]
                            stringByReplacingOccurrencesOfString:@"<" withString:@""]
                            stringByReplacingOccurrencesOfString:@">" withString:@""]
                            stringByReplacingOccurrencesOfString:@" " withString:@""];
    if (DEBUG) {
        NSLog(@"Device token from APNs server is %@", token);
    }
    [group sendDeviceToken:token];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
        NSLog(@"Register remote notification failed with error: %@", error.localizedDescription);
    }
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
        NSLog(@"didReceiveRemoteNotification, userInfo = %@", userInfo);
    }
    NSDictionary *aps = [userInfo valueForKey:@"aps"];
    NSString *category = [aps valueForKey:@"category"];
    if ([category isEqualToString:@"message"]) {
        [self sync];
        [BannerTool showWithTitle:nil
                         subtitle:[aps valueForKey:@"alert"]
                            image:nil];
    }
}

// Background fetch.
- (void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
        NSLog(@"Background fetch started...");
    }
    [self sync];
}


#pragma mark - DataStack
@synthesize dataStack = _dataStack;

- (DataStack *)dataStack {
    if (_dataStack) {
        return _dataStack;
    }
    _dataStack = [[DataStack alloc] initWithModelName:@"Model"];
    return _dataStack;
}

@synthesize grouperDataStack = _grouperDataStack;

- (DataStack *)grouperDataStack {
    if (_grouperDataStack) {
        return _grouperDataStack;
    }
    _grouperDataStack = [[DataStack alloc] initWithModelName:@"Static"];
    return _grouperDataStack;
}

#pragma mark - Service
- (void)setRootViewControllerWithIdentifer:(NSString *)identifer {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController = [storyboard instantiateViewControllerWithIdentifier:identifer];
    [self.window makeKeyAndVisible];
}

- (void)sync {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    [group checkServerState:^(NSDictionary *serverStates, BOOL sync) {
        if (sync) {
            [[ReceiveManager sharedInstance] receiveWithCompletion:^{
                if (DEBUG) {
                    NSLog(@"Sync ended...");
                }
            }];
        }
    }];
}

@end
