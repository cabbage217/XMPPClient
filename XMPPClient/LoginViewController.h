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

@property (nonatomic, weak) IBOutlet UITextField *jidField;
@property (nonatomic, weak) IBOutlet UITextField *passwordField;
@property (nonatomic, weak) IBOutlet UISwitch *switcher;
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *indicatorView;
@property (nonatomic, weak) IBOutlet UIButton *loginButton;
@property (nonatomic, weak) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet UILabel *jidLabel;
@property (weak, nonatomic) IBOutlet UILabel *passwordLabel;
@property (weak, nonatomic) IBOutlet UILabel *remberPwdLabel;

@property (nonatomic) BOOL logining;

- (IBAction)login: (id)sender;
- (IBAction)cancel:(id)sender;
- (void)showLogin: (BOOL)show;
- (void)haveLogined;
- (IBAction)hideKeyboard: (id)sender;

@end
