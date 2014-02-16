//
//  FaceRecAPI.m
//  FaceRec-iOS
//
//  Created by Charles Wang on 2/15/14.
//  Copyright (c) 2014 Charles Wang. All rights reserved.
//

#import "FaceRecAPI.h"

@implementation FaceRecAPI

/*
 *@param dict
 *@param response
 *@param error
 */
+(void) createAccount:(NSDictionary*) dict response:(NSDictionary**)response error:(NSError**) error{
    //Check if the parameters exist.
    if([dict objectForKey:@"firstname"] && [dict objectForKey:@"lastname"] && [dict objectForKey:@"email"] &&
            [dict objectForKey:@"username"] && [dict objectForKey:@"password"])
    {
        NSDictionary* requestObjects = [[NSDictionary alloc] initWithObjectsAndKeys:
                                       [dict objectForKey:@"firstname"], @"firstname",
                                       [dict objectForKey:@"lastname"], @"lastname",
                                       [dict objectForKey:@"email"], @"email",
                                       [dict objectForKey:@"username"], @"username",
                                       [dict objectForKey:@"password"], @"password",
                                       nil];
        NSMutableURLRequest* request = [self createRequestAtPath:@"/signup" json:requestObjects HTTPMethod:@"POST" timeout:10.0];
        NSHTTPURLResponse *serverResponse = nil;
        NSData *data_response = [NSURLConnection sendSynchronousRequest:request returningResponse:&serverResponse error:error];
        
        if(serverResponse != nil)
        {
            if([serverResponse statusCode] == 201)
            {
                if(data_response != nil)
                    *response = [NSJSONSerialization JSONObjectWithData:data_response options:0 error:error];
            }
            else if([serverResponse statusCode] == 301)
            {
                //Create error object
            }
        }
    }
    else
    {
        //Create error object
    }
}

+(void) login:(NSDictionary*) dict response:(NSDictionary**) response error:(NSError**) error{
    //Check if the parameters exist.
    if([dict objectForKey:@"username"] && [dict objectForKey:@"password"])
    {
        NSDictionary* requestObjects = [[NSDictionary alloc] initWithObjectsAndKeys:
                                        [dict objectForKey:@"username"], @"username",
                                        [dict objectForKey:@"password"], @"password",
                                        nil];
        NSMutableURLRequest* request = [self createRequestAtPath:@"/login" json:requestObjects HTTPMethod:@"POST" timeout:10.0];
        NSHTTPURLResponse *serverResponse = nil;
        NSData *data_response = [NSURLConnection sendSynchronousRequest:request returningResponse:&serverResponse error:error];
        
        if(serverResponse != nil)
        {
            if([serverResponse statusCode] == 200)
            {
                if(data_response != nil)
                    *response = [NSJSONSerialization JSONObjectWithData:data_response options:0 error:error];
            }
            else if([serverResponse statusCode] == 301)
            {
                //Create error object
            }
        }
    }
    else
    {
        //Create error object
    }
}

+(void) logout:(NSDictionary*) response error:(NSError**) error{
    
}

+(void) addPerson:(NSDictionary*) dict response:(NSDictionary**) response error:(NSError**) error{
    //Check if the parameters exist.
    if([dict objectForKey:@"firstname"] && [dict objectForKey:@"lastname"] &&
       [dict objectForKey:@"email"] && [dict objectForKey:@"username"])
    {
        NSDictionary* requestObjects = [[NSDictionary alloc] initWithObjectsAndKeys:
                                        [dict objectForKey:@"firstname"], @"firstname",
                                        [dict objectForKey:@"lastname"], @"lastname",
                                        [dict objectForKey:@"email"], @"email",
                                        [dict objectForKey:@"username"], @"username",
                                        nil];
        NSMutableURLRequest* request = [self createRequestAtPath:@"/people/register" json:requestObjects HTTPMethod:@"POST" timeout:10.0];
        NSHTTPURLResponse *serverResponse = nil;
        NSData *data_response = [NSURLConnection sendSynchronousRequest:request returningResponse:&serverResponse error:error];
        
        if(serverResponse != nil)
        {
            if([serverResponse statusCode] == 201)
            {
                if(data_response != nil)
                    *response = [NSJSONSerialization JSONObjectWithData:data_response options:0 error:error];
            }
            else if([serverResponse statusCode] == 301)
            {
                //Create error object
            }
        }
    }
    else
    {
        //Create error object
    }
}

