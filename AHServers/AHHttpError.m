//
//  ServerError.m
//  Server
//
//  Created by Eldon on 11/5/13.
//  Copyright (c) 2013 Eldon Ahrold. All rights reserved.
//

#import "AHHttpError.h"

NSString *const SEDomain = @"com.aapps.httperror";

static NSString *const SENoURLSpecifiedMsg         = @"The URL For request not specified!";
static NSString *const SECouldNotInitConnectionMsg = @"Could not initialize Connection";
static NSString *const SECanceledByUserMsg         = @"Connection canceled by user";
static NSString *const SEUnknownErrorMsg           = @"There was a unknown problem, sorry!";


@implementation AHHttpError

+ (NSError*) errorWithCode:(int)code
{
    NSDictionary *info = [NSDictionary dictionaryWithObjectsAndKeys:[AHHttpError errorTextForCode:code], NSLocalizedDescriptionKey, nil];
    return [self errorWithDomain:SEDomain code:code userInfo:info];
}

+ (NSError*) errorWithCode:(NSInteger)code message:(NSString*)msg
{
    NSDictionary *info = [NSDictionary dictionaryWithObjectsAndKeys:msg, NSLocalizedDescriptionKey, nil];
    return [self errorWithDomain:SEDomain code:code userInfo:info];
}

+(NSError*)errorFromURLResponse:(NSHTTPURLResponse*)response{
    NSInteger code = response.statusCode;
    NSDictionary *info = @{NSLocalizedDescriptionKey: [NSHTTPURLResponse localizedStringForStatusCode:response.statusCode]};
    
    return [self errorWithDomain:SEDomain code:code userInfo:info];
}



+(NSString*)errorTextForCode:(int)code {
    NSString *codeText = @"";
    switch (code) {
        case SENoURLSpecified:
            codeText = SENoURLSpecifiedMsg;
            break;
        case SECouldNotInitConnection:
            codeText = SECouldNotInitConnectionMsg;
            break;
        case SECanceledByUser:
            codeText = SECanceledByUserMsg;
            break;
        default:
            codeText = SEUnknownErrorMsg;
            break;
    }
    return codeText;
}


@end
