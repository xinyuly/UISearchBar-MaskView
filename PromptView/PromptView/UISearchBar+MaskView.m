//
//  UISearchBar+MaskView.m
//  PromptView
//
//  Created by lixinyu on 16/11/15.
//  Copyright © 2016年 xinyuly. All rights reserved.
//

#import "UISearchBar+MaskView.h"
#import <objc/runtime.h>

static char *XYMaskViewKey = "XYMaskViewKey";

@interface MaskView : UIView

@end

@implementation MaskView

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    [self.superview endEditing:YES];
}

@end

@implementation UISearchBar (MaskView)
#pragma mark - UITextFieldDelegate
- (void)textFieldDidBeginEditing:(UITextField *)textField {
    [self showMaskView];
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    [self removeMaskView];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    return YES;
}
#pragma mark - Methods
- (void)showMaskView {
    CGRect mainViewBounds = [[UIApplication sharedApplication] keyWindow].bounds;
    CGRect rect = [self.superview convertRect:self.frame toView:[[UIApplication sharedApplication] keyWindow]];
    CGRect contextViewFrame = CGRectMake(CGRectGetMinX(rect),
                                         CGRectGetMaxY(rect),
                                         CGRectGetWidth(rect),
                                         CGRectGetHeight(mainViewBounds) - CGRectGetMaxY(rect));
    [[self _maskView] setFrame:contextViewFrame];
    [[self _maskView] setAlpha:0.0f];
    [self.window addSubview:[self _maskView]];
    
    [UIView animateKeyframesWithDuration:0.2
                                   delay:0
                                 options:UIViewKeyframeAnimationOptionAllowUserInteraction | UIViewKeyframeAnimationOptionBeginFromCurrentState
                              animations:^{
                                  [[self _maskView] setAlpha:0.6];
                              } completion:nil];
    
}

- (void)removeMaskView {
    [UIView animateKeyframesWithDuration:0.2
                                   delay:0
                                 options:UIViewKeyframeAnimationOptionAllowUserInteraction | UIViewKeyframeAnimationOptionBeginFromCurrentState
                              animations:^{
                                  [[self _maskView] setAlpha:0.0f];
                              } completion:^(BOOL finished) {
                                  [[self _maskView] removeFromSuperview];
                              }];
}
#pragma mark - setter && getter
- (MaskView *)_maskView {
    MaskView *maskView = (MaskView *)objc_getAssociatedObject(self, XYMaskViewKey);
    if (maskView == nil) {
        maskView = [[MaskView alloc] init];
        [maskView setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.6]];
        maskView.frame = CGRectMake(0, 0, 100, 100);        objc_setAssociatedObject(self, XYMaskViewKey, maskView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return maskView;
}

@end
