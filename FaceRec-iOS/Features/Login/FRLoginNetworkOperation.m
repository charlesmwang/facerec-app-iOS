//
//  FRLoginNetworkOperation.m
//  FaceRec-iOS
//
//  Created by Charles Wang on 11/8/14.
//  Copyright (c) 2014 Charles Wang. All rights reserved.
//

#import "FRLoginNetworkOperation.h"
#import "FRAccessToken.h"

static NSString * const kLoginURL = @"/login";

@interface FRLoginNetworkOperation () <NSURLSessionDelegate>

@end

@implementation FRLoginNetworkOperation

+ (void)performLoginWithUsername:(NSString *)username
                        password:(NSString *)password
                         success:(FRLoginSuccessHandler)success
                         failure:(FRFailureHandler)failure
{
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:[self sharedInstance] delegateQueue:[NSOperationQueue mainQueue]];
    
    NSDictionary *loginCredentials = @{
                                       @"username" : username,
                                       @"password" : password,
                                       };
    
    NSError *errorInJSONSerialization;
    
    NSData *uploadData = [NSJSONSerialization dataWithJSONObject:loginCredentials options:NSJSONWritingPrettyPrinted error:&errorInJSONSerialization];
    
    if(errorInJSONSerialization)
    {
        failure(errorInJSONSerialization);
        return;
    }
    
    NSURLRequest *request = [self createURLRequestWithURLPath:kLoginURL httpMethod:FRNetworkOperationHTTPMethodPOST];
    
    [[session uploadTaskWithRequest:request fromData:uploadData completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
         if(error)
         {
             failure(error);
         }
         else
         {
             if([((NSHTTPURLResponse *)response) statusCode] == 200)
             {
                 NSError *errorInJSON;
                 NSDictionary *jsonResponse = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&errorInJSON];
                 if(errorInJSON)
                 {
                     failure(errorInJSON);
                 }
                 else
                 {
                     FRAccessToken *accessToken = [[FRAccessToken alloc] initWithAccessToken:[jsonResponse objectForKey:@"access_token"] expirationDate:[jsonResponse objectForKey:@"expiration"]];
                     success(accessToken);
                 }
             }
             else
             {
                 failure(nil);
             }
         }
     }] resume];
}


@end
