//
//  JTQRCodeViewController.h
//  JTBaseViewController
//
//  Created by John TSai on 2019/5/13.
//

#import <UIKit/UIKit.h>

@class JTQRCodeViewController;

@protocol JTQRCodeViewControllerDelegate <NSObject>

/**
 扫描结果
 @return YES ,停止扫描
 */
-(BOOL)viewController:(JTQRCodeViewController *)vc scanResult:(NSString *)result;

@end

@interface JTQRCodeViewController : UIViewController

@property(nonatomic,weak) id<JTQRCodeViewControllerDelegate> delegate;

@end

