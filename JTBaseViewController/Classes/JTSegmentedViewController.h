//
//  JTSegmentedViewController.h
//  JTBaseViewController
//
//  Created by John TSai on 2019/5/10.
//

#import <UIKit/UIKit.h>
#import <HMSegmentedControl/HMSegmentedControl.h>


@interface JTSegmentItem : NSObject

- (instancetype)initWithTitle:(nullable NSString *)title;

@end

@interface JTSegmentedControl : HMSegmentedControl

@property(nonatomic, copy) NSArray<JTSegmentItem *> *items;

@property(nullable, nonatomic, weak) JTSegmentItem *selectedItem;

@end

@interface JTSegmentedViewController : UIViewController

@property(nonatomic, strong, readonly) JTSegmentedControl *segmentBar;

@property(nonatomic, copy) NSArray<UIViewController *> *viewControllers;

@property(nonatomic, weak) UIViewController *selectedViewController;

@property(nonatomic) NSInteger selectedIndex;

@end
