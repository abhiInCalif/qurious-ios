//
//  ProfileViewController.m
//  Qurious_iOS
//
//  Created by Helen Yu on 4/14/14.
//  Copyright (c) 2014 Qurious. All rights reserved.
//

#import "ProfileViewController.h"
#import "Person.h"
#import "EditViewController.h"
#import "SkillViewController.h"
#import "Skill.h"
#import "QApiRequests.h"
#import "PIctureNameButtonTableViewCell.h"
#import "SWRevealViewController.h"

@interface ProfileViewController ()

@end




@implementation ProfileViewController

static Person* me;
static ProfileViewController* _self;
static UIImage* myPicture;

void saveCallback (id arg) {
    NSLog(@"Save profile JSON: %@", arg);
    printf("%s", "Saved a profile");
}



void pictureCallback(id arg) {
    NSLog(@"Save picture JSON: %@", arg);
    printf("%s", "Saved a picture");
}

#pragma mark - Managing the detail item


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"editProfile"]) {
        NSArray *navigationControllers = [[segue destinationViewController] viewControllers];
        EditViewController *editViewController = [navigationControllers objectAtIndex:0];
        [editViewController setDetailItem:me];
    }
    if ([[segue identifier] isEqualToString:@"showSkillEdit"]) {
        [[segue destinationViewController] setDetailItem:me];
    }
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [me skills].count + 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.section == 0 && indexPath.row == 0) {
        return 369.0f;
    }
    // "Else"
    return 63.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //    UITableViewCell *cell = [tableView
    //                             dequeueReusableCellWithIdentifier:@"Cell"
    //                             forIndexPath:indexPath];
    
    static NSString *picIdentifier = @"PictureCell";
    static NSString *bioIdentifier = @"BioCell";
    static NSString *skillIdentifier = @"SkillCell";
    if (indexPath.row == 0) {
        PIctureNameButtonTableViewCell* cell = (PIctureNameButtonTableViewCell *)[self.tableView dequeueReusableCellWithIdentifier:picIdentifier];
//        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
//            NSData *imageData = [NSData dataWithContentsOfURL:[me profPic]];
//            
//            dispatch_async(dispatch_get_main_queue(), ^{
//                // Update the UI
//                cell.picture.image = [UIImage imageWithData:imageData];
//            });
//        });
        cell.picture.image = myPicture;
        
        NSString *name = [NSString stringWithFormat:@"%@ %@", [me firstName], [me lastName]];
        if ([name isEqualToString: @" "]) cell.name.text = [me username];
        else cell.name.text = name;
        cell.email.text = [me email];
        return cell;
    } else if (indexPath.row == 1) {
        UITableViewCell *cell = (UITableViewCell *)[self.tableView dequeueReusableCellWithIdentifier:bioIdentifier];
        UILabel* label = (UILabel *)[cell.contentView viewWithTag:100];
        label.text = [me bio];
        return cell;
    } else {
        UITableViewCell *cell = (UITableViewCell *)[self.tableView dequeueReusableCellWithIdentifier:skillIdentifier];
        int row = indexPath.row - 2;
        UILabel* label = (UILabel *)[cell.contentView viewWithTag:10];
        label.text = [[[me skills] objectAtIndex:row] name];
        return cell;
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}


- (IBAction)save:(UIStoryboardSegue *)segue {
    if ([[segue identifier] isEqualToString:@"saveInput"]) {
        EditViewController *editController = [segue sourceViewController];
        [me setFirstName:editController.firstNameField.text];
        [me setLastName:editController.lastNameField.text];
        [me setEmail:editController.emailField.text];
        [me setBio:editController.bioField.text];
        
        
        [QApiRequests editProfile: [me firstName] andLastName: [me lastName] andBio:[me bio] andEmail:[me email] andProfile:[NSString stringWithFormat:@"%@ %@", [me firstName], [me lastName]] andCallback: saveCallback];
        
        if (editController.hasNewImage == YES) {
            [QApiRequests uploadImage:editController.selectedImage.image andId:[NSString stringWithFormat: @"%i",[me userID]] andCallback:pictureCallback];
            myPicture = editController.selectedImage.image;
        }
        [(UITableView*)_self.tableView reloadData];


    }
    
}




- (IBAction)cancel:(UIStoryboardSegue *)segue {
    
}



void profileCallback (id arg){
    NSLog(@"My Profile JSON: %@", arg);
    if (![arg isKindOfClass: [NSString class]] && [arg isKindOfClass:[NSArray class]] && arg != NULL) {
        NSDictionary *fields = arg[0][@"profile"][0][@"fields"];
        me = [[Person alloc] init];
        me.firstName = fields[@"profile_first"];
        me.lastName = fields[@"profile_last"];
        if (![fields[@"profile_pic"]  isEqual: @""]) {
            NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://qurious.info:8080/%@", fields[@"profile_pic"]]];
            me.profPic = url;
        }
        me.email = fields[@"user_email"];
        me.bio = fields[@"user_bio"];
        me.userID = [fields[@"user"] intValue];
        me.username = fields[@"profile_name"];
        NSDictionary *skills = arg[0][@"skills"];
        NSMutableArray * allmyskills = [[NSMutableArray alloc] init];
        for (NSDictionary * skill in skills) {
            Skill * mySkill = [[Skill alloc] init];
            mySkill.name = skill[@"fields"][@"name"];
            mySkill.desc = skill[@"fields"][@"desc"];
            mySkill.price = skill[@"fields"][@"price"];
            mySkill.skillID = [skill[@"pk"] intValue];
            if ([skill[@"fields"][@"is_marketable"] intValue] == 1) mySkill.isMarketable = YES;
            else mySkill.isMarketable = NO;
            [allmyskills insertObject:mySkill atIndex:0];
        }
        me.skills = allmyskills;
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        NSData *imageData = [NSData dataWithContentsOfURL:[me profPic]];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            // Update the UI
            myPicture = [UIImage imageWithData:imageData];
            [(UITableView*)_self.tableView reloadData];
        });
    });

    //[_self configureView];
    //[_self loadButtons];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Change button color
    //_sideBarButton.tintColor = [UIColor colorWithWhite:0.96f alpha:0.2f];
    
    // Set the side bar button action. When it's tapped, it'll show up the sidebar.
    _sideBarButton.target = self.revealViewController;
    _sideBarButton.action = @selector(revealToggle:);
    
    // Set the gesture
    [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    
    _self = self;
    self.tableView.allowsSelection = NO;

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSInteger myID = [defaults integerForKey:@"myID"];
    [QApiRequests getProfiles: myID andCallback: &profileCallback];

    
}

//- (void)viewWillAppear:(BOOL)animated {
//    [super viewWillAppear:animated];
//    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
//    NSInteger myID = [defaults integerForKey:@"myID"];
//    [QApiRequests getProfiles: myID andCallback: &profileCallback];
//}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
