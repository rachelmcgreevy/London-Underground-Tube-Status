//
//  SecondViewController.m
//  London Underground Tube Status
//
//  Created by Rachel McGreevy on 20/01/2017.
//  Copyright © 2017 Rachel McGreevy. All rights reserved.
//

#import "SecondViewController.h"

@interface SecondViewController ()

@end

@implementation SecondViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    CGFloat screenHeight = [[UIScreen mainScreen] bounds].size.height;
    CGFloat screenWidth = [[UIScreen mainScreen] bounds].size.width;
    UIView *vc = [[UIView alloc] initWithFrame:CGRectMake(0,0,screenWidth,screenHeight)];
    vc.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"tubemap.jpg"]];
    self.view = vc;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
