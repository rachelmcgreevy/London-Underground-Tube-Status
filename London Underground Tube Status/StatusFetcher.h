//
//  StatusFetcher.h
//  London Underground Tube Status
//
//  Created by Rachel McGreevy on 21/01/2017.
//  Copyright © 2017 Rachel McGreevy. All rights reserved.
//
#import <UIKit/UIKit.h>

@interface StatusFetcher : NSObject <NSXMLParserDelegate>

- (NSMutableArray *)getLiveTubeStatus;
- (NSMutableArray *)getWeekendTubeStatus;

@end
