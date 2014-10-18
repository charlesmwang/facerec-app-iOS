//
//  FRNetworkOperation.m
//  FaceRec-iOS
//
//  Created by Charles Wang on 11/9/14.
//  Copyright (c) 2014 Charles Wang. All rights reserved.
//

#import "FRNetworkOperation.h"

static NSTimeInterval const kTimeoutInterval = 5.0;

@interface FRNetworkOperation () <NSURLSessionDelegate>

@end

@implementation FRNetworkOperation

+ (instancetype)sharedInstance
{
    static dispatch_once_t once;
    static id sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

+ (NSURLRequest *)createURLRequestWithURLPath:(NSString *)urlPath httpMethod:(FRNetworkOperationHTTPMethod)httpMethod
{
    NSURL *url = [NSURL URLWithString:[@"http://192.168.1.125:1337" stringByAppendingString:urlPath]];
    
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:kTimeoutInterval];
    
    switch (httpMethod)
    {
        case FRNetworkOperationHTTPMethodGET:
            urlRequest.HTTPMethod = @"GET";
            break;
        case FRNetworkOperationHTTPMethodPOST:
            urlRequest.HTTPMethod = @"POST";
            break;
        case FRNetworkOperationHTTPMethodPUT:
            urlRequest.HTTPMethod = @"PUT";
            break;
        case FRNetworkOperationHTTPMethodDELETE:
            urlRequest.HTTPMethod = @"DELETE";
            break;
        default:
            break;
    }
    
    [urlRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    return urlRequest;
}

#pragma mark - Delegate

- (void)URLSession:(NSURLSession *)session
didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge
 completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential *))completionHandler
{
    completionHandler(NSURLSessionAuthChallengeUseCredential, [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust]);
}

@end
