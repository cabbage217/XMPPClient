//
//  ChatViewController.h
//  iPhoneXMPP
//
//  Created by System Administrator on 5/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AppDelegate;
@class TableView;

@interface ChatViewController : UIViewController<UITableViewDelegate, UITableViewDataSource, UITextViewDelegate>

@property (strong) AppDelegate *appDelegate;
@property (strong) NSString *rosterJid;

@property (weak) IBOutlet UITextView *textView;
@property (weak) IBOutlet TableView *chatTableView;
@property (weak, nonatomic) IBOutlet UIView *inputView;
@property (weak, nonatomic) IBOutlet UIView *theTableView;
@property (weak, nonatomic) IBOutlet UIButton *sendButton;
@property (weak, nonatomic) IBOutlet UIButton *clearButton;

- (void)readFromDatabase;
- (void) chatTableScrollToBottom;

- (IBAction)sendButtonClicked: (id)sender;
- (IBAction)clearButtonClicked: (id)sender;

@end