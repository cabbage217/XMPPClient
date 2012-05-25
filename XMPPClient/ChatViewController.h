//
//  ChatViewController.h
//  iPhoneXMPP
//
//  Created by System Administrator on 5/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AppDelegate;

@interface ChatViewController : UIViewController<UITableViewDelegate, UITableViewDataSource>

@property (strong) AppDelegate *appDelegate;
@property (weak) IBOutlet UITextView *textView;
@property (weak) IBOutlet UITableView *chatTableView;
@property (strong) NSString *rosterJid;
@property (strong) NSMutableArray *allRecord;

- (void)readFromDatabase;
- (IBAction)sendButtonClicked: (id)sender;
- (IBAction)clearButtonClicked: (id)sender;

@end
