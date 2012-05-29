//
//  TableView.h
//  XMPPClient
//

#import <UIKit/UIKit.h>

@protocol TableViewProtocol <NSObject>

@optional
- (void)tableViewTouched;
- (void)beginEditing;

@end

@interface TableView : UITableView

@property (nonatomic, strong) id parent;
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)enterEditing: (UIGestureRecognizer *)gestureRecognizer;

@end

