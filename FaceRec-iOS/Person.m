//
//  Person.m
//  FaceRec-iOS
//
//  Created by Charles Wang on 2/15/14.
//  Copyright (c) 2014 Charles Wang. All rights reserved.
//

#import "Person.h"

@implementation Person

@synthesize firstName, lastName, email, trackingID, services;

-(id) initWithFirstName:(NSString*) firstname LastName:(NSString*) lastname Email:(NSString*) Email
{
    self = [super init];
    if(self)
    {
        self.firstName = firstname;
        self.lastName = lastname;
        self.email = Email;
        self.trackingID = -1;
        self.sortUser = [firstName uppercaseString];
    }
    return self;
}

-(NSString*) fullname
{
    return [NSString stringWithFormat:@"%@ %@",self.firstName, self.lastName];
}

-(NSComparisonResult) compare:(Person*) other {
    return [[other.firstName uppercaseString] compare:[other.firstName uppercaseString]];
}


@end
