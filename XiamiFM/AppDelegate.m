//
//  AppDelegate.m
//  XiamiFM
//
//  Created by Alex F on 11/10/12.
//  Copyright (c) 2012 Alex F. All rights reserved.
//
#import <AVFoundation/AVPlayerItem.h>
#import <AFNetworking/AFXMLRequestOperation.h>
#import "AppDelegate.h"
#import "ASPlaylist.h"
#import "PlaylistParser.h"
#import "Track.h"


@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    self.playlist = [[ASPlaylist alloc] init];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playlistError:) name:ASStreamError object:self.playlist];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playlistRunningOutOfSong:) name:ASRunningOutOfSongs object:self.playlist];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playlistRunningOutOfSong:) name:ASNoSongsLeft object:self.playlist];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(newSongPlaying:) name:ASNewSongPlaying object:self.playlist];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(createdNewSteam:) name:ASCreatedNewStream object:self.playlist];
    [self fetchMoreSongs];
    [self.playlist setVolume:1];
    [self disable];
    
    [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(oneSecondTick:) userInfo:nil repeats:YES];
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
}

- (void)playlistError:(NSNotification *)notification {
    NSAssert([notification object] == self.playlist,
             @"Should only receive notifications for the current playlist");
    NSLog(@"error");
}

- (void)playlistRunningOutOfSong:(NSNotification *)notification {
    [self fetchMoreSongs];
}

- (void)newSongPlaying:(NSNotification *)notification {
    
}

- (void)createdNewSteam:(NSNotification *)notification {
    [self ready];
}

- (void)oneSecondTick:(NSTimer *)timer {
    double p;
    BOOL ret = [self.playlist progress:&(p)];
    if (!ret) {
        return;
    }
    
    [NSAnimationContext beginGrouping];
    [[NSAnimationContext currentContext] setDuration:0.1];
    [[self.progress animator] setDoubleValue:p];
    [NSAnimationContext endGrouping];
}

- (void)fetchMoreSongs {
    NSString *fmURL = @"http://www.xiami.com/radio/xml/type/8/id/0";
    NSURLRequest *theRequest=[NSURLRequest requestWithURL:[NSURL URLWithString:fmURL]
                                              cachePolicy:NSURLRequestUseProtocolCachePolicy
                                          timeoutInterval:60.0];
    
    AFXMLRequestOperation *operation = [AFXMLRequestOperation XMLParserRequestOperationWithRequest:theRequest success:^(NSURLRequest *request, NSHTTPURLResponse *response, NSXMLParser *XMLParser) {
        PlaylistParser *parser = [[PlaylistParser alloc] initWithXMLParser:XMLParser];
        for (Track *track in parser.playlist) {
            [self.playlist addSong:[NSURL URLWithString:track.realLocation] play:NO];
            NSLog(@"add Track: %@", track.realLocation);
        }
        [self ready];
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, NSXMLParser *XMLParser) {
        NSLog(@"error: %@", error);
    }];

    [operation start];
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

- (void)disable {
    self.btnPlay.enabled = NO;
    self.btnPlay.title = @"Play";
    self.btnStop.enabled = NO;
    self.btnNext.enabled = NO;
}

- (IBAction)play:(NSButton *)sender {
    if (self.playlist.isPlaying) {
        [self.playlist pause];
        [self stopped];
    } else {
        [self.playlist play];
        [self playing];
    }
}

- (IBAction)stop:(NSButton *)sender {
    [self.playlist stop];
    [self stopped];
}

- (IBAction)next:(NSButton *)sender {
    [self.playlist next];
}

- (IBAction)volumeChanged:(NSSlider *)sender {
    NSLog(@"slider changed: %d", self.volumeSlider.intValue);
    [self.playlist setVolume:[self.volumeSlider doubleValue]/100];
}
@end
