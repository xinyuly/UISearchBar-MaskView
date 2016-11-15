//
//  KIModalView.h
//  Kitalker
//
//  Created by 杨 烽 on 14-5-13.
//  Copyright (c) 2014年 Kitalker. All rights reserved.
//

#import <UIKit/UIKit.h>

extern int const KIModalViewDismissWithCancelTag;
extern int const KIModalViewDismissWithConfirmTag;

@class KIModalView;
typedef void(^KIModalViewWillDismissBlock)      (KIModalView *view, int tag, id userInfo);
typedef void(^KIModalViewDidDismissBlock)       (KIModalView *view, int tag, id userInfo);
typedef void(^KIModalViewWillShowBlock)         (KIModalView *view);
typedef void(^KIModalViewDidShowBlock)          (KIModalView *view);
typedef void(^KIModalViewCallbackHandlerBlock)  (KIModalView *view, int tag, id userInfo);

typedef NS_ENUM(NSInteger, KIModalViewTransitionIn) {
    KIModalViewTransitionInDefault,
    KIModalViewTransitionFadeIn,
    
    KIModalViewTransitionFlipFromTop,
    KIModalViewTransitionFlipFromBottom,
    KIModalViewTransitionFlipFromLeft,
    KIModalViewTransitionFlipFromRight,
    
    KIModalViewTransitionBounceIn,
};

typedef NS_ENUM(NSInteger, KIModalViewTransitionOut) {
    KIModalViewTransitionOutDefault,
    KIModalViewTransitionFadeOut,
    
    KIModalViewTransitionFlipToTop,
    KIModalViewTransitionFlipToBottom,
    KIModalViewTransitionFlipToLeft,
    KIModalViewTransitionFlipToRight,
    
    KIModalViewTransitionBounceOut,
};

typedef NS_ENUM(NSInteger, KIModalViewDockToSide) {
    KIModalViewDockDefault,
    KIModalViewDockOnTheTop,
    KIModalViewDockOnTheBottom,
    KIModalViewDockOnTheLeft,
    KIModalViewDockOnTheRight
};

@interface KIModalView : UIView {
    UIView *_contentView;
}

@property (nonatomic, strong) UIView *contentView;

@property (nonatomic, strong) UIColor *maskViewBackgroundColor;

@property (nonatomic, assign) BOOL dismissWhenTouchMaskView;

@property (nonatomic, assign) KIModalViewTransitionIn   transitionIn;
@property (nonatomic, assign) KIModalViewTransitionOut  transitionOut;
@property (nonatomic, assign) KIModalViewDockToSide     dockToSide;

@property (nonatomic, assign) NSTimeInterval    dismissAfterDelay;

//default nil
@property (nonatomic, strong) UIButton  *confirmButton;
@property (nonatomic, strong) UIButton  *cancelButton;

- (void)setWillShowBlock:(KIModalViewWillShowBlock)block;

- (void)setDidShowBlock:(KIModalViewDidShowBlock)block;

- (void)setWillDismissBlock:(KIModalViewWillDismissBlock)block;

- (void)setDidDismissBlock:(KIModalViewDidDismissBlock)block;

- (void)setCallbackHandlerBlock:(KIModalViewCallbackHandlerBlock)block;

- (BOOL)isModal;

- (void)show;

- (void)showInNavigationController:(UINavigationController *)controller;

- (void)show:(BOOL)modal;

- (void)showInView:(UIView *)view;

- (void)dismiss;

- (BOOL)isShow;

//contentview 调用
- (void)dismissWithTag:(int)tag userInfo:(id)userInfo;

- (void)makeCall:(int)tag userInfo:(id)userInfo;

@end

#pragma mark - Category UIView (KIModalView)
@interface UIView (KIModalView)
@property (nonatomic, assign, readonly) KIModalView *modalView;

//content view 可以选择性的实现这里面的方法
- (void)didMoveToModalView:(KIModalView *)modalView;

- (void)willShowWithModalView:(KIModalView *)modalView;
- (void)didShowWithModalView:(KIModalView *)modalView;

- (void)willDismissWithModalView:(KIModalView *)modalView;
- (void)didDismissWithModalView:(KIModalView *)modalView;

- (BOOL)modalViewShouldDismissWithTag:(int)tag;

//如果设置了confirmButton或者cancelButton,可以选择性的重写这两个方法。
- (void)confirmButtonAction:(UIButton *)sender;
- (void)cancelButtonAction:(UIButton *)sender;
@end
