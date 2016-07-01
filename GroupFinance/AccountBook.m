//
//  AccountBook.m
//  GroupFinance
//
//  Created by lidaye on 4/26/16.
//  Copyright © 2016 limeng. All rights reserved.
//

#import "AccountBook.h"

@implementation AccountBook

- (void)awakeFromInsert {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    [super awakeFromInsert];
    if(!self.uniqueIdentifier) {
        self.uniqueIdentifier=[[NSUUID UUID] UUIDString];
        self.using=[NSNumber numberWithBool:NO];
    }
}

@end
