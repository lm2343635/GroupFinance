//
//  AccountBook.h
//  GroupFinance
//
//  Created by lidaye on 4/26/16.
//  Copyright © 2016 limeng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

NS_ASSUME_NONNULL_BEGIN

@class Classification;
@class Account;
@class Shop;
@class Record;
@class Photo;
@class Template;
@class User;

@interface AccountBook : NSManagedObject

- (NSMutableArray *)getCooperatersWithJSONArray;

- (void)setCooperatersWithJSONArray:(NSArray *)cooperaters;

@end

NS_ASSUME_NONNULL_END

#import "AccountBook+CoreDataProperties.h"
