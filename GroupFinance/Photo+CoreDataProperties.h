//
//  Photo+CoreDataProperties.h
//  GroupFinance
//
//  Created by 李大爷的电脑 on 7/24/16.
//  Copyright © 2016 limeng. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Photo.h"

NS_ASSUME_NONNULL_BEGIN

@interface Photo (CoreDataProperties)

@property (nullable, nonatomic, retain) NSDate *createDate;
@property (nullable, nonatomic, retain) NSData *data;
@property (nullable, nonatomic, retain) NSString *userId;
@property (nullable, nonatomic, retain) AccountBook *accountBook;

@end

NS_ASSUME_NONNULL_END
