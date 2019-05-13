//
//  JTTableViewController.h
//  JTBaseViewController
//
//  Created by John TSai on 2019/5/13.
//

#import <UIKit/UIKit.h>
#import <MJRefresh/MJRefresh.h>

@interface JTTableViewController : UITableViewController

@property (nonatomic, assign) BOOL needHeaderRefresh; // 是否需要添加头部刷新, 头部刷新时会自动q消除footer的nomoredata状态
@property (nonatomic, assign) BOOL needFooterRefresh; // 是否需要添加底部刷新

@property (nonatomic, copy) MJRefreshComponentRefreshingBlock headerRefreshingBlock;
@property (nonatomic, copy) MJRefreshComponentRefreshingBlock footerRefreshingBlock;
@property (nonatomic, assign) BOOL setNoMoreData; // 设置footer是否有更多数据

@end
