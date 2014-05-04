//
//  ServerHelpers.h
//  Server
//
//  Created by Eldon on 11/7/13.
//  Copyright (c) 2013 Eldon Ahrold. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AHHttpServerTrust : NSObject
+(AHHttpServerTrust*)sharedTrust;

-(void)handelChallenge:(NSURLAuthenticationChallenge *)challenge existingCredential:(NSURLCredential*)existingCredential error:(NSError **)error;

-(void)promptForUserAuth:(void (^)(NSURLCredential* credential,NSURLCredentialPersistence persistence))success failure:(void (^)(NSError *error))failure;

-(void)promptForCertTrust:(NSURLAuthenticationChallenge *)challenge success:(void (^)(BOOL success))success;

-(NSURLCredential*)promptForUserAuth:(NSError**)error;

-(BOOL)promptForCertTrust:(NSURLAuthenticationChallenge *)challenge;

+(void)resetCred:(NSURLProtectionSpace*)space;

@end
