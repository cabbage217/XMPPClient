//
//  ChatTableViewCell.h
//  Drsoon
//
//  Created by gump on 11-10-25.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
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
