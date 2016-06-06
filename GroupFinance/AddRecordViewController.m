//
//  AddRecordViewController.m
//  GroupFinance
//
//  Created by lidaye on 5/29/16.
//  Copyright © 2016 limeng. All rights reserved.
//

#import <MobileCoreServices/MobileCoreServices.h>
#import "AddRecordViewController.h"
#import "SelectRecordItemTableViewController.h"
#import "DaoManager.h"
#import "AlertTool.h"
#import "DateTool.h"

@interface AddRecordViewController ()

@end

@implementation AddRecordViewController {
    DaoManager *dao;
    NSUInteger selectItemType;
    UIImagePickerController *imagePickerController;
    BOOL saveRecordType;
    AccountBook *usingAccountBook;
}

- (void)viewDidLoad {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    [super viewDidLoad];
    dao=[[DaoManager alloc] init];
    usingAccountBook=[dao.accountBookDao getUsingAccountBook];
    imagePickerController=[[UIImagePickerController alloc] init];
    imagePickerController.delegate=self;
    saveRecordType=NO;
    [self setTime:[[NSDate alloc] init]];
}

- (void)viewWillAppear:(BOOL)animated {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    if(_item!=nil) {
        switch (selectItemType) {
            case SELECT_ITEM_TYPE_CLASSIFICATION:
                _selectedClassification=(Classification *)_item;
                [_selectClassificationButton setTitle:_selectedClassification.cname
                                             forState:UIControlStateNormal];
                break;
            case SELECT_ITEM_TYPE_ACCOUNT:
                _selectedAccount=(Account *)_item;
                [_selectAccountButton setTitle:_selectedAccount.aname
                                      forState:UIControlStateNormal];
                break;
            case SELECT_ITEM_TYPE_SHOP:
                _selectedShop=(Shop *)_item;
                [_selectShopButton setTitle:_selectedShop.sname
                                   forState:UIControlStateNormal];
                break;
            default:
                break;
        }
    }
    if(_template!=nil) {
        saveRecordType=_template.saveRecordType.boolValue;
        [_saveTypeSwitch setOn:saveRecordType];
        _saveTypeLabel.text=saveRecordType? @"Save as Earn": @"Save as Spend";
        _selectedClassification=_template.classification;
        [_selectClassificationButton setTitle:_selectedClassification.cname
                                     forState:UIControlStateNormal];
        _selectedAccount=_template.account;
        [_selectAccountButton setTitle:_selectedAccount.aname
                              forState:UIControlStateNormal];
        _selectedShop=_template.shop;
        [_selectShopButton setTitle:_selectedShop.sname
                           forState:UIControlStateNormal];
    }
}

#pragma mark - UITextViewDelegate
-(void)textViewDidBeginEditing:(UITextView *)textView {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class,NSStringFromSelector(_cmd));
    }
    if(textView==_remarkTextView) {
        CGRect frame = textView.frame;
        int offset=frame.origin.y+textView.frame.size.height-(self.view.frame.size.height-KeyboardHeight);
        NSTimeInterval animationDuration = 0.30f;
        [UIView beginAnimations:@"ResizeForKeyboard" context:nil];
        [UIView setAnimationDuration:animationDuration];
        //将视图的Y坐标向上移动offset个单位，以使下面腾出地方用于软键盘的显示
        if(offset > 0) {
            self.view.frame=CGRectMake(0.0f,-offset,self.view.frame.size.width,self.view.frame.size.height);
        }
        [UIView commitAnimations];
        _remarkOK.hidden=NO;
    }
}

-(void)textViewDidEndEditing:(UITextView *)textView {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class,NSStringFromSelector(_cmd));
    }
    self.view.frame =CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
}

#pragma mark - UIImagePickerControllerDelegate
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'",self.class,NSStringFromSelector(_cmd));
        NSLog(@"MediaInfo: %@",info);
    }
    // 获取用户拍摄的是照片还是视频
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    // 判断获取类型：图片
    if([mediaType isEqualToString:(NSString *)kUTTypeImage]) {
        _photoImage=[info objectForKey:UIImagePickerControllerEditedImage];
        [_takePhotoButton setImage:_photoImage forState:UIControlStateNormal];
    }
    // 隐藏UIImagePickerController
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    UIViewController *controller=[segue destinationViewController];
    if([segue.identifier isEqualToString:@"selectRecordItemSegue"]) {
        [controller setValue:[NSNumber numberWithInteger:selectItemType] forKey:@"selectItemType"];
    } else if ([segue.identifier isEqualToString:@"saveAsTemplateSegue"]) {
        [controller setValue:[NSNumber numberWithBool:saveRecordType] forKey:@"recordType"];
        [controller setValue:_selectedClassification forKey:@"selectedClassification"];
        [controller setValue:_selectedAccount forKey:@"selectedAccount"];
        [controller setValue:_selectedShop forKey:@"selectedShop"];
    }
}

