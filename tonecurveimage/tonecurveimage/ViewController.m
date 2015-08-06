//
//  ViewController.m
//  tonecurveimage
//
//  Created by yuki naniwa on 2015/08/05.
//  Copyright (c) 2015年 tonetoneimage. All rights reserved.
//

#import "ViewController.h"

#import "GPUImage.h"
#import "BlocksKit.h"
#import "BlocksKit+UIKit.h"
#import "UIView+Toast.h"

@interface ViewController ()
{
    NSInteger indexfilter;
}
@property (nonatomic) GPUImageView *imageview;

@property (weak, nonatomic) IBOutlet UILabel *filtername;
@property (weak, nonatomic) IBOutlet UILabel *labeldesc;
@property(nonatomic) GPUImagePicture* picture;

@property(nonatomic) NSMutableArray* arrayFilter;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    _arrayFilter = [NSMutableArray array];
    [_arrayFilter addObject:[[GPUImageToneCurveFilter alloc] initWithACV:@"curves_1"]];
    [_arrayFilter addObject:[[GPUImageToneCurveFilter alloc] initWithACV:@"curves_2"]];
    [_arrayFilter addObject:[[GPUImageToneCurveFilter alloc] initWithACV:@"curves_3"]];
    
    UIImage *inputImage = [UIImage imageNamed:@"Lenna"];
    self.picture = [[GPUImagePicture alloc] initWithImage:inputImage smoothlyScaleOutput:YES];
    
    GPUImageOutput<GPUImageInput>* filter = _arrayFilter.firstObject;
    
    self.imageview = [[GPUImageView alloc] initWithFrame:self.view.frame];
    
    [self.view addSubview:self.imageview];
    
    [self.picture addTarget:filter];
    [filter addTarget:self.imageview];
    [self.picture processImage];
    
    [self.view bringSubviewToFront:self.filtername];
    [self.view bringSubviewToFront:self.labeldesc];
    
    self.filtername.text = @"curves_1";
    self.view.userInteractionEnabled = YES;
    UISwipeGestureRecognizer *swipe = [[UISwipeGestureRecognizer alloc] bk_initWithHandler:^(UIGestureRecognizer *sender, UIGestureRecognizerState state, CGPoint location) {
        
        [self.picture removeTarget:_arrayFilter[indexfilter]];
        
        indexfilter = ++indexfilter%_arrayFilter.count;
        NSString* filterfile = [NSString stringWithFormat:@"curves_%ld",indexfilter+1];
        
        [self.picture addTarget:_arrayFilter[indexfilter]];
        [_arrayFilter[indexfilter] addTarget:self.imageview];
        [self.picture processImage];
        
        self.filtername.text = filterfile;
    }];
    swipe.direction = UISwipeGestureRecognizerDirectionLeft|UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer:swipe];
    
    [self.view bk_whenTapped:^{
        [_arrayFilter[indexfilter] useNextFrameForImageCapture];
        [self.picture processImage];
        UIImage *currentFilteredImage = [_arrayFilter[indexfilter] imageFromCurrentFramebuffer];
        UIImageWriteToSavedPhotosAlbum(currentFilteredImage, NULL, NULL, NULL);
        [self.view makeToast:@"save image."];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
