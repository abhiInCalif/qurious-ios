//
//  EditViewController.m
//  Qurious_iOS
//
//  Created by Helen Yu on 3/31/14.
//  Copyright (c) 2014 Qurious. All rights reserved.
//

#import "EditViewController.h"
#import "Person.h"

@interface EditViewController () {
    NSMutableArray *skills;
}
@end

@implementation EditViewController

@synthesize detailItem = _detailItem;
@synthesize firstNameField = _firstNameField;
@synthesize lastNameField = _lastNameField;
@synthesize emailField = _emailField;
@synthesize bioField = _bioField;
@synthesize imageView = _imageView;

- (void)setDetailItem:(id)detailItem {
    if (_detailItem != detailItem) {
        _detailItem = detailItem;
        [self configureView];
    }
}

- (void)configureView {
    if (self.detailItem && [self.detailItem isKindOfClass:[Person class]]) {
        self.firstNameField.text = [self.detailItem firstName];
        self.lastNameField.text = [self.detailItem lastName];
        self.emailField.text = [self.detailItem email];
        self.bioField.text = [self.detailItem bio];
        self.imageView.image = [self.detailItem profPic];
        
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if ((textField == self.firstNameField) ||
        (textField == self.lastNameField) ||
        (textField == self.emailField)){
        [textField resignFirstResponder];
    }
    return YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureView];
    skills = [self.detailItem skills];
}

#pragma mark - Table View

//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
//{
//    return 1;
//}
//
//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
//{
//    return skills.count;
//}
//
//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    UITableViewCell *cell = [tableView
//                             dequeueReusableCellWithIdentifier:@"Cell"
//                             forIndexPath:indexPath];
//    NSString *skill = skills[indexPath.row];
//    cell.textLabel.text = skill;
//    return cell;
//}
//
//- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    // Return NO if you do not want the specified item to be editable.
//    return YES;
//}
//
//- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    if (editingStyle == UITableViewCellEditingStyleDelete) {
//        [skills removeObjectAtIndex:indexPath.row];
//        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
//    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
//        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
//    }
//}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end