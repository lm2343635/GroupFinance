//
//  AccountBookDao.h
//  GroupFinance
//
//  Created by lidaye on 5/22/16.
//  Copyright © 2016 limeng. All rights reserved.
//

#import "DaoTemplate.h"

#define AccountBookEntityName @"AccountBook"

@interface AccountBookDao : DaoTemplate

- (NSManagedObjectID *)saveWithName:(NSString *)abname forOwner:(NSString *)userId;

- (AccountBook *)getUsingAccountBook;

- (void)setUsingAccountBook:(AccountBook *)accountBook;

@end
