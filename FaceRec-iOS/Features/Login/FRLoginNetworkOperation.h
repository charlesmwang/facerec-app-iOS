//
//  FRLoginNetworkOperation.h
//  FaceRec-iOS
//
//  Created by Charles Wang on 11/8/14.
//  Copyright (c) 2014 Charles Wang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FRNetworkOperation.h"

@class FRAccessToken;

typedef void(^FRLoginSuccessHandler) (FRAccessToken *accessToken);

@interface FRLoginNetworkOperation : FRNetworkOperation

+ (void)performLoginWithUsername:(NSString *)username
                        password:(NSString *)password
                         success:(FRLoginSuccessHandler)success
                         failure:(FRFailureHandler)failure;

@end
