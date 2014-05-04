//
//  AHHttpRequest.h
//  Server
//
//  Created by Eldon on 12/18/13.
//  Copyright (c) 2013 Eldon Ahrold. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AHHttpManager.h"

@interface AHHttpRequest : NSObject

+(NSData*)getDataFromServer:(NSString*)URL;
+(NSData*)getDataFromServer:(NSString*)URL error:(NSError**)error;

+(NSData*)getDataFromServer:(NSString*)URL user:(NSString*)user password:(NSString*)password;
+(NSData*)getDataFromServer:(NSString*)URL user:(NSString*)user password:(NSString*)password error:(NSError**)error;

+(void)PostData:(NSData*)data toServer:(NSString*)URL;
+(void)PostData:(NSData*)data toServer:(NSString*)URL error:(NSError**)error;
+(void)PostData:(NSData*)data toServer:(NSString*)URL user:(NSString*)user password:(NSString*)password;
+(void)PostData:(NSData*)data ToServer:(NSString*)URL user:(NSString*)user password:(NSString*)password error:(NSError**)error;


+(BOOL)checkURL:(NSString*)URL __deprecated;
+(void)checkURL:(NSString*)URL status:(void(^)(BOOL avaliable))reply;

@end
