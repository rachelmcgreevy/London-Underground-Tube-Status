//
//  SettingsViewController.m
//  London Underground Tube Status
//
//  Created by Rachel McGreevy on 12/02/2017.
//  Copyright © 2017 Rachel McGreevy. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SettingsViewController.h"

@interface SettingsViewController ()

@end

@implementation SettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    CGFloat screenHeight = [[UIScreen mainScreen] bounds].size.height;
    CGFloat screenWidth = [[UIScreen mainScreen] bounds].size.width;
    UIView *vc = [[UIView alloc] initWithFrame:CGRectMake(0,0,screenWidth,screenHeight)];
    vc.backgroundColor = [UIColor whiteColor];
    self.view = vc;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