#pragma mark - Action
- (IBAction)save:(id)sender {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    if(_selectedAccount==nil||
       _selectedClassification==nil||
       _selectedShop==nil||
       [_moneyTextFeild.text isEqualToString:@""]) {
        [AlertTool showAlert:@"Money, classification, account or shop is empty."];
        return;
    }
    int moneyInt=(int)_moneyTextFeild.text.doubleValue;
    NSNumber *money=[NSNumber numberWithInt: saveRecordType==YES ? moneyInt: -moneyInt];
    Photo *photo=nil;
    //如果用户拍过照就要新建Photo对象
    if(_photoImage!=nil) {
        NSManagedObjectID *pid=[dao.photoDao saveWithData:UIImageJPEGRepresentation(_photoImage, 1.0)
                                            inAccountBook:usingAccountBook];
        if(DEBUG) {
            NSLog(@"Create photo(pid=%@) in accountBook %@", pid, usingAccountBook.abname);
        }
        photo=(Photo *)[dao getObjectById:pid];
    }
    
    NSManagedObjectID *rid=[dao.recordDao saveWithMoney:money
                                              andRemark:_remarkTextView.text
                                                andTime:_selectedTime
                                      andClassification:_selectedClassification
                                             andAccount:_selectedAccount
                                                andShop:_selectedShop
                                               andPhoto:photo
                                          inAccountBook:usingAccountBook];
    if(DEBUG) {
        NSLog(@"Create record(rid=%@) in accountBook %@", rid, usingAccountBook.abname);
    }
    if(rid) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (IBAction)selectClassification:(id)sender {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    _item=nil;
    selectItemType=SELECT_ITEM_TYPE_CLASSIFICATION;
    [self performSegueWithIdentifier:@"selectRecordItemSegue" sender:self];
}

- (IBAction)selectAccount:(id)sender {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    _item=nil;
    selectItemType=SELECT_ITEM_TYPE_ACCOUNT;
    [self performSegueWithIdentifier:@"selectRecordItemSegue" sender:self];
}

- (IBAction)selectShop:(id)sender {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    _item=nil;
    selectItemType=SELECT_ITEM_TYPE_SHOP;
    [self performSegueWithIdentifier:@"selectRecordItemSegue" sender:self];
}

- (IBAction)selectTime:(id)sender {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    _selectTimeButton.enabled=NO;
    [_timeSelectorView initWithCallback:^(NSObject *object) {
        [self setTime:(NSDate *)object];
    }];
}

- (IBAction)takePhoto:(id)sender {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    UIAlertController *alertController=[UIAlertController alertControllerWithTitle:@"Choose Photo from"
                                                                           message:nil
                                                                    preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *cancelAction=[UIAlertAction actionWithTitle:@"Cancel"
                                                         style:UIAlertActionStyleCancel
                                                       handler:nil];
    UIAlertAction *cameraAction=[UIAlertAction actionWithTitle:@"Camera"
                                                         style:UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction * _Nonnull action) {
                                                           if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
                                                               // 将sourceType设为UIImagePickerControllerSourceTypeCamera代表拍照或拍视频
                                                               imagePickerController.sourceType=UIImagePickerControllerSourceTypeCamera;
                                                               // 设置模式为拍摄照片
                                                               imagePickerController.cameraCaptureMode=UIImagePickerControllerCameraCaptureModePhoto;
                                                               // 设置使用手机的后置摄像头（默认使用后置摄像头）
                                                               imagePickerController.cameraDevice=UIImagePickerControllerCameraDeviceRear;
                                                               // 设置拍摄的照片允许编辑
                                                               imagePickerController.allowsEditing=YES;
                                                           }else{
                                                               NSLog(@"iOS Simulator cannot open camera.");
                                                               [AlertTool showAlert:@"iOS Simulator cannot open camera."];
                                                           }
                                                           // 显示picker视图控制器
                                                           [self presentViewController:imagePickerController animated: YES completion:nil];
                                                       }];
    UIAlertAction *libraryAction=[UIAlertAction actionWithTitle:@"Photo Library"
                                                          style:UIAlertActionStyleDefault
                                                        handler:^(UIAlertAction * _Nonnull action) {
                                                            // 设置选择载相册的图片
                                                            imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                                                            imagePickerController.allowsEditing = YES;
                                                            // 显示picker视图控制器
                                                            [self presentViewController:imagePickerController animated: YES completion:nil];
                                                        }];
    [alertController addAction:cancelAction];
    [alertController addAction:cameraAction];
    [alertController addAction:libraryAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (IBAction)changeSaveType:(id)sender {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    if([sender isOn]) {
        saveRecordType=YES;
        _saveTypeLabel.text=@"Save as Earn";
    } else {
        saveRecordType=NO;
        _saveTypeLabel.text=@"Save as Spend";
    }
}

- (IBAction)finishEditRemark:(id)sender {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'",self.class,NSStringFromSelector(_cmd));
    }
    [_remarkTextView resignFirstResponder];
    _remarkOK.hidden=YES;
}

- (IBAction)saveAsTemplate:(id)sender {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'",self.class,NSStringFromSelector(_cmd));
    }
    if(_selectedAccount==nil||_selectedClassification==nil||_selectedShop==nil) {
        [AlertTool showAlert:@"Classification, account or shop is empty!"];
        return;
    }
    [self performSegueWithIdentifier:@"saveAsTemplateSegue" sender:self];
}

#pragma mark - Service
-(void)setTime:(NSDate *)time {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'",self.class,NSStringFromSelector(_cmd));
    }
    _selectedTime=time;
    _selectTimeButton.enabled=YES;
    [_selectTimeButton setTitle:[DateTool formateDate:_selectedTime withFormat:DateFormatYearMonthDayHourMinutes]
                       forState:UIControlStateNormal];
}

@end