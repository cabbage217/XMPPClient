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
#import "TableView.h"

#import "XMPP.h"

@interface ChatViewController() <TableViewProtocol>

@property (strong) NSArray *allRecord;
@property (nonatomic) CGRect theTableViewOriFrame;
@property (nonatomic) CGRect inputViewOriFrame;

- (void)keyboardWillShow:(NSNotification *)notification;
- (void)keyboardWillHide:(NSNotification *)notification;

@end

@implementation ChatViewController

@synthesize appDelegate = appDelegate_;
@synthesize textView = _textView;
@synthesize chatTableView = _chatTableView;
@synthesize inputView = _inputView;
@synthesize theTableView = _theTableView;
@synthesize sendButton = _sendButton;
@synthesize clearButton = _clearButton;
@synthesize rosterJid = rosterJid_;
@synthesize allRecord = allRecode_;
@synthesize theTableViewOriFrame = _theTableViewOriFrame;
@synthesize inputViewOriFrame = _inputViewOriFrame;


////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma -mark ChatViewController lifecycle
////////////////////////////////////////////////////////////////////////////////////////////////////////////

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
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
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
    
    _textView.layer.borderWidth = 1;
    _textView.layer.cornerRadius = 5;

    _chatTableView.delegate = self;
    _chatTableView.dataSource = self;
    _chatTableView.parent = self;
    _textView.delegate = self;
    
    // read chat data from database
    [self readFromDatabase];
    
    UIColor *backgroundImage = [UIColor colorWithPatternImage: [UIImage imageNamed: @"main_bg.png"]];
    self.view.backgroundColor = backgroundImage;
    _chatTableView.layer.cornerRadius = 5;
    _textView.layer.cornerRadius = 5;
}

- (void)viewDidUnload
{
    [self setInputView:nil];
    [self setTheTableView:nil];
    [self setSendButton:nil];
    [self setClearButton:nil];
    [super viewDidUnload];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    _textView = nil;
    _chatTableView = nil;
    allRecode_ = nil;
    rosterJid_ = nil;
    appDelegate_ = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [self chatTableScrollToBottom];
    _inputViewOriFrame = _inputView.frame;
    _theTableViewOriFrame = _theTableView.frame;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return UIInterfaceOrientationPortrait == interfaceOrientation;
}

///////////////////////////////////////////////////////////////////////////////////////////
#pragma -mark public menthods
///////////////////////////////////////////////////////////////////////////////////////////
- (void)readFromDatabase
{
    self.allRecord = [[NSArray alloc] initWithArray: [ChatMessage findWithSqlWithParameters: [NSString stringWithFormat: @"SELECT * FROM ChatMessage WHERE (sender IN (?, ?)) AND (receiver IN (?, ?))"], appDelegate_.xmppStream.myJID.bare, rosterJid_, appDelegate_.xmppStream.myJID.bare, rosterJid_, nil]];
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
    if ([_textView.text isEqualToString: @""])
    {
        return;
    }
    
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
    msg.sender =  appDelegate_.xmppStream.myJID.bare;
    msg.receiver = self.rosterJid;
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
    _textView.text = @"";
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
    
    msg.content = chatMessage.content;
    msg.time = [NSDate dateWithTimeIntervalSince1970: chatMessage.time];
    msg.isNew = true;
    if ([chatMessage.sender isEqualToString: appDelegate_.xmppStream.myJID.bare])
    {
        msg.from = false;
        msg.peer = chatMessage.receiver;
    }
    else
    {
        msg.from = true;
        msg.peer = chatMessage.sender;
    }
    [cell setup:msg withWidth:tableView.frame.size.width];
    
    return cell;
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Table view delegate
///////////////////////////////////////////////////////////////////////////////////////////////////////////

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = 44;
    ChatMessage *chatMessage= [self.allRecord objectAtIndex: indexPath.row];
    Message *msg = [[Message alloc] init];
    msg.content = chatMessage.content;
    msg.time = [NSDate dateWithTimeIntervalSince1970: chatMessage.time];
    if ([chatMessage.sender isEqualToString: appDelegate_.xmppStream.myJID.bare])
    {
        msg.from = false;
        msg.peer = chatMessage.receiver;
    }
    else
    {
        msg.from = true;
        msg.peer = chatMessage.sender;
    }
    
    height = [ChatTableViewCell heightOfCellWithContent:msg withWidth:tableView.frame.size.width];
    
    return height;
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - TableViewProtocol
///////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void) tableViewTouched
{
    [_textView resignFirstResponder];
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - UITextView delegate
///////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)textViewDidChange:(UITextView *)textView
{
    if (![textView.text isEqualToString: @""])
    {
        _sendButton.enabled = YES;
        _clearButton.enabled = YES;
        _sendButton.alpha = 1;
        _clearButton.alpha = 1;
    }
    else
    {
        _sendButton.enabled = NO;
        _clearButton.enabled = NO;
        _sendButton.alpha = 0.5;
        _clearButton.alpha = 0.5;
    }
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - keyboard events
///////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)keyboardWillShow:(NSNotification *)notification
{
    if (nil == self.view.superview)
        return;
    /*
     Reduce the size of the text view so that it's not obscured by the keyboard.
     Animate the resize so that it's in sync with the appearance of the keyboard.
     */
    
    NSDictionary *userInfo = [notification userInfo];
    
    // Get the origin of the keyboard when it's displayed.
    NSValue* aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    
    // Get the top of the keyboard as the y coordinate of its origin in self's view's coordinate system. The bottom of the text view's frame should align with the top of the keyboard's final position.
    CGRect keyboardRect = [aValue CGRectValue];
    keyboardRect = [self.view convertRect:keyboardRect fromView:nil];
    
    CGFloat keyboardHeight = keyboardRect.size.height;
    
    // Get the duration of the animation.
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue: &animationDuration];
    
    // Animate the resize of the text view's frame in sync with the keyboard's appearance.
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration: animationDuration];
    
    if ([_textView isFirstResponder])
    {
        _theTableView.frame = CGRectMake(_theTableViewOriFrame.origin.x, _theTableViewOriFrame.origin.y, _theTableViewOriFrame.size.width, _theTableViewOriFrame.size.height - keyboardHeight);
        _inputView.frame = CGRectMake(_inputViewOriFrame.origin.x, _inputViewOriFrame.origin.y-keyboardHeight, _inputViewOriFrame.size.width,_inputViewOriFrame.size.height);
    }
    
    [UIView commitAnimations];
    
    [self chatTableScrollToBottom];
}
- (void)keyboardWillHide:(NSNotification *)notification
{
    if (nil == self.view.superview)
        return;
    NSDictionary* userInfo = [notification userInfo];
    
    /*
     Restore the size of the text view (fill self's view).
     Animate the resize so that it's in sync with the disappearance of the keyboard.
     */
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:animationDuration];
    
    if ([_textView isFirstResponder])
    {
        _theTableView.frame = _theTableViewOriFrame;
        _inputView.frame = _inputViewOriFrame; 
    }
    
    [UIView commitAnimations];
    
    [self chatTableScrollToBottom];
}

@end
