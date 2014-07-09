//
//  GMAlertView.m
//  State_Hunt
//
//  Created by Gary Morris on 7/8/14.
//  Copyright (c) 2014 Gary Morris. All rights reserved.
//

#import "GMAlertView.h"

@implementation GMAlertAction

- (instancetype)initWithTitle:(NSString *)title
{
    self = [super init];
    if (self) {
        _title = title;
    }
    return self;
}

@end


@interface GMAlertView() <UIAlertViewDelegate>
@property (nonatomic, strong)   UIAlertView*    alertView;
@property (nonatomic, copy)     GMAlertAction*  cancelAction;
@property (nonatomic, copy)     GMAlertAction*  otherAction;
@property (nonatomic, strong)   GMAlertView*    currentAlert;
@end


@implementation GMAlertView

- (instancetype)initWithTitle:(NSString *)title
                      message:(NSString *)message
                 cancelAction:(GMAlertAction*)cancelAction
                  otherAction:(GMAlertAction*)otherAction
{
    self = [super init];
    if (self) {
        // Initialization code
        _alertView = [[UIAlertView alloc] initWithTitle:title
                                                message:message
                                               delegate:self
                                      cancelButtonTitle:cancelAction.title
                                      otherButtonTitles:nil];
        _cancelAction = cancelAction;
        
        if (otherAction.title.length) {
            _otherAction = otherAction;
            [_alertView addButtonWithTitle:otherAction.title];
        }
    }
    return self;
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        if (self.cancelAction.buttonPressed) {
            self.cancelAction.buttonPressed();
        }
    } else if (buttonIndex == 1) {
        if (self.otherAction.buttonPressed) {
            self.otherAction.buttonPressed();
        }
    }
    [self alertViewCancel:alertView];
}

- (void)alertViewCancel:(UIAlertView *)alertView
{
    self.alertView      = nil;
    self.cancelAction   = nil;
    self.otherAction    = nil;
    self.currentAlert   = nil;
}

- (void)show
{
    [self.alertView show];
    
    // hold onto self, so this alert object doesn't get released until the alert is dismissed
    self.currentAlert = self;
}

@end
