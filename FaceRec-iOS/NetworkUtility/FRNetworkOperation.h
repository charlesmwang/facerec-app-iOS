//
//  FRNetworkOperation.h
//  FaceRec-iOS
//
//  Created by Charles Wang on 11/9/14.
//  Copyright (c) 2014 Charles Wang. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, FRNetworkOperationHTTPMethod)
{
    FRNetworkOperationHTTPMethodGET = 0,
    FRNetworkOperationHTTPMethodPOST,
    FRNetworkOperationHTTPMethodPUT,
    FRNetworkOperationHTTPMethodDELETE
};

typedef void(^FRFailureHandler) (NSError *error);

@interface FRNetworkOperation : NSObject

+ (NSURLRequest *)createURLRequestWithURLPath:(NSString *)urlPath httpMethod:(FRNetworkOperationHTTPMethod)httpMethod;
+ (instancetype)sharedInstance;

@end
