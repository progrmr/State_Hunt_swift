//
//  GMAlertView.h
//  State_Hunt
//
//  Created by Gary Morris on 7/8/14.
//  Copyright (c) 2014 Gary Morris. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GMAlertAction : NSObject

@property (nonatomic, copy)     NSString* title;
@property (nonatomic, copy)     void (^buttonPressed)(void);

- (instancetype)initWithTitle:(NSString *)title;

@end


@interface GMAlertView : NSObject

- (instancetype)initWithTitle:(NSString *)title
                      message:(NSString *)message
                 cancelAction:(GMAlertAction*)cancelAction
                  otherAction:(GMAlertAction*)otherAction;

- (void)show;

@end
