//
//  FRUser.h
//  FaceRec-iOS
//
//  Created by Charles Wang on 2/16/14.
//  Copyright (c) 2014 Charles Wang. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FRAccessToken;

@interface FRUser : NSObject

+ (instancetype)sharedInstance;

- (void)loggedInWithUsername:(NSString *)username accessToken:(FRAccessToken *)accessToken;
- (id)initWithUsername:(NSString *)m_username token:m_token expiration:(NSString *)date;
- (void)logout;

- (NSDictionary *)json;
- (NSString *)generateSubURL;

@property (nonatomic, readonly) NSString *username;
@property (nonatomic, readonly) NSString *access_token;

@end
