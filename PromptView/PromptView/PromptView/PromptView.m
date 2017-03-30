//
//  PromptView.m
//  TestPromptView
//
//  Created by smok on 16/11/15.
//  Copyright © 2016年 xinyuly. All rights reserved.
//

#import "PromptView.h"
#import "KIModalView.h"

@interface PromptView ()

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UITextView  *textView;
@property (nonatomic, strong) KIModalView *modalView;

@end

@implementation PromptView

- (instancetype)init {
    if ([super init]) {
        [self setup];
    }
    return self;
}

- (void)setup {
    self.contentView = [[UIView alloc] init];
    self.contentView.backgroundColor = [UIColor colorWithWhite:240/255.0 alpha:1];
    
    UIImageView *imageView = [[UIImageView alloc] init];
    [imageView setContentMode:UIViewContentModeScaleAspectFill];
    [imageView setClipsToBounds:YES];
    self.imageView = imageView;
    [self.contentView addSubview:self.imageView];
    
    self.textView = [[UITextView alloc] init];
    self.textView.userInteractionEnabled = NO;
    [self.textView setTextColor:[UIColor colorWithWhite:106/255.0 alpha:1]];
    [self.textView setTextAlignment:NSTextAlignmentCenter];
    self.textView.font = [UIFont systemFontOfSize:20];
    self.textView.backgroundColor = [UIColor clearColor];
    [self.contentView addSubview:self.textView];
}

- (void)showInView:(UIView *)view {
    CGRect superFrame = view.bounds;
    CGFloat imgWidth = 80;
    CGFloat width = superFrame.size.width;
    CGFloat imgY = 150;
    self.contentView.frame = superFrame;
    self.imageView.frame = CGRectMake((width-imgWidth)*0.5, imgY, imgWidth, imgWidth);
    self.textView.frame = CGRectMake(10, imgY+imgWidth+10, width-20, superFrame.size.height - CGRectGetMaxY(self.imageView.bounds));
    [self.modalView showInView:view];
}

- (void)show {
    [self.modalView show];
}

- (void)dismiss {
    [self.modalView dismiss];
}

#pragma mark - setter && getter
- (void)setImage:(UIImage *)image {
    [self.imageView setImage:image];
}

- (void)setMessage:(NSString *)message {
    [self.textView setText:message];
}

- (void)setMessageColor:(UIColor *)color {
    if (color) {
        [self.textView setTextColor:color];
    }
}

- (void)setMessageFont:(UIFont *)font {
    if (font) {
        self.textView.font = font;
    }
}

- (void)setBackgroundColor:(UIColor *)color {
    if (color) {
        [self.contentView setBackgroundColor:color];
    }
}

- (KIModalView *)modalView {
    if (_modalView == nil) {
        _modalView = [[KIModalView alloc] init];
        [_modalView setTransitionIn:KIModalViewTransitionFadeIn];
        [_modalView setTransitionOut:KIModalViewTransitionFadeOut];
        [_modalView setContentView:self.contentView];
    }
    return _modalView;
}
@end
