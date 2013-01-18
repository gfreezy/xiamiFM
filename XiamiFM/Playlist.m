//
//  Playlist.m
//  XiamiFM
//
//  Created by Alex F on 11/11/12.
//  Copyright (c) 2012 Alex F. All rights reserved.
//

#import "Playlist.h"
#import "PlaylistParser.h"
#import <AFNetworking/AFXMLRequestOperation.h>

@implementation Playlist

- (id)init {
    if (self = [super init]) {
        [self fetchFromUpstream];
    }
    return self;
}

- (NSMutableArray *)playingList {
    if (!_playingList) {
        _playingList = [NSMutableArray arrayWithCapacity:20];
    }
    return _playingList;
}

- (PlaylistStatus)status {
    if (!_status) {
        _status = PlaylistEmpty;
    }
    return _status;
}

- (Track *)first {
    return [[self more:1] lastObject];
}

- (NSArray *)more:(NSUInteger)count {
    if (self.playingList.count < count && (self.status == PlaylistEmpty || self.status == PlaylistNotEmptyAndIsReady)) {
        // Only one load is allowed
        [self fetchFromUpstream];
        self.status = PlaylistNotEmptyAndIsLoading;
    }
    if (self.status == PlaylistNotEmptyAndIsReady) {
        NSRange range = NSMakeRange(0, count);
        NSArray *poped = [self.playingList subarrayWithRange:range];
        [self.playingList removeObjectsInRange:range];

        return poped;
    }
    return @[];
}

- (void)fetchFromUpstream {
    NSString *fmURL = @"http://www.xiami.com/radio/xml/type/8/id/0";
    NSURLRequest *theRequest=[NSURLRequest requestWithURL:[NSURL URLWithString:fmURL]
                                              cachePolicy:NSURLRequestUseProtocolCachePolicy
                                          timeoutInterval:60.0];
    
    AFXMLRequestOperation *operation = [AFXMLRequestOperation XMLParserRequestOperationWithRequest:theRequest success:^(NSURLRequest *request, NSHTTPURLResponse *response, NSXMLParser *XMLParser) {
        PlaylistParser *parser = [[PlaylistParser alloc] initWithXMLParser:XMLParser];
        [self.playingList addObjectsFromArray:parser.playlist];
        self.status = PlaylistNotEmptyAndIsReady;
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, NSXMLParser *XMLParser) {
        NSLog(@"error: %@", error);
    }];
    
    [operation start];
}

@end
