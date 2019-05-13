//
//  JTImagePickerController.m
//  JTImagePicker
//
//  Created by John TSai on 2018/2/12.
//  Copyright © 2018年 JohnTsai. All rights reserved.
//

#import "JTImagePickerController.h"

@interface JTImagePickerController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@end

@implementation JTImagePickerController

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.delegate = self;
    }
    return self;
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    if (self.didFinishPickingMedia) {
        __weak JTImagePickerController *picker = self;
        self.didFinishPickingMedia(picker, info);
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    if (self.didCancel) {
        __weak JTImagePickerController *picker = self;
        self.didCancel(picker);
    }
}



@end
