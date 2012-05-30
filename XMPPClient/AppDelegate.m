#import "AppDelegate.h"
#import "RosterTableViewController.h"
#import "LoginViewController.h"
#import "ChatViewController.h"
#import "ChatMessage.h"

#import "GCDAsyncSocket.h"
#import "XMPP.h"
#import "XMPPReconnect.h"
#import "XMPPCapabilitiesCoreDataStorage.h"
#import "XMPPRosterCoreDataStorage.h"
#import "XMPPvCardAvatarModule.h"
#import "XMPPvCardCoreDataStorage.h"
#import "Appdatabase.h"

#import "DDLog.h"
#import "DDTTYLogger.h"

#import <CFNetwork/CFNetwork.h>

// Log levels: off, error, warn, info, verbose
#if DEBUG
static const int ddLogLevel = LOG_LEVEL_VERBOSE;
#else
static const int ddLogLevel = LOG_LEVEL_INFO;
#endif

@interface AppDelegate()

@property (nonatomic) BOOL isLogining;

- (void)setupStream;
- (void)teardownStream;

- (void)goOnline;
- (void)goOffline;

@end

@implementation AppDelegate

@synthesize isLogining = _isLogining;
@synthesize xmppStream = _xmppStream;
@synthesize xmppReconnect = _xmppReconnect;
@synthesize xmppRoster = _xmppRoster;
@synthesize xmppRosterStorage = _xmppRosterStorage;
@synthesize xmppvCardStorage = _xmppvCardStorage;
@synthesize xmppvCardTempModule = _xmppvCardTempModule;
@synthesize xmppvCardAvatarModule = _xmppvCardAvatarModule;
@synthesize xmppCapabilities = _xmppCapabilities;
@synthesize xmppCapabilitiesStorage = _xmppCapabilitiesStorage;
@synthesize database = _database;
@synthesize password = _password;
@synthesize isXmppConnected = _isXmppConnected;
@synthesize loginViewController = _loginViewController;
@synthesize rosterTableViewController = _rosterTableViewController;
@synthesize isLogined = _isLogined;
@synthesize allowSSLHostNameMismatch = _allowSSLHostNameMismatch;
@synthesize allowSelfSignedCertificates = _allowSelfSignedCertificates;
@synthesize isUserCancelLogin = _isUserCancelLogin;

@synthesize window = _window;

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark UIApplicationDelegate
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Configure logging framework
	[DDLog addLogger:[DDTTYLogger sharedInstance]];
    
    // setup database
    self.database = [[AppDatabase alloc] initWithMigrations];
    // create table Message when not exist in database
    if (![[self database] checkTableWithName: @"ChatMessage"])
    {
        [[self database] createMyTable];
    }
    
    _loginViewController = nil;
    _rosterTableViewController = nil;
    _isLogining = NO;
    _isLogined = NO;
    _isUserCancelLogin = NO;
    
    // Setup the XMPP stream
	[self setupStream];
    
	return YES;
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    
    #if TARGET_IPHONE_SIMULATOR
	DDLogError(@"The iPhone simulator does not process background network traffic. "
			   @"Inbound traffic is queued until the keepAliveTimeout:handler: fires.");
    #endif
    
	if ([application respondsToSelector:@selector(setKeepAliveTimeout:handler:)]) 
	{
		[application setKeepAliveTimeout:600 handler:^{
			
			DDLogVerbose(@"KeepAliveHandler");
			
			// Do other keep alive stuff here.
		}];
	}
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

///////////////////////////////////////////////////////////////////////////////
#pragma -mark private menthods
///////////////////////////////////////////////////////////////////////////////
- (void)setupStream
{
	NSAssert(_xmppStream == nil, @"Method setupStream invoked multiple times");
	
	// Setup xmpp stream
	_xmppStream = [[XMPPStream alloc] init];
	
#if !TARGET_IPHONE_SIMULATOR
	{
		
		xmppStream.enableBackgroundingOnSocket = YES;
	}
#endif
	
	// Setup reconnect
	_xmppReconnect = [[XMPPReconnect alloc] init];
	
	// Setup roster
	_xmppRosterStorage = [[XMPPRosterCoreDataStorage alloc] init];
	
	_xmppRoster = [[XMPPRoster alloc] initWithRosterStorage: _xmppRosterStorage];
	
	_xmppRoster.autoFetchRoster = YES;
	_xmppRoster.autoAcceptKnownPresenceSubscriptionRequests = YES;
	
	// Setup vCard support
	_xmppvCardStorage = [XMPPvCardCoreDataStorage sharedInstance];
	_xmppvCardTempModule = [[XMPPvCardTempModule alloc] initWithvCardStorage:_xmppvCardStorage];
	
	_xmppvCardAvatarModule = [[XMPPvCardAvatarModule alloc] initWithvCardTempModule:_xmppvCardTempModule];
	
	_xmppCapabilitiesStorage = [XMPPCapabilitiesCoreDataStorage sharedInstance];
    _xmppCapabilities = [[XMPPCapabilities alloc] initWithCapabilitiesStorage:_xmppCapabilitiesStorage];
    
    _xmppCapabilities.autoFetchHashedCapabilities = YES;
    _xmppCapabilities.autoFetchNonHashedCapabilities = NO;
    
	[_xmppRoster            activate:_xmppStream];
	[_xmppvCardTempModule   activate:_xmppStream];
	[_xmppvCardAvatarModule activate:_xmppStream];
	[_xmppCapabilities      activate:_xmppStream];
    
	[_xmppStream addDelegate:self delegateQueue:dispatch_get_main_queue()];
	[_xmppRoster addDelegate:self delegateQueue:dispatch_get_main_queue()];
	
	_allowSelfSignedCertificates = NO;
	_allowSSLHostNameMismatch = NO;
}

