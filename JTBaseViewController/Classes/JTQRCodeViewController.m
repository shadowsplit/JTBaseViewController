//
//  JTQRCodeViewController.m
//  JTBaseViewController
//
//  Created by John TSai on 2019/5/13.
//

#import "JTQRCodeViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import <CoreImage/CoreImage.h>
#import "JTImagePickerController.h"


#define kMaskColor [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5] //遮罩颜色
#define kAppName [[NSBundle mainBundle].infoDictionary objectForKey:@"CFBundleDisplayName"]
#define kDefaultLineWidth 1/[UIScreen mainScreen].scale
#define kThemeColor [UIColor greenColor]

@interface JTQRCodeViewController ()
<AVCaptureMetadataOutputObjectsDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>

//---view
@property (nonatomic, strong) UIActivityIndicatorView *indicatorView; //菊花
@property (nonatomic, strong) UILabel *flashLabel;
@property (nonatomic, strong) UIView *lineAnimateView;
//---avfoundation
@property (nonatomic, strong) AVCaptureDevice *device;
@property (nonatomic, strong) AVCaptureDeviceInput *input;
@property (nonatomic, strong) AVCaptureMetadataOutput *output;
@property (nonatomic, strong) AVCaptureSession *session;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *preview;
//---
@property (nonatomic, strong) UIView *backView; //透明背景视图
@property (nonatomic, strong) JTImagePickerController *imagePicker;
@property (nonatomic, strong) UIButton *pickerImageButton;

@end

@implementation JTQRCodeViewController

#pragma mark - life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"二维码/条形码";
    self.view.backgroundColor = [UIColor blackColor];
    [self configUI];
#if TARGET_IPHONE_SIMULATOR
    //模拟器
    UILabel *warnLabel = [[UILabel alloc] initWithFrame:self.view.bounds];
    warnLabel.text = @"模拟器无法打开相机";
    warnLabel.textColor = [UIColor whiteColor];
    warnLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:warnLabel];
#elif TARGET_OS_IPHONE
    //打开相机
    [self openCamera];
#endif
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if (!self.presentedViewController) {
        [self.navigationController setNavigationBarHidden:NO animated:animated];
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - AVCaptureMetadataOutputObjectsDelegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    NSString *stringValue;
    if ([metadataObjects count ] > 0)
    {
        //        [self playSystemAudio];//扫描成功播放系统声音
        AVMetadataMachineReadableCodeObject *metadataObject = [metadataObjects objectAtIndex:0];
        stringValue = metadataObject.stringValue;
        
        if ([self dealQRcodeString:stringValue]) {
            // 停止扫描
            [_session stopRunning];
        }
    }
}

#pragma mark - PublicMethod
// 生成二维码
/*
 if the qr code is blurry, try this. CIImage *image = [self createQRForString:qrString]; CGAffineTransform transform = CGAffineTransformMakeScale(5.0f, 5.0f); // Scale by 5 times along both dimensions CIImage *output = [image imageByApplyingTransform: transform];
 */
- (UIImage *)createQRForString:(NSString *)qrString {
    // Need to convert the string to a UTF-8 encoded NSData object
    NSData *stringData = [qrString dataUsingEncoding:NSUTF8StringEncoding];
    
    // Create the filter
    CIFilter *qrFilter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    // Set the message content and error-correction level
    [qrFilter setValue:stringData forKey:@"inputMessage"];
    [qrFilter setValue:@"H" forKey:@"inputCorrectionLevel"];
    
    // Send the image back
    return [UIImage imageWithCGImage:(__bridge CGImageRef _Nonnull)(qrFilter.outputImage)];
}

#pragma mark - event response
//闪光灯开关
- (void)changeFlashMode:(id)sender
{
    UIButton *flashButton = sender;
    flashButton.selected = !flashButton.selected;
    BOOL flashOn = flashButton.selected;
    self.flashLabel.text = flashOn ? @"开":@"关";
    [self switchFlashMode:flashOn];
}

