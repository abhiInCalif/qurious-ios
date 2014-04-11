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
    OTSession* _session;
    OTPublisher* _publisher;
    OTSubscriber* _subscriber;
}

// Take care of this later
static double widgetHeight = 240;
static double widgetWidth = 320;
static NSString* kApiKey = @"";    // Replace with your OpenTok API key
static NSString* kSessionId = @""; // Replace with your generated session ID
static NSString* kToken = @"";     // Replace with your generated token (use the Dashboard or an OpenTok server-side library)

void callback(id arg) {
    
    // do nothing valuable
    NSLog(@"JSON: %@", arg);
    printf("%s", "Hi");
    
    NSDictionary * results = arg;
    for (NSDictionary *jsonobject in results) {
        NSDictionary *fields = jsonobject[@"fields"];
        kApiKey = fields[@"api"];
        kSessionId = fields[@"session"];
        kToken = fields[@"token"];
    }
}


static bool subscribeToSelf = NO; // Change to NO to subscribe to streams other than your own.

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    _session = [[OTSession alloc] initWithSessionId:kSessionId
                                           delegate:self];
    [QApiRequests getVideo:&callback];

    [self doConnect];
}

#pragma mark - OpenTok methods

- (void)doConnect
{
    [_session connectWithApiKey:kApiKey token:kToken];
}

- (void)sessionDidConnect:(OTSession*)session
{
    NSLog(@"sessionDidConnect (%@)", session.sessionId);
    [self doPublish];
}

- (void)doPublish
{
    _publisher = [[OTPublisher alloc] initWithDelegate:self];
    [_publisher setName:[[UIDevice currentDevice] name]];
    [_session publish:_publisher];
    [self.view addSubview:_publisher.view];
    [_publisher.view setFrame:CGRectMake(0, 0, widgetWidth, widgetHeight)];
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

- (void)subscriberDidConnectToStream:(OTSubscriber*)subscriber
{
    NSLog(@"subscriberDidConnectToStream (%@)", subscriber.stream.connection.connectionId);
    [subscriber.view setFrame:CGRectMake(0, widgetHeight, widgetWidth, widgetHeight)];
    [self.view addSubview:subscriber.view];
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

- (void)updateSubscriber {
    for (NSString* streamId in _session.streams) {
        OTStream* stream = [_session.streams valueForKey:streamId];
        if (![stream.connection.connectionId isEqualToString: _session.connection.connectionId]) {
            _subscriber = [[OTSubscriber alloc] initWithStream:stream delegate:self];
            break;
        }
    }
}

- (void)sessionDidDisconnect:(OTSession*)session
{
    NSString* alertMessage = [NSString stringWithFormat:@"Session disconnected: (%@)", session.sessionId];
    NSLog(@"sessionDidDisconnect (%@)", alertMessage);
    [self showAlert:alertMessage];
}

- (void)session:(OTSession*)session didFailWithError:(OTError*)error {
    NSLog(@"sessionDidFail");
    [self showAlert:[NSString stringWithFormat:@"There was an error connecting to session %@", session.sessionId]];
}

@end
