//
//  FRMainMenuNetworkOperation.m
//  FaceRec-iOS
//
//  Created by Charles Wang on 11/9/14.
//  Copyright (c) 2014 Charles Wang. All rights reserved.
//

#import "FRMainMenuNetworkOperation.h"

static NSString * const kLogoutURL = @"/logout";

@implementation FRMainMenuNetworkOperation

+ (void)performLogoutWithSuccess:(FRLogoutSuccessHandler)success failure:(FRFailureHandler)failure
{
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:[self sharedInstance] delegateQueue:[NSOperationQueue mainQueue]];
    
    NSURLRequest *request = [self createURLRequestWithURLPath:kLogoutURL httpMethod:FRNetworkOperationHTTPMethodGET];
    
    [[session downloadTaskWithRequest:request completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error) {
        if(error)
        {
            failure(error);
        }
        else
        {
            success();
        }
    }] resume];
    
}

@end
