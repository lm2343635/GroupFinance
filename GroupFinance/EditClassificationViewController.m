//
//  EditClassificationViewController.m
//  GroupFinance
//
//  Created by lidaye on 5/22/16.
//  Copyright © 2016 limeng. All rights reserved.
//

#import "EditClassificationViewController.h"
#import "AlertTool.h"
#import "SendTool.h"

@interface EditClassificationViewController ()

@end

@implementation EditClassificationViewController {
    DaoManager *dao;
}

- (void)viewDidLoad {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    [super viewDidLoad];
    dao=[[DaoManager alloc] init];
}

- (void)viewWillAppear:(BOOL)animated {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    [_cnameTextField setText:_classification.cname];
}

#pragma mark - Action
- (IBAction)save:(id)saveButton {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    NSString *cname=_cnameTextField.text;
    if([cname isEqualToString:@""]) {
        [AlertTool showAlertWithTitle:@"Warning"
                           andContent:@"Classification name is empty!"
                     inViewController:self];
        return;
    }
    _classification.cname = cname;
    [dao saveContext];
    [[[SendTool alloc] initWithObject:_classification] sendShares];
    [self.navigationController popViewControllerAnimated:YES];
}

@end
