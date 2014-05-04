//
//  ServerHelpers.m
//  Server
//
//  Created by Eldon on 11/7/13.
//  Copyright (c) 2013 Eldon Ahrold. All rights reserved.
//

#import "AHHttpServerTrust.h"
#import <SecurityInterface/SFCertificateTrustPanel.h>
#import <Cocoa/Cocoa.h>


@implementation AHHttpServerTrust

+(AHHttpServerTrust *)sharedTrust{
    static dispatch_once_t onceToken;
    static AHHttpServerTrust* shared;
    dispatch_once(&onceToken, ^{
        shared = [AHHttpServerTrust new];
    });
    return shared;
}

-(void)handelChallenge:(NSURLAuthenticationChallenge *)challenge existingCredential:(NSURLCredential*)existingCredential error:(NSError *__autoreleasing*)error{
    if ([challenge.protectionSpace.authenticationMethod
         isEqualToString:NSURLAuthenticationMethodServerTrust]){
        {
            if([self promptForCertTrust:challenge]){
                [challenge.sender useCredential:[NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust] forAuthenticationChallenge:challenge];
            }else{
                [[challenge sender] cancelAuthenticationChallenge:challenge];
            };
        }
    }
    
    else if ([challenge previousFailureCount] < 3) {
        if(existingCredential){
            [[challenge sender]  useCredential:existingCredential
                    forAuthenticationChallenge:challenge];
        }else{
            NSURLCredential* credential = [self promptForUserAuth:nil];
            if(credential){
                [[challenge sender]  useCredential: credential forAuthenticationChallenge:challenge];
            }else{
                [[challenge sender] continueWithoutCredentialForAuthenticationChallenge:challenge];
            }
        }
    }else{
        [[challenge sender] continueWithoutCredentialForAuthenticationChallenge:challenge];
        [AHHttpServerTrust resetCred:challenge.protectionSpace];
    }
};

-(BOOL)promptForCertTrust:(NSURLAuthenticationChallenge *)challenge{
    SecTrustResultType secresult = kSecTrustResultInvalid;
    if (SecTrustEvaluate(challenge.protectionSpace.serverTrust, &secresult) == errSecSuccess) {
        switch (secresult) {
            case kSecTrustResultUnspecified: // The OS trusts this certificate implicitly.
            case kSecTrustResultProceed: // The user explicitly told the OS to trust it.
            {
                return YES;
            }
            default:
            {
                SFCertificateTrustPanel *panel = [SFCertificateTrustPanel sharedCertificateTrustPanel];
                [panel setAlternateButtonTitle:@"Cancel"];
                [panel setInformativeText:@"The server is offering a certificate that doesn't match.  You may be putting your info at risk, if you would like to trust this server anyway?"];
                
                BOOL button = [panel runModalForTrust:challenge.protectionSpace.serverTrust
                                              message:@"Certificate Mismatch"];
                panel = nil;
                return button;
            }
        }
    }
    return NO;
}

-(void)promptForCertTrust:(NSURLAuthenticationChallenge *)challenge success:(void (^)(BOOL))success{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        success([self promptForCertTrust:challenge]);
    }];
}

-(NSURLCredential *)promptForUserAuth:(NSError*__autoreleasing*)error{
    NSString *user;
    NSString *password;
    NSURLCredential *credential;
    NSURLCredentialPersistence saveToKeychain;
    CFUserNotificationRef authNotification;
    CFOptionFlags responseFlags;
    SInt32 cfError;
    
    NSString *appName;
    NSString *alertHeader;
    NSArray  *panelTextField;
    CFOptionFlags flags;
    NSDictionary *panelDict;
    
    
    appName = [[NSRunningApplication currentApplication] localizedName];
    
    alertHeader = [NSString stringWithFormat:@"%@ Needs a password to continue",appName];
    
    panelTextField = @[NSLocalizedString(@"Username:", @"Textbox name"),
                                 NSLocalizedString(@"Password:", @"Textbox name")];
    
    
    flags = kCFUserNotificationPlainAlertLevel |
                            CFUserNotificationSecureTextField(1);
    
    panelDict = [NSDictionary dictionaryWithObjectsAndKeys:
                               panelTextField,kCFUserNotificationTextFieldTitlesKey,
                               @"Add to Keychain",kCFUserNotificationCheckBoxTitlesKey,
                               alertHeader,kCFUserNotificationAlertHeaderKey,
                               @"Cancel",kCFUserNotificationAlternateButtonTitleKey,
                               @"",kCFUserNotificationAlertMessageKey,nil];
    
    authNotification = CFUserNotificationCreate(kCFAllocatorDefault,
                                                0,
                                                flags,
                                                &cfError,
                                                (__bridge CFDictionaryRef)panelDict);
    
    
    cfError = CFUserNotificationReceiveResponse(authNotification,
                                                0,
                                                &responseFlags);
    
    if (cfError){
        CFRelease(authNotification);
        return nil;
    }
    
    int button = responseFlags & 0x3;
    
    if (button == kCFUserNotificationAlternateResponse)
    {
        CFRelease(authNotification);
        return nil;
    }
    
    if ( responseFlags & CFUserNotificationCheckBoxChecked(0))
    {
        saveToKeychain = NSURLCredentialPersistencePermanent;
    }else{
        saveToKeychain = NSURLCredentialPersistenceNone;
    }
    
    user = (__bridge NSString *)(CFUserNotificationGetResponseValue(authNotification,
                                                                    kCFUserNotificationTextFieldValuesKey,
                                                                    0));
    
    password = (__bridge NSString *)(CFUserNotificationGetResponseValue(authNotification,
                                                                        kCFUserNotificationTextFieldValuesKey,
                                                                        1));
    
    CFRelease(authNotification); // this releases usernameRef and passwordRef
    
    credential = [NSURLCredential credentialWithUser:user
                                            password:password
                                         persistence:saveToKeychain];
    
    return credential;
}

-(void)promptForUserAuth:(void (^)(NSURLCredential *, NSURLCredentialPersistence))success failure:(void (^)(NSError *))failure{
	[[NSOperationQueue mainQueue] addOperationWithBlock:^{
        NSURLCredential *credential;
        NSError *error;
        
        credential = [self promptForUserAuth:&error];
        
        if(credential){
            success(credential,NO);
        }else{
            failure(error);
        }
    }];
}


+(void)resetCred:(NSURLProtectionSpace*)space{
    NSDictionary *credentialsDict = [[NSURLCredentialStorage sharedCredentialStorage] credentialsForProtectionSpace:space];
    if ([credentialsDict count] > 0)
    {
        id userName;
        NSEnumerator *userNameEnumerator = [credentialsDict keyEnumerator];
        while (userName = [userNameEnumerator nextObject]) {
            NSURLCredential *cred = [credentialsDict objectForKey:userName];
            [[NSURLCredentialStorage sharedCredentialStorage] removeCredential:cred
                                                            forProtectionSpace:space];
        }
    }
}


@end
