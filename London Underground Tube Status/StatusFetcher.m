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
    
    NSMutableArray *jsonArray = [self fetchTubeUpdate];
    NSMutableArray *newArray = [NSMutableArray array];
    for (int i=0; i < jsonArray.count; i++){
        NSMutableArray *rowArray = [NSMutableArray arrayWithCapacity:3];
        [rowArray insertObject:[jsonArray[i] objectForKey:@"name"] atIndex:0];
        [rowArray insertObject:[[jsonArray[i] objectForKey:@"lineStatuses"][0] objectForKey:@"statusSeverityDescription"] atIndex:1];
        if ([[jsonArray[i] objectForKey:@"lineStatuses"][0] objectForKey:@"reason"] != nil)
        {
            [rowArray insertObject:[[jsonArray[i] objectForKey:@"lineStatuses"][0] objectForKey:@"reason"] atIndex:2];
        } else {
            [rowArray insertObject:@" " atIndex:2];
        }
        [newArray insertObject:rowArray atIndex:i];
    }
    NSLog(@"%@", newArray);
    return newArray;
}

- (NSMutableArray *)fetchTubeUpdate{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.tfl.gov.uk/Line/Mode/tube%%2Cdlr%%2Coverground%%2Ctram/Status?detail=false"]];
    NSData *data = [NSData dataWithContentsOfURL:url];
    NSMutableArray *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:NULL];
    NSLog(@"%@", json);
    return json;
}

@end
