//
//  KIModalView.m
//  Kitalker
//
//  Created by 杨 烽 on 14-5-13.
//  Copyright (c) 2014年 Kitalker. All rights reserved.
//

#import "KIModalView.h"

#define kAnimationForShow      @"kAnimationForShow"
#define kAnimationForDismiss   @"kAnimationForDismiss"

int const KIModalViewDismissWithCancelTag   = 0;
int const KIModalViewDismissWithConfirmTag  = 1;

@interface KIModalView ()
@property (nonatomic, assign) BOOL      modal;
@property (nonatomic, assign) int       dismissTag;
@property (nonatomic, strong) id        userInfo;
@property (nonatomic, copy) KIModalViewWillShowBlock        willShowBlcok;
@property (nonatomic, copy) KIModalViewDidShowBlock         didShowBlock;
@property (nonatomic, copy) KIModalViewWillDismissBlock     willDismissBlock;
@property (nonatomic, copy) KIModalViewDidDismissBlock      didDismissBlock;
@property (nonatomic, copy) KIModalViewCallbackHandlerBlock callbackHandlerBlock;
@property (nonatomic, strong) UIView    *maskView;
@property (nonatomic, assign) BOOL      parentViewScrollEnabled;
@property (nonatomic, assign) BOOL      isShow;

@property (nonatomic, assign) CGRect    rectWithWindow;
@end

@implementation KIModalView

#pragma mark - Lifecycle
- (void)dealloc {
    _maskView = nil;
    _contentView = nil;
    _willShowBlcok = nil;
    _didShowBlock = nil;
    _willDismissBlock = nil;
    _didDismissBlock = nil;
    _userInfo = nil;
    _confirmButton = nil;
    _cancelButton = nil;
    _callbackHandlerBlock = nil;
    _maskViewBackgroundColor = nil;
}

- (id)init {
    if (self = [super init]) {
        [self modalViewSetup];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self modalViewSetup];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self modalViewSetup];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self modalViewSetup];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self.maskView setFrame:self.bounds];
}

- (void)removeFromSuperview {
    UIView *view = [self superview];
    if ([view isKindOfClass:[UIScrollView class]]) {
        UIScrollView *scrollView = (UIScrollView *)view;
        [scrollView setScrollEnabled:self.parentViewScrollEnabled];
        [scrollView removeObserver:self forKeyPath:@"contentOffset" context:nil];
    }
    [super removeFromSuperview];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
    
    UITouch *touch = [touches anyObject];
    if (touch.view == self.maskView && self.dismissWhenTouchMaskView) {
        self.dismissTag = KIModalViewDismissWithCancelTag;
        [self dismiss];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"contentOffset"]) {
        UIScrollView *scrollView = (UIScrollView *)object;
        CGRect newFrame = [scrollView convertRect:self.rectWithWindow fromView:[UIApplication sharedApplication].keyWindow];
        [self setFrame:newFrame];
        [scrollView bringSubviewToFront:self];
    }
}

#pragma mark - Event response
- (void)confirmButtonAction:(UIButton *)sender {
    [self dismissWithTag:KIModalViewDismissWithConfirmTag userInfo:nil];
    [self.confirmButton confirmButtonAction:sender];
}

- (void)cancelButtonAction:(UIButton *)sender {
    [self dismissWithTag:KIModalViewDismissWithCancelTag userInfo:nil];
    [self.contentView cancelButtonAction:sender];
}

#pragma mark - Methods
- (void)modalViewSetup {
    [self setBackgroundColor:[UIColor clearColor]];
    
    [self setMaskViewBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.4]];
    
    if (_maskView == nil) {
        _maskView = [[UIView alloc] init];
        [self addSubview:_maskView];
    }
    [self setModal:YES];
    [self setIsShow:NO];
    [self setDismissWhenTouchMaskView:YES];
    
    [self setDismissAfterDelay:0];
    [self setDismissTag:KIModalViewDismissWithCancelTag];
    [self setTransitionIn:KIModalViewTransitionInDefault];
    [self setTransitionOut:KIModalViewTransitionOutDefault];
}

- (void)showWithModal:(BOOL)modal {
    _modal = modal;
    if (_modal) {
        [self.maskView setBackgroundColor:self.maskViewBackgroundColor];
        [self.maskView setAlpha:0.2];
    } else {
        [self.maskView setBackgroundColor:[UIColor clearColor]];
        [self.maskView setAlpha:1.0];
    }
    
    [self setUserInteractionEnabled:_modal];
    [self.modalView setUserInteractionEnabled:_modal];
}

- (void)show {
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    [self showInView:window];
}

