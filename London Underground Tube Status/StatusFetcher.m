//
//  StatusFetcher.m
//  London Underground Tube Status
//
//  Created by Rachel McGreevy on 21/01/2017.
//  Copyright © 2017 Rachel McGreevy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "StatusFetcher.h"

@interface StatusFetcher ()

@end

@implementation StatusFetcher

- (NSMutableArray *)getLiveTubeStatus {
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.tfl.gov.uk/Line/Mode/tube%%2Cdlr%%2Coverground%%2Ctram/Status?detail=false"]];
    NSData *data = [NSData dataWithContentsOfURL:url];
    NSMutableArray *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:NULL];
    NSLog(@"%@", json);
    return json;
}

@end
