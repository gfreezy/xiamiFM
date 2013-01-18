//
//  PlaylistParser.h
//  XiamiFM
//
//  Created by Alex F on 11/11/12.
//  Copyright (c) 2012 Alex F. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Track;

@interface PlaylistParser : NSObject <NSXMLParserDelegate> {
    NSMutableArray *trackList;
    Track *track;
    NSMutableString *currentValue;
}

@property (strong, nonatomic) NSXMLParser *parser;

@property (readonly) NSArray *playlist;

- (id)initWithData:(NSData *)data;

- (id)initWithXMLParser:(NSXMLParser *)XMLParser;

@end
