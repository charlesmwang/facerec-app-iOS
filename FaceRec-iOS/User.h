//
//  User.h
//  FaceRec-iOS
//
//  Created by Charles Wang on 2/16/14.
//  Copyright (c) 2014 Charles Wang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface User : NSObject


+ (User*) CurrentUser;
- (id)initWithUsername: (NSString*)_username token:_token;
- (void) logout;

@property (nonatomic, strong) NSString* username;
@property (nonatomic, strong) NSString* access_token;

//@property (nonatomic, strong) NSDate* expiration;

@end
