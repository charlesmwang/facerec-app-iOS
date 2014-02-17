//
//  FaceRecServer.m
//  FaceRec-iOS
//
//  Created by Charles Wang on 1/29/14.
//  Copyright (c) 2014 Charles Wang. All rights reserved.
//

#import "FaceRecServer.h"

@implementation FaceRecServer
@synthesize ip_address, port, isUsingSSL, URL;

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
        self.isUsingSSL = NO;
        //server.URL = [NSString stringWithFormat:@"http://%@:%d",server.ip_address, server.port];
    }
    return server;
}

- (NSString*) url
{
    if(isUsingSSL)
        return [NSString stringWithFormat:@"https://%@:%d",server.ip_address, server.port];
    else
        return [NSString stringWithFormat:@"http://%@:%d",server.ip_address, server.port];
}

- (NSString*) goToURL: (NSString*) path
{
    if(isUsingSSL)
        return [NSString stringWithFormat:@"https://%@:%d%@",server.ip_address, server.port, path];
    else
        return [NSString stringWithFormat:@"http://%@:%d%@",server.ip_address, server.port, path];
}

-(void) clear
{
    ip_address = nil;
    port = -1;
}


@end