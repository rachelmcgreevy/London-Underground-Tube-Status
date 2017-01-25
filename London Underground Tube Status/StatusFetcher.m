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
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.tfl.gov.uk/Line/Mode/tube%%2Cdlr%%2Coverground%%2Ctram%%2Ctflrail%%2Ccable-car/Status?detail=false"]];
    NSData *data = [NSData dataWithContentsOfURL:url];
    NSMutableArray *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:NULL];
    NSLog(@"%@", json);
    return json;
}

- (NSMutableArray *)getWeekendTubeStatus {
    
    NSMutableArray *jsonArray = [self fetchWeekendTubeUpdate];
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

- (NSMutableArray *)fetchWeekendTubeUpdate{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://data.tfl.gov.uk/tfl/syndication/feeds/TubeThisWeekend_v1.xml?app_id=&app_key="]];
    NSData *data = [NSData dataWithContentsOfURL:url];
    
    
    NSXMLParser *parser = [[NSXMLParser alloc]initWithContentsOfURL:url];
    parser.delegate = self;
    [parser parse];
    
    
    NSMutableArray *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:NULL];
    NSLog(@"%@", json);
    return json;
}
- (void) parserDidStartDocument:(NSXMLParser *)parser {
    NSLog(@"parserDidStartDocument");
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
    NSLog(@"didStartElement --> %@", elementName);
}

-(void) parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    NSLog(@"foundCharacters --> %@", string);
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
    NSLog(@"didEndElement   --> %@", elementName);
}

- (void) parserDidEndDocument:(NSXMLParser *)parser {
    NSLog(@"parserDidEndDocument");
}

@end
