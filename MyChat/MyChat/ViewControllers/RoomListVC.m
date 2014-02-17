//
//  RoomListVC.m
//  MyChat
//
//  Created by Dal Rupnik on 15/02/14.
//  Copyright (c) 2014 arvystate.net. All rights reserved.
//

#import "Room.h"

#import "RoomListVC.h"
#import "RoomVC.h"

@interface RoomListVC () <UIAlertViewDelegate, NSNetServiceBrowserDelegate, NSNetServiceDelegate>

@property (nonatomic, strong) NSMutableArray* services;
@property (nonatomic, strong) NSMutableArray* rooms;
@property (nonatomic, strong) NSMutableArray* otherServices;

@property (nonatomic, strong) NSNetServiceBrowser* browser;

@end

@implementation RoomListVC

- (NSMutableArray *)services
{
    if (!_services)
    {
        _services = [NSMutableArray array];
    }
    
    return _services;
}

- (NSMutableArray *)rooms
{
    if (!_rooms)
    {
        _rooms = [NSMutableArray array];
    }
    
    return _rooms;
}

- (NSMutableArray *)otherServices
{
    if (!_otherServices)
    {
        _otherServices = [NSMutableArray array];
    }
    
    return _otherServices;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
	self.browser = [[NSNetServiceBrowser alloc] init];
	self.browser.delegate = self;
	[self.browser searchForServicesOfType:@"_MyChat._tcp." inDomain:@""];
}

#pragma mark - NetServiceBrowser Delegate
- (void)netServiceBrowser:(NSNetServiceBrowser *)aNetServiceBrowser didFindService:(NSNetService *)aNetService moreComing:(BOOL)moreComing
{
	aNetService.delegate = self;
	[aNetService startMonitoring];
    
	[self.otherServices addObject:aNetService];
    
	NSLog(@"found: %@", aNetService);
    
	if (!moreComing)
	{
		[self updateServices];
	}
}

- (void)netServiceBrowser:(NSNetServiceBrowser *)aNetServiceBrowser
         didRemoveService:(NSNetService *)aNetService moreComing:(BOOL)moreComing
{
	[self.rooms removeObject:aNetService];
	[self.otherServices removeObject:aNetService];
    
	NSLog(@"removed: %@", aNetService);
    
	if (!moreComing)
	{
		[self.tableView reloadData];
	}
}

#pragma mark - NSNetService Delegate
- (void)netService:(NSNetService *)sender didUpdateTXTRecordData:(NSData *)data
{
	[self updateServices];
    
	[sender stopMonitoring];
}

- (BOOL)isLocalServiceIdentifier:(NSString *)identifier
{
	for (Room *room in self.rooms)
	{
		if ([room.identifier isEqualToString:identifier])
		{
			return YES;
		}
	}
    
	return NO;
}

- (void)updateServices
{
	BOOL didUpdate = NO;
    
	for (NSNetService *service in [self.otherServices copy])
	{
		NSDictionary *dict = [NSNetService dictionaryFromTXTRecordData:service.TXTRecordData];
        
		if (!dict)
		{
			continue;
		}
        
		NSString *identifier = [[NSString alloc] initWithData:dict[@"ID"] encoding:NSUTF8StringEncoding];
        
		if (![self isLocalServiceIdentifier:identifier])
		{
			[self.services addObject:service];
			didUpdate = YES;
		}
        
		[self.otherServices removeObject:service];
	}
    
	if (didUpdate)
	{
		[self.tableView reloadData];
	}
}

- (IBAction)newRoomButtonTap:(UIBarButtonItem *)sender
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Room name" message:@"Enter room name:" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Ok", nil];
    alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    
    [alertView show];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    //
    // Block cancel
    //
    
    if (buttonIndex == 0)
    {
        return;
    }
    
    UITextField* roomName = [alertView textFieldAtIndex:0];
    
    Room *room = [[Room alloc] initWithRoomName:roomName.text];
	[self.rooms addObject:room];
	[room start];
    
	[self.tableView reloadData];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"RoomSegue"])
    {
        NSIndexPath* indexPath = [self.tableView indexPathForCell:sender];
        
        if (indexPath.section == 0)
        {
            [segue.destinationViewController setRoom:self.rooms[indexPath.row]];
        }
        else if (indexPath.section == 1)
        {
            [segue.destinationViewController setRoom:self.services[indexPath.row]];
        }
    }
}

#pragma mark - UITableView Delegate / Datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 2;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	if (section == 0)
	{
		return @"My rooms";
	}
    
	return @"Other rooms";
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	if (section == 0)
	{
		return [self.rooms count];
	}
    
	return [self.services count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RoomCell"];
    
	if (indexPath.section == 0)
	{
		Room *room = self.rooms[indexPath.row];
		cell.textLabel.text = room.name;
		cell.detailTextLabel.text = nil;
	}
	else
	{
		NSNetService *service = self.services[indexPath.row];

		NSDictionary *dict = [NSNetService dictionaryFromTXTRecordData:service.TXTRecordData];
        
        NSLog(@"TXT: %@", service);
        
		NSString *roomName = [[NSString alloc] initWithData:dict[@"RoomName"] encoding:NSUTF8StringEncoding];
		cell.textLabel.text = roomName;
		cell.detailTextLabel.text = [service name];
	}
    
	return cell;
}

@end
