//
//  User.m
//  FaceRec-iOS
//
//  Created by Charles Wang on 2/16/14.
//  Copyright (c) 2014 Charles Wang. All rights reserved.
//

#import "User.h"

@implementation User

static User *CurrentUser = nil;

+ (User*) CurrentUser
{
    if(CurrentUser == nil)
    {
        return nil;
    }
    return CurrentUser;
}

- (id)initWithUsername: (NSString*)m_username token:m_token
{
    CurrentUser = [super init];
    if(self)
    {
        self.username = m_username;
        self.access_token = m_token;
    }
    return self;
}

-(void) logout
{
    self.username = nil;
    self.access_token = nil;
}
@end
