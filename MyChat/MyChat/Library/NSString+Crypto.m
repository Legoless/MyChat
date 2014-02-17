//
//  NSString+Crypto.m
//  MyChat
//
//  Created by Dal Rupnik on 17/02/14.
//  Copyright (c) 2014 arvystate.net. All rights reserved.
//

#import "NSString+Crypto.h"

@implementation NSString (Crypto)

+ (NSString *)stringWithUUID
{
    //
    // Create UUID with Core Foundation
    //
    
	CFUUIDRef uuidObj = CFUUIDCreate(nil);

	NSString *uuidString = (__bridge_transfer NSString *)CFUUIDCreateString(nil, uuidObj);
    
	CFRelease(uuidObj);
    
	return uuidString;
}

@end
