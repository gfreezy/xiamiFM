//
//  AppDelegate.m
//  XiamiFM
//
//  Created by Alex F on 11/10/12.
//  Copyright (c) 2012 Alex F. All rights reserved.
//
#import <AVFoundation/AVPlayerItem.h>
#import "AppDelegate.h"


@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    self.player = [[MusicPlayer alloc] init];
    [self.player addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:NULL];

    [self stopped];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"status"]) {
        Status o = (Status)[[change valueForKey:NSKeyValueChangeNewKey] integerValue];
        switch (o) {
            case ready:
                NSLog(@"ready");
                [self ready];
                break;
            case loading:
                NSLog(@"loading");
                [self loading];
                break;
            case playing:
                NSLog(@"playing");
                [self playing];
                break;
            case stopped:
                NSLog(@"stopped");
                [self stopped];
                break;
            case error:
                NSLog(@"error");
                [self reloadMusicPlayer];
                [self stopped];
                break;
        }
    }
}

- (void)ready {
    self.btnPlay.enabled = YES;
    self.btnStop.enabled = NO;
    self.btnNext.enabled = YES;
    self.btnPlay.title = @"Play";
}

- (void)loading {
    self.btnPlay.enabled = NO;
    self.btnPlay.title = @"Loading";
    self.btnStop.enabled = NO;
    self.btnNext.enabled = YES;
}

- (void)playing {
    self.btnPlay.enabled = YES;
    self.btnPlay.title = @"Pause";
    self.btnStop.enabled = YES;
    self.btnNext.enabled = YES;
}

- (void)stopped {
    self.btnPlay.enabled = YES;
    self.btnPlay.title = @"Play";
    self.btnStop.enabled = NO;
    self.btnNext.enabled = NO;
}

- (IBAction)play:(NSButton *)sender {
    if (self.player.status == playing) {
        [self.player pause];
    } else if (self.player.status == ready) {
        [self.player play];
    }
}

- (IBAction)stop:(NSButton *)sender {
    [self.player stop];
}

- (IBAction)next:(NSButton *)sender {
    [self.player next];
}

- (void)reloadMusicPlayer {
    [self.player removeObserver:self forKeyPath:@"status" context:NULL];
    self.player = [[MusicPlayer alloc] init];
    [self.player addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:NULL];
}
@end
