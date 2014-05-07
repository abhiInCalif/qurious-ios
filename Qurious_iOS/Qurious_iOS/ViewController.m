//
//  ViewController.m
//  Qurious_iOS
//
//  Created by Aditya Agarwalla on 4/9/14.
//  Copyright (c) 2014 Qurious. All rights reserved.
//

#import "ViewController.h"
#import "QApiRequests.h"

@implementation ViewController {
    OTPublisher* _publisher;
    OTSubscriber* _subscriber;
    __weak IBOutlet UIView *navPopup;
}
@synthesize session = _session;

static NSString* const kApiKey = @"44722692";    // Replace with your OpenTok API key
static NSString* kSessionId = @"2_MX40NDcyMjY5Mn5-U2F0IEFwciAxMiAxOTo0MjowOSBQRFQgMjAxNH4wLjMxMjIyMjU0fn4"; // Replace with your generated session ID
static NSString* kToken = @"";    // Replace with your generated token (use the Dashboard or an OpenTok server-side library)
static void* object;
static double widgetHeight;
static double widgetWidth;


void sessioncallback(id arg) {
    // do nothing valuable
    NSLog(@"Get Token JSON: %@", arg);
    if ([arg isKindOfClass: [NSDictionary class]] &&  [arg objectForKey:@"token"] != nil) {
        kToken = ((NSDictionary*) arg)[@"token"];
        [(__bridge ViewController*)object doConnect];
    }
}

static bool subscribeToSelf = NO; // Change to NO to subscribe to streams other than your own.

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    widgetHeight = screenRect.size.height / 2;
    widgetWidth = screenRect.size.width;
    //[self.navigationItem setHidesBackButton:YES animated:NO];
    //self.navigationController.navigationBar.hidden = YES;
    object = (__bridge void *)(self);
    _session = [[OTSession alloc] initWithSessionId:kSessionId
                                           delegate:self];
    [QApiRequests getToken:kSessionId andCallback:&sessioncallback];
    /*UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showHideNavbar:)];
    tapRecognizer.numberOfTapsRequired = 2;
    [navPopup addGestureRecognizer:tapRecognizer];*/
    
}
/*
-(void) showHideNavbar:(id) sender
{
    if (self.navigationController.navigationBar.hidden == NO)
    {
        [self.navigationController setNavigationBarHidden:YES animated:YES];
    }
    else if (self.navigationController.navigationBar.hidden == YES)
    {
        [self.navigationController setNavigationBarHidden:NO animated:YES];
    }
}*/

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

+ (void) setSessionToken:(NSString*)sessionID {
    kSessionId = sessionID;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return NO;
    } else {
        return YES;
    }
}

- (void)updateSubscriber {
    for (NSString* streamId in _session.streams) {
        OTStream* stream = [_session.streams valueForKey:streamId];
        if (![stream.connection.connectionId isEqualToString: _session.connection.connectionId]) {
            _subscriber = [[OTSubscriber alloc] initWithStream:stream delegate:self];
            break;
        }
    }
}

- (IBAction)endClicked:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
    [_session disconnect]; // exit out of controller
    
}

#pragma mark - OpenTok methods

- (void)doConnect
{
    [_session connectWithApiKey:kApiKey token:kToken];
}

