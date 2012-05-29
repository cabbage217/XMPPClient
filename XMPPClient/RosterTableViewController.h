#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@class TableView;

@interface RosterTableViewController : UIViewController <NSFetchedResultsControllerDelegate, UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong, readonly)NSFetchedResultsController *fetchedResultsController;
@property (nonatomic) BOOL isEditting;

@property (nonatomic, weak) IBOutlet UIBarButtonItem *addRosterButton;
@property (nonatomic, weak) IBOutlet TableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *popoverView;

- (IBAction)addRoster: (id)sender;
- (void)newMsgCome;

@end
