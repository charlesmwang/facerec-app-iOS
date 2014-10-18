//
//  FRPersonNetworkOperation.h
//  FaceRec-iOS
//
//  Created by Charles Wang on 11/9/14.
//  Copyright (c) 2014 Charles Wang. All rights reserved.
//

#import "FRNetworkOperation.h"

typedef void(^FRPeopleSuccessHandler) (NSArray *people);
typedef void(^FRFailureHandler) (NSError *error);

typedef void(^FRPersonSuccessHandler) (NSArray *people);

@class FRPerson;

@interface FRPersonNetworkOperation : FRNetworkOperation

+ (void)retrievePeopleWithSuccess:(FRPeopleSuccessHandler)success failure:(FRFailureHandler)failure;

+ (void)addPerson:(FRPerson *)person success:(FRPersonSuccessHandler)success failure:(FRFailureHandler)failure;

@end
