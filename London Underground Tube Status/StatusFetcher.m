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


@property (nonatomic, strong) NSMutableArray *weekendTubeArray;

@property (nonatomic, strong) NSMutableArray *lineArray;

@property (nonatomic, strong) NSMutableString *foundValue;

@property (nonatomic, strong) NSString *currentElement;

@property int elementCount;

@property int serviceReasonCount;

@property (nonatomic, strong) NSString *tflAppID;
@property (nonatomic, strong) NSString *tflAppKey;

@end

@implementation StatusFetcher

- (NSMutableArray *)getLiveTubeStatus {
    
    NSMutableArray *jsonArray = [self fetchTubeUpdate];
    NSMutableArray *newArray = [NSMutableArray array];
    for (int i=0; i < jsonArray.count; i++){
        NSMutableArray *rowArray = [NSMutableArray arrayWithCapacity:3];
        [rowArray insertObject:[jsonArray[i] objectForKey:@"name"] atIndex:0];
        [self checkForNames:rowArray];
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

- (void)checkForNames:(NSMutableArray *)rowArray{
    if ([rowArray[0] isEqualToString:@"London Overground"]){
        rowArray[0] = @"Overground";
    } else if ([rowArray[0] isEqualToString:@"Hammersmith & City"]){
        rowArray[0] = @"H'smith & City";
    }
}

- (NSMutableArray *)fetchTubeUpdate{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.tfl.gov.uk/Line/Mode/tube%%2Cdlr%%2Coverground%%2Ctram%%2Ctflrail%%2Ccable-car/Status?detail=false"]];
    //need to check if feed is empty/broken
    NSData *data = [NSData dataWithContentsOfURL:url];
    NSMutableArray *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:NULL];
    NSLog(@"%@", json);
    return json;
}

- (NSMutableArray *)getWeekendTubeStatus {
    
    return [self fetchWeekendTubeUpdate];
}

- (NSMutableArray *)fetchWeekendTubeUpdate{
    _tflAppID = @"312884b8";
    _tflAppKey = @"874b1c0f7b3986f47a809ccc5406a840";
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://data.tfl.gov.uk/tfl/syndication/feeds/TubeThisWeekend_v1.xml?app_id=%@&app_key=%@", self.tflAppID, self.tflAppKey]];
    
    NSXMLParser *parser = [[NSXMLParser alloc]initWithContentsOfURL:url];
    parser.delegate = self;
    [parser parse];
    
    return self.weekendTubeArray;
}

- (void) parserDidStartDocument:(NSXMLParser *)parser {
    NSLog(@"parserDidStartDocument");
    self.elementCount = 0;
    self.foundValue = [[NSMutableString alloc] init];
    self.weekendTubeArray = [[NSMutableArray alloc] init];
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
    NSLog(@"didStartElement --> %@", elementName);
    
    if ([elementName isEqualToString:@"Line"]) {
        self.lineArray = [NSMutableArray arrayWithCapacity:3];
        self.serviceReasonCount = 0;
    };
    self.currentElement = elementName;
}

-(void) parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    NSLog(@"foundCharacters --> %@", string);
    
    if ([self.currentElement isEqualToString:@"Name"] ||
        [self.currentElement isEqualToString:@"Text"]) {
        
        if (![string isEqualToString:@" "]) {
            [self.foundValue appendString:string];
        }
    }
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
    NSLog(@"didEndElement   --> %@", elementName);
    
    if ([elementName isEqualToString:@"Line"]) {
        // If the closing element equals to "Line" then the all the data of a line has been parsed and the dictionary should be added to the data array.
        [self.weekendTubeArray insertObject:self.lineArray atIndex:self.elementCount];
        self.elementCount++;
        self.serviceReasonCount = 0;
    }
    else if ([elementName isEqualToString:@"Name"]){
        // If the line name element was found then store it.
        
        [self.lineArray insertObject:[NSString stringWithString:self.foundValue] atIndex:0];
    }
    else if ([elementName isEqualToString:@"Text"]){
        if (self.serviceReasonCount == 0) {
            // If the toponym name element was found then store it.
            [self.lineArray insertObject:[NSString stringWithString:self.foundValue] atIndex:1];
        } else {
            [self.lineArray insertObject:[NSString stringWithString:self.foundValue] atIndex:2];
        }
        self.serviceReasonCount++;
    }
    
    // Clear the mutable string.
    [self.foundValue setString:@""];
}

- (void) parserDidEndDocument:(NSXMLParser *)parser {
    NSLog(@"parserDidEndDocument");
}
@end
