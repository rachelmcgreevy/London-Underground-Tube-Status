//
//  FirstViewController.m
//  London Underground Tube Status
//
//  Created by Rachel McGreevy on 20/01/2017.
//  Copyright © 2017 Rachel McGreevy. All rights reserved.
//

#import "FirstViewController.h"
#import "StatusFetcher.h"

@interface FirstViewController ()

@property CGFloat screenWidth;
@property CGFloat screenHeight;
@property CGPoint cellOrigin;
@property (strong, nonatomic) NSMutableDictionary *tubeColours;
//@property (strong, nonatomic) UIScrollView *gridView;
@property (strong, nonatomic) UICollectionView *gridView;
@property (strong, nonatomic) NSMutableArray *tubeStatus;
@property BOOL isExpanded;
@property (strong, nonatomic) NSIndexPath *expandedCellIndexPath;

@end

@implementation FirstViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    _screenHeight = [[UIScreen mainScreen] bounds].size.height;
    _screenWidth = [[UIScreen mainScreen] bounds].size.width;
    UIView *vc = [[UIView alloc] initWithFrame:CGRectMake(0,0,_screenWidth,_screenHeight)];
    vc.backgroundColor = [UIColor whiteColor];
    self.view = vc;
    
    [self assignTubeColours];
    StatusFetcher *fetcher = [[StatusFetcher alloc] init];
    _tubeStatus = [fetcher getLiveTubeStatus];
    [self setUpToolbar];
    [self setUpGrid];

}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)assignTubeColours {
    _tubeColours = [[NSMutableDictionary alloc] initWithCapacity:10];
    [_tubeColours setObject:[UIColor colorWithRed:178/255.f green:99/255.f blue:0/255.f alpha:1.f] forKey:@"Bakerloo"];
    [_tubeColours setObject:[UIColor colorWithRed:220/255.f green:36/255.f blue:31/255.f alpha:1.f] forKey:@"Central"];
    [_tubeColours setObject:[UIColor colorWithRed:255/255.f green:211/255.f blue:41/255.f alpha:1.f] forKey:@"Circle"];
    [_tubeColours setObject:[UIColor colorWithRed:0/255.f green:125/255.f blue:50/255.f alpha:1.f] forKey:@"District"];
    [_tubeColours setObject:[UIColor colorWithRed:244/255.f green:169/255.f blue:190/255.f alpha:1.f] forKey:@"Hammersmith & City"];
    [_tubeColours setObject:[UIColor colorWithRed:161/255.f green:165/255.f blue:167/255.f alpha:1.f] forKey:@"Jubilee"];
    [_tubeColours setObject:[UIColor colorWithRed:155/255.f green:0/255.f blue:88/255.f alpha:1.f] forKey:@"Metropolitan"];
    [_tubeColours setObject:[UIColor colorWithRed:0/255.f green:0/255.f blue:0/255.f alpha:1.f] forKey:@"Northern"];
    [_tubeColours setObject:[UIColor colorWithRed:0/255.f green:25/255.f blue:168/255.f alpha:1.f] forKey:@"Piccadilly"];
    [_tubeColours setObject:[UIColor colorWithRed:0/255.f green:152/255.f blue:216/255.f alpha:1.f] forKey:@"Victoria"];
    [_tubeColours setObject:[UIColor colorWithRed:147/255.f green:206/255.f blue:186/255.f alpha:1.f] forKey:@"Waterloo & City"];
    [_tubeColours setObject:[UIColor colorWithRed:239/255.f green:123/255.f blue:16/255.f alpha:1.f] forKey:@"London Overground"];
    [_tubeColours setObject:[UIColor colorWithRed:0/255.f green:175/255.f blue:173/255.f alpha:1.f] forKey:@"DLR"];
    [_tubeColours setObject:[UIColor colorWithRed:0/255.f green:189/255.f blue:25/255.f alpha:1.f] forKey:@"Tram"];
}

