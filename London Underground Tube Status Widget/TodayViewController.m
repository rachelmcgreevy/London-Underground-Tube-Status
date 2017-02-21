//
//  TodayViewController.m
//  London Underground Tube Status Widget
//
//  Created by Rachel McGreevy on 14/02/2017.
//  Copyright © 2017 Rachel McGreevy. All rights reserved.
//

#import "TodayViewController.h"
#import "StatusFetcher.h"
#import <NotificationCenter/NotificationCenter.h>

@interface TodayViewController () <NCWidgetProviding>

@property (strong, nonatomic) NSMutableArray *tubeStatus;
@property (strong, nonatomic) StatusFetcher *statusFetcher;

@property (weak, nonatomic) IBOutlet UILabel *widgetLabel;

@end

@implementation TodayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    _statusFetcher = [[StatusFetcher alloc] init];
    [self getTubeStatus:[_statusFetcher getLiveTubeStatus]];
    NSMutableArray *linesWithDisruptions = [self getBadServiceList];
    NSString *sentanceToDisplay = [self setUpSentance:linesWithDisruptions];
    [self setUpLabel:sentanceToDisplay];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)widgetPerformUpdateWithCompletionHandler:(void (^)(NCUpdateResult))completionHandler {
    // Perform any setup necessary in order to update the view.
    
    // If an error is encountered, use NCUpdateResultFailed
    // If there's no update required, use NCUpdateResultNoData
    // If there's an update, use NCUpdateResultNewData

    completionHandler(NCUpdateResultNewData);
}

- (void)getTubeStatus:(NSMutableArray *)tubeStatusData {
    if (_tubeStatus == nil) {
        _tubeStatus = tubeStatusData;
    } else {
        for (int i = 0; i < _tubeStatus.count; i++) {
            NSString *lineName = _tubeStatus[i][0];
            for (int j = 0; j < tubeStatusData.count; j++){
                if ([tubeStatusData[j][0] isEqualToString:lineName]) {
                    _tubeStatus[i][1] = tubeStatusData[j][1];
                    _tubeStatus[i][2] = tubeStatusData[j][2];
                    break;
                }
            }
        }
    }
}

- (NSMutableArray *)getBadServiceList {
    NSMutableArray *lineList = [[NSMutableArray alloc] init];
    for(NSMutableArray *line in _tubeStatus){
        if(![line[1] isEqualToString:@"Good Service"]){
            [lineList addObject:line[0]];
        }
    }
    return lineList;
}

- (NSString *)setUpSentance:(NSMutableArray *)linesWithDisruptions {
    if (linesWithDisruptions == nil){
        return @"A good service is running on all lines";
    }
    else if (linesWithDisruptions.count == 1){
        return [NSString stringWithFormat:@"The %@ line is disrupted, but a good service is running on all other lines", linesWithDisruptions[0]];
    } else {
        NSString *lineList = @"";
        for(int i = 0; i < linesWithDisruptions.count; i++){
            lineList = [lineList stringByAppendingString:linesWithDisruptions[i]];
            if(i < (linesWithDisruptions.count - 2)){
                lineList = [lineList stringByAppendingString:@", "];
            } else if (i == (linesWithDisruptions.count - 2)){
                lineList = [lineList stringByAppendingString:@", and "];
            }
        }
        return [NSString stringWithFormat:@"The %@ lines are disrupted, but a good service is running on all other lines", lineList];
    }

}

- (void)setUpLabel:(NSString *)labelText {
    _widgetLabel.textColor = [UIColor blackColor];
    _widgetLabel.text = labelText;
}

@end