- (void)showInNavigationController:(UINavigationController *)controller {
    if (![controller isKindOfClass:[UINavigationController class]]) {
        return ;
    }
    [self setTransitionIn:KIModalViewTransitionFlipFromTop];
    [self setTransitionOut:KIModalViewTransitionFlipToTop];
    [self setDockToSide:KIModalViewDockOnTheTop];
    
    [self showInView:controller.topViewController.view];
}

- (void)show:(BOOL)modal {
    _modal = modal;
    [self show];
}

- (void)showInView:(UIView *)view {
    if (self.isShow) {
        return ;
    }
    
    [self setIsShow:YES];
    [self showWithModal:self.modal];
    
    if (self.contentView != nil) {
        [self addSubview:self.contentView];
        [self.contentView didMoveToModalView:self];
        
        [self.contentView willShowWithModalView:self];
    }
    
    if ([view isKindOfClass:[UIScrollView class]]) {
        UIScrollView *scrollView = (UIScrollView *)view;
        [self setParentViewScrollEnabled:scrollView.scrollEnabled];
        [scrollView setScrollEnabled:NO];
        [scrollView addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:nil];
    }
    
    CGRect frame = self.contentView.bounds;
    CGRect superViewBounds = view.bounds;
    
    [self setFrame:superViewBounds];
    [view addSubview:self];
    [view bringSubviewToFront:self];
    
    //记录下 view 相对于 window 的位置
    self.rectWithWindow = [view convertRect:self.frame toView:[[UIApplication sharedApplication] keyWindow]];
    
    //动画效果
    
    BOOL fadeIn = NO;
    
    switch (self.transitionIn) {
        case KIModalViewTransitionFlipFromTop: {
            frame.origin.x = (CGRectGetWidth(superViewBounds) - CGRectGetWidth(frame)) / 2;
            frame.origin.y = 0 - CGRectGetHeight(frame);
            [self.contentView setFrame:frame];
            frame.origin.y = (CGRectGetHeight(superViewBounds)-CGRectGetHeight(frame)) / 2;
        }
            break;
        case KIModalViewTransitionFlipFromBottom: {
            frame.origin.x = (CGRectGetWidth(superViewBounds) - CGRectGetWidth(frame)) / 2;
            frame.origin.y = CGRectGetHeight(superViewBounds);
            [self.contentView setFrame:frame];
            frame.origin.y = (CGRectGetHeight(superViewBounds)-CGRectGetHeight(frame)) / 2;
        }
            break;
        case  KIModalViewTransitionFlipFromLeft: {
            frame.origin.x = -CGRectGetWidth(superViewBounds);
            frame.origin.y = (CGRectGetHeight(superViewBounds)-CGRectGetHeight(frame)) / 2;
            [self.contentView setFrame:frame];
            frame.origin.x = (CGRectGetWidth(superViewBounds) - CGRectGetWidth(frame)) / 2;
        }
            break;
        case  KIModalViewTransitionFlipFromRight: {
            frame.origin.x = CGRectGetWidth(superViewBounds);
            frame.origin.y = (CGRectGetHeight(superViewBounds)-CGRectGetHeight(frame)) / 2;
            [self.contentView setFrame:frame];
            frame.origin.x = (CGRectGetWidth(superViewBounds) - CGRectGetWidth(frame)) / 2;
        }
            break;
        case KIModalViewTransitionFadeIn: {
            frame.origin.x = (CGRectGetWidth(superViewBounds) - CGRectGetWidth(frame)) / 2;
            frame.origin.y = (CGRectGetHeight(superViewBounds)-CGRectGetHeight(frame)) / 2;
            [self.contentView setFrame:frame];
            [self.contentView setAlpha:0.0];
            fadeIn = YES;
        }
            break;
        case KIModalViewTransitionBounceIn: {
            frame.origin.x = (CGRectGetWidth(superViewBounds) - CGRectGetWidth(frame)) / 2;
            frame.origin.y = (CGRectGetHeight(superViewBounds)-CGRectGetHeight(frame)) / 2;
            CGRect newFrame = CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, frame.size.height);
            [self.contentView setFrame:newFrame];
            
            [self.contentView.layer setAffineTransform:CGAffineTransformScale(view.transform, 0.01, 0.01)];
        }
            break;
        default: {
            frame.origin.x = (CGRectGetWidth(superViewBounds) - CGRectGetWidth(frame)) / 2;
            frame.origin.y = (CGRectGetHeight(superViewBounds)-CGRectGetHeight(frame)) / 2;
            CGRect newFrame = CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, frame.size.height);
            [self.contentView setFrame:newFrame];
            
            CGAffineTransform scale = CGAffineTransformScale(self.contentView.transform, 0.1, 0.1);
            self.contentView.transform = scale;
            
            fadeIn = YES;
            
        }
            break;
    }
    
    
    switch (self.dockToSide) {
        case KIModalViewDockOnTheTop: {
            frame.origin.y = 0;
        }
            break;
        case KIModalViewDockOnTheBottom: {
            frame.origin.y = CGRectGetHeight(superViewBounds) - CGRectGetHeight(frame);
        }
            break;
        case KIModalViewDockOnTheLeft: {
            frame.origin.x = 0;
        }
            break;
        case KIModalViewDockOnTheRight: {
            frame.origin.x = CGRectGetWidth(superViewBounds) - CGRectGetWidth(frame);
        }
            break;
        default: {
        }
            break;
    }
    
    NSTimeInterval duration = 0.3f;
    
    if (self.transitionIn == KIModalViewTransitionBounceIn) {
        duration = 0.3f;
        [self jellyIn];
    }
    
    if (self.willShowBlcok != nil) {
        self.willShowBlcok(self);
    }
    
    [UIView animateWithDuration:duration
                          delay:0
                        options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionLayoutSubviews
                     animations:^{
                         self.contentView.transform = CGAffineTransformIdentity;
                         [self.contentView setFrame:frame];
                         if (fadeIn) {
                             [self.contentView setAlpha:1.0];
                         }
                         [self.maskView setAlpha:1.0];
                     } completion:^(BOOL finished) {
                         [self.contentView didShowWithModalView:self];
                         
                         if (self.didShowBlock != nil) {
                             self.didShowBlock(self);
                         }
                         
                         if (self.dismissAfterDelay != 0) {
                             [self performSelector:@selector(dismiss) withObject:nil afterDelay:self.dismissAfterDelay];
                         }
                     }];
}

- (void)dismissWithTag:(int)tag userInfo:(id)userInfo {
    [self setDismissTag:tag];
    [self setUserInfo:userInfo];
    [self dismiss];
}

- (void)dismiss {
    if (!self.isShow) {
        return ;
    }
    
    BOOL dismissable = self.contentView != nil ? [self.contentView modalViewShouldDismissWithTag:self.dismissTag] : YES;
    if (dismissable == NO) {
        return ;
    }
    
    [self setIsShow:NO];
    
    [self endEditing:YES];
    
    [self.contentView willDismissWithModalView:self];
    
    //动画效果
    CGRect frame = self.contentView.frame;
    
    BOOL fadeOut = NO;
    
    [self.contentView.layer removeAnimationForKey:kAnimationForShow];
    
    CGAffineTransform scale = CGAffineTransformIdentity;
    switch (self.transitionOut) {
        case KIModalViewTransitionFlipToTop: {
            frame.origin.y = 0 - CGRectGetHeight(frame);
        }
            break;
        case KIModalViewTransitionFlipToBottom: {
            frame.origin.y = CGRectGetHeight(self.frame);
        }
            break;
        case  KIModalViewTransitionFlipToLeft: {
            frame.origin.x = -CGRectGetWidth(self.frame);
        }
            break;
        case  KIModalViewTransitionFlipToRight: {
            frame.origin.x = CGRectGetWidth(self.frame);
        }
            break;
        case KIModalViewTransitionFadeOut: {
            fadeOut = YES;
        }
            break;
        case KIModalViewTransitionBounceOut: {
            fadeOut = YES;
            //do nothing
        }
            break;
        default: {
            self.contentView.transform = CGAffineTransformIdentity;
            scale = CGAffineTransformScale(self.contentView.transform, 0.1, 0.1);
            fadeOut = YES;
        }
            break;
    }
    
    NSTimeInterval duration = 0.3f;
    
    if (self.transitionOut == KIModalViewTransitionBounceOut) {
        duration = 1.0f;
        [self jellyOut];
    }
    
    if (self.willDismissBlock != nil) {
        self.willDismissBlock(self, self.dismissTag, self.userInfo);
    }
    
    [UIView animateWithDuration:duration
                          delay:0
                        options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionLayoutSubviews
                     animations:^{
                         [self.contentView setFrame:frame];
                         self.contentView.transform = scale;
                         if (fadeOut) {
                             [self.contentView setAlpha:0.0];
                         }
                         [self.maskView setAlpha:0.0];
                     } completion:^(BOOL finished) {
                         [self.contentView.layer removeAnimationForKey:kAnimationForDismiss];
                         [self removeFromSuperview];
                         [self.contentView didDismissWithModalView:self];
                         
                         if (self.didDismissBlock != nil) {
                             self.didDismissBlock(self, self.dismissTag, self.userInfo);
                         }
                         
                         [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(dismiss) object:nil];
                     }];
    
    
}