- (void)setUpToolbar {
    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, _screenWidth, 60)];
    [toolbar setBackgroundImage:[UIImage new] forToolbarPosition:UIToolbarPositionAny barMetrics:UIBarMetricsDefault];
    toolbar.backgroundColor = [UIColor whiteColor];
    UISegmentedControl *segmentedControl = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects: @"Live", @"Weekend", nil]];
    segmentedControl.frame = CGRectMake(0, 0, 150, 25);
    segmentedControl.tintColor = [UIColor blackColor];
    [segmentedControl addTarget:self action:@selector(segmentedControlAction:) forControlEvents: UIControlEventValueChanged];
    segmentedControl.selectedSegmentIndex = 0;
    segmentedControl.center = CGPointMake(_screenWidth/2, 40);
    [toolbar addSubview:segmentedControl];
    [self.view addSubview:toolbar];
}

- (void)setUpGrid {
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.minimumLineSpacing = 0;
    layout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    layout.itemSize = CGSizeMake(_screenWidth/3, _screenHeight/5.7);
    layout.sectionInset = UIEdgeInsetsZero;
    layout.minimumInteritemSpacing = 0;
    layout.minimumLineSpacing = 0;
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    _gridView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 60, _screenWidth, _screenHeight-60) collectionViewLayout:layout];
    [_gridView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"cell"];
    _gridView.dataSource = self;
    _gridView.delegate = self;
    _gridView.backgroundColor = [UIColor whiteColor];
    [_gridView addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleGesture:)]];
    [self.view addSubview:_gridView];
    
    /*
    _gridView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 60, _screenWidth, _screenHeight-60)];
    _gridView.backgroundColor = [UIColor whiteColor];
    _gridView.contentSize = CGSizeMake(_screenWidth, _screenHeight *1.2);
    [self.view addSubview:_gridView];
    for (int i=0; i<14; i++){
        UIView *gridCell = [[UIView alloc] initWithFrame:CGRectMake(((i%3)*_screenWidth/3),(floor(i/3)*_screenHeight)/5.7, _screenWidth/3, _screenHeight/5.7)];
        
        UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(dragCell:)];
        [panRecognizer setMinimumNumberOfTouches:1];
        [panRecognizer setMaximumNumberOfTouches:1];
        [gridCell addGestureRecognizer:panRecognizer];
        
        NSString *tubeName = [_tubeStatus[i] objectForKey:@"name"];
        gridCell.backgroundColor=[_tubeColours objectForKey:tubeName];
        
        UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 20, gridCell.frame.size.width, 20)];
        nameLabel.tag = 3;
        nameLabel.adjustsFontSizeToFitWidth = YES;
        [nameLabel setFont:[UIFont systemFontOfSize:14]];
        nameLabel.textColor = [UIColor whiteColor];
        nameLabel.text = tubeName;
        nameLabel.textAlignment = NSTextAlignmentCenter;
        [gridCell addSubview:nameLabel];
        
        UILabel *statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 70, gridCell.frame.size.width,20)];
        statusLabel.adjustsFontSizeToFitWidth = YES;
        statusLabel.tag = 4;
        [statusLabel setFont:[UIFont systemFontOfSize:14]];
        statusLabel.textColor = [UIColor whiteColor];
        statusLabel.text = [[_tubeStatus[i] objectForKey:@"lineStatuses"][0] objectForKey:@"statusSeverityDescription"];
        statusLabel.textAlignment = NSTextAlignmentCenter;
        [gridCell addSubview:statusLabel];
        
        UILabel *descriptionLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 170, _screenWidth,80)];
        descriptionLabel.tag = 5;
        descriptionLabel.numberOfLines = 0;
        [descriptionLabel setFont:[UIFont systemFontOfSize:14]];
        descriptionLabel.textColor = [UIColor whiteColor];
        descriptionLabel.text = [[_tubeStatus[i] objectForKey:@"lineStatuses"][0] objectForKey:@"reason"];
        descriptionLabel.textAlignment = NSTextAlignmentCenter;
        descriptionLabel.hidden = YES;
        [gridCell addSubview:descriptionLabel];
        
        
        gridCell.tag = i +32;
        [gridCell addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickedOnCellView:)]];
        [_gridView addSubview:gridCell];
    } */
}

