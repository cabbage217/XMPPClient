//
//  LoginViewController.h
//  iPhoneXMPP
//
//  Created by System Administrator on 5/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString *const kXMPPmyJID;
extern NSString *const kXMPPmyPassword;

@interface LoginViewController : UIViewController

@property (weak) IBOutlet UITextField *jidField;
@property (weak) IBOutlet UITextField *passwordField;
@property (weak) IBOutlet UIActivityIndicatorView *indicatorView;
@property (weak) IBOutlet UIButton *loginButton;
@property (nonatomic) BOOL logining;

- (IBAction)login: (id)sender;
- (void)showLogin: (BOOL)show;
- (void)haveLogined;
- (IBAction)hideKeyboard: (id)sender;

@end
