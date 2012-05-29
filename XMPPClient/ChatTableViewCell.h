//
//  ChatTableViewCell.h
//  XMPPClient
//


#import <UIKit/UIKit.h>

@interface Message : NSObject 
@property (nonatomic, strong) NSString * peer;
@property (nonatomic, strong) NSDate * time;
@property (nonatomic, strong) NSString * content;
@property bool from;
@property bool isNew;
@end

@interface ChatTableViewCell : UITableViewCell

- (void)setup:(Message *) message withWidth:(CGFloat)cellWidth;

+ (CGFloat)heightOfCellWithContent:(Message *) msg withWidth:(CGFloat)cellWidth;



@end
