//
//  FRUser.m
//  FaceRec-iOS
//
//  Created by Charles Wang on 2/16/14.
//  Copyright (c) 2014 Charles Wang. All rights reserved.
//

#import "FRUser.h"
#import "FRAccessToken.h"

@interface FRUser ()

@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSDate *expiration;
@property (copy, nonatomic) FRAccessToken *accessToken;

@end

@implementation FRUser

+ (instancetype)sharedInstance
{
    static dispatch_once_t once;
    static id sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (void)loggedInWithUsername:(NSString *)username accessToken:(FRAccessToken *)accessToken
{
    self.username = username;
    self.accessToken = accessToken;
}

- (id)initWithUsername: (NSString*)m_username token:m_token expiration:(NSString*) date
{
    self = [super init];
    if(self)
    {
        self.username = m_username;
        NSDateFormatter *df = [[NSDateFormatter alloc] init];
        NSTimeZone *timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
        [df setTimeZone:timeZone];
        [df setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"];
        self.expiration = [df dateFromString:date];
    }
    return self;
}

-(void) logout
{
    self.username = nil;
    self.accessToken = nil;
}

- (NSDictionary *)json
{
    return @{
             @"username":self.username,
             @"accessToken":[self.accessToken json],
             };
}

- (NSString *)generateSubURL
{
    return [NSString stringWithFormat:@"?username=%@&token=%@",self.username,self.accessToken.accessToken];
}


@end
