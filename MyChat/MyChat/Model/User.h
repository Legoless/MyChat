//
//  User.h
//  MyChat
//
//  Created by Dal Rupnik on 15/02/14.
//  Copyright (c) 2014 arvystate.net. All rights reserved.
//

#import "DTBonjourDataConnection.h"

@interface User : DTBonjourDataConnection

@property (nonatomic, strong) NSString* roomName;

@end
