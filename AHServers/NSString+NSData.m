//
//  NSString+NSData.m
//  Server
//
//  Created by Eldon on 11/5/13.
//  Copyright (c) 2013 Eldon Ahrold. All rights reserved.
//

#import "NSString+NSData.h"

@implementation NSString (NSData)
+(NSString*)stringWithData:(NSData*)data{
    return [[NSString alloc]initWithData:data encoding:NSASCIIStringEncoding];
}

@end
