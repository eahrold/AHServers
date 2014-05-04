//
//  Server.m
//  SerialImportDS
//
//  Created by Eldon Ahrold on 8/14/13.
//  Copyright (c) 2013 Eldon Ahrold. All rights reserved.
//

#import "AHHttpManager.h"
#import "AHHttpServerTrust.h"
#import "AHHttpError.h"

#import "NSString+Base64.h"
#import "NSDictionary+NSData.h"
#import "NSString+NSData.h"

@interface AHURLConnection : NSURLConnection

@property (nonatomic,readwrite,strong) void(^ServerResponse)(NSData *data, NSError *error);
@property (nonatomic,readwrite,strong) NSMutableData *data;
@property (nonatomic,readwrite,strong) NSHTTPURLResponse *response;
@property (nonatomic,readwrite,strong) NSError *error;


@end

@implementation AHURLConnection

@end


@interface AHHttpManager()
@property (nonatomic,readwrite,strong) NSMutableArray *connections;
@property (nonatomic,readwrite,strong) NSOperationQueue *connectionQueue;
@end

@implementation AHHttpManager{

}

#pragma mark - init methods
- (id)init{
    self = [super init];
    if (self) {
        _connectionQueue = [NSOperationQueue mainQueue];
        _connectionQueue.maxConcurrentOperationCount = 3;
        _connections = [NSMutableArray arrayWithCapacity:10];
        _timeout = 10.0;
        _cachePolicy = NSURLRequestUseProtocolCachePolicy;
    }
    return self;
}

- (id)initWithQueue{
    self = [self init];
    if (self) {
        _connectionQueue = [[NSOperationQueue alloc] init];
    }
    return self;
}

-(id)initWithURL:(NSURL*)url{
    self = [self init];
    if (self) {
        self.URL= url;
    }
    return self;
}

-(id)initWithURLString:(NSString*)url{
    self = [self init];
    if (self) {
        if(url)self.URL= [NSURL URLWithString:url];
    }
    return self;
}

#pragma mark - Setter extensions
-(void)setAuthHeaderWithUser:(NSString *)name andPassword:(NSString *)pass{
    NSString *header = [[NSString stringWithFormat:@"%@:%@",name,pass]base64EncodedString];
    self.authHeader = [ NSString stringWithFormat:@"Basic %@",header];
}

-(void)setAuthHeaderWithHeader:(NSString*)header{
    self.authHeader = [ NSString stringWithFormat:@"Basic %@",header];
}

#pragma mark - GET requests
-(void)GET:(void(^)(NSData *data, NSError *error))reply{
    if (!self.URL) {
        reply(nil,[AHHttpError errorWithCode:SENoURLSpecified]);
        return;
    }
    
    if([_authName isEqualToString:@""])_authName = nil;
    if([_authPass isEqualToString:@""])_authPass = nil;

    NSURLRequest *request = [NSURLRequest requestWithURL:self.URL cachePolicy:self.cachePolicy timeoutInterval:self.timeout];
    AHURLConnection *connection = [[AHURLConnection alloc] initWithRequest:request delegate:self startImmediately:NO];
    
    if (!connection) {
        reply(nil,[AHHttpError errorWithCode:SECouldNotInitConnection]);
        return;
    }
    
    [connection setDelegateQueue:self.connectionQueue];
    connection.data = [NSMutableData dataWithCapacity:1024];
    
    connection.ServerResponse = reply;
    [connection start];
    
    [self.connections addObject:connection];
}

-(NSData*)syncGET:(NSError*__autoreleasing*)error{
    NSData* data;
    if(!self.URL){
        if(error)*error = [AHHttpError errorWithCode:SENoURLSpecified];
        return NO;
    }
    
    NSError *intError = nil;
    NSURLResponse *response = nil;
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:self.URL];
    request.HTTPMethod = @"GET";
    [request setValue:@"application/x-www-form-urlencoded; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    
    if(self.authHeader){
        [request setValue:self.authHeader forHTTPHeaderField:@"Authorization"];
    }
    
    [request setHTTPBody:data];
    data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&intError];
    if(error){
        *error = intError;
        return nil;
    }
    return data;
}

#pragma mark - POST request

-(BOOL)POST:(NSData*)data error:(NSError*__autoreleasing*)error{
    if(!self.URL){
        if(error)*error = [AHHttpError errorWithCode:SENoURLSpecified];
        return NO;
    }
    
    NSError *intError = nil;
    NSURLResponse *response = nil;
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:self.URL];
    request.HTTPMethod = @"POST";
    [request setValue:@"application/x-www-form-urlencoded; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    
    if(self.authHeader){
        [request setValue:self.authHeader forHTTPHeaderField:@"Authorization"];
    }

    [request setHTTPBody:data];
    [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&intError];
    if(error){
        *error = intError;
        return NO;
    }
    return YES;
}

#pragma mark - helper methods
- (void)cancelConnections {
    [self.connectionQueue setSuspended:YES];
    [self.connectionQueue cancelAllOperations];
    [self.connectionQueue addOperationWithBlock:^{
        for (AHURLConnection *connection in self.connections) {
            [connection cancel];
            connection.ServerResponse(nil,[AHHttpError errorWithCode:SECanceledByUser]);
        }
        [self.connections removeAllObjects];
    }];
    [self.connectionQueue setSuspended:NO];
}



#pragma mark - NSURLConnectionDelegate

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    AHURLConnection *serverConnection = (AHURLConnection *)connection;
    serverConnection.ServerResponse(nil,error);
    [self.connections removeObject:serverConnection];
}

- (BOOL)connection:(NSURLConnection *)connection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace
{
	if ([protectionSpace.authenticationMethod
         isEqualToString:NSURLAuthenticationMethodServerTrust] ||
        [protectionSpace.authenticationMethod
         isEqualToString:NSURLAuthenticationMethodHTTPDigest]  ||
        [protectionSpace.authenticationMethod
         isEqualToString:NSURLAuthenticationMethodHTTPBasic]   ||
        [protectionSpace.authenticationMethod
         isEqualToString:NSURLAuthenticationMethodDefault]){
        return YES;
    }
   return NO;
}

- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge{
    
       [[NSOperationQueue mainQueue]addOperationWithBlock:^{
           NSURLCredential* existingCredential;
           NSError* error;
           if(_authName && _authPass){
               existingCredential = [NSURLCredential credentialWithUser:_authName
                                                               password:_authPass
                                                            persistence:NSURLCredentialPersistenceNone];
           }
           [[AHHttpServerTrust sharedTrust] handelChallenge:challenge existingCredential:
            existingCredential error:&error];
           if(error){
               NSLog(@"%@",error.localizedDescription);
           }
       }];
}


- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    AHURLConnection *serverConnection = (AHURLConnection *)connection;
    _response = (NSHTTPURLResponse*)response;
    serverConnection.data.length = 0;
}

- (NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)response {
    if (response != nil) {
        if ([[self.URL absoluteString] isEqualToString:[[request URL] absoluteString]]) {
            NSMutableURLRequest *redirect = [[NSMutableURLRequest alloc] initWithURL:_URL];       
            [redirect setHTTPMethod:request.HTTPMethod];
            if (self.requestData != nil) {
                [redirect setHTTPBody:self.requestData];
            }
            [redirect setAllHTTPHeaderFields:[request allHTTPHeaderFields]];
            return redirect;
        } else {
            return request;
        }
    } else {
        return request;
    }
}


- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    NSLog(@"Connection Finishing");
    AHURLConnection *serverConnection = (AHURLConnection *)connection;
    [_connections removeObject:connection];
    
    if ([_response isKindOfClass:[NSHTTPURLResponse class]]) {
        if (_response.statusCode >= 400){
            serverConnection.ServerResponse(nil,[AHHttpError errorFromURLResponse:_response]);
            return;
        }
    }
    serverConnection.ServerResponse(serverConnection.data,nil);
}

#pragma mark - NSURLConnectionDataDelegate
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    AHURLConnection *serverConnection = (AHURLConnection *)connection;
    [serverConnection.data appendData:data];
}
@end
