//
//  ChatViewController.m
//  iPhoneXMPP
//
//  Created by System Administrator on 5/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "ChatViewController.h"
#import "AppDelegate.h"
#import "ChatMessage.h"
#import "ChatTableViewCell.h"

#import "XMPP.h"

@interface ChatViewController()

- (void) chatTableScrollToBottom;

@end

@implementation ChatViewController

@synthesize appDelegate = appDelegate_;
@synthesize textView;
@synthesize chatTableView;
@synthesize rosterJid = rosterJid_;
@synthesize allRecord = allRecode_;

- (id)init
{
    self = [super initWithNibName:nil bundle:nil];
    if (self)
    {
        
    }
    
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [[self view] setBackgroundColor: [UIColor groupTableViewBackgroundColor]];
    
    // set title
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 400, 44)];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.font = [UIFont boldSystemFontOfSize:20.0];
    titleLabel.numberOfLines = 1;
    titleLabel.adjustsFontSizeToFitWidth = YES;
    titleLabel.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.5];
    titleLabel.textAlignment = UITextAlignmentCenter;
    titleLabel.text = [[NSString alloc] initWithFormat: @"Chat with %s", [[self rosterJid] UTF8String]];
    [titleLabel sizeToFit];
    self.navigationItem.titleView = titleLabel;
    
    textView.layer.borderWidth = 1;
    textView.layer.cornerRadius = 5;
    
    [self.chatTableView setDelegate: self];
    [self.chatTableView setDataSource: self];
    
    // read chat data from database
    [self readFromDatabase];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self chatTableScrollToBottom];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

- (void)readFromDatabase
{
    self.allRecord = [[NSMutableArray alloc] initWithArray: [ChatMessage findByColumn: @"rosterDisplayName" value: [self rosterJid]]];
}

- (void)chatTableScrollToBottom
{
    if (0 < self.allRecord.count)
    {
        [self.chatTableView scrollToRowAtIndexPath: [NSIndexPath indexPathForRow: self.allRecord.count - 1 inSection: 0] atScrollPosition: UITableViewScrollPositionBottom animated: YES];
    }
}

////////////////////////////////////////////////////////
#pragma mark - actions
////////////////////////////////////////////////////////

- (IBAction)sendButtonClicked: (id)sender
{
    NSXMLElement *body = [NSXMLElement elementWithName: @"body"];
    [body setStringValue: self.textView.text];
    
    NSXMLElement *message = [NSXMLElement elementWithName: @"message"];
    [message addAttributeWithName: @"type" stringValue: @"chat"];
    [message addAttributeWithName: @"to" stringValue: self.rosterJid];
    [message addChild:body];
    
    [[[self appDelegate] xmppStream] sendElement: message];
    
    // save into database
    ChatMessage *msg = [[ChatMessage alloc] init];
    msg.direction = 1;
    msg.rosterDisplayName = self.rosterJid;
    msg.content = self.textView.text;
    msg.time = [[NSDate date] timeIntervalSince1970];
    [msg save];
    
    self.textView.text = @"";
    
    [self readFromDatabase];
    [[self chatTableView] reloadData];
    [self chatTableScrollToBottom];
}

- (IBAction)clearButtonClicked: (id)sender
{
    self.textView.text = @"";
}

/////////////////////////////////////////////////////////
#pragma mark - Table view data source
/////////////////////////////////////////////////////////

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    [self readFromDatabase];
    return self.allRecord.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"ChatCell";
    
    ChatTableViewCell *cell = (ChatTableViewCell *)[tableView dequeueReusableCellWithIdentifier: CellIdentifier];
    if (cell == nil) {
        cell = [[ChatTableViewCell alloc] initWithStyle: UITableViewCellStyleDefault reuseIdentifier: CellIdentifier];
    }
    
    // Configure the cell...
    ChatMessage *chatMessage= [self.allRecord objectAtIndex: indexPath.row];
    Message *msg = [[Message alloc] init];
    msg.peer = chatMessage.rosterDisplayName;
    msg.content = chatMessage.content;
    msg.time = [NSDate dateWithTimeIntervalSince1970: chatMessage.time];
    msg.isNew = true;
    if (1 == chatMessage.direction)
    {
        msg.from = false;
    }
    else
    {
        msg.from = true;
    }
    [cell setup:msg withWidth:tableView.frame.size.width];
    
    return cell;
}

/////////////////////////////////////////////////////////
#pragma mark - Table view delegate
/////////////////////////////////////////////////////////

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = 44;
    ChatMessage *chatMessage= [self.allRecord objectAtIndex: indexPath.row];
    Message *msg = [[Message alloc] init];
    msg.peer = chatMessage.rosterDisplayName;
    msg.content = chatMessage.content;
    msg.time = [NSDate dateWithTimeIntervalSince1970: chatMessage.time];
    if (1 == chatMessage.direction)
    {
        msg.from = true;
    }
    else
    {
        msg.from = false;
    }
    
    height = [ChatTableViewCell heightOfCellWithContent:msg withWidth:tableView.frame.size.width];
    
    return height;
}

@end
