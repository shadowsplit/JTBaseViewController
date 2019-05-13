//
//  JTImagePickerController.h
//  JTImagePicker
//
//  Created by John TSai on 2018/2/12.
//  Copyright © 2018年 JohnTsai. All rights reserved.
//

#import <UIKit/UIKit.h>

@class JTImagePickerController;

typedef void(^JTImagePickerDidFinishPickingMedia)(__weak JTImagePickerController *picker, NSDictionary<NSString *,id> *info);

typedef void(^JTImagePickerDidCancel)(__weak JTImagePickerController *picker);

@interface JTImagePickerController : UIImagePickerController

@property (nonatomic, copy) JTImagePickerDidFinishPickingMedia didFinishPickingMedia;
@property (nonatomic, copy) JTImagePickerDidCancel didCancel;

@end
