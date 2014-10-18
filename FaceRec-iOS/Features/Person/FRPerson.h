//
//  FRPerson.h
//  FaceRec-iOS
//
//  Created by Charles Wang on 2/15/14.
//  Copyright (c) 2014 Charles Wang. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, FRPersonSortMethod)
{
    FRPersonSortMethodByFirstName = 0,
    FRPersonSortMethodByLastName,
    FRPersonSortMethodByEmail,
    FRPersonSortMethodCount,//This must be last
};

@interface FRPerson : NSObject

@property (readonly, nonatomic) NSString *email;

- (NSComparisonResult)compare:(FRPerson*) otherPerson sortMethod:(FRPersonSortMethod)sortMethod;
-(id) initWithFirstName:(NSString*) firstname lastName:(NSString*) lastname email:(NSString*) Email;
-(NSString*) fullname;

- (NSString *)extractFirstLetterWithSortMethod:(FRPersonSortMethod)sortMethod;

- (NSDictionary *)json;

@end
