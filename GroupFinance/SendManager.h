//
//  SendTool.h
//  GroupFinance
//
//  Created by lidaye on 04/11/2016.
//  Copyright © 2016 limeng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DaoManager.h"

@interface SendManager : NSObject

// Message sequence.
@property (nonatomic) NSInteger sequence;

// How many servers has been sent.
@property (nonatomic) NSInteger sent;

// Get single instance.
+ (instancetype)sharedInstance;

// Send update message for a sync entity.
- (void)update:(SyncEntity *)object;

// Send delete message for a sync entity.
- (void)delete:(SyncEntity *)object;

// Send confirm message;
- (void)confirm;

@end