+(void) getPeopleList:(NSDictionary*) dict response:(NSArray**) response error:(NSError**) error{
    //Check if the parameters exist.
    if([dict objectForKey:@"username"])
    {
        NSMutableURLRequest* request = [self createRequestAtPath: [NSString stringWithFormat:@"/people?%@=%@",@"username",[dict objectForKey:@"username"]]
                                                            json:nil HTTPMethod:@"GET" timeout:10.0];
        NSHTTPURLResponse *serverResponse = nil;
        NSData *data_response = [NSURLConnection sendSynchronousRequest:request returningResponse:&serverResponse error:error];
        
        if(serverResponse != nil)
        {
            if([serverResponse statusCode] == 200)
            {
                if(data_response != nil)
                {
                    NSMutableArray *m_array = [[NSMutableArray alloc]init];
                    NSArray *t_response = [NSJSONSerialization JSONObjectWithData:data_response options:0 error:error];
                    for(NSDictionary *d in t_response)
                    {
                        [m_array addObject:[[Person alloc] initWithFirstName:[d objectForKey:@"firstname"] LastName:[d objectForKey:@"lastname"] Email:[d objectForKey:@"email"]]];
                    }
                    *response = [NSArray arrayWithArray:m_array];
                    m_array = nil;
                }
            }
            else if([serverResponse statusCode] == 301)
            {
                //Create error object
            }
        }
    }
    else
    {
        //Create error object
    }
}

+(void) addFace:(NSDictionary*) dict response:(NSDictionary**) response error:(NSError**)error{
    //Check if the parameters exist.
    if([dict objectForKey:@"username"] && [dict objectForKey:@"image"] &&
       [dict objectForKey:@"imageformat"] && [dict objectForKey:@"person"])
    {
        NSDictionary* requestObjects = [[NSDictionary alloc] initWithObjectsAndKeys:
                                        [dict objectForKey:@"username"], @"username",
                                        [(Person*)[dict objectForKey:@"person"] email], @"email",
                                        [self imageToBase64:(UIImage*)[dict objectForKey:@"image"]], @"image",
                                        [dict objectForKey:@"imageformat"], @"imageformat",
                                        nil];
        NSMutableURLRequest* request = [self createRequestAtPath:@"/faces/add" json:requestObjects HTTPMethod:@"POST" timeout:10.0];
        NSHTTPURLResponse *serverResponse = nil;
        NSData *data_response = [NSURLConnection sendSynchronousRequest:request returningResponse:&serverResponse error:error];
        
        if(serverResponse != nil)
        {
            if([serverResponse statusCode] == 201)
            {
                if(data_response != nil)
                    *response = [NSJSONSerialization JSONObjectWithData:data_response options:0 error:error];
            }
            else if([serverResponse statusCode] == 301)
            {
                //Create error object
            }
        }
    }
    else
    {
        //Create error object
    }
}

+(NSMutableURLRequest*)createRequestAtPath: (NSString*) path json:(NSDictionary*) json HTTPMethod:(NSString*) method timeout:(double) time
{
    NSMutableString* url_string = [[NSMutableString alloc]init];
    //Getting Server IP Address
    
    //[url_string appendString:[[FaceRecServer Server] URL]];
    [url_string appendString:@"http://192.168.1.125:1337"];
    [url_string appendString:path];
    NSLog(@"%@",url_string);
    NSURL* url = [[NSURL alloc]initWithString:url_string];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:time];
    [request setHTTPMethod:method];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    NSError *error = nil;
    if(json != nil)
    {
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:json options:0 error:&error];
        [request setHTTPBody:jsonData];
    }
    return request;
}

+(NSString*)imageToBase64:(UIImage*) image
{
    return [UIImageJPEGRepresentation(image, 1.0) base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
}
@end
