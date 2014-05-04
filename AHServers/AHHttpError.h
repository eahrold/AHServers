//
//  ServerError.h
//  Server
//
//  Created by Eldon on 11/5/13.
//  Copyright (c) 2013 Eldon Ahrold. All rights reserved.
//

#import <Foundation/Foundation.h>
extern NSString *const SEDomain;

@interface AHHttpError : NSError
+(NSError*)errorWithCode:(int)code;
+(NSError*)errorWithCode:(NSInteger)rc message:(NSString*)msg;
+(NSError*)errorFromURLResponse:(NSHTTPURLResponse*)response;

@end

enum ServerErrorCodes {
    SESuccess = 0,
    SENoURLSpecified = 1001,
    SECouldNotInitConnection = 1002,
    SECanceledByUser = 3001,
};