//
//  InvitationViewController.m
//  XMPPClient
//
//  Created by Jason Yuan on 12-4-25.
//  Copyright (c) 2012年 Cabbage All rights reserved.
//

#import "InvitationViewController.h"
#import "AppDelegate.h"

@interface InvitationViewController()

@property (nonatomic, strong)AppDelegate *appDelegate;

@end

@implementation InvitationViewController

@synthesize informLabel = _informLabel;
@synthesize addButton = _addButton;
@synthesize userNameEdit = _userNameEdit;
@synthesize nickNameEdit = _nickNameEdit;
@synthesize appDelegate = _appDelegate;
@synthesize delegate = _delegate;

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    _appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
}

- (void)viewDidUnload
{
    [self setInformLabel:nil];
    [self setAddButton:nil];
    [self setUserNameEdit:nil];
    [self setNickNameEdit:nil];
    [self setAppDelegate: nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

- (IBAction)onAddPressed:(id)sender 
{
    if ([_userNameEdit.text length] == 0)
    {
        _informLabel.text = NSLocalizedString(@"Please input the JID of receiver", @"");
        return;
    }
    if ([_userNameEdit.text isEqualToString: [[[_appDelegate xmppStream] myJID] bare]])
    {
        _informLabel.text = NSLocalizedString(@"Can not add self", @"");
        return;
    }
    
    [_appDelegate.xmppRoster addUser: [XMPPJID jidWithString: _userNameEdit.text] withNickname: _nickNameEdit.text];
    
    _userNameEdit.text = @"";
    _nickNameEdit.text = @"";
    
    if ([_delegate respondsToSelector: @selector(confirm)])
    {
        [_delegate confirm];
    }
}

@end
