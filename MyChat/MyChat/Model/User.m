//
//  User.m
//  MyChat
//
//  Created by Dal Rupnik on 15/02/14.
//  Copyright (c) 2014 arvystate.net. All rights reserved.
//

#import "User.h"

@implementation User

- (id)initWithService:(NSNetService *)service
{
	self = [super initWithService:service];
    
	if (self)
	{
		NSDictionary *dict = [NSNetService dictionaryFromTXTRecordData:service.TXTRecordData];
        
		self.roomName = [[NSString alloc] initWithData:dict[@"RoomName"] encoding:NSUTF8StringEncoding];
	}
    
	return self;
}

@end