- (void)doPublish
{
    _publisher = [[OTPublisher alloc] initWithDelegate:self];
    [_publisher setName:[[UIDevice currentDevice] name]];
    [_session publish:_publisher];
    [self.view addSubview:_publisher.view];
    [_publisher.view setFrame:CGRectMake(widgetWidth - 120, widgetHeight*2 - 200, 120, 120)];
    UIButton *endButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [endButton addTarget:self
                  action:@selector(endClicked:)
        forControlEvents:UIControlEventTouchUpInside];
    endButton.titleLabel.font = [UIFont systemFontOfSize:16.0];
    [endButton setTitle:@"End" forState:UIControlStateNormal];
    endButton.frame = CGRectMake(widgetWidth/4, widgetHeight * 2 - 50, widgetWidth/2, 40.0);
    [endButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [endButton setBackgroundColor:[UIColor redColor]];
    [self.view addSubview:endButton];
}

- (void)sessionDidConnect:(OTSession*)session
{
    NSLog(@"sessionDidConnect (%@)", session.sessionId);
    [self doPublish];
}

- (void)sessionDidDisconnect:(OTSession*)session
{
    NSString* alertMessage = [NSString stringWithFormat:@"Session disconnected: (%@)", session.sessionId];
    NSLog(@"sessionDidDisconnect (%@)", alertMessage);
    //[self showAlert:alertMessage];
}


- (void)session:(OTSession*)mySession didReceiveStream:(OTStream*)stream
{
    NSLog(@"session didReceiveStream (%@)", stream.streamId);
    
    // See the declaration of subscribeToSelf above.
    if ( (subscribeToSelf && [stream.connection.connectionId isEqualToString: _session.connection.connectionId])
        ||
        (!subscribeToSelf && ![stream.connection.connectionId isEqualToString: _session.connection.connectionId])
        ) {
        if (!_subscriber) {
            _subscriber = [[OTSubscriber alloc] initWithStream:stream delegate:self];
        }
    }
}

- (void)session:(OTSession*)session didDropStream:(OTStream*)stream{
    NSLog(@"session didDropStream (%@)", stream.streamId);
    NSLog(@"_subscriber.stream.streamId (%@)", _subscriber.stream.streamId);
    if (!subscribeToSelf
        && _subscriber
        && [_subscriber.stream.streamId isEqualToString: stream.streamId])
    {
        _subscriber = nil;
        [self updateSubscriber];
    }
}

- (void)session:(OTSession *)session didCreateConnection:(OTConnection *)connection {
    NSLog(@"session didCreateConnection (%@)", connection.connectionId);
}

- (void) session:(OTSession *)session didDropConnection:(OTConnection *)connection {
    NSLog(@"session didDropConnection (%@)", connection.connectionId);
}

- (void)subscriberDidConnectToStream:(OTSubscriber*)subscriber
{
    NSLog(@"subscriberDidConnectToStream (%@)", subscriber.stream.connection.connectionId);
    [subscriber.view setFrame:CGRectMake(-widgetWidth/2, 0, 2*widgetWidth, widgetHeight*2)];
    [self.view addSubview:subscriber.view];
    UIButton *endButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [endButton addTarget:self
                  action:@selector(endClicked:)
        forControlEvents:UIControlEventTouchUpInside];
    if (_publisher)
    {
        [self.view bringSubviewToFront:_publisher.view];
    }
    endButton.titleLabel.font = [UIFont systemFontOfSize:16.0];
    [endButton setTitle:@"End" forState:UIControlStateNormal];
    endButton.frame = CGRectMake(widgetWidth/4, widgetHeight * 2 - 50, widgetWidth/2, 40.0);
    [endButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [endButton setBackgroundColor:[UIColor redColor]];
    [self.view addSubview:endButton];
}

- (void)publisher:(OTPublisher*)publisher didFailWithError:(OTError*) error {
    NSLog(@"publisher didFailWithError %@", error);
    [self showAlert:[NSString stringWithFormat:@"There was an error publishing."]];
}

- (void)subscriber:(OTSubscriber*)subscriber didFailWithError:(OTError*)error
{
    NSLog(@"subscriber %@ didFailWithError %@", subscriber.stream.streamId, error);
    [self showAlert:[NSString stringWithFormat:@"There was an error subscribing to stream %@", subscriber.stream.streamId]];
}

- (void)session:(OTSession*)session didFailWithError:(OTError*)error {
    NSLog(@"sessionDidFail");
    [self showAlert:[NSString stringWithFormat:@"There was an error connecting to session %@", session.sessionId]];
}



- (void)showAlert:(NSString*)string {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Message from video session"
                                                    message:string
                                                   delegate:self
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}

@end