- (void)backTouch:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - private method
- (void)configUI
{
    self.backView = [[UIView alloc] initWithFrame:self.view.bounds];
    self.backView.backgroundColor = kMaskColor;
    self.backView.userInteractionEnabled = YES;
    [self.view addSubview:self.backView];
    
    //添加bar
    CGFloat topBarH = 44.f;
    UIView *topBarContainer = [[UIView alloc] initWithFrame:(CGRect){0,20,self.view.bounds.size.width,topBarH}];
    topBarContainer.backgroundColor = [UIColor clearColor];
    topBarContainer.userInteractionEnabled = YES;
    [self.view addSubview:topBarContainer];
    
    //返回按钮
    CGFloat backButtonSize = topBarH;
    UIButton *backButton  = [UIButton buttonWithType:UIButtonTypeCustom];
    backButton.translatesAutoresizingMaskIntoConstraints = NO;
    [backButton setImage:[UIImage imageNamed:@"mainBack"] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(backTouch:) forControlEvents:UIControlEventTouchUpInside];
    [topBarContainer addSubview:backButton];
    
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = @"扫码查询";
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.font = [UIFont systemFontOfSize:18];
    titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [topBarContainer addSubview:titleLabel];
    
    [topBarContainer addSubview:self.pickerImageButton];
    
    NSDictionary *views = @{
                            @"backButton": backButton,
                            @"titleLabel": titleLabel,
                            @"pickerImageButton": self.pickerImageButton,
                            };
    
    [topBarContainer addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-10-[backButton(40)]->=0-[titleLabel]->=0-[pickerImageButton(60)]-10-|"
                                                                            options:NSLayoutFormatAlignAllCenterY
                                                                            metrics:nil
                                                                              views:views]];
    [topBarContainer addConstraint:[NSLayoutConstraint constraintWithItem:backButton
                                                                attribute:NSLayoutAttributeCenterY
                                                                relatedBy:NSLayoutRelationEqual
                                                                   toItem:topBarContainer
                                                                attribute:NSLayoutAttributeCenterY
                                                               multiplier:1
                                                                 constant:0]];
    
    [topBarContainer addConstraint:[NSLayoutConstraint constraintWithItem:titleLabel
                                                                attribute:NSLayoutAttributeCenterX
                                                                relatedBy:NSLayoutRelationEqual
                                                                   toItem:topBarContainer
                                                                attribute:NSLayoutAttributeCenterX
                                                               multiplier:1
                                                                 constant:0]];
    
    [topBarContainer addConstraint:[NSLayoutConstraint constraintWithItem:backButton
                                                                attribute:NSLayoutAttributeHeight
                                                                relatedBy:NSLayoutRelationEqual
                                                                   toItem:nil
                                                                attribute:NSLayoutAttributeNotAnAttribute
                                                               multiplier:1
                                                                 constant:backButtonSize]];
    
    [topBarContainer addConstraint:[NSLayoutConstraint constraintWithItem:self.pickerImageButton
                                                                attribute:NSLayoutAttributeHeight
                                                                relatedBy:NSLayoutRelationEqual
                                                                   toItem:nil
                                                                attribute:NSLayoutAttributeNotAnAttribute
                                                               multiplier:1
                                                                 constant:backButtonSize]];
    
    //菊花
    self.indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    self.indicatorView.hidesWhenStopped = true;
    self.indicatorView.frame = self.view.bounds;
    [self.view addSubview:self.indicatorView];
}

- (void)openCamera
{
    AVAuthorizationStatus authorStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (authorStatus == AVAuthorizationStatusAuthorized) {
        //加载。。。
        [self loadingCameraView];
    } else if (authorStatus == AVAuthorizationStatusNotDetermined){
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
            if (granted) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self loadingCameraView];
                });
            }
        }];
    } else {
        //没有权限访问相机
        NSString *title = [NSString stringWithFormat:@"请进入 设置 > 隐私 > 相机 以允许“%@”访问你的相机",kAppName];
        
        UIAlertController *alert = [[UIAlertController alloc] init];
        UIAlertAction *sureAction = [UIAlertAction actionWithTitle:@"确定"
                                                             style:UIAlertActionStyleDefault
                                                           handler:nil];
        alert.title = title;
        [alert addAction:sureAction];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

- (void)loadingCameraView {
    [self.indicatorView startAnimating];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        [self createCameraView];
    });
}

