//
//  MessageModel.h
//  iPhoneXMPP
//
//  Created by System Administrator on 5/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "MojoModel.h"

@interface ChatMessage : MojoModel

@property NSUInteger direction;   // 0: come from other, 1: send by self
@property (strong) NSString *sender;
@property (strong) NSString *receiver;
@property (strong) NSString *content;
@property (nonatomic) NSTimeInterval time;

@end
