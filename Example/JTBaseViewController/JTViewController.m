//
//  JTViewController.m
//  JTBaseViewController
//
//  Created by JohnTsaii on 05/10/2019.
//  Copyright (c) 2019 JohnTsaii. All rights reserved.
//

#import "JTViewController.h"
#import "JTSegmentedViewController.h"
#import "JTTableViewController.h"
#import "JTQRCodeViewController.h"

@interface JTViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;

@end

@implementation JTViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.view addSubview:self.tableView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
    return 10;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    
    [self configureCell:cell forRowAtIndexPath:indexPath];
    
    return cell;
}

- (void)configureCell:(UITableViewCell *)cell
    forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        cell.textLabel.text = @"segmentVC";
    } else if (indexPath.row == 1) {
        cell.textLabel.text = @"tableViewVC";
    } else if (indexPath.row == 2) {
        cell.textLabel.text = @"qrCodeVC";
    }
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        [self pushToSegVC];
    } else if (indexPath.row == 1) {
        [self pushToTVVC];
    } else if (indexPath.row == 2) {
        [self pushToQRVC];
    }
}

- (void)pushToSegVC {
    JTSegmentedViewController *vcxxx = [[JTSegmentedViewController alloc] init];
    
    JTViewController *vc1 = [[JTViewController alloc] init];
    vc1.view.backgroundColor = [UIColor yellowColor];
    JTSegmentItem *item1 = [[JTSegmentItem alloc] initWithTitle:@"标题一"];
    
    JTViewController *vc2 = [[JTViewController alloc] init];
    vc2.view.backgroundColor = [UIColor blueColor];
    JTSegmentItem *item2 = [[JTSegmentItem alloc] initWithTitle:@"标题二"];
    
    JTViewController *vc3 = [[JTViewController alloc] init];
    vc3.view.backgroundColor = [UIColor redColor];
    JTSegmentItem *item3 = [[JTSegmentItem alloc] initWithTitle:@"标题三"];
    
    [vcxxx.segmentBar setItems:@[item1, item2, item3]];
    vcxxx.viewControllers = @[vc1, vc2, vc3];
    
    [self.navigationController pushViewController:vcxxx animated:YES];
}

- (void)pushToTVVC {
    JTTableViewController *vc = [[JTTableViewController alloc] initWithStyle:UITableViewStyleGrouped];
    vc.needHeaderRefresh = YES;
//    vc.needFooterRefresh = YES;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)pushToQRVC {
    JTQRCodeViewController *vc = [[JTQRCodeViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

@end
