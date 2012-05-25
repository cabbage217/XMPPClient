#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>


@interface RosterTableViewController : UITableViewController <NSFetchedResultsControllerDelegate>
{
	NSFetchedResultsController *fetchedResultsController;
}

@end
