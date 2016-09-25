//
//  Account+CoreDataProperties.h
//  GroupFinance
//
//  Created by lidaye on 31/10/2016.
//  Copyright © 2016 limeng. All rights reserved.
//

#import "Account+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface Account (CoreDataProperties)

+ (NSFetchRequest<Account *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSNumber *ain;
@property (nullable, nonatomic, copy) NSString *aname;
@property (nullable, nonatomic, copy) NSNumber *aout;
@property (nullable, nonatomic, copy) NSString *creator;

@end

NS_ASSUME_NONNULL_END
