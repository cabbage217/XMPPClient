#import <QuartzCore/QuartzCore.h>

#import "RosterTableViewController.h"
#import "AppDelegate.h"
#import "ChatViewController.h"
#import "InvitationViewController.h"
#import "TableView.h"

#import "XMPPFramework.h"
#import "DDLog.h"

// Log levels: off, error, warn, info, verbose
#if DEBUG
  static const int ddLogLevel = LOG_LEVEL_VERBOSE;
#else
  static const int ddLogLevel = LOG_LEVEL_INFO;
#endif

@interface RosterTableViewController() <UIAlertViewDelegate, TableViewProtocol, UIPopoverControllerDelegate>

@property (nonatomic, strong) UIPopoverController * invitationPop;
@property (nonatomic, strong) ChatViewController *currentChatViewController;
@property (nonatomic) BOOL isChatting;
@property (strong) NSString *currentDelete;
@property (strong, nonatomic) NSString *currentChatWith;

- (void)logOut;

@end

@implementation RosterTableViewController

@synthesize fetchedResultsController = _fetchedResultsController;
@synthesize invitationPop = _invitationPop;
@synthesize addRosterButton = _addRosterButton;
@synthesize tableView = _tableView;
@synthesize popoverView = _popoverView;
@synthesize currentChatWith = _currentChatWith;
@synthesize currentChatViewController = _currentChatViewController;
@synthesize isChatting = _isChatting;
@synthesize currentDelete = _currentDelete;
@synthesize isEditting = _isEditing;

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Accessors
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (AppDelegate *)appDelegate
{
	return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark View lifecycle
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // title
	UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 400, 44)];
	titleLabel.backgroundColor = [UIColor clearColor];
	titleLabel.textColor = [UIColor whiteColor];
	titleLabel.font = [UIFont boldSystemFontOfSize:20.0];
	titleLabel.numberOfLines = 1;
	titleLabel.adjustsFontSizeToFitWidth = YES;
	titleLabel.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.5];
	titleLabel.textAlignment = UITextAlignmentCenter;
    
	if ([[self appDelegate] isLogined]) 
	{
		titleLabel.text = [[[[self appDelegate] xmppStream] myJID] bare];
	} else
	{
		titleLabel.text = NSLocalizedString(@"No JID", @"");
	}
	[titleLabel sizeToFit];
	self.navigationItem.titleView = titleLabel;
    
    [self appDelegate].rosterTableViewController = self;
    
    _tableView.layer.cornerRadius = 5;
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.parent = self;
    UILongPressGestureRecognizer *longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget: _tableView action: @selector(enterEditing:)];
    
    [_tableView addGestureRecognizer: longPressGestureRecognizer];
    
    _fetchedResultsController = nil;
    _invitationPop = nil;
    _currentChatWith = nil;
    _currentChatViewController = nil;
    _isChatting = NO;
    _isEditing = NO;
    _currentDelete = nil;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    _fetchedResultsController = nil;
    _addRosterButton = nil;
    _tableView = nil;
    _popoverView = nil;
    _invitationPop = nil;
    _currentChatWith = nil;
    _currentChatViewController = nil;
    _isChatting = NO;
    _isEditing = NO;
    _currentDelete = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear: animated];
    _isChatting = NO;
}

