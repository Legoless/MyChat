//
//  RoomVC.m
//  MyChat
//
//  Created by Dal Rupnik on 15/02/14.
//  Copyright (c) 2014 arvystate.net. All rights reserved.
//

#import "Room.h"
#import "User.h"
#import "Message.h"

#import "RoomVC.h"

@interface RoomVC () <JSMessagesViewDelegate, JSMessagesViewDataSource, DTBonjourDataConnectionDelegate, DTBonjourServerDelegate>

@property (nonatomic, strong) NSMutableArray* messages;

@property (nonatomic, weak) Room* server;
@property (nonatomic, strong) User* client;

@end

@implementation RoomVC

- (NSMutableArray *)messages
{
    if (!_messages)
    {
        _messages = [NSMutableArray array];
    }
    
    return _messages;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    self.delegate = self;
    self.dataSource = self;
    
    [[JSBubbleView appearance] setFont:[UIFont systemFontOfSize:20.0]];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if ([self.room isKindOfClass:[Room class]])
    {
        self.server = self.room;
        self.server.delegate = self;
        
        self.title = self.server.name;
    }
    else if ([self.room isKindOfClass:[NSNetService class]])
    {
        self.client = [[User alloc] initWithService:self.room];
        self.client.delegate = self;
        
        [self.client open];
        
        self.title = [self.client roomName];
    }
}

#pragma mark - DTBonjourServer Delegate (Server)

- (void)bonjourServer:(DTBonjourServer *)server didReceiveObject:(id)object onConnection:(DTBonjourDataConnection *)connection
{
    Message* message = [[Message alloc] init];
    message.text = object;
    
	[self.messages insertObject:message atIndex:0];
	[self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationTop];
}

#pragma mark - DTBonjourConnection Delegate (Client)

- (void)connection:(DTBonjourDataConnection *)connection didReceiveObject:(id)object
{
	Message* message = [[Message alloc] init];
    message.text = object;
    
	[self.messages insertObject:message atIndex:0];
	[self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationTop];
}

- (void)connectionDidClose:(DTBonjourDataConnection *)connection
{
	if (connection == self.client)
	{
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Room Closed" message:@"The server has closed the room." delegate:self cancelButtonTitle:@"Exit" otherButtonTitles:nil];
		[alert show];
	}
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	[self.navigationController popViewControllerAnimated:YES];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.messages count];
}

#pragma mark - JSMessagesView Delegate (Server)
- (void)didSendText:(NSString *)text
{
    if (self.server)
	{
		[self.server broadcastObject:text];
	}
	else if (self.client)
	{
		NSError *error;
        
		if (![self.client sendObject:text error:&error])
		{
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
			[alert show];
		}
	}
    
    Message* message = [[Message alloc] init];
    message.text = text;
    message.outgoing = YES;
    
	[self.messages insertObject:message atIndex:0];
	[self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationTop];

}

- (JSBubbleMessageType)messageTypeForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.messages[indexPath.row] isOutgoing] ? JSBubbleMessageTypeOutgoing : JSBubbleMessageTypeIncoming;
}

- (UIImageView *)bubbleImageViewWithType:(JSBubbleMessageType)type forRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIImageView* imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 5.0, 2.0)];
    
    imageView.layer.cornerRadius = 10.0;
    
    if (type == JSBubbleMessageTypeIncoming)
    {
        imageView.backgroundColor = [UIColor colorWithRed:29.0 / 255.0 green:98.0 / 255.0 blue:240.0 / 255.0 alpha:1.0];
    }
    else
    {
        imageView.backgroundColor = [UIColor colorWithRed:11.0 / 255.0 green:211.0 / 255.0 blue:24.0 / 255.0 alpha:1.0];
    }
    
    return imageView;
}

- (NSString *)textForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.messages[indexPath.row] text];
}

- (NSDate *)timestampForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.messages[indexPath.row] time];
}

- (UIImageView *)avatarImageViewForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

- (NSString *)subtitleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.messages[indexPath.row] isOutgoing] ? @"Sent" : @"Received";
}

- (void)configureCell:(JSBubbleMessageCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    if (cell)
    {
        cell.bubbleView.textView.textColor = [UIColor whiteColor];
    }
}

- (JSMessagesViewTimestampPolicy)timestampPolicy
{
    return JSMessagesViewTimestampPolicyAll;
}

- (JSMessagesViewSubtitlePolicy)subtitlePolicy
{
    return JSMessagesViewSubtitlePolicyAll;
}

- (JSMessagesViewAvatarPolicy)avatarPolicy
{
    return JSMessagesViewAvatarPolicyNone;
}

- (JSMessageInputViewStyle)inputViewStyle
{
    return JSMessageInputViewStyleFlat;
}

@end
