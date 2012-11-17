//
//  Playlist.h
//  XiamiFM
//
//  Created by Alex F on 11/11/12.
//  Copyright (c) 2012 Alex F. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Track.h"

typedef enum {
    PlaylistEmpty = 0,
    PlaylistEmptyAndIsLoading,
    PlaylistNotEmptyAndIsReady,
    PlaylistNotEmptyAndIsLoading,
}PlaylistStatus;

@interface Playlist : NSObject {
    NSMutableData *receivedData;
}

@property (strong, nonatomic) NSMutableArray *playedList;

@property (strong, nonatomic) NSMutableArray *playingList;

@property (nonatomic) PlaylistStatus status;

- (NSArray *)more:(NSUInteger)count;

- (void) fetchFromUpstream;

@end
