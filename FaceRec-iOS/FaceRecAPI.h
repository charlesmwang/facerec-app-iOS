//
//  FaceRecAPI.h
//  FaceRec-iOS
//
//  Created by Charles Wang on 2/15/14.
//  Copyright (c) 2014 Charles Wang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Person.h"

@interface FaceRecAPI : NSObject

+ (void) createAccount:(NSDictionary*) dict response:(NSDictionary**)response error:(NSError**) error;
+ (void) login:(NSDictionary*) dict response:(NSDictionary**) response error:(NSError**) error;
+ (void) getPeopleList:(NSDictionary*) dict response:(NSArray**) response error:(NSError**) error;
+ (void) addPerson:(NSDictionary*) dict response:(NSDictionary**) response error:(NSError**) error;
+ (void) addFace:(NSDictionary*) dict response:(NSDictionary**) response error:(NSError**)error;
+ (NSString*)imageToBase64:(UIImage*) image;
+ (void) logout:(NSDictionary*) response error:(NSError**) error;

@end
