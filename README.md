# Grouper [![Build Status](https://travis-ci.org/lm2343635/Grouper.svg?branch=master)](https://travis-ci.org/lm2343635/Grouper) [![Version](https://img.shields.io/cocoapods/v/Grouper.svg?style=flat)](http://cocoapods.org/pods/Grouper) [![License](https://img.shields.io/cocoapods/l/Grouper.svg?style=flat)](http://cocoapods.org/pods/Grouper) [![Platform](https://img.shields.io/cocoapods/p/Grouper.svg?style=flat)](http://cocoapods.org/pods/Grouper)
A framework for developing app using secret sharing and multiple untrusted servers.

## Introduction
Conventional client-server mode applications require central servers for storing shared data. The users of such mobile applications must fully trust the central server and their application providers. If a central server is compromised by hackers, user information may be revealed because data is often stored on the server in cleartext. Users may lose their data when service providers shut down their services.

Grouper uses secret sharing and multiple untrusted servers to solve this problem. In Grouper, a device use Secret Sharing scheme to divide a message into several shares and upload them to multiple untrusted servers. Other devices download shares and recover shares to original message by Secret Sharing scheme. Thus, user data can be protected. 

## Features

- A self-destruction system with data recovery.
- Protected data synchronization using the extend secret sharing scheme.
- Easy group management for the iOS platform.

## Demo
We have developed an demo app called [AccountBook](https://github.com/lm2343635/AccountBook) using Grouper framework.

## Installation

Grouper is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'Grouper', '~> 2.2'
```

## Documentation

Grouper uses its own Web service. The Web service by Java EE is here [Grouper-Server](https://github.com/lm2343635/Grouper-Server).

Grouper is developed with Objective-C. Import header file into your project.

```objective-c
#import <Grouper/Grouper.h>
```

### Prepare
Grouper object inclueds 3 subobject, they are group(GroupManager), sender(SenderManager), receiver(ReceiverManager).

Grouper relys on [Sync](https://github.com/SyncDB/Sync) framework to syncrhonize data between devices. Thus, when you setup Core Data stack in AppDelegate, you should use DataStack provided in [Sync](https://github.com/SyncDB/Sync) framework.

```objective-c
_dataStack = [[DataStack alloc] initWithModelName:@"Model"];
```

Next, setup Grouper witg your appId, entities, data stack and main storyboard.

```objective-c
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    grouper = [Grouper sharedInstance];
    [grouper setupWithAppId:@"test-app"
                   entities:[NSArray arrayWithObjects:@"Test", nil]
                  dataStack:[self dataStack]
             mainStoryboard:storyboard];
}
```

The attribue entities is an array which constains the names of all entities saved in Core Data.
If an entity A which is referenced by an entity B, you need to ensure that **A should be in the front of B** in the entities array.

### Entity Design

All your Core Data entity should be subentity of SyncEntity, and all your NSManagedObjects should be subclass of SyncEntity. SyncEntity class has been provied in Grouper framework. Create SyncEntity in your Model.xcdatamodeld file and set parent entity as SyncEntity for your entity.

| Attribute | Type   | Explanation                  |
|-----------|--------|------------------------------|
| createAt  | Date   | Create date of this entity   |
| creator   | String | Creator of this entity       |
| remoteID  | String | Remote ID for Sync framework |
| updator   | String | Updater of this entity       |
| updateAt  | String | Update date of this entity   | 

### Group Management

Grouper provides group initialzation related function in Init.storyboard and member management in Members.storyboard. Use these 2 storyboards directly by **grouper.ui.groupInit** and **grouper.ui.members**.

### Data Synchronization

Grouper use SenderManager to send data and ReceiverManager to receive data. 

Use these methods to send data by grouper.sender.

```objective-c
// Send an update message for a sync entity.
- (void)update:(NSManagedObject *)entity;

// Delete a sync entity and send a delete message.
- (void)delete:(NSManagedObject *)entity;

// Send update messages for multiple sync entities.
- (void)updateAll:(NSArray *)entities;

// Delete multiple sync entities and send delete messages.
- (void)deleteAll:(NSArray *)entities;

// Send confirm message;
- (void)confirm;

// Send resend message which contains not existed sequences to receiver.
- (void)resend:(NSArray *)sequences to:(NSString *)receiver;
```

Use this method to receiver data by grouper.receiver.

```objective-c
// Receive message and do something in completion block.
- (void)receiveWithCompletion:(Completion)completion;
```

More information can be found in Demo app [AccountBook](https://github.com/lm2343635/AccountBook).

## Author

Meng Li, http://fczm.pw, lm2343635@126.com

## License

Grouper is available under the MIT license. See the LICENSE file for more info.
