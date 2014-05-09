//
//  ProfileViewController.h
//  Qurious_iOS
//
//  Created by Helen Yu on 4/14/14.
//  Copyright (c) 2014 Qurious. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProfileViewController : UITableViewController
@property (strong, nonatomic) IBOutlet UIBarButtonItem *sideBarButton;
- (IBAction)save:(UIStoryboardSegue *)sender;
- (IBAction)cancel:(UIStoryboardSegue *)sender;
@end

