//
//  AppDelegate.m
//  GroupFinance
//
//  Created by lidaye on 4/23/16.
//  Copyright © 2016 limeng. All rights reserved.
//

#import "AppDelegate.h"
#import "DaoManager.h"
#import "GroupTool.h"

@interface AppDelegate ()

@end

@implementation AppDelegate {
    GroupTool *group;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }

    group = [[GroupTool alloc] init];
    if (DEBUG) {
        NSLog(@"Number of group menbers is %ld", (long)group.members);
        NSLog(@"Group id is %@, group name is %@, group owner is %@", group.groupId, group.groupName, group.owner);
        for (NSString *address in group.servers.allKeys) {
            NSLog(@"Untrusted server %@, access key is %@", address, group.servers[address]);
        }
    }
    
    _mcManager = [[MCManager alloc] init];

    //Init facebook OAuth.
    [[FBSDKApplicationDelegate sharedInstance] application:application
                             didFinishLaunchingWithOptions:launchOptions];
    
    //Init AFHTTPSessionManager.
    [self sessionManager];
    if (group.members > 0) {
        [self sessionManagers];
    }
    
    //Set root view controller.
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"uid"] == nil) {
        [self setRootViewControllerWithIdentifer:@"loginViewController"];
    } else {
        [self setRootViewControllerWithIdentifer:@"mainTabBarController"];
    }
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
        NSLog(@"Register remote notification success, token = %@", deviceToken);
    }
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
        
    }
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    BOOL handled = [[FBSDKApplicationDelegate sharedInstance] application:application
                                                                  openURL:url
                                                        sourceApplication:options[UIApplicationOpenURLOptionsSourceApplicationKey]
                                                               annotation:options[UIApplicationOpenURLOptionsAnnotationKey]
                    ];
    // Add user logic here.
    return handled;
}

#pragma mark - DataStack
@synthesize dataStack = _dataStack;

- (DATAStack *)dataStack {
    if (_dataStack) {
        return _dataStack;
    }
    _dataStack = [[DATAStack alloc] initWithModelName:@"Model"];
    return _dataStack;
}

#pragma mark - AFNetworking
@synthesize sessionManagers = _sessionManagers;

- (NSDictionary *)sessionManagers {
    if (_sessionManagers == nil) {
        [self refreshSessionManagers];
    }
    return _sessionManagers;
}

- (void)refreshSessionManagers {
    NSMutableDictionary *managers = [[NSMutableDictionary alloc] init];
    group = [[GroupTool alloc] init];
    for (NSString *address in group.servers.allKeys) {
        AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
        //Set access key in request header.
        [manager.requestSerializer setValue:[group.servers valueForKey:address] forHTTPHeaderField:@"key"];
        manager.responseSerializer = [[AFCompoundResponseSerializer alloc] init];
        [managers setObject:manager forKey:address];
    }
    _sessionManagers = managers;
}

@synthesize sessionManager = _sessionManager;

- (AFHTTPSessionManager *)sessionManager {
    if(_sessionManager == nil) {
        _sessionManager = [AFHTTPSessionManager manager];
        _sessionManager.responseSerializer = [[AFCompoundResponseSerializer alloc] init];
    }
    return _sessionManager;
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

@end
