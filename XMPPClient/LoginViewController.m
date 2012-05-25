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

@interface LoginViewController()

- (void)setField: (UITextField *)field forKey: (NSString *)key;

@end

@implementation LoginViewController

@synthesize jidField;
@synthesize passwordField;
@synthesize indicatorView;
@synthesize loginButton;
@synthesize logining;


- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)awakeFromNib {
    self.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
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
    
    jidField.text = [[NSUserDefaults standardUserDefaults] stringForKey:kXMPPmyJID];
    passwordField.text = [[NSUserDefaults standardUserDefaults] stringForKey:kXMPPmyPassword];
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

- (void)setField:(UITextField *)field forKey:(NSString *)key
{
    if (field.text != nil) 
    {
        [[NSUserDefaults standardUserDefaults] setObject:field.text forKey:key];
    } else {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:key];
    }
}

-(void)showLogin:(BOOL)show
{
    if (show)
    {
        [self.indicatorView stopAnimating];
        self.jidField.alpha = 1;
        self.passwordField.alpha = 1;
        self.loginButton.selected = NO;
        self.logining = NO;
    }
    else
    {
        [self.indicatorView startAnimating];
        self.jidField.alpha = 0.5;
        self.passwordField.alpha = 0.5;
        self.loginButton.selected = YES;
        self.logining = YES;
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
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    if (self.logining)
    {
        [appDelegate disconnect];
        [self showLogin: YES];
        return;
    }
    
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
        
    [self setField: jidField forKey: kXMPPmyJID];
    [self setField: passwordField forKey:kXMPPmyPassword];
    
    [self dismissModalViewControllerAnimated:YES];
    
    [appDelegate connect];
    
}

- (IBAction)hideKeyboard:(id)sender
{
    [sender resignFirstResponder];
    [self login: sender];
}

@end
