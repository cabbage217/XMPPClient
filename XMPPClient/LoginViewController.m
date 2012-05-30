//
//  LoginViewController.m
//  iPhoneXMPP
//
//  Created by System Administrator on 5/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "LoginViewController.h"
#import "RosterTableViewController.h"
#import "AppDelegate.h"

#define DISABLE_ALPHA 0.3
#define ENABLE_ALPHA 1

NSString *const kXMPPmyJID = @"kXMPPmyJID";
NSString *const kXMPPmyPassword = @"kXMPPmyPassword";
NSString *const kRemenberPassword = @"kRemenberPassword";

@interface LoginViewController()

@property (weak) AppDelegate *appDelegate;

- (void)setField: (id)obj forKey: (NSString *)key;

@end

@implementation LoginViewController

@synthesize appDelegate = _appDelegate;
@synthesize jidField = _jidField;
@synthesize passwordField = _passwordField;
@synthesize switcher = _switcher;
@synthesize indicatorView = _indicatorView;
@synthesize loginButton = _loginButton;
@synthesize cancelButton = _cancelButton;
@synthesize jidLabel = _jidLabel;
@synthesize passwordLabel = _passwordLabel;
@synthesize remberPwdLabel = _remberPwdLabel;
@synthesize logining = _logining;


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
    
    _appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    _appDelegate.loginViewController = self;
    
    _logining = NO;
    UIColor *background = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"login_bg.png"]];
    self.view.backgroundColor = background;
}

- (void)viewWillAppear:(BOOL)animated 
{
    [super viewWillAppear:animated];
    
    _jidField.text = [[NSUserDefaults standardUserDefaults] stringForKey:kXMPPmyJID];
    if ([[[NSUserDefaults standardUserDefaults] stringForKey: kRemenberPassword] isEqualToString: @"YES"])
    {
        _passwordField.text = [[NSUserDefaults standardUserDefaults] stringForKey:kXMPPmyPassword];
        _switcher.on = YES;
    }
    else
    {
        _passwordField.text = @"";
        _switcher.on = NO;
    }
    
    [_appDelegate disconnect];
    [self showLogin: YES];
    
}

- (void)viewDidUnload
{
    [self setJidLabel:nil];
    [self setPasswordLabel:nil];
    [self setRemberPwdLabel:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return (UIInterfaceOrientationPortrait == interfaceOrientation);
}

- (void)setField: (id)obj forKey: (NSString *)key
{
    if ([obj isKindOfClass: [UITextField class]])
    {
        UITextField *field = (UITextField *)obj;
        if (field.text != nil) 
        {
            [[NSUserDefaults standardUserDefaults] setObject:field.text forKey: key];
        }
        else
        {
            [[NSUserDefaults standardUserDefaults] removeObjectForKey: key];
        }
    }
    else
        if ([obj isKindOfClass: [UISwitch class]])
        {
            UISwitch *switcherTemp = (UISwitch *)obj;
            if (switcherTemp.on)
            {
                [[NSUserDefaults standardUserDefaults] setObject: @"YES" forKey: key];
            }
            else
            {
                [[NSUserDefaults standardUserDefaults] removeObjectForKey: key];
            }
        }
    
}

-(void)showLogin:(BOOL)show
{
    if (show)
    {
        [_indicatorView stopAnimating];
        _logining = NO;
        
        _jidField.enabled = YES;
        _passwordField.enabled = YES;
        _switcher.enabled = YES;
        _loginButton.enabled = YES;
        _cancelButton.enabled = NO;
        _jidField.alpha = ENABLE_ALPHA;
        _passwordField.alpha = ENABLE_ALPHA;
        _switcher.alpha = ENABLE_ALPHA;
        _loginButton.alpha = ENABLE_ALPHA;
        _cancelButton.alpha = DISABLE_ALPHA;
        
        _jidLabel.alpha = ENABLE_ALPHA;
        _passwordLabel.alpha = ENABLE_ALPHA;
        _remberPwdLabel.alpha = ENABLE_ALPHA;
        
    }
    else
    {
        [_indicatorView startAnimating];
        _logining = YES;
        
        _jidField.enabled = NO;
        _passwordField.enabled = NO;
        _switcher.enabled = NO;
        _loginButton.enabled = NO;
        _cancelButton.enabled = YES;
        _jidField.alpha = DISABLE_ALPHA;
        _passwordField.alpha = DISABLE_ALPHA;
        _switcher.alpha = DISABLE_ALPHA;
        _loginButton.alpha = DISABLE_ALPHA;
        _cancelButton.alpha = ENABLE_ALPHA;
        
        _jidLabel.alpha = DISABLE_ALPHA;
        _passwordLabel.alpha = DISABLE_ALPHA;
        _remberPwdLabel.alpha = DISABLE_ALPHA;
        
    }
}

- (void)haveLogined
{
    [self showLogin: YES];
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Actions
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (IBAction)login:(id)sender
{    
    if ((0 == self.jidField.text.length) || (0 == self.passwordField.text.length))
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle: NSLocalizedString(@"Error", @"")
                                                            message: NSLocalizedString(@"JID and password can not be empty", @"")
                                                           delegate: nil
                                                  cancelButtonTitle: NSLocalizedString(@"OK", @"")
                                                  otherButtonTitles: nil];
        [alertView show];
        
        return;
    }
    
    [self showLogin: NO];
        
    [self setField: _jidField forKey: kXMPPmyJID];
    [self setField: _passwordField forKey: kXMPPmyPassword];
    [self setField: _switcher forKey: kRemenberPassword];
    
    [_appDelegate connect];
    
}

- (IBAction)cancel:(id)sender
{
    _appDelegate.isUserCancelLogin = YES;
    [_appDelegate disconnect];
    [self showLogin: YES];
}

- (IBAction)hideKeyboard:(id)sender
{
    [sender resignFirstResponder];
    [self login: sender];
}

@end
