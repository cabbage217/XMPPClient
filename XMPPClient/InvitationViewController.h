//
//  InvitationViewController.h
//  DrsoonClient
//
//  Created by Jason Yuan on 12-4-25.
//  Copyright (c) 2012年 Drsoon.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol InvitationViewDelegate <NSObject>

@required
- (void) confirm;

@end

@interface InvitationViewController : UIViewController

@property (weak) id<InvitationViewDelegate> delegate;

@property (weak) IBOutlet UILabel *informLabel;
@property (weak) IBOutlet UIButton *addButton;
@property (weak) IBOutlet UITextField *userNameEdit;
@property (weak) IBOutlet UITextField *nickNameEdit;

- (IBAction)onAddPressed:(id)sender;
@end
