//
//  MusicPlayer.h
//  XiamiFM
//
//  Created by Alex F on 11/11/12.
//  Copyright (c) 2012 Alex F. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVPlayer.h>
#import "Playlist.h"

typedef enum {
    stopped = 0,
    loading,
    ready,
    playing,
    error,
} Status;

@interface MusicPlayer : NSObject {
    BOOL isPlaying;
}

@property (strong, nonatomic) AVQueuePlayer *queuePlayer;

@property (nonatomic) float volume;

@property (strong, nonatomic) Playlist *playlist;

@property (nonatomic) Status status;

- (void) play;

- (void) next;

- (void) stop;

- (void) pause;

- (void) volumeUp:(float)volume;

- (void) volumeDown:(float)volume;

@end
