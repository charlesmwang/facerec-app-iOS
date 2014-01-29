//
//  FaceRecServer.m
//  FaceRec-iOS
//
//  Created by Charles Wang on 1/29/14.
//  Copyright (c) 2014 Charles Wang. All rights reserved.
//

#import "FaceRecServer.h"

@implementation FaceRecServer
@synthesize ip_address, port, URL;

static FaceRecServer *server = nil;

+ (FaceRecServer *) Server
{
    if(server == nil)
    {
        return nil;
    }
    return server;
}

- (id)initWithIpAddress: (NSString*)ipaddress port:(int)port_num
{
    if(server != nil)
    {
        [server clear];
    }
    server = [super init];
    if (server)
    {
        server.ip_address = ipaddress;
        server.port = port_num;
        server.URL = [NSString stringWithFormat:@"http://%@:%d",server.ip_address, server.port];
    }
    return server;
}

/*+(BOOL)test_connection
{
    if(server == nil)
        return NO;
    
    NSMutableString* url_string = [[NSMutableString alloc]init];
    
    //Getting Server IP Address
    [url_string appendString:[server URL]];
    [url_string appendString:@"/utility/test_connection/"];
    NSLog(@"%@",url_string);
    NSURL* url = [[NSURL alloc]initWithString:url_string];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:5.0];
    [request setHTTPMethod:@"POST"];
    NSError *error = nil;
    
    NSHTTPURLResponse *statusResponse = nil;
    [NSURLConnection sendSynchronousRequest:request returningResponse:&statusResponse error:&error];
    
    if(statusResponse != nil && [statusResponse statusCode] == 699)
    {
        return YES;
    }
    
    return NO;
}*/

-(void) clear
{
    ip_address = nil;
    port = -1;
}


@end