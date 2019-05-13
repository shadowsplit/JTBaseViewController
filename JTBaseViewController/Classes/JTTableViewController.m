//
//  JTTableViewController.m
//  JTBaseViewController
//
//  Created by John TSai on 2019/5/13.
//

#import "JTTableViewController.h"

@interface JTTableViewController ()

@end

@implementation JTTableViewController

#pragma mark - LifeCycle

- (void)viewDidLoad {
    [super viewDidLoad];
}

#pragma mark - Delegate & DataSource

#pragma mark - EventResponse

#pragma mark - PublicMethod

#pragma mark - PrivateMethod

#pragma mark - Setters
- (void)setNeedHeaderRefresh:(BOOL)needHeaderRefresh {
    _needHeaderRefresh = needHeaderRefresh;
    if (needHeaderRefresh) {
        __weak typeof(self)weakSelf = self;
        self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
            __strong __typeof(weakSelf)strongSelf = weakSelf;
            if (strongSelf.headerRefreshingBlock) {
                [strongSelf.tableView.mj_footer resetNoMoreData];
                strongSelf.headerRefreshingBlock();
                [strongSelf.tableView.mj_header endRefreshing];
            }
        }];
    } else {
        self.tableView.mj_header = nil;
    }
}

- (void)setNeedFooterRefresh:(BOOL)needFooterRefresh {
    _needFooterRefresh = needFooterRefresh;
    if (needFooterRefresh) {
        __weak typeof(self)weakSelf = self;
        self.tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
            __strong __typeof(weakSelf)strongSelf = weakSelf;
            if (strongSelf.footerRefreshingBlock) {
                strongSelf.footerRefreshingBlock();
                [strongSelf.tableView.mj_footer endRefreshing];
            }
        }];
    } else {
        self.tableView.mj_footer = nil;
    }
}

- (void)setSetNoMoreData:(BOOL)setNoMoreData {
    if (setNoMoreData) {
        [self.tableView.mj_footer endRefreshingWithNoMoreData];
    } else {
        [self.tableView.mj_footer resetNoMoreData];
    }
}

#pragma mark - Getters

@end