////////////////////////////////////////////////////////////////////////
- (void)jellyIn {
    CAKeyframeAnimation *jellyIn = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
    [jellyIn setDuration:1.0f];
    
    NSArray *values = [[NSArray alloc] initWithObjects:
                       [NSNumber numberWithFloat:0.01f],
                       [NSNumber numberWithFloat:1.2f],
                       [NSNumber numberWithFloat:0.8f],
                       [NSNumber numberWithFloat:1.1f],
                       [NSNumber numberWithFloat:0.85f],
                       [NSNumber numberWithFloat:1.0f],
                       [NSNumber numberWithFloat:0.9f],
                       [NSNumber numberWithFloat:1.0f],
                       [NSNumber numberWithFloat:0.95f],
                       [NSNumber numberWithFloat:1.0f],
                       nil];
    [jellyIn setValues:values];
    
    NSArray *times = [[NSArray alloc] initWithObjects:
                      [NSNumber numberWithFloat:0.1f],
                      [NSNumber numberWithFloat:0.3f],
                      [NSNumber numberWithFloat:0.5f],
                      [NSNumber numberWithFloat:0.6f],
                      [NSNumber numberWithFloat:0.7f],
                      [NSNumber numberWithFloat:0.8f],
                      [NSNumber numberWithFloat:0.9f],
                      [NSNumber numberWithFloat:0.92f],
                      [NSNumber numberWithFloat:0.95f],
                      [NSNumber numberWithFloat:0.97f],
                      nil];
    [jellyIn setKeyTimes:times];
    [self.contentView.layer addAnimation:jellyIn forKey:kAnimationForShow];
    [self.contentView.layer setValue:@(1.0) forKeyPath:@"transform.scale"];
}

- (void)jellyOut {
    CAKeyframeAnimation *jellyOut = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
    [jellyOut setDuration:1.0f];
    
    NSArray *values = [[NSArray alloc] initWithObjects:
                       [NSNumber numberWithFloat:1.0f],
                       [NSNumber numberWithFloat:1.3f],
                       [NSNumber numberWithFloat:0.0f],
                       nil];
    [jellyOut setValues:values];
    
    NSArray *times = [[NSArray alloc] initWithObjects:
                      [NSNumber numberWithFloat:0.1f],
                      [NSNumber numberWithFloat:0.3f],
                      [NSNumber numberWithFloat:0.5f],
                      nil];
    [jellyOut setKeyTimes:times];
    
    [self.contentView.layer addAnimation:jellyOut forKey:kAnimationForDismiss];
}
////////////////////////////////////////////////////////////////////////

- (void)makeCall:(int)tag userInfo:(id)userInfo {
    if (_callbackHandlerBlock != nil) {
        _callbackHandlerBlock(self, tag, userInfo);
    }
}

#pragma mark - Getters and setters
- (void)setConfirmButton:(UIButton *)confirmButton {
    _confirmButton = confirmButton;
    [_confirmButton addTarget:self
                       action:@selector(confirmButtonAction:)
             forControlEvents:UIControlEventTouchUpInside];
}

- (void)setCancelButton:(UIButton *)cancelButton {
    _cancelButton = cancelButton;
    [_cancelButton addTarget:self
                      action:@selector(cancelButtonAction:)
            forControlEvents:UIControlEventTouchUpInside];
}

- (void)setWillShowBlock:(KIModalViewWillShowBlock)block {
    _willShowBlcok = [block copy];
}

- (void)setDidShowBlock:(KIModalViewDidShowBlock)block {
    _didShowBlock = [block copy];
}

- (void)setWillDismissBlock:(KIModalViewWillDismissBlock)block {
    _willDismissBlock = [block copy];
}

- (void)setDidDismissBlock:(KIModalViewDidDismissBlock)block {
    _didDismissBlock = [block copy];
}

- (void)setCallbackHandlerBlock:(KIModalViewCallbackHandlerBlock)block {
    _callbackHandlerBlock = [block copy];
}

- (BOOL)isModal {
    return self.modal;
}

@end

#pragma mark - Category UIView (KIModalView)
@implementation UIView (KIModalView)

- (KIModalView *)modalView {
    if ([self isKindOfClass:[KIModalView class]]) {
        return (KIModalView *)self;
    }
    
    UIView *superView = [self.superview modalView];
    if ([superView isKindOfClass:[KIModalView class]]) {
        return (KIModalView *)superView;
    }
    return nil;
}

- (void)didMoveToModalView:(KIModalView *)modalView {
}

- (void)willShowWithModalView:(KIModalView *)modalView {
}

- (void)didShowWithModalView:(KIModalView *)modalView {
}

- (void)willDismissWithModalView:(KIModalView *)modalView {
}

- (void)didDismissWithModalView:(KIModalView *)modalView {
}

- (BOOL)modalViewShouldDismissWithTag:(int)tag {
    return YES;
}

- (void)confirmButtonAction:(UIButton *)sender {
}
- (void)cancelButtonAction:(UIButton *)sender {
}
@end
