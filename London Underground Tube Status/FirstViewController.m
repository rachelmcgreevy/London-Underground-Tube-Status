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
@property (strong, nonatomic) StatusFetcher *statusFetcher;
@property (strong, nonatomic) NSString *currentState;

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
    _statusFetcher = [[StatusFetcher alloc] init];
    _tubeStatus = [_statusFetcher getLiveTubeStatus];
    _currentState = @"Live";
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
    [_tubeColours setObject:[UIColor colorWithRed:0/255.f green:25/255.f blue:168/255.f alpha:1.f] forKey:@"TfL Rail"];
    [_tubeColours setObject:[UIColor colorWithRed:220/255.f green:36/255.f blue:31/255.f alpha:1.f] forKey:@"Emirates Air Line"];
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
    _gridView.bounces = YES;
    _gridView.alwaysBounceVertical = YES;
    _gridView.backgroundColor = [UIColor whiteColor];
    [_gridView addGestureRecognizer:[[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleGesture:)]];
    [self.view addSubview:_gridView];
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    refreshControl.backgroundColor = [UIColor whiteColor];
    refreshControl.tintColor = [UIColor blackColor];
    [refreshControl addTarget:self
                            action:@selector(updateTubeStatus)
             forControlEvents:UIControlEventValueChanged];
    
    _gridView.refreshControl = refreshControl;
    
   }

- (void)segmentedControlAction:(UISegmentedControl *)sender {
    if ([[sender titleForSegmentAtIndex:sender.selectedSegmentIndex] isEqualToString:@"Live"])
    {
        _currentState = @"Live";
        //fetch real time tube status
        _tubeStatus  = [_statusFetcher getLiveTubeStatus];

    } else {
        _currentState = @"Weekend";
        //fetch weekend tube status
    _tubeStatus  = [_statusFetcher getWeekendTubeStatus];
    }
    //update labels in correct order
    [_gridView reloadData];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _tubeStatus.count;
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

    if ([cell viewWithTag:3] != nil) {
        UILabel *nameLabel = [cell viewWithTag:3];
        nameLabel.text = tubeName;
    } else {
        UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 20, cell.frame.size.width, 20)];
        nameLabel.tag = 3;
        nameLabel.adjustsFontSizeToFitWidth = YES;
        [nameLabel setFont:[UIFont systemFontOfSize:14]];
        nameLabel.textColor = [UIColor whiteColor];
        nameLabel.text = tubeName;
        nameLabel.textAlignment = NSTextAlignmentCenter;
        [cell addSubview:nameLabel];
    }
    
    if ([cell viewWithTag:4] != nil) {
        UILabel *statusLabel = [cell viewWithTag:4];
        statusLabel.text = _tubeStatus[indexPath.row][1];
    } else {
        UILabel *statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 70, cell.frame.size.width,20)];
        statusLabel.adjustsFontSizeToFitWidth = YES;
        statusLabel.tag = 4;
        [statusLabel setFont:[UIFont systemFontOfSize:14]];
        statusLabel.textColor = [UIColor whiteColor];
        statusLabel.text = _tubeStatus[indexPath.row][1];
        statusLabel.textAlignment = NSTextAlignmentCenter;
        [cell addSubview:statusLabel];
    }
    
    if ([cell viewWithTag:5] != nil) {
        UILabel *descriptionLabel = [cell viewWithTag:5];
        descriptionLabel.text = _tubeStatus[indexPath.row][2];
    } else {
        UILabel *descriptionLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 170, _screenWidth,210)];
        descriptionLabel.tag = 5;
        descriptionLabel.numberOfLines = 0;
        [descriptionLabel setFont:[UIFont systemFontOfSize:12]];
        descriptionLabel.textColor = [UIColor whiteColor];
        descriptionLabel.text = _tubeStatus[indexPath.row][2];
        descriptionLabel.textAlignment = NSTextAlignmentCenter;
        descriptionLabel.hidden = YES;
        [cell addSubview:descriptionLabel];
    }

    [cell addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickedOnCellView:)]];

    return cell;
}

-(void)handleGesture:(UILongPressGestureRecognizer*)gesture{
    switch (gesture.state) {
        case UIGestureRecognizerStateBegan:{
            NSIndexPath *indexPath=[_gridView indexPathForItemAtPoint:[gesture locationInView:_gridView]];
            if(indexPath!=nil)
                [_gridView beginInteractiveMovementForItemAtIndexPath:indexPath];
            [[_gridView cellForItemAtIndexPath:indexPath].layer addAnimation:[self getShakeAnimation] forKey:@""];
            break;
        }
        case UIGestureRecognizerStateChanged:{
            [_gridView updateInteractiveMovementTargetPosition:[gesture locationInView:_gridView]];
            break;
        }
        case UIGestureRecognizerStateEnded:{
            NSIndexPath *indexPath=[_gridView indexPathForItemAtPoint:[gesture locationInView:_gridView]];
            [_gridView endInteractiveMovement];
            [[_gridView cellForItemAtIndexPath:indexPath].layer removeAllAnimations];
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
    UILabel *newLabel = [[UILabel alloc] initWithFrame:CGRectMake(oldLabel.frame.origin.x+10, oldLabel.frame.origin.y, _screenWidth-20, oldLabel.frame.size.height)];
    newLabel.font = oldLabel.font;
    newLabel.text = oldLabel.text;
    newLabel.numberOfLines = oldLabel.numberOfLines;
    newLabel.textColor = oldLabel.textColor;
    newLabel.textAlignment = oldLabel.textAlignment;
    newLabel.hidden = NO;
    return newLabel;
}

- (CAAnimation*)getShakeAnimation
{
    CAKeyframeAnimation* animation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    
    CGFloat wobbleAngle = 0.06f;
    
    NSValue* valLeft = [NSValue valueWithCATransform3D:CATransform3DMakeRotation(wobbleAngle, 0.0f, 0.0f, 1.0f)];
    NSValue* valRight = [NSValue valueWithCATransform3D:CATransform3DMakeRotation(-wobbleAngle, 0.0f, 0.0f, 1.0f)];
    animation.values = [NSArray arrayWithObjects:valLeft, valRight, nil];
    
    animation.autoreverses = YES;
    animation.duration = 0.125;
    animation.repeatCount = HUGE_VALF;
    
    return animation;
}

- (void)updateTubeStatus {
    if ([_currentState isEqualToString:@"Live"]) {
        _tubeStatus  = [_statusFetcher getLiveTubeStatus];
    } else {
        _tubeStatus  = [_statusFetcher getWeekendTubeStatus];
    }
    [_gridView reloadData];
    //for each cell in grid, update labels.
    [_gridView.refreshControl endRefreshing];
}

@end
