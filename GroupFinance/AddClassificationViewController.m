//
//  AddClassificationViewController.m
//  GroupFinance
//
//  Created by lidaye on 5/22/16.
//  Copyright © 2016 limeng. All rights reserved.
//

#import "AddClassificationViewController.h"
#import "DaoManager.h"
#import "AlertTool.h"

@interface AddClassificationViewController ()

@end

@implementation AddClassificationViewController {
    DaoManager *dao;
}

- (void)viewDidLoad {
    if(DEBUG) {
        NSLog(@"Running %@ %@'", self.class, NSStringFromSelector(_cmd));
    }
    [super viewDidLoad];
    dao=[[DaoManager alloc] init];
}

#pragma mark - Action
- (IBAction)save:(id)sender {
    if(DEBUG) {
        NSLog(@"Running %@ %@'", self.class, NSStringFromSelector(_cmd));
    }
    NSString *cname=_cnameTextField.text;
    if([cname isEqualToString:@""]) {
        [AlertTool showAlert:@"Classification name is empty!"];
        return;
    }
    AccountBook *usingAccountBook=[dao.accountBookDao getUsingAccountBook];
    if(usingAccountBook==nil) {
        [AlertTool showAlert:@"Choose an using account book at first!"];
        return;
    }
    [dao.classificationDao saveWithName:cname inAccountBook:usingAccountBook];
    [self.navigationController popViewControllerAnimated:YES];
}
@end