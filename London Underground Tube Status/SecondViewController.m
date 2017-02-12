//
//  SecondViewController.m
//  London Underground Tube Status
//
//  Created by Rachel McGreevy on 20/01/2017.
//  Copyright © 2017 Rachel McGreevy. All rights reserved.
//

#import "SecondViewController.h"

@interface SecondViewController ()

@property (nonatomic, strong) UIImageView *backgroundImage;

@end

@implementation SecondViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    CGFloat screenHeight = [[UIScreen mainScreen] bounds].size.height;
    CGFloat screenWidth = [[UIScreen mainScreen] bounds].size.width;
    UIScrollView *vc = [[UIScrollView alloc] initWithFrame:CGRectMake(0,0,screenWidth,screenHeight)];
    //vc.backgroundColor = [UIColor whiteColor];
    vc.minimumZoomScale=0.5;
    vc.zoomScale=1.5;
    vc.maximumZoomScale=3.0;
    vc.contentSize=CGSizeMake(1700, 1140);
    _backgroundImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 25, 1700, 1140)];
    _backgroundImage.image = [UIImage imageNamed:@"Graphics/tubemap.png"];
    _backgroundImage.contentMode = UIViewContentModeScaleAspectFit;
    [vc addSubview:_backgroundImage];
    vc.delegate=self;
    [vc setBackgroundColor:[UIColor whiteColor]];
    self.view = vc;
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.backgroundImage;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