- (void)viewWillDisappear:(BOOL)animated
{
    if (!_isChatting)
    {
        [self logOut];
        [super viewWillDisappear: animated];
    }
    else
    {
        if (_tableView.isEditing)
        {
            [_tableView setEditing: NO animated: YES];
        }
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma -mark Actions
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (IBAction)addRoster: (id)sender
{   
    if (_isEditing)
    {
        [_tableView setEditing: NO animated: YES];
        _isEditing = NO;
        self.navigationItem.rightBarButtonItem.title = NSLocalizedString(@"Add", @"");
        return;
    }
    
    InvitationViewController *invitationViewController = [[InvitationViewController alloc] initWithNibName: @"InvitationViewController" bundle:nil];
    _invitationPop = [[UIPopoverController alloc] initWithContentViewController: invitationViewController];
    _invitationPop.delegate = self;
    _invitationPop.popoverContentSize = invitationViewController.view.frame.size;

    [_invitationPop presentPopoverFromRect: CGRectMake(_popoverView.frame.origin.x + _popoverView.frame.size.width - 50, 0, 40, 1) inView: self.view permittedArrowDirections:UIPopoverArrowDirectionUp animated: YES];
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma -mark private menthods
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)logOut
{
    [[self appDelegate] disconnect];
	[[[self appDelegate] xmppvCardTempModule] removeDelegate: self];
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma -mark public menthods
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)newMsgCome
{
    [_currentChatViewController readFromDatabase];
    [_currentChatViewController.chatTableView reloadData];
    [_currentChatViewController chatTableScrollToBottom];
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark NSFetchedResultsController
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (NSFetchedResultsController *)fetchedResultsController
{
	if (_fetchedResultsController == nil)
	{
		NSManagedObjectContext *moc = [[self appDelegate] managedObjectContext_roster];
		
		NSEntityDescription *entity = [NSEntityDescription entityForName:@"XMPPUserCoreDataStorageObject"
		                                          inManagedObjectContext: moc];
		
		NSSortDescriptor *sd1 = [[NSSortDescriptor alloc] initWithKey:@"sectionNum" ascending:YES];
		NSSortDescriptor *sd2 = [[NSSortDescriptor alloc] initWithKey:@"displayName" ascending:YES];
		
		NSArray *sortDescriptors = [NSArray arrayWithObjects: sd1, sd2, nil];
		
		NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
		[fetchRequest setEntity:entity];
		[fetchRequest setSortDescriptors:sortDescriptors];
		[fetchRequest setFetchBatchSize:10];
		
		_fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
		                                                               managedObjectContext:moc
		                                                                 sectionNameKeyPath:@"sectionNum"
		                                                                          cacheName:nil];
		[_fetchedResultsController setDelegate:self];
		
		
		NSError *error = nil;
		if (![_fetchedResultsController performFetch:&error])
		{
			DDLogError(@"Error performing fetch: %@", error);
		}
	
	}
	
	return _fetchedResultsController;
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
	[_tableView reloadData];
}

/////////////////////////////////////////////////////////////////////////////////////////////
#pragma -mark InvitationViewDelegate
/////////////////////////////////////////////////////////////////////////////////////////////

- (void)confirm
{
    if (_invitationPop)
        [_invitationPop dismissPopoverAnimated: YES];
}

/////////////////////////////////////////////////////////////////////////////////////////////
#pragma -mark UIPopoverControllerDelegate
/////////////////////////////////////////////////////////////////////////////////////////////

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    if (_invitationPop)
        _invitationPop = nil;
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark UITableViewCell helpers
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)configurePhotoForCell:(UITableViewCell *)cell user:(XMPPUserCoreDataStorageObject *)user
{
	// Our xmppRosterStorage will cache photos as they arrive from the xmppvCardAvatarModule.
	// We only need to ask the avatar module for a photo, if the roster doesn't have it.
	
	if (user.photo != nil)
	{
		cell.imageView.image = user.photo;
	} 
	else
	{
		NSData *photoData = [[[self appDelegate] xmppvCardAvatarModule] photoDataForJID:user.jid];

		if (photoData != nil)
			cell.imageView.image = [UIImage imageWithData:photoData];
		else
            if ([user.jidStr isEqualToString: [[[[self appDelegate] xmppStream] myJID] bare]])
                 cell.imageView.image = [UIImage imageNamed: @"self"];
            else
                if (![user isOnline])
                    cell.imageView.image = [UIImage imageNamed:@"rosterOffline"];
                else
                    cell.imageView.image = [UIImage imageNamed: @"rosterOnline"];
	}
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark UITableView
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return [[[self fetchedResultsController] sections] count];
}

- (NSString *)tableView:(UITableView *)sender titleForHeaderInSection:(NSInteger)sectionIndex
{
	NSArray *sections = [[self fetchedResultsController] sections];
	
	if (sectionIndex < [sections count])
	{
		id <NSFetchedResultsSectionInfo> sectionInfo = [sections objectAtIndex:sectionIndex];
        
		int section = [sectionInfo.name intValue];
		switch (section)
		{
			case 0  : return NSLocalizedString(@"Online", @"");
			case 1  : return NSLocalizedString(@"Away", @"");
			default : return NSLocalizedString(@"Offline", @"");
		}
	}
	
	return @"";
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionIndex
{
	NSArray *sections = [[self fetchedResultsController] sections];
	
	if (sectionIndex < [sections count])
	{
		id <NSFetchedResultsSectionInfo> sectionInfo = [sections objectAtIndex:sectionIndex];
		return sectionInfo.numberOfObjects;
	}
	
	return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *CellIdentifier = @"RosterCell";
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil)
	{
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
		                               reuseIdentifier:CellIdentifier];
	}
	
	XMPPUserCoreDataStorageObject *user = [[self fetchedResultsController] objectAtIndexPath:indexPath];
	
    if ([user.jidStr isEqualToString: [[[[self appDelegate] xmppStream] myJID] bare]])
        cell.textLabel.text = [NSString stringWithFormat: NSLocalizedString(@"Self (%@)", @""), user.jidStr];
	else
        cell.textLabel.text = [NSString stringWithFormat: @"%@ (%@)", user.nickname, user.jidStr];
	[self configurePhotoForCell:cell user:user];
	
	return cell;
}

