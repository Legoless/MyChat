//
//  Message.h
//  MyChat
//
//  Created by Dal Rupnik on 17/02/14.
//  Copyright (c) 2014 arvystate.net. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Message : NSObject

@property (nonatomic, strong) NSString* text;
@property (nonatomic, getter = isOutgoing) BOOL outgoing;
@property (nonatomic, strong) NSDate* time;

@end
