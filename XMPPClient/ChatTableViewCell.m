//
//  ChatTableViewCell.m
//  Drsoon
//
//  Created by gump on 11-10-25.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "ChatTableViewCell.h"

static const CGFloat margin = 4;
static const CGFloat titleHeight = 24;
static const CGFloat bubbleMargin = 16;

static const CGFloat NAME_FONT_SIZE = 17;
static const CGFloat DATE_FONT_SIZE = 12;
static const CGFloat CONTENT_FONT_SIZE = 15;

static const CGFloat untouchedWidth = 40, untouchedHeight = 30;

static UIImage *leftBubble = nil;
static UIImage *rightBubble = nil;
static const CGFloat bubbleHeight = 24;

@implementation Message
@synthesize content;
@synthesize from;
@synthesize peer;
@synthesize time;
@synthesize isNew;

@end

@interface ChatTableViewCell ()

+ (void) getShowName: (NSString **) name andWidth: (CGFloat *) width forMessage: (Message *) msg;
+ (CGSize) calcContenSize: (NSString *) content withWidth: (CGFloat) width;
+ (BOOL)theDay: (NSDate *)day isSameTo: (NSDate *)comparandDay;

@property (strong, nonatomic) UILabel *nameLabel;
@property (strong, nonatomic) UILabel *dateLabel;
@property (strong, nonatomic) UILabel *contentLabel;
@property (strong, nonatomic) UIImageView *cellBackgroundImage;

@end

@implementation ChatTableViewCell
@synthesize nameLabel;
@synthesize dateLabel;
@synthesize contentLabel;
@synthesize cellBackgroundImage;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        nameLabel = [[UILabel alloc] init];
        [nameLabel setFont:[UIFont systemFontOfSize:NAME_FONT_SIZE]];
        nameLabel.backgroundColor = [UIColor clearColor];
        dateLabel = [[UILabel alloc]init];
        [dateLabel setFont:[UIFont systemFontOfSize:DATE_FONT_SIZE]];
        dateLabel.backgroundColor = [UIColor clearColor];
        contentLabel = [[UILabel alloc] init];
        contentLabel.backgroundColor = [UIColor clearColor];
        contentLabel.numberOfLines = 0;
        [contentLabel setFont:[UIFont systemFontOfSize:CONTENT_FONT_SIZE]];
        cellBackgroundImage = [[UIImageView alloc] init];
        [self addSubview:nameLabel];
        [self addSubview:dateLabel];
        [self addSubview:cellBackgroundImage];
        [self addSubview:contentLabel];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}



