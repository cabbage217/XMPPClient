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

NSString *const kXMPPmyJID = @"kXMPPmyJID";
NSString *const kXMPPmyPassword = @"kXMPPmyPassword";
NSString *const kRemenberPassword = @"kRemenberPassword";

@interface LoginViewController()

- (void)setField: (id)obj forKey: (NSString *)key;

@end

@implementation LoginViewController

@synthesize jidField = _jidField;
@synthesize passwordField = _passwordField;
@synthesize switcher = _switcher;
@synthesize indicatorView = _indicatorView;
@synthesize loginButton = _loginButton;
@synthesize cancelButton = _cancelButton;
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
    // Do any additional setup after loading the view from its nib.
    self.logining = NO;
    UIColor *background = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"login_bg.png"]];
    self.view.backgroundColor = background;
}

- (void)viewWillAppear:(BOOL)animated 
{
    [super viewWillAppear:animated];
    
    _jidField.text = [[NSUserDefaults standardUserDefaults] stringForKey:kXMPPmyJID];
    NSLog(@"%@", [[NSUserDefaults standardUserDefaults] stringForKey: kRemenberPassword]);
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
        _jidField.enabled = YES;
        _jidField.alpha = 1;
        _passwordField.enabled = YES;
        _passwordField.alpha = 1;
        _switcher.enabled = YES;
        _switcher.alpha = 1;
        _loginButton.enabled = YES;
        _loginButton.alpha = 1;
        _cancelButton.enabled = NO;
        _cancelButton.alpha = 0.5;
        _logining = NO;
    }
    else
    {
        [_indicatorView startAnimating];
        _jidField.enabled = NO;
        _jidField.alpha = 0.5;
        _passwordField.enabled = NO;
        _passwordField.alpha = 0.5;
        _switcher.enabled = NO;
        _switcher.alpha = 0.5;
        _loginButton.enabled = NO;
        _loginButton.alpha = 0.5;
        _cancelButton.enabled = YES;
        _cancelButton.alpha = 1;
        _logining = YES;
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
//    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
//    if (self.logining)
//    {
//        [appDelegate disconnect];
//        [self showLogin: YES];
//        return;
//    }
    
    if ((0 == self.jidField.text.length) || (0 == self.passwordField.text.length))
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                            message:@"jid and password can not be empty"
                                                           delegate:nil
                                                  cancelButtonTitle:@"Ok"
                                                  otherButtonTitles:nil];
        [alertView show];
        
        return;
    }
    
    [self showLogin: NO];
        
    [self setField: _jidField forKey: kXMPPmyJID];
    [self setField: _passwordField forKey: kXMPPmyPassword];
    [self setField: _switcher forKey: kRemenberPassword];
    
//    [self dismissModalViewControllerAnimated:YES];
    
//    [appDelegate connect];
    
}

- (IBAction)cancel:(id)sender
{
//    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
//    [appDelegate disconnect];
    [self showLogin: YES];
}

- (IBAction)hideKeyboard:(id)sender
{
    [sender resignFirstResponder];
    [self login: sender];
}

@end
