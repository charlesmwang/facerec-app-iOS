//
//  FaceRecServer.h
//  FaceRec-iOS
//
//  Created by Charles Wang on 1/29/14.
//  Copyright (c) 2014 Charles Wang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FaceRecServer : NSObject

+ (FaceRecServer *) Server;
- (id)initWithIpAddress: (NSString*)ipaddress port:(int)port_num;
//+ (BOOL)test_connection;
-(void) clear;

@property (nonatomic,strong) NSString* ip_address;
@property (nonatomic,assign) int port;
@property (nonatomic,strong) NSString* URL;
@end