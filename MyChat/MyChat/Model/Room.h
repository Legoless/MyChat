//
//  Room.h
//  MyChat
//
//  Created by Dal Rupnik on 15/02/14.
//  Copyright (c) 2014 arvystate.net. All rights reserved.
//

#import "DTBonjourServer.h"

@interface Room : DTBonjourServer

@property (nonatomic, strong) NSString* name;

@property (nonatomic, strong) NSString* identifier;

- (id)initWithRoomName:(NSString *)roomName;

@end