- (void)createCameraView
{
    // Device
    _device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    // Input
    _input = [AVCaptureDeviceInput deviceInputWithDevice:self.device error:nil];
    
    // Output
    _output = [[AVCaptureMetadataOutput alloc] init];
    [_output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    
    // Session
    _session = [[AVCaptureSession alloc] init];
    [_session setSessionPreset:AVCaptureSessionPresetHigh];
    
    if ([_session canAddInput:self.input])
    {
        [_session addInput:self.input];
    }
    
    if ([_session canAddOutput:self.output])
    {
        [_session addOutput:self.output];
        // 条码类型 AVMetadataObjectTypeQRCode
        _output.metadataObjectTypes = @[AVMetadataObjectTypeQRCode,AVMetadataObjectTypeCode93Code,AVMetadataObjectTypeCode39Code,AVMetadataObjectTypeCode128Code,AVMetadataObjectTypeCode39Mod43Code,AVMetadataObjectTypeEAN13Code,AVMetadataObjectTypeEAN8Code];
    }
    
    // Start
    [_session startRunning];
    
    dispatch_sync(dispatch_get_main_queue(), ^{
        [self.indicatorView stopAnimating];
        // Preview
        self.preview = [AVCaptureVideoPreviewLayer layerWithSession:self.session];
        self.preview.videoGravity = AVLayerVideoGravityResizeAspectFill;
        self.preview.frame = self.view.layer.bounds;
        [self.view.layer insertSublayer:self.preview atIndex:0];
        self.preview.opacity = 0.f;
        
        //修饰视图
        CGFloat width = self.view.bounds.size.width;
        CGFloat height = self.view.bounds.size.height;
        
        CGFloat visualViewSize = 230.f;
        CGFloat visualViewMargin = (width - visualViewSize)/2;
        CGRect maskRect = (CGRect){visualViewMargin,(height - visualViewSize)/2,visualViewSize,visualViewSize};
        self.output.rectOfInterest = (CGRect){maskRect.origin.y/height,maskRect.origin.x/width,maskRect.size.height/height,maskRect.size.width/width}; //设置二维码可扫描区域
        CALayer *maskLayer = [CALayer layer];
        maskLayer.frame = self.backView.bounds;
        maskLayer.opacity = 1.f;
        self.backView.layer.mask = maskLayer;
        
        //添加黑色遮罩视图
        CALayer *topLayer = [CALayer layer];
        topLayer.frame = (CGRect){0,0,width,(height - visualViewSize)/2};
        topLayer.backgroundColor = [UIColor whiteColor].CGColor;
        [maskLayer addSublayer:topLayer];
        CALayer *leftLayer = [CALayer layer];
        leftLayer.frame = (CGRect){0,0,visualViewMargin,height};
        leftLayer.backgroundColor = [UIColor whiteColor].CGColor;
        [maskLayer addSublayer:leftLayer];
        CALayer *bottomLayer = [CALayer layer];
        bottomLayer.frame = (CGRect){0,CGRectGetMaxY(maskRect),width,(height - visualViewSize)/2};
        bottomLayer.backgroundColor = [UIColor whiteColor].CGColor;
        [maskLayer addSublayer:bottomLayer];
        CALayer *rightLayer = [CALayer layer];
        rightLayer.frame = (CGRect){CGRectGetMaxX(maskRect),0,visualViewMargin,height};
        rightLayer.backgroundColor = [UIColor whiteColor].CGColor;
        [maskLayer addSublayer:rightLayer];
        
        //取景框Containner
        UIView *visualViewContainer = [[UIView alloc] initWithFrame:maskRect];
        [self.view addSubview:visualViewContainer];
        
        //添加动画线条
        CGFloat lineW = CGRectGetWidth(visualViewContainer.frame);
        CGFloat lineH = 2.f;
        self.lineAnimateView = [[UIView alloc] initWithFrame:(CGRect){0,0,lineW,lineH}];
        self.lineAnimateView.backgroundColor = kThemeColor;
        self.lineAnimateView.layer.cornerRadius = 10.f;
        [visualViewContainer addSubview:self.lineAnimateView];
        //启动动画
        [self startAnimateLineView];
        
        //取景框
        UIView *visualView = [[UIView alloc] initWithFrame:visualViewContainer.bounds];
        visualView.layer.borderColor = [UIColor whiteColor].CGColor;
        visualView.layer.borderWidth = kDefaultLineWidth;
        [visualViewContainer addSubview:visualView];
        
        //添加四个角的修饰图
        [self createCornerViewInView:visualViewContainer];
        
        //提示性文字
        UILabel *warnLabel = [[UILabel alloc] initWithFrame:(CGRect){(width - maskRect.size.width)/2,CGRectGetMaxY(visualViewContainer.frame) + 20.f,maskRect.size.width,14.f}];
        warnLabel.backgroundColor = [UIColor clearColor];
        warnLabel.text = @"请将条码放入框内，即可自动扫描";
        warnLabel.font = [UIFont systemFontOfSize:12.f];
        warnLabel.textAlignment = NSTextAlignmentCenter;
        warnLabel.textColor = [UIColor whiteColor];
        warnLabel.layer.cornerRadius = 3.f;
        warnLabel.clipsToBounds = YES;
        [self.view addSubview:warnLabel];
        
        //闪光灯按钮
        CGFloat oriX = (CGRectGetWidth(self.view.bounds) - 37)/2;
        CGFloat oriY = CGRectGetMaxY(warnLabel.frame) + ((CGRectGetHeight(self.view.bounds) - CGRectGetMaxY(warnLabel.frame)) - 51)/2 - 20;
        UIButton *flashButton  = [UIButton buttonWithType:UIButtonTypeCustom];
        flashButton.frame = (CGRect){oriX,oriY,37,51};
        [flashButton setImage:[UIImage imageNamed:@"flashLightOff"] forState:UIControlStateNormal];
        [flashButton setImage:[UIImage imageNamed:@"flashLightOn"] forState:UIControlStateSelected];
        [flashButton addTarget:self action:@selector(changeFlashMode:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:flashButton];
        
        [self.view addSubview:self.flashLabel];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self.preview.opacity = 1.f;
        });
    });
}

