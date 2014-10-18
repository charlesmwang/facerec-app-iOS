//
//  FRMainMenuNetworkOperation.h
//  FaceRec-iOS
//
//  Created by Charles Wang on 11/9/14.
//  Copyright (c) 2014 Charles Wang. All rights reserved.
//

#import "FRNetworkOperation.h"

typedef void(^FRLogoutSuccessHandler) (void);

@interface FRMainMenuNetworkOperation : FRNetworkOperation

+ (void)performLogoutWithSuccess:(FRLogoutSuccessHandler)success failure:(FRFailureHandler)failure;

@end