- (void)teardownStream
{
	[_xmppStream removeDelegate:self];
	[_xmppRoster removeDelegate:self];
	
	[_xmppReconnect         deactivate];
	[_xmppRoster            deactivate];
	[_xmppvCardTempModule   deactivate];
	[_xmppvCardAvatarModule deactivate];
	[_xmppCapabilities      deactivate];
	
	[_xmppStream disconnect];
	
	_xmppStream = nil;
	_xmppReconnect = nil;
    _xmppRoster = nil;
	_xmppRosterStorage = nil;
	_xmppvCardStorage = nil;
    _xmppvCardTempModule = nil;
	_xmppvCardAvatarModule = nil;
	_xmppCapabilities = nil;
	_xmppCapabilitiesStorage = nil;
    _loginViewController = nil;
    _rosterTableViewController = nil;
    _isLogining = NO;
    _isLogined = NO;
}

- (void)goOnline
{
	XMPPPresence *presence = [XMPPPresence presence]; // type="available" is implicit
	[[self xmppStream] sendElement:presence];
    
    _isLogining = NO;
    _isLogined = YES;
    [_loginViewController showLogin: YES];
    
    [_loginViewController performSegueWithIdentifier: @"rosterListSegue" sender: _loginViewController];
}

- (void)goOffline
{
	XMPPPresence *presence = [XMPPPresence presenceWithType:@"unavailable"];
	
	[[self xmppStream] sendElement: presence];
    _isLogining = NO;
    _isLogined = NO;
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Connect/disconnect
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (BOOL)connect
{
	if (![_xmppStream isDisconnected]) {
		return YES;
	}
    
    [_xmppReconnect activate: _xmppStream];
    
	NSString *myJID = [[NSUserDefaults standardUserDefaults] stringForKey: kXMPPmyJID];
	NSString *myPassword = [[NSUserDefaults standardUserDefaults] stringForKey: kXMPPmyPassword];
    
	//
	// If you don't want to use the Settings view to set the JID, 
	if (myJID == nil || myPassword == nil) {
		return NO;
	}
    
	[_xmppStream setMyJID:[XMPPJID jidWithString:myJID]];
	_password = myPassword;
    _isLogining = YES;
    
	NSError *error = nil;
	if (![_xmppStream connect: &error])
	{
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle: NSLocalizedString(@"Error connecting", @"")
		                                                    message: NSLocalizedString(@"Some errors occured when connecting to server, please re-login.", @"")
		                                                   delegate: nil
		                                          cancelButtonTitle: NSLocalizedString(@"OK", @"")
		                                          otherButtonTitles: nil];
		[alertView show];
        
		DDLogError(@"Error connecting: %@", error);
        
		return NO;
	}
    
	return YES;
}

- (void)disconnect
{
    if (_isLogined)
	{
        [self goOffline];
        [_xmppStream disconnect];
    }
    else
        if (_isLogining)
        {
            [_xmppStream disconnect];
            _isLogining = NO;
        }
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Core Data
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (NSManagedObjectContext *)managedObjectContext_roster
{
	return [_xmppRosterStorage mainThreadManagedObjectContext];
}

- (NSManagedObjectContext *)managedObjectContext_capabilities
{
	return [_xmppCapabilitiesStorage mainThreadManagedObjectContext];
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark XMPPStream Delegate
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)xmppStream:(XMPPStream *)sender socketDidConnect:(GCDAsyncSocket *)socket 
{
	DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
}

- (void)xmppStream:(XMPPStream *)sender willSecureWithSettings:(NSMutableDictionary *)settings
{
	DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
	
	if (_allowSelfSignedCertificates)
	{
		[settings setObject:[NSNumber numberWithBool:YES] forKey:(NSString *)kCFStreamSSLAllowsAnyRoot];
	}
	
	if (_allowSSLHostNameMismatch)
	{
		[settings setObject:[NSNull null] forKey:(NSString *)kCFStreamSSLPeerName];
	}
	else
	{
		NSString *expectedCertName = nil;
		
		NSString *serverDomain = _xmppStream.hostName;
		NSString *virtualDomain = [_xmppStream.myJID domain];
		
		if ([serverDomain isEqualToString:@"talk.google.com"])
		{
			if ([virtualDomain isEqualToString:@"gmail.com"])
			{
				expectedCertName = virtualDomain;
			}
			else
			{
				expectedCertName = serverDomain;
			}
		}
		else if (serverDomain == nil)
		{
			expectedCertName = virtualDomain;
		}
		else
		{
			expectedCertName = serverDomain;
		}
		
		if (expectedCertName)
		{
			[settings setObject:expectedCertName forKey:(NSString *)kCFStreamSSLPeerName];
		}
	}
}

- (void)xmppStreamDidSecure:(XMPPStream *)sender
{
	DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
}

- (void)xmppStreamDidConnect:(XMPPStream *)sender
{
	DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
	
	_isXmppConnected = YES;
	
	NSError *error = nil;
	
	if (![[self xmppStream] authenticateWithPassword:_password error:&error])
	{
		DDLogError(@"Error authenticating: %@", error);
	}
}

- (void)xmppStreamDidAuthenticate:(XMPPStream *)sender
{
	DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
	
	[self goOnline];
}

- (void)xmppStream:(XMPPStream *)sender didNotAuthenticate:(NSXMLElement *)error
{
	DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Login Failed", @"")
                                                        message:NSLocalizedString(@"Login failed, wrong JID or password, please retry.", @"")
                                                       delegate:nil 
                                              cancelButtonTitle:NSLocalizedString(@"OK", @"")
                                              otherButtonTitles:nil];
    [alertView show];
    
    _isLogining = NO;
    [_loginViewController showLogin: YES];
}

