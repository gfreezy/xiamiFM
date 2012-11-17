//
//  Playlist.m
//  XiamiFM
//
//  Created by Alex F on 11/11/12.
//  Copyright (c) 2012 Alex F. All rights reserved.
//

#import "Playlist.h"
#import "PlaylistParser.h"

@implementation Playlist

- (id)init {
    if (self = [super init]) {
        [self fetchFromUpstream];
    }
    return self;
}

- (NSMutableArray *)playedList {
    if (!_playedList) {
        _playedList = [NSMutableArray arrayWithCapacity:20];
    }
    return _playedList;
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
        [self.playedList addObjectsFromArray:poped];

        return poped;
    }
    return @[];
}

- (void)fetchFromUpstream {
    NSString *fmURL = @"http://www.xiami.com/radio/xml/type/8/id/0";
    NSURLRequest *theRequest=[NSURLRequest requestWithURL:[NSURL URLWithString:fmURL]
                                              cachePolicy:NSURLRequestUseProtocolCachePolicy
                                          timeoutInterval:60.0];
    NSURLConnection *theConnection=[[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
    if (theConnection) {
        receivedData = [NSMutableData data];
    } else {
        NSLog(@"fetch from upstream failed");
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    [receivedData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [receivedData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    // inform the user
    NSLog(@"Connection failed! Error - %@ %@",
          [error localizedDescription],
          [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    PlaylistParser *parser = [[PlaylistParser alloc] initWithData:receivedData];
    [self.playingList addObjectsFromArray:parser.playlist];
    self.status = PlaylistNotEmptyAndIsReady;
}

@end