- (void)setup:(Message *)message withWidth:(CGFloat)cellWidth
{
    //keep some margin
    cellWidth -= 2 * margin;
    message.content = [message.content stringByReplacingOccurrencesOfString:@"<br>" withString:@"\n"];
    
    if (nil == leftBubble)
    {
        UIImage *ori = [UIImage imageNamed:@"bubble_default_left.png"];
        leftBubble = [ori stretchableImageWithLeftCapWidth:untouchedWidth topCapHeight:untouchedHeight];
    }
    if (nil == rightBubble)
    {
        UIImage *ori = [UIImage imageNamed:@"bubble_default_right.png"];
        rightBubble = [ori stretchableImageWithLeftCapWidth:untouchedWidth topCapHeight:untouchedHeight];
    }
  
    CGFloat nameWidth=0;
    NSString *senderName=@"";
    
    [ChatTableViewCell getShowName:&senderName andWidth:&nameWidth forMessage:message];
    
    NSDateFormatter *formatter  = [[NSDateFormatter alloc] init];
    if ([ChatTableViewCell theDay: message.time isSameTo: [NSDate date]]) 
    {
        [formatter setDateFormat:@"HH:mm:ss"];
    }else
    {
        [formatter setDateFormat:@"MM-dd HH:mm:ss"];
    }
    
    [formatter setTimeZone:[NSTimeZone localTimeZone]];  
    NSString *day=[formatter stringFromDate:message.time];
    
    self.dateLabel.text = day;
    self.nameLabel.text = senderName;
    self.contentLabel.text = message.content;
    
    CGFloat maxContentWidth = 0.7 * (cellWidth-nameWidth- 3 * margin);
    CGSize contentSize = [ChatTableViewCell calcContenSize:message.content withWidth: maxContentWidth];
    CGFloat contentHeight = contentSize.height;
    CGFloat contentWidth = contentSize.width;

    if (message.isNew)
    {
        contentLabel.textColor = [UIColor blackColor];
        dateLabel.textColor = [UIColor blackColor];
        nameLabel.textColor = [UIColor blackColor];
    }
    else
    {
        contentLabel.textColor = [UIColor grayColor];
        dateLabel.textColor = [UIColor grayColor];
        nameLabel.textColor = [UIColor grayColor];
    }
    if (!message.from) 
    {
        self.nameLabel.textAlignment = UITextAlignmentLeft;
        self.nameLabel.frame=CGRectMake(margin, contentHeight + margin * 7, nameWidth, titleHeight);
        self.dateLabel.textAlignment = UITextAlignmentCenter;
        self.dateLabel.frame=CGRectMake(0, margin, cellWidth, titleHeight);
        self.cellBackgroundImage.image = leftBubble;
        self.cellBackgroundImage.frame = CGRectMake(nameWidth + margin * 3, titleHeight, contentWidth + 3 * bubbleMargin, contentHeight + 10 * margin);
        self.contentLabel.frame=CGRectMake(self.cellBackgroundImage.frame.origin.x + 2 * bubbleMargin, self.cellBackgroundImage.frame.origin.y + 5 * margin, contentWidth, contentHeight);
    }
    else
    {
        self.nameLabel.textAlignment = UITextAlignmentRight;
        self.nameLabel.frame=CGRectMake(cellWidth-nameWidth - margin, contentHeight + margin * 7, nameWidth, titleHeight);
        self.dateLabel.textAlignment = UITextAlignmentCenter;
        self.dateLabel.frame=CGRectMake(0, 2 * margin, cellWidth, titleHeight);
        self.cellBackgroundImage.image = rightBubble;
        self.cellBackgroundImage.frame=CGRectMake(self.nameLabel.frame.origin.x - contentWidth - 3 * bubbleMargin - 2 * margin, titleHeight, contentWidth + 3 * bubbleMargin, contentHeight + 10 * margin);
        self.contentLabel.frame=CGRectMake(self.cellBackgroundImage.frame.origin.x + bubbleMargin, self.cellBackgroundImage.frame.origin.y + 5 * margin, contentWidth, contentHeight);
    }
}

+ (CGFloat)heightOfCellWithContent:(Message *) msg withWidth:(CGFloat)cellWidth
{
    //keep some margin
    cellWidth -= 2 * margin;
    
    CGFloat nameWidth=0;
    NSString *senderName=@"";
    
    [ChatTableViewCell getShowName:&senderName andWidth:&nameWidth forMessage:msg];
    
    CGSize contentSize = [ChatTableViewCell calcContenSize:msg.content withWidth: 0.7 * (cellWidth-nameWidth- 3 * margin)];
    
    return contentSize.height + titleHeight + margin * 12;
}

+ (CGSize)calcContenSize:(NSString *)content withWidth:(CGFloat)width
{
    content = [content stringByReplacingOccurrencesOfString:@"<br>" withString:@"\n"];
    CGSize contentSize =  [content sizeWithFont:[UIFont systemFontOfSize:CONTENT_FONT_SIZE] constrainedToSize:CGSizeMake(width - margin - 3 * bubbleMargin, 2000) lineBreakMode:UILineBreakModeWordWrap];
    if (contentSize.height < bubbleHeight)
        contentSize.height = bubbleHeight;
    return contentSize;
}

+ (void)getShowName:(NSString **)name andWidth:(CGFloat *)width forMessage:(Message *)msg
{
    if (!msg.from)
    {
        *name = NSLocalizedString(@"Me", @"");
    }
    else
    {
        *name = msg.peer;
    }
    *width =  [*name sizeWithFont:[UIFont systemFontOfSize:NAME_FONT_SIZE] constrainedToSize:CGSizeMake(2000, titleHeight) lineBreakMode:UILineBreakModeWordWrap].width;
}

+ (BOOL)theDay: (NSDate *)day isSameTo: (NSDate *)comparandDay;
{
    NSCalendar* calendar = [NSCalendar currentCalendar];
    
    unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit;
    NSDateComponents* comp1 = [calendar components:unitFlags fromDate:day];
    NSDateComponents* comp2 = [calendar components:unitFlags fromDate:comparandDay];
    
    return [comp1 day]   == [comp2 day] &&
    [comp1 month] == [comp2 month] &&
    [comp1 year]  == [comp2 year];
}
 
@end
