//
//  Room.m
//  MyChat
//
//  Created by Dal Rupnik on 15/02/14.
//  Copyright (c) 2014 arvystate.net. All rights reserved.
//

#import "Room.h"
#import "NSString+Crypto.h"

@implementation Room

- (id)initWithRoomName:(NSString *)roomName
{
	self = [super initWithBonjourType:@"_MyChat._tcp."];
    
	if (self)
	{
		self.name = roomName;
        
        self.identifier = [NSString stringWithUUID];
        
        self.TXTRecord = @{ @"ID" : [self.identifier dataUsingEncoding:NSUTF8StringEncoding], @"RoomName" : [self.name dataUsingEncoding:NSUTF8StringEncoding] };
	}
    
	return self;
}

- (void)connection:(DTBonjourDataConnection *)connection didReceiveObject:(id)object
{
	[super connection:connection didReceiveObject:object];
    
	for (DTBonjourDataConnection *oneConnection in self.connections)
	{
		if (oneConnection != connection)
		{
			[oneConnection sendObject:object error:NULL];
		}
	}
}

@end
