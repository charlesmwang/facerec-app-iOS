//
//  FRPersonNetworkOperation.m
//  FaceRec-iOS
//
//  Created by Charles Wang on 11/9/14.
//  Copyright (c) 2014 Charles Wang. All rights reserved.
//

#import "FRPersonNetworkOperation.h"
#import "FRPerson.h"
#import "FRUser.h"

static NSString *const kPeopleURL = @"/people";

static NSString *const kFirstNameKey = @"firstname";
static NSString *const kLastNameKey = @"lastname";
static NSString *const kEmailKey = @"email";

@implementation FRPersonNetworkOperation

+ (void)retrievePeopleWithSuccess:(FRPeopleSuccessHandler)success failure:(FRFailureHandler)failure
{
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:[self sharedInstance] delegateQueue:[NSOperationQueue mainQueue]];
    
    FRUser *currentUser = [FRUser sharedInstance];
    
    
    NSURLRequest *urlRequest = [self createURLRequestWithURLPath:[kPeopleURL stringByAppendingString:[currentUser generateSubURL]]
                                                      httpMethod:FRNetworkOperationHTTPMethodGET];
    
    [[session downloadTaskWithRequest:urlRequest completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error) {
        if(error)
        {
            failure(error);
        }
        else
        {
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
            if([httpResponse statusCode] == 200)
            {
                NSArray *jsonArray = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfURL:location]
                                                                      options:NSJSONReadingAllowFragments
                                                                        error:&error];
                if(error)
                {
                    failure(error);
                }
                else
                {
                    NSMutableArray *people = [NSMutableArray arrayWithCapacity:[jsonArray count]];
                    
                    for (NSUInteger i = 0; i < [jsonArray count]; i++)
                    {
                        NSDictionary *personDictionary = jsonArray[i];
                        people[i] = [[FRPerson alloc] initWithFirstName:personDictionary[kFirstNameKey]
                                                               lastName:personDictionary[kLastNameKey]
                                                                  email:personDictionary[kEmailKey]];
                    }
                    
                    success([NSArray arrayWithArray:people]);
                }
                
            }
            else
            {
                failure(nil);
            }
        }
    }] resume];
    
}

+ (void)addPerson:(FRPerson *)person success:(FRPersonSuccessHandler)success failure:(FRFailureHandler)failure
{
    
}

@end
