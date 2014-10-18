//
//  FRAccessToken.m
//  FaceRec-iOS
//
//  Created by Charles Wang on 11/8/14.
//  Copyright (c) 2014 Charles Wang. All rights reserved.
//

#import "FRAccessToken.h"

@interface FRAccessToken () <NSCopying>

@property (nonatomic, copy) NSString *accessToken;
@property (nonatomic, copy) NSDate *expirationDate;

@end

@implementation FRAccessToken

- (instancetype)initWithAccessToken:(NSString *)accessToken expirationDate:(NSString *)expirationDate
{
    self = [super init];
    if(self)
    {
        _accessToken = accessToken;
        NSDateFormatter *df = [[NSDateFormatter alloc] init];
        NSTimeZone *timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
        [df setTimeZone:timeZone];
        [df setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"];
        _expirationDate = [df dateFromString:expirationDate];
    }
    return self;
}

- (NSDictionary *)json
{
    return @{
             @"accessToken":self.accessToken,
             };
}

- (id)copyWithZone:(NSZone *)zone
{
    FRAccessToken *copy = [[FRAccessToken allocWithZone:zone] init];
    copy.accessToken = [_accessToken copy];
    copy.expirationDate = [_expirationDate copy];
    return copy;
}

@end
