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
    [NSEvent addGlobalMonitorForEventsMatchingMask:(NSKeyDownMask|NSSystemDefinedMask) handler:^(NSEvent *event) {
        if (event.type == NSSystemDefined) {
            // the following code is from http://weblog.rogueamoeba.com/2007/09/29/apple-keyboard-media-key-event-handling/
            int keyCode = (event.data1 & 0xFFFF0000) >> 16;
            int keyFlags = ([event data1] & 0x0000FFFF);
            int keyDown = (((keyFlags & 0xFF00) >> 8)) == 0xB;  //0xA is keyup, 0xB is keydown
            if (keyDown) {
                switch (keyCode) {
                    case 19:    //next key
                        [self next:nil];
                        break;
                    case 16:    // play or stop key
                        [self play:nil];
                        break;
                    case 20:  // prev key
                        break;
                    default:
                        break;
                }
            }
        }
    }];
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