- (void)tableView: (UITableView *)tableView didSelectRowAtIndexPath: (NSIndexPath *)indexPath
{
    XMPPUserCoreDataStorageObject *user = [[self fetchedResultsController] objectAtIndexPath:indexPath];
    _currentChatWith = user.jidStr;
    _isChatting = YES;
    [_tableView setEditing: NO animated: NO];
    [self performSegueWithIdentifier: @"chatSegue" sender: self];
}

- (void)tableView:(UITableView *)tableView willBeginEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    _isEditing = YES;
    self.navigationItem.rightBarButtonItem.title = NSLocalizedString(@"Done", @"");
}

- (void)tableView: (UITableView *)tableView didEndEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    _isEditing = NO;
    self.navigationItem.rightBarButtonItem.title = NSLocalizedString(@"Add", @"");
}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    XMPPUserCoreDataStorageObject *user = [[self fetchedResultsController] objectAtIndexPath:indexPath];
    if ([user.jidStr isEqualToString: [[[[self appDelegate] xmppStream] myJID] bare]])
        return NO;
    else 
        return YES;
}

//- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    return UITableViewCellEditingStyleDelete;
//}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NSLocalizedString(@"Delete", @"");
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        XMPPUserCoreDataStorageObject *user = [[self fetchedResultsController] objectAtIndexPath:indexPath];
        _currentDelete = user.jidStr;
        UIAlertView * avlterView;
        avlterView = [[UIAlertView alloc] initWithTitle: NSLocalizedString(@"Delete Roster", @"")
                                                message: [NSString stringWithFormat: NSLocalizedString(@"Confirm to remove the roster\n  %@?\n", @""), user.jidStr]
                                            delegate: self 
                                   cancelButtonTitle: NSLocalizedString(@"Cancel", @"")
                                   otherButtonTitles: NSLocalizedString(@"Confirm", @""), nil];
        [avlterView show];
    }
}

/////////////////////////////////////////////////////////////////////////////////////////////
#pragma -mark TableViewProtocol
/////////////////////////////////////////////////////////////////////////////////////////////

- (void)beginEditing
{
    _isEditing = YES;
    self.navigationItem.rightBarButtonItem.title = NSLocalizedString(@"Done", @"");
    [_tableView setEditing: YES animated: YES];
}

/////////////////////////////////////////////////////////////////////////////////////////////
#pragma -mark UIAlertViewDelegate
/////////////////////////////////////////////////////////////////////////////////////////////

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex==alertView.firstOtherButtonIndex)
    {
        [[[self appDelegate] xmppRoster ]removeUser: [XMPPJID jidWithString: _currentDelete]];
    }
    
    [_tableView setEditing: NO animated: YES];
    _isEditing = NO;
    self.navigationItem.rightBarButtonItem.title = NSLocalizedString(@"Add", @"");
}

/////////////////////////////////////////////////////////////////////////////////////////////
#pragma -mark prepareForSegue
/////////////////////////////////////////////////////////////////////////////////////////////

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString: @"chatSegue"])
    {
        ChatViewController *chatViewController = (ChatViewController *)segue.destinationViewController;
        chatViewController.appDelegate = [self appDelegate];
        chatViewController.rosterJid = _currentChatWith;
        _currentChatViewController = chatViewController;
    }
}

@end