- (void)startAnimateLineView
{
    //remove
    [self.lineAnimateView.layer removeAllAnimations];
    //add
    CABasicAnimation *basicAni = [CABasicAnimation animationWithKeyPath:@"position.y"];
    CGFloat offsetY = CGRectGetHeight(self.lineAnimateView.superview.frame);
    basicAni.toValue = @(offsetY);
    basicAni.duration = 2.f;
    basicAni.autoreverses = YES;
    basicAni.repeatCount = NSNotFound;
    basicAni.removedOnCompletion = NO;
    basicAni.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    basicAni.fillMode = kCAFillModeBoth;
    
    [self.lineAnimateView.layer addAnimation:basicAni forKey:@"qrcodelineviewanimate"];
}

- (void)createCornerViewInView:(UIView *)container
{
    CGFloat length = 20.f;
    CGFloat width = 3.f;
    CGFloat cWidth = container.bounds.size.width;
    CGFloat cHeight = container.bounds.size.height;
    
    UIView *v1 = [self viewWithGreenColorInContainer:container];
    v1.frame = (CGRect){0,0,length,width};
    UIView *v2 = [self viewWithGreenColorInContainer:container];
    v2.frame = (CGRect){cWidth-length,0,length,width};
    UIView *v3 = [self viewWithGreenColorInContainer:container];
    v3.frame = (CGRect){0,cHeight-width,length,width};
    UIView *v4 = [self viewWithGreenColorInContainer:container];
    v4.frame = (CGRect){cWidth-length,cHeight-width,length,width};
    
    UIView *va = [self viewWithGreenColorInContainer:container];
    va.frame = (CGRect){0,0,width,length};
    UIView *vb = [self viewWithGreenColorInContainer:container];
    vb.frame = (CGRect){cWidth-width,0,width,length};
    UIView *vc = [self viewWithGreenColorInContainer:container];
    vc.frame = (CGRect){0,cHeight-length,width,length};
    UIView *vd = [self viewWithGreenColorInContainer:container];
    vd.frame = (CGRect){cWidth-width,cHeight-length,width,length};
}

- (void)pickerImageButtonClicked {
    [self presentViewController:self.imagePicker animated:YES completion:nil];
}

