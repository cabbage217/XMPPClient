//
//  TableView.m
//  XMPPClient
//

#import "TableView.h"

@implementation TableView
@synthesize parent = _parent;

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if ([_parent respondsToSelector:@selector(tableViewTouched)])
    {
        [_parent tableViewTouched];
        
    }
    [super touchesBegan:touches withEvent:event]; 
}

- (void)enterEditing: (UIGestureRecognizer *)gestureRecognizer
{
    if (UIGestureRecognizerStateBegan == gestureRecognizer.state)
    {
        if ([_parent respondsToSelector: @selector(beginEditing)])
        {
            [_parent beginEditing];
        }
    }
}

@end
