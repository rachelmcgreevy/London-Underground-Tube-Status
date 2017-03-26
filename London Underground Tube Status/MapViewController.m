//
//  MapViewController.m
//  London Underground Tube Status
//
//  Created by Rachel McGreevy on 20/01/2017.
//  Copyright © 2017 Rachel McGreevy. All rights reserved.
//

#import "MapViewController.h"

@interface MapViewController ()

@property (nonatomic, strong) UIImageView *backgroundImage;

@end

@implementation MapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    CGFloat screenHeight = [[UIScreen mainScreen] bounds].size.height;
    CGFloat screenWidth = [[UIScreen mainScreen] bounds].size.width;
    UIWebView *vc = [[UIWebView alloc] initWithFrame:CGRectMake(0, 30, screenWidth, screenHeight)];
    NSString *path = [[NSBundle mainBundle] pathForResource:@"Graphics/tubemap2" ofType:@"pdf"];
    NSURL *detailURL = [NSURL fileURLWithPath:path];
    NSURLRequest *request = [NSURLRequest requestWithURL:detailURL];
    [vc loadRequest:request];
    vc.scalesPageToFit = YES;
    vc.backgroundColor = [UIColor whiteColor];
    self.view = vc;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
