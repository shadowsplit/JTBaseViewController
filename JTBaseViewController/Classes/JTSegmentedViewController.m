//
//  JTSegmentedViewController.m
//  JTBaseViewController
//
//  Created by John TSai on 2019/5/10.
//

#import "JTSegmentedViewController.h"

static CGFloat JTSegmentedBarHeight = 44.0;

@interface JTSegmentItem ()

@property (nonatomic, copy) NSString *title;

@end

@implementation JTSegmentItem
- (instancetype)initWithTitle:(nullable NSString *)title {
    self.title = title;
    return [self init];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self setUp];
    }
    return self;
}

- (void)setUp {
    
}
@end

@implementation JTSegmentedControl

- (void)setItems:(NSArray<JTSegmentItem *> *)items {
    _items = items;
    NSMutableArray *titles = [[NSMutableArray alloc] initWithCapacity:items.count];
    for (JTSegmentItem *i in items) {
        [titles addObject:i.title];
    }
    self.sectionTitles = titles;
}

@end

@interface JTSegmentedViewController ()

@property (nonatomic, strong) JTSegmentedControl *segmentBar;

@end

@implementation JTSegmentedViewController

- (instancetype)init {
    self = [super init];
    if (self) {
        [self setUp];
    }
    return self;
}

#pragma mark - LifeCycle

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Delegate & DataSource

#pragma mark - EventResponse

#pragma mark - PublicMethod

#pragma mark - PrivateMethod
- (void)setUp {
    [self.view addSubview:self.segmentBar];
    self.view.backgroundColor = [UIColor whiteColor];
    self.selectedIndex = -1;
}

- (void)moveViewControllerToIndex:(NSUInteger)index {
    if (self.selectedIndex == index) {
        return;
    }
    
    UIViewController *vc = [self.viewControllers objectAtIndex:index];
    self.selectedIndex = index;
    self.segmentBar.selectedItem = [self.segmentBar.items objectAtIndex:index];
    if (vc) {
        if (self.selectedViewController) {
            [self.selectedViewController willMoveToParentViewController:nil];
            [self.selectedViewController.view removeFromSuperview];
            [self.selectedViewController removeFromParentViewController];
        }

        [self addChildViewController:vc];
        self.selectedViewController = vc;
        vc.view.frame = CGRectMake(0, JTSegmentedBarHeight, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame));
        [self.view addSubview:vc.view];
        [vc didMoveToParentViewController:self];
    }
}

#pragma mark - Setter
- (void)setViewControllers:(NSArray<UIViewController *> *)viewControllers {
    _viewControllers = viewControllers;
    [self moveViewControllerToIndex:0];
}

#pragma mark - Getters
- (JTSegmentedControl *)segmentBar {
    if (!_segmentBar) {
        _segmentBar = [[JTSegmentedControl alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth([UIScreen mainScreen].bounds), JTSegmentedBarHeight)];
        _segmentBar.selectionIndicatorLocation = HMSegmentedControlSelectionIndicatorLocationDown;
        __weak typeof(self)weakSelf = self;
        [_segmentBar setIndexChangeBlock:^(NSInteger index) {
            __strong __typeof(weakSelf)strongSelf = weakSelf;
            [strongSelf moveViewControllerToIndex:index];
        }];
        _segmentBar.backgroundColor = [UIColor whiteColor];
    }
    return _segmentBar;
}

@end