- (void)segmentedControlAction:(id)sender {
    //fetch weekend tube status and update labels
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 14;
}

- (BOOL)collectionView:(UICollectionView *)collectionView canMoveItemAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}

- (void)collectionView:(UICollectionView *)collectionView moveItemAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath{
    
    //change the order of entries in the data source to match the new visual order of the cells.
    
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    
    
    NSString *tubeName = _tubeStatus[indexPath.row][0];
    cell.backgroundColor=[_tubeColours objectForKey:tubeName];
    
    UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 20, cell.frame.size.width, 20)];
    nameLabel.tag = 3;
    nameLabel.adjustsFontSizeToFitWidth = YES;
    [nameLabel setFont:[UIFont systemFontOfSize:14]];
    nameLabel.textColor = [UIColor whiteColor];
    nameLabel.text = tubeName;
    nameLabel.textAlignment = NSTextAlignmentCenter;
    [cell addSubview:nameLabel];
    
    UILabel *statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 70, cell.frame.size.width,20)];
    statusLabel.adjustsFontSizeToFitWidth = YES;
    statusLabel.tag = 4;
    [statusLabel setFont:[UIFont systemFontOfSize:14]];
    statusLabel.textColor = [UIColor whiteColor];
    statusLabel.text = _tubeStatus[indexPath.row][1];
    statusLabel.textAlignment = NSTextAlignmentCenter;
    [cell addSubview:statusLabel];
    
    UILabel *descriptionLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 170, _screenWidth,80)];
    descriptionLabel.tag = 5;
    descriptionLabel.numberOfLines = 0;
    [descriptionLabel setFont:[UIFont systemFontOfSize:14]];
    descriptionLabel.textColor = [UIColor whiteColor];
    descriptionLabel.text = _tubeStatus[indexPath.row][2];
    descriptionLabel.textAlignment = NSTextAlignmentCenter;
    descriptionLabel.hidden = YES;
    [cell addSubview:descriptionLabel];


    [cell addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickedOnCellView:)]];

    return cell;
}

-(void)handleGesture:(UILongPressGestureRecognizer*)gesture{
    switch (gesture.state) {
        case UIGestureRecognizerStateBegan:{
            NSIndexPath *indexPath=[_gridView indexPathForItemAtPoint:[gesture locationInView:_gridView]];
            if(indexPath!=nil)
                [_gridView beginInteractiveMovementForItemAtIndexPath:indexPath];
            break;
        }
        case UIGestureRecognizerStateChanged:{
            [_gridView updateInteractiveMovementTargetPosition:[gesture locationInView:_gridView]];
            break;
        }
        case UIGestureRecognizerStateEnded:{
            [_gridView endInteractiveMovement];
            break;
        }
            
        default:
            [_gridView cancelInteractiveMovement];
            break;
    }
}

- (void)clickedOnCellView:(id)sender {
    UICollectionViewCell *senderView = (UICollectionViewCell *)[(UITapGestureRecognizer *)sender view];
    _expandedCellIndexPath = [_gridView indexPathForCell:senderView];
    
    UIView *expandedView = [[UIView alloc] initWithFrame:CGRectMake(0, 60, _screenWidth, _screenHeight)];
    expandedView.backgroundColor = senderView.backgroundColor;
    
    [expandedView addSubview:[self copyLabel:[senderView viewWithTag:3]]];
    
    [expandedView addSubview:[self copyLabel:[senderView viewWithTag:4]]];
    
    [expandedView addSubview:[self copyLabel:[senderView viewWithTag:5]]];
    
    [self.view addSubview:expandedView];
    [expandedView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickedOnExpandedView:)]];
}

