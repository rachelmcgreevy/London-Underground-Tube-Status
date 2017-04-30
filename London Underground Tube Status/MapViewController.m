//
//  MapViewController.m
//  London Underground Tube Status
//
//  Created by Rachel McGreevy on 20/01/2017.
//  Copyright © 2017 Rachel McGreevy. All rights reserved.
//
#import <WebKit/WebKit.h>
#import <QuartzCore/QuartzCore.h>
#import <CoreGraphics/CoreGraphics.h>
#import "MapViewController.h"

@interface MapViewController ()

@property (nonatomic, strong) UIImageView *backgroundImage;
@property (nonatomic, strong) UIView *imageView;
@property (nonatomic) CGPDFPageRef myPageRef;

@end

@implementation MapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    CGFloat screenHeight = [[UIScreen mainScreen] bounds].size.height;
    CGFloat screenWidth = [[UIScreen mainScreen] bounds].size.width;
    
    self.view = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight)];
    ((UIScrollView *) self.view).delegate = self;
    self.view.backgroundColor = [UIColor whiteColor];
    
    _imageView = [[UIView alloc] initWithFrame:CGRectMake(0, 20, screenWidth, screenHeight-20) ];
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"Graphics/tubemap" ofType:@"pdf"];
    NSURL *pdfURL = [NSURL fileURLWithPath:filePath];
    CGPDFDocumentRef myDocumentRef = CGPDFDocumentCreateWithURL((CFURLRef) pdfURL);
    _myPageRef = CGPDFDocumentGetPage(myDocumentRef, 1);
    
    CGRect pageRect = CGRectIntegral(CGPDFPageGetBoxRect(_myPageRef, kCGPDFCropBox));
    ((UIScrollView *) self.view).minimumZoomScale = (self.view.frame.size.width / pageRect.size.width);
    ((UIScrollView *) self.view).maximumZoomScale = 10;
    ((UIScrollView *) self.view).contentSize = pageRect.size;
    
    CATiledLayer *tiledLayer = [CATiledLayer layer];
    tiledLayer.delegate = self;
    tiledLayer.tileSize = CGSizeMake(200, 200);
    tiledLayer.levelsOfDetail = 1000;
    tiledLayer.levelsOfDetailBias = 1000;
    tiledLayer.frame = CGRectIntegral(CGPDFPageGetBoxRect(_myPageRef, kCGPDFCropBox));
    [_imageView.layer addSublayer:tiledLayer];
    
    [self.view addSubview:_imageView];
    ((UIScrollView *) self.view).zoomScale = ((UIScrollView *) self.view).minimumZoomScale;
    
    
    UIView *statusBar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 20)];
    statusBar.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:statusBar];
    
}

-(void)viewDidLayoutSubviews {
    //((UIScrollView *)self.view).contentOffset = CGPointMake(-10, -30);
}

- (void)viewWillAppear:(BOOL)animated {
    //((UIScrollView *)self.view).contentOffset = CGPointMake(-10, -30);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return _imageView;
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale{

}

- (void)drawLayer:(CALayer *)layer inContext:(CGContextRef)context {
    CGContextSetRGBFillColor(context, 1.0, 1.0, 1.0, 1.0);
    CGContextFillRect(context, CGContextGetClipBoundingBox(context));
    CGContextTranslateCTM(context, 0.0, layer.bounds.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextConcatCTM(context, CGPDFPageGetDrawingTransform(_myPageRef, kCGPDFCropBox, layer.bounds, 0, true));
    CGContextDrawPDFPage(context, _myPageRef);
}

@end
