//
//  NSString+StringSanitizer.m
//  ODUserMaker
//
//  Created by Eldon Ahrold on 7/17/13.
//  Copyright (c) 2013 Eldon Ahrold. All rights reserved.
//

#import "NSString+StringSanitizer.h"

@implementation NSString (StringSanitizer)
-(NSString*)stringByTrimmingLeadingWhitespace {
    NSInteger i = 0;
    
    while ((i < [self length])
           && [[NSCharacterSet whitespaceCharacterSet] characterIsMember:[self characterAtIndex:i]]) {
        i++;
    }
    return [self substringFromIndex:i];
}
@end