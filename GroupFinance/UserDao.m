//
//  UserDao.m
//  GroupFinance
//
//  Created by lidaye on 7/1/16.
//  Copyright © 2016 limeng. All rights reserved.
//

#import "UserDao.h"

@implementation UserDao

- (User *)saveOrUpdateWithJSONObject:(NSObject *)object {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    User *user = [self getByUserId:[object valueForKey:@"id"]];
    if(user == nil) {
        user = [NSEntityDescription insertNewObjectForEntityForName:UserEntityName
                                             inManagedObjectContext:self.context];
    }
    user.userId = [object valueForKey:@"id"];
    user.email = [object valueForKey:@"email"];
    user.name = [object valueForKey:@"name"];
    user.gender = [object valueForKey:@"gender"];
    user.pictureUrl = [[[object valueForKey:@"picture"] valueForKey:@"data"] valueForKey:@"url"];
    user.picture = [NSData dataWithContentsOfURL:[NSURL URLWithString:user.pictureUrl]];
    [self saveContext];
    return user;
}

- (User *)getByUserId:(NSString *)userId {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    NSPredicate *predicate=[NSPredicate predicateWithFormat:@"userId=%@", userId];
    return (User *)[self getByPredicate:predicate withEntityName:UserEntityName];
}

- (User *)getUsingUser {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [self getByUserId:[defaults valueForKey:@"userId"]];
}

@end
