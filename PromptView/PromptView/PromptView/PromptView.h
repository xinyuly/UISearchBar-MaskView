//
//  PromptView.h
//  TestPromptView
//
//  Created by smok on 16/11/15.
//  Copyright © 2016年 xinyuly. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PromptView : NSObject

@property (nonatomic, strong) UIView *contentView;

- (void)setImage:(UIImage *)image;

- (void)setMessage:(NSString *)message;

- (void)showInView:(UIView *)view;

- (void)dismiss;
//default value
- (void)setMessageColor:(UIColor *)color;

- (void)setMessageFont:(UIFont *)font;

- (void)setBackgroundColor:(UIColor *)color;
@end
