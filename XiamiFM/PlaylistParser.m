//
//  PlaylistParser.m
//  XiamiFM
//
//  Created by Alex F on 11/11/12.
//  Copyright (c) 2012 Alex F. All rights reserved.
//

#import "PlaylistParser.h"
#import "Track.h"

@implementation PlaylistParser

- (id)initWithData:(NSData *)data {
    if (self = [super init]) {
        _parser = [[NSXMLParser alloc] initWithData:data];
        [self parse];
    }
    return self;
}

- (id)initWithXMLParser:(NSXMLParser *)XMLParser {
    if (self = [super init]) {
        _parser = XMLParser;
        [self parse];
    }
    return self;
}

- (void)parse {
    [self.parser setDelegate:self];
//    [self.parser setShouldResolveExternalEntities:YES];
    [self.parser parse];
}

- (NSArray *)playlist {
    return [trackList copy];
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
    if ([elementName isEqualToString:@"trackList"]) {
        if (!trackList) {
            trackList = [[NSMutableArray alloc] init];
        }
    }
    if ([elementName isEqualToString:@"track"]) {
        if (!track) {
            track = [[Track alloc] init];
        }
    }
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    if (!currentValue) {
        currentValue = [[NSMutableString alloc] initWithCapacity:50];
    }
    [currentValue appendString:string];
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
    NSString *value = [currentValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if ([elementName isEqualToString:@"song_name"]) {
        track.songName = value;
    } else if ([elementName isEqualToString:@"song_id"]) {
        track.songID = value;
    } else if ([elementName isEqualToString:@"album_id"]) {
        track.albumID = value;
    } else if ([elementName isEqualToString:@"album_name"]) {
        track.albumName = value;
    } else if ([elementName isEqualToString:@"album_cover"]) {
        track.albumCover = value;
    } else if ([elementName isEqualToString:@"artist_id"]) {
        track.artistID = value;
    } else if ([elementName isEqualToString:@"artist_name"]) {
        track.artistName = value;
    } else if ([elementName isEqualToString:@"grade"]) {
        track.grade = value;
    } else if ([elementName isEqualToString:@"location"]) {
        track.location = value;
    } else if ([elementName isEqualToString:@"track"]) {
        [trackList addObject:track];
        track = nil;
    }
    [currentValue setString:@""];
}
@end
