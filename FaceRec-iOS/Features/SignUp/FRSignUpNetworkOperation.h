//
//  FRSignUpNetworkOperation.h
//  FaceRec-iOS
//
//  Created by Charles Wang on 11/9/14.
//  Copyright (c) 2014 Charles Wang. All rights reserved.
//

#import "FRNetworkOperation.h"

typedef void(^FRSignUpSuccessHandler) (void);

@interface FRSignUpNetworkOperation : FRNetworkOperation

+ (void)performSignUpWithFirstName:(NSString *)firstName
                          lastName:(NSString *)lastName
                             email:(NSString *)email
                          username:(NSString *)username
                          password:(NSString *)password
                           success:(FRSignUpSuccessHandler)success
                           failure:(FRFailureHandler)failure;
@end
