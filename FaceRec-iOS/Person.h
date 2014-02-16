//
//  Person.h
//  FaceRec-iOS
//
//  Created by Charles Wang on 2/15/14.
//  Copyright (c) 2014 Charles Wang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Person : NSObject
@property (nonatomic, strong) NSString* firstName;
@property (nonatomic, strong) NSString* lastName;
@property (nonatomic, strong) NSString* email;
@property (nonatomic, assign) int trackingID;

-(id) initWithFirstName:(NSString*) firstname LastName:(NSString*) lastname Email:(NSString*) Email;
-(NSString*) fullname;
@end