- (void)clickedOnExpandedView:(id)sender {
    UIView *senderView = [(UITapGestureRecognizer *)sender view];
    [senderView removeFromSuperview];
}

-(UILabel *)copyLabel:(UILabel *)oldLabel {
    UILabel *newLabel = [[UILabel alloc] initWithFrame:CGRectMake(oldLabel.frame.origin.x, oldLabel.frame.origin.y, _screenWidth, oldLabel.frame.size.height)];
    newLabel.font = oldLabel.font;
    newLabel.text = oldLabel.text;
    newLabel.numberOfLines = oldLabel.numberOfLines;
    newLabel.textColor = oldLabel.textColor;
    newLabel.textAlignment = oldLabel.textAlignment;
    newLabel.hidden = NO;
    return newLabel;
}


/*
- (void)dragCell:(id)sender {
    [_gridView bringSubviewToFront:[(UIPanGestureRecognizer*)sender view]];
    UIView *senderView = [(UIPanGestureRecognizer*)sender view];
    CGPoint translatedPoint = [(UIPanGestureRecognizer*)sender translationInView:self.view];
    
    
    senderView.center = CGPointMake(senderView.center.x + translatedPoint.x, senderView.center.y + translatedPoint.y);
    
    for (UIView *gridCell in [_gridView subviews]){
        if (gridCell != senderView){
            if(CGRectContainsPoint(gridCell.frame, senderView.center)) {
                CGPoint currentCellCenter = gridCell.center;
                
                [UIView transitionWithView:gridCell duration:.5 options: UIViewAnimationOptionTransitionNone animations:^{ gridCell.center = CGPointMake(currentCellCenter.x + _screenWidth/3 , currentCellCenter.y);} completion:NULL];
            }
        }
    }
    [sender setTranslation:CGPointMake(0, 0) inView:self.view];
    
 
    if ([(UIPanGestureRecognizer*)sender state] == UIGestureRecognizerStateEnded) {
        
        CGFloat finalX = ;
        CGFloat finalY = ;
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:.2];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDidStopSelector:@selector(animationDidFinish)];
        [[sender view] setCenter:CGPointMake(finalX, finalY)];
        [UIView commitAnimations];
    }
}



- (void)clickedOnCellView:(id)sender {
    UIView *cellView = [_gridView viewWithTag:[(UIGestureRecognizer *)sender view].tag];
    [_gridView bringSubviewToFront:cellView];
    [UIView transitionWithView:cellView duration:.5 options:UIViewAnimationOptionTransitionNone animations:^{
        int i = cellView.tag - 32;
        if (cellView.frame.size.width != _screenWidth){
            cellView.frame = CGRectMake(0,_gridView.contentOffset.y, _screenWidth, _screenHeight);
            _gridView.scrollEnabled = NO;
            
            UILabel *nameLabel = [cellView viewWithTag:3];
            nameLabel.center = CGPointMake(cellView.frame.size.width/2, 30);
            UILabel *statusLabel = [cellView viewWithTag:4];
            statusLabel.center = CGPointMake(cellView.frame.size.width/2, 80);
            
            UILabel *descriptionLabel = [cellView viewWithTag:5];
            descriptionLabel.hidden = NO;
            
        } else {
            cellView.frame = CGRectMake(((i%3)*_screenWidth/3),(floor(i/3)*_screenHeight)/5.7, _screenWidth/3, _screenHeight/5.7);
            _gridView.scrollEnabled = YES;
            
            UILabel *nameLabel = [cellView viewWithTag:3];
            nameLabel.center = CGPointMake(cellView.frame.size.width/2, 30);
            UILabel *statusLabel = [cellView viewWithTag:4];
            statusLabel.center = CGPointMake(cellView.frame.size.width/2, 70);
            UILabel *descriptionLabel = [cellView viewWithTag:5];
            descriptionLabel.hidden = YES;
            
        }
    } completion:NULL];
}
*/
@end
