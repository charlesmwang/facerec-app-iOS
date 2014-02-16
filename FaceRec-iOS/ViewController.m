//
//  ViewController.m
//  FaceRec-iOS
//
//  Created by Charles Wang on 1/29/14.
//  Copyright (c) 2014 Charles Wang. All rights reserved.
//

#import "ViewController.h"
#import "SocketIOJSONSerialization.h"

@interface ViewController ()

@end

@implementation ViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //handshake
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://localhost:1337/"] cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:10];
    
    [request setHTTPMethod: @"GET"];
    
    NSError *requestError;
    NSURLResponse *urlResponse = nil;
    NSData *response1 = [NSURLConnection sendSynchronousRequest:request returningResponse:&urlResponse error:&requestError];
    
	// Do any additional setup after loading the view.
    FaceRecServer *server = [[FaceRecServer alloc]initWithIpAddress:@"localhost" port:1337];
    _socket = [[SocketIO alloc] initWithDelegate:self];
    [_socket connectToHost:server.ip_address onPort:server.port];
    //[socket sendMessage:@"hello world"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) socketIODidConnect:(SocketIO *)socket
{
    NSLog(@"YES!");
}

-(void) socketIO:(SocketIO *)socket didReceiveEvent:(SocketIOPacket *)packet
{
    if([packet.name isEqualToString:@"world"])
    {
        NSArray *data = [[packet dataAsJSON] objectForKey:@"args"];
        NSLog(@"%@",[data objectAtIndex:0]);
        NSDictionary *json = [data objectAtIndex:0];
        
        NSLog(@"Name: %@, Message %@",[json objectForKey:@"name"], [json objectForKey:@"message"]);
    }
    else if([packet.name isEqualToString:@"error"])
    {
        NSArray *data = [[packet dataAsJSON] objectForKey:@"args"];
        NSLog(@"%@",[data objectAtIndex:0]);
        NSDictionary *json = [data objectAtIndex:0];
        
        NSLog(@"Message %@",[json objectForKey:@"message"]);
    }
}

- (void) socketIO:(SocketIO *)socket didReceiveJSON:(SocketIOPacket *)packet
{
    NSLog(@"Here as well!");
}

- (IBAction)greeting:(id)sender {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:@"Charles" forKey:@"username"];
    [dict setObject:@"From iOS App" forKey:@"image"];
    [dict setObject:@".jpg" forKey:@"imageformat"];
    
    [_socket sendEvent:@"recognize" withData:dict];
}

@end
