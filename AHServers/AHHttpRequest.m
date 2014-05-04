//
//  AHHttpRequest.m
//  Server
//
//  Created by Eldon on 12/18/13.
//  Copyright (c) 2013 Eldon Ahrold. All rights reserved.
//

#import "AHHttpRequest.h"
#import "AHHttpManager.h"

@implementation AHHttpRequest
+(NSData *)getDataFromServer:(NSString *)URL{
    return [self getDataFromServer:URL error:nil];
}

+(NSData *)getDataFromServer:(NSString *)URL error:(NSError *__autoreleasing *)error{
    return [self getDataFromServer:URL user:nil password:nil error:error];
}

+(NSData *)getDataFromServer:(NSString *)URL user:(NSString *)user password:(NSString *)password{
    return [self getDataFromServer:URL user:nil password:nil error:nil];

}

+(NSData *)getDataFromServer:(NSString *)URL user:(NSString *)user password:(NSString *)password error:(NSError *__autoreleasing *)error{
    NSData *returnData;
    AHHttpManager *manager = [[AHHttpManager alloc]initWithQueue];
    manager.URL = [NSURL URLWithString:URL];
    manager.authName = user;
    manager.authPass = password;
    
    return returnData;
}


+(void)PostData:(NSData *)data toServer:(NSString *)URL error:(NSError *__autoreleasing *)error
{
}
+(void)PostData:(NSData *)data toServer:(NSString *)URL
{
}
+(void)PostData:(NSData *)data toServer:(NSString *)URL
           user:(NSString *)user password:(NSString *)password
{
}
+(void)PostData:(NSData *)data ToServer:(NSString *)URL user:(NSString *)user
       password:(NSString *)password error:(NSError *__autoreleasing *)error
{
}

+(void)checkURL:(NSString*)URL status:(void(^)(BOOL avaliable))reply
{
    NSOperationQueue *queue = [NSOperationQueue new];
    [queue addOperationWithBlock:^{
        NSError *error = nil;
        NSHTTPURLResponse *response = nil;
        
        // Create the request.
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:URL]];
        
        // set as GET request
        request.HTTPMethod = @"GET";
        request.timeoutInterval = 3;
        
        // set header fields
        [request setValue:@"application/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];

        
        
        // Create url connection and fire request
        [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
        
        NSInteger server_rc = [response statusCode];
        
        if(server_rc >= 400 || error){
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                reply(NO);
            }];
        }else{
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                reply(YES);
            }];
        }
    }];
}

+(BOOL)checkURL:(NSString*)url{
    BOOL rc = YES;
    NSError *error = nil;
    NSHTTPURLResponse *response = nil;
    
    // Create the request.
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    
    // set as GET request
    request.HTTPMethod = @"GET";
    request.timeoutInterval = 3;
    
    // set header fields
    [request setValue:@"application/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    // Create url connection and fire request
    [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    
    NSInteger server_rc = [response statusCode];
    
    if(server_rc >= 400 || error){
        rc = NO;
    }
    
    return rc;
}


@end
