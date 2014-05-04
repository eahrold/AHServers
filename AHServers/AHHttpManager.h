//
//  Server.h
//  Server Framework
//
//  Created by Eldon Ahrold on 8/14/13.
//  Copyright (c) 2013 Eldon Ahrold. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AHHttpManager : NSObject <NSURLConnectionDelegate,NSURLConnectionDataDelegate>{
}

@property (copy) NSURL    *URL;
@property (copy) NSString *port;

@property (copy) NSString *authName;
@property (copy) NSString *authPass;
@property (copy) NSString *fingerPrint;
@property (copy,nonatomic) NSString *authHeader;

@property (copy) NSData   *requestData;
@property (copy) NSHTTPURLResponse   *response;

@property (nonatomic,readwrite) NSTimeInterval timeout;
@property (nonatomic,readwrite) NSURLRequestCachePolicy cachePolicy;

-(id)initWithQueue;
-(id)initWithURL:(NSURL*)URL;
-(id)initWithURLString:(NSString*)URL;

-(void)setAuthHeaderWithUser:(NSString*)name andPassword:(NSString*)pass;
-(void)setAuthHeaderWithHeader:(NSString*)header;

-(void)GET:(void(^)(NSData *data,NSError *error))reply;

-(BOOL)POST:(NSData*)data error:(NSError**)error;
-(NSData*)syncGET:(NSError**)error;

-(void)cancelConnections;

@end
