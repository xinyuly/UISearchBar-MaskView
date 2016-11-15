//
//  ViewController.m
//  PromptView
//
//  Created by smok on 16/11/15.
//  Copyright © 2016年 xinyuly. All rights reserved.
//

#import "ViewController.h"
#import "PromptView.h"
#import "UISearchBar+MaskView.h"

@interface ViewController ()<UISearchBarDelegate>

@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, strong) UIView *bgView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.searchBar];
    self.searchBar.delegate = self;
    self.searchBar.frame = CGRectMake(0, 64, self.view.bounds.size.width, 44);
    self.searchBar.placeholder = @"Search";
    [self.searchBar becomeFirstResponder];
    
    self.bgView = [[UIView alloc] init];
    [self.view addSubview:self.bgView];
    self.bgView.frame = CGRectMake(0, 108, self.view.bounds.size.width, self.view.bounds.size.height);
}
#pragma mark - setter && getter
- (UISearchBar *)searchBar {
    if (_searchBar == nil) {
        _searchBar = [[UISearchBar alloc] init];
    }
    return _searchBar;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
    
    PromptView *promptView = [[PromptView alloc] init];
    [promptView setMessage:@"购物车暂无商品,购物车暂无商品"];
    [promptView setImage:[UIImage imageNamed:@"p_empty_cart"]];
    [promptView showInView:self.bgView];
}
@end
