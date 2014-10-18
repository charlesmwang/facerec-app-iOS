//
//  FRSignUpNetworkOperation.m
//  FaceRec-iOS
//
//  Created by Charles Wang on 11/9/14.
//  Copyright (c) 2014 Charles Wang. All rights reserved.
//

#import "FRSignUpNetworkOperation.h"

static NSString * const kSignUpURL = @"/signup";

@implementation FRSignUpNetworkOperation

+ (void)performSignUpWithFirstName:(NSString *)firstName
                          lastName:(NSString *)lastName
                             email:(NSString *)email
                          username:(NSString *)username
                          password:(NSString *)password
                           success:(FRSignUpSuccessHandler)success
                           failure:(FRFailureHandler)failure
{
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:[self sharedInstance] delegateQueue:[NSOperationQueue mainQueue]];
    
    NSDictionary *newUser = @{
                              @"firstname":firstName,
                              @"lastname":lastName,
                              @"email":email,
                              @"username":username,
                              @"password":password
                              };
    
    NSURLRequest *urlRequest = [self createURLRequestWithURLPath:kSignUpURL httpMethod:FRNetworkOperationHTTPMethodPOST];
    
    NSError *errorInJSONSerialization;
    
    NSData *uploadData = [NSJSONSerialization dataWithJSONObject:newUser options:NSJSONWritingPrettyPrinted error:&errorInJSONSerialization];
    
    if(errorInJSONSerialization)
    {
        failure(errorInJSONSerialization);
        return;
    }
    
    [[session uploadTaskWithRequest:urlRequest fromData:uploadData completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if(error)
        {
            failure(error);
        }
        else
        {
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
            if ([httpResponse statusCode] == 201)
            {
                success();
            }
            else
            {
                failure(nil);
            }
        }
    }] resume];
    
}

@end