- (UIView *)viewWithGreenColorInContainer:(UIView *)container
{
    UIView *temp = [[UIView alloc] init];
    temp.backgroundColor = kThemeColor;
    [container addSubview:temp];
    return temp;
}

- (void)switchFlashMode:(BOOL)on
{
    [self.session beginConfiguration];
    [self.device lockForConfiguration:nil];
    if (on) {
        if ([self.device isTorchModeSupported:AVCaptureTorchModeOn]) {
            self.device.torchMode = AVCaptureTorchModeOn;
        }
        [self settingFlashMode:AVCaptureFlashModeOn];
    } else {
        if ([self.device isTorchModeSupported:AVCaptureTorchModeOff]) {
            self.device.torchMode = AVCaptureTorchModeOff;
        }
        [self settingFlashMode:AVCaptureFlashModeOff];
    }
    [self.device unlockForConfiguration];
    [self.session commitConfiguration];
}

- (void)settingFlashMode:(AVCaptureFlashMode)mode {
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 10.0) {
        if (@available(iOS 10.0, *)) {
            [AVCapturePhotoSettings photoSettings].flashMode = mode;
        } else {
            self.device.flashMode = mode;
        }
    } else {
        self.device.flashMode = mode;
    }
}

/**
 解析二维码/条形码
 */
- (BOOL)dealQRcodeString:(NSString *)stringValue
{
    if ([self.delegate respondsToSelector:@selector(viewController:scanResult:)]) {
        return [self.delegate viewController:self scanResult:stringValue];
    } else {
        return false;
    }
}

- (NSString *)detectionQRCodeWithImage:(UIImage *)image {
    @autoreleasepool {
        NSCAssert(image != nil, @"**Assertion Error** detectQRCode : image is nil");
        
        CIImage* ciImage = [[CIImage alloc] initWithImage:image];
        
        NSDictionary* options;
        options = @{CIDetectorAccuracy : CIDetectorAccuracyHigh};
        
        CIDetector* qrDetector = [CIDetector detectorOfType:CIDetectorTypeQRCode
                                                    context:nil
                                                    options:options];
        NSArray * features = [qrDetector featuresInImage:ciImage options:@{}];
        if (features.count > 0) {
            CIQRCodeFeature *feature = features.firstObject;
            ciImage = nil;
            return feature.messageString;
        }
        ciImage = nil;
        return nil;
    }
}

#pragma mark - Getter
- (UILabel *)flashLabel {
    if (!_flashLabel) {
        _flashLabel = [[UILabel alloc] init];
        _flashLabel.text = @"关";
        _flashLabel.textColor = [UIColor whiteColor];
        _flashLabel.font = [UIFont systemFontOfSize:14];
    }
    return _flashLabel;
}

- (JTImagePickerController *)imagePicker {
    if (!_imagePicker) {
        _imagePicker = [[JTImagePickerController alloc] init];
        _imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        
        __weak typeof(self)weakSelf = self;
        _imagePicker.didFinishPickingMedia = ^(JTImagePickerController *__weak picker, NSDictionary<NSString *,id> *info) {
            __strong __typeof(weakSelf)strongSelf = weakSelf;
            UIImage *image = [info objectForKey:@"UIImagePickerControllerEditedImage"];
            if (image) {
                NSString *result = [strongSelf detectionQRCodeWithImage:image];
                [strongSelf dealQRcodeString:result];
            }
            [picker dismissViewControllerAnimated:YES completion:nil];
        };
        _imagePicker.didCancel = ^(JTImagePickerController *__weak picker) {
            [picker dismissViewControllerAnimated:YES completion:nil];
        };
        _imagePicker.allowsEditing = YES;
    }
    return _imagePicker;
}


- (UIButton *)pickerImageButton {
    if (!_pickerImageButton) {
        _pickerImageButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _pickerImageButton.translatesAutoresizingMaskIntoConstraints = NO;
        [_pickerImageButton setTitle:@"相册" forState:UIControlStateNormal];
        _pickerImageButton.titleLabel.font = [UIFont systemFontOfSize:16];
        [_pickerImageButton addTarget:self action:@selector(pickerImageButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    }
    return _pickerImageButton;
}

@end
