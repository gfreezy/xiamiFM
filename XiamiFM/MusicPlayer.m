//
//  MusicPlayer.m
//  XiamiFM
//
//  Created by Alex F on 11/11/12.
//  Copyright (c) 2012 Alex F. All rights reserved.
//

#import <AVFoundation/AVPlayerItem.h>
#import <CoreMedia/CMTime.h>
#import "MusicPlayer.h"
#import "Track.h"


@implementation MusicPlayer

- (id)init {
    if (self = [super init]) {
        isPlaying = NO;
        self.playlist = [[Playlist alloc] init];
        [self.playlist addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:NULL];
    }
    return self;
}

- (AVQueuePlayer *)queuePlayer {
    if (!_queuePlayer) {
        _queuePlayer = [[AVQueuePlayer alloc] init];
        [_queuePlayer addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:NULL];
    }
    return _queuePlayer;
}

- (Status)status {
    if (!_status) {
        _status = stopped;
    }
    return _status;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (![keyPath isEqualToString:@"status"]) {
        return;
    }
    NSUInteger value = [[change valueForKey:NSKeyValueChangeNewKey] unsignedIntegerValue];
    
    if(object == self.playlist) {
        if((PlaylistStatus)value == PlaylistNotEmptyAndIsReady) {
            NSLog(@"playlist load ready");
            [self loadMoreTracks];
        }
    }
    
    else if (object == self.queuePlayer) {
        if((AVPlayerStatus)value == AVPlayerStatusFailed) {
            NSLog(@"queue player error: %@", self.queuePlayer.error);
            self.status = error;
        }
    }
    
    else {
        if ((AVPlayerItemStatus)value == AVPlayerStatusReadyToPlay) {
            NSLog(@"playitem status ready");
            self.status = ready;
            if (isPlaying) {
                self.status = playing;
            }
        }
        else if((AVPlayerItemStatus)value == AVPlayerStatusFailed) {
            NSLog(@"playitem status error");
            [self next];
        } else {
            NSLog(@"playitem status other: %lu", value);
        }
    }
}

- (void)play {
    if (self.queuePlayer.items.count <= 1) {
        [self loadMoreTracks];
        self.status = loading;
    }

    if (self.queuePlayer.items.count >= 1 && self.status == ready) {
        [self.queuePlayer play];
        self.status = playing;
        isPlaying = YES;
    } else {
        self.status = loading;
    }
}

- (void)next {
    @try {
        [self.queuePlayer.currentItem removeObserver:self forKeyPath:@"status" context:NULL];
    }
    @catch (NSException *exception) {
        ;
    }
    
    if (self.queuePlayer.items.count <= 1) {
        [self loadMoreTracks];
    }
    
    self.status = loading;
    
    [self.queuePlayer advanceToNextItem];
    [self.queuePlayer.currentItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:NULL ];

    switch (self.queuePlayer.currentItem.status) {
        case AVPlayerItemStatusReadyToPlay:
            NSLog(@"playitem status ready immediately");
            self.status = isPlaying ? playing: ready;
            break;
        case AVPlayerItemStatusFailed:
            NSLog(@"playitem status failed immediately");
            [self next];
        default:
            break;
    }
}

- (void)stop {
    [self pause];
    [self.queuePlayer seekToTime:kCMTimeZero];
}

- (void)pause {
    [self.queuePlayer pause];
    self.status = ready;
    isPlaying = NO;
}

- (float) volume {
    return self.queuePlayer.volume;
}

- (void)setVolume:(float)volume {
    self.queuePlayer.volume = volume;
}

- (void)volumeDown:(float)volume {
    self.volume -= volume;
}

- (void)volumeUp:(float)volume {
    self.volume += volume;
}

- (void)loadMoreTracks {
    [self addTracks:[self.playlist more:5]];
}

- (void)addTrack:(Track *)track {
    NSURL *url = [NSURL URLWithString:track.realLocation];
    AVPlayerItem *item = [AVPlayerItem playerItemWithURL:url];
    if ([self.queuePlayer canInsertItem:item afterItem:nil]) {
        if (self.queuePlayer.items.count == 0) {
            [item addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:NULL];
        }
        [self.queuePlayer insertItem:item afterItem:nil];
    }
}

- (void) addTracks:(NSArray *)tracks {
    for (Track *track in tracks) {
        [self addTrack:track];
    }
}

@end