- (BOOL)xmppStream:(XMPPStream *)sender didReceiveIQ:(XMPPIQ *)iq
{
	DDLogVerbose(@"%@: %@ - %@", THIS_FILE, THIS_METHOD, [iq elementID]);
	
	return NO;
}

- (void)xmppStream:(XMPPStream *)sender didReceiveMessage:(XMPPMessage *)message
{
	DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    
	if ([message isChatMessageWithBody])
	{
		XMPPUserCoreDataStorageObject *user = [_xmppRosterStorage userForJID:[message from]
		                                                         xmppStream:_xmppStream
		                                               managedObjectContext:[self managedObjectContext_roster]];
		
		NSString *body = [[message elementForName:@"body"] stringValue];
		NSString *jidStr = [user jidStr];
        
        // save into database
        ChatMessage *msg = [[ChatMessage alloc] init];
        msg.direction = 0;
        msg.receiver = _xmppStream.myJID.bare;
        msg.sender = jidStr;
        msg.content = body;
        msg.time = [[NSDate date] timeIntervalSince1970];
        [msg save];
        
        if (_rosterTableViewController)
        {
            [_rosterTableViewController newMsgCome];
        }
	}
}

- (void)xmppStream:(XMPPStream *)sender didReceivePresence:(XMPPPresence *)presence
{
	DDLogVerbose(@"%@: %@ - %@", THIS_FILE, THIS_METHOD, [presence fromStr]);
}

- (void)xmppStream:(XMPPStream *)sender didReceiveError:(id)error
{
	DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
}

- (void)xmppStreamDidDisconnect:(XMPPStream *)sender withError:(NSError *)error
{
	DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    if (_isUserCancelLogin)
    {
        _isUserCancelLogin = NO;
        [_xmppReconnect deactivate];
        return;
    }
    
    if (!_isXmppConnected)
    {
        DDLogError(@"Unable to connect to server. Check xmppStream.hostName");
        _isLogining = NO;
        _isLogined = NO;
        [_loginViewController showLogin: YES];
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle: NSLocalizedString(@"Login Failed", @"") message: NSLocalizedString(@"Login failed, Unable to connect to server.", @"") delegate:nil cancelButtonTitle: NSLocalizedString(@"OK", @"") otherButtonTitles:nil];
        [alertView show];
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark XMPPRosterDelegate
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)xmppRoster:(XMPPRoster *)sender didReceiveBuddyRequest:(XMPPPresence *)presence
{
	DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
	
	XMPPUserCoreDataStorageObject *user = [_xmppRosterStorage userForJID:[presence from]
	                                                         xmppStream:_xmppStream
	                                               managedObjectContext:[self managedObjectContext_roster]];
	
	NSString *displayName = [user displayName];
	NSString *jidStrBare = [presence fromStr];
	NSString *body = nil;
	
	if (![displayName isEqualToString:jidStrBare])
	{
		body = [NSString stringWithFormat: NSLocalizedString(@"Buddy request from %@ <%@>", @""), displayName, jidStrBare];
	}
	else
	{
		body = [NSString stringWithFormat: NSLocalizedString(@"Buddy request from %@", @""), displayName];
	}
	
	
	if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateActive)
	{
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:displayName
		                                                    message:body 
		                                                   delegate:nil 
		                                          cancelButtonTitle:NSLocalizedString(@"Not implemented", @"")
		                                          otherButtonTitles:nil];
		[alertView show];
	} 
	else 
	{
		// We are not active, so use a local notification instead
		UILocalNotification *localNotification = [[UILocalNotification alloc] init];
		localNotification.alertAction = NSLocalizedString(@"Not implemented", @"");
		localNotification.alertBody = body;
		
		[[UIApplication sharedApplication] presentLocalNotificationNow:localNotification];
	}
	
}

@end
