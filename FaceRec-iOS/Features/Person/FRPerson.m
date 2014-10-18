//
//  FRPerson.m
//  FaceRec-iOS
//
//  Created by Charles Wang on 2/15/14.
//  Copyright (c) 2014 Charles Wang. All rights reserved.
//

#import "FRPerson.h"

@interface FRPerson ()<NSCopying>

@property (nonatomic, strong) NSString* firstName;
@property (nonatomic, strong) NSString* lastName;
@property (nonatomic, strong) NSString* email;
@property (nonatomic, assign) NSUInteger trackingID;
@property (nonatomic, strong) NSMutableDictionary* services;

@end

@implementation FRPerson

- (id)initWithFirstName:(NSString*) firstname lastName:(NSString*) lastname email:(NSString*) Email
{
    self = [super init];
    if(self)
    {
        _firstName = firstname;
        _lastName = lastname;
        _email = Email;
        _trackingID = -1;
    }
    return self;
}

- (NSString*)fullname
{
    return [NSString stringWithFormat:@"%@ %@",self.firstName, self.lastName];
}

- (NSComparisonResult)compare:(FRPerson*) otherPerson sortMethod:(FRPersonSortMethod)sortMethod
{
    //Add more cases
    NSComparisonResult result = 0;
    switch (sortMethod)
    {
        case FRPersonSortMethodByFirstName:
            result = [[self.firstName uppercaseString] compare:[otherPerson.firstName uppercaseString]];
            break;
        case FRPersonSortMethodByLastName:
            result = [[self.lastName uppercaseString] compare:[otherPerson.lastName uppercaseString]];
            break;
        case FRPersonSortMethodByEmail:
            result = [[self.email uppercaseString] compare:[otherPerson.email uppercaseString]];
            break;
        default:
            NSAssert(nil, @"It should never reach here");
            break;
    }
    return result;
}

- (NSString *)extractFirstLetterWithSortMethod:(FRPersonSortMethod)sortMethod
{
    NSString *firstCharacter;
    switch (sortMethod)
    {
        case FRPersonSortMethodByFirstName:
            firstCharacter = [self.firstName substringToIndex:1];
            break;
        case FRPersonSortMethodByLastName:
            firstCharacter = [self.lastName substringToIndex:1];
            break;
        case FRPersonSortMethodByEmail:
            firstCharacter = [self.email substringToIndex:1];
            break;
        default:
            NSAssert(nil, @"It should never reach here");
            break;
    }
    return firstCharacter;
}

- (NSDictionary *)json
{
    return @{
             @"firstname":self.firstName,
             @"lastname" :self.lastName,
             @"email"    :self.email,
             };
}

- (id)copyWithZone:(NSZone *)zone
{
    FRPerson *copy = [[FRPerson allocWithZone:zone] init];
    copy.firstName = [_firstName copy];
    copy.lastName = [_lastName copy];
    copy.email = [_email copy];
    copy.trackingID = _trackingID;
    copy.services = [_services copy];
    return copy;
}



@end
