//
//  FRAccessToken.h
//  FaceRec-iOS
//
//  Created by Charles Wang on 11/8/14.
//  Copyright (c) 2014 Charles Wang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FRAccessToken : NSObject

@property (nonatomic, copy, readonly) NSString *accessToken;
@property (nonatomic, copy, readonly) NSDate *expirationDate;

- (instancetype)initWithAccessToken:(NSString *)accessToken expirationDate:(NSString *)expirationDate;

- (NSDictionary *)json;

@end
