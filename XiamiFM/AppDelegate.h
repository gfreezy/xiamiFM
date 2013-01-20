//
//  AppDelegate.h
//  XiamiFM
//
//  Created by Alex F on 11/10/12.
//  Copyright (c) 2012 Alex F. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class ASPlaylist;

@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *window;

@property (weak) IBOutlet NSButton *btnPlay;

@property (weak) IBOutlet NSButton *btnStop;

@property (weak) IBOutlet NSButton *btnNext;

@property (weak) IBOutlet NSTextField *labelStatus;

@property (weak) IBOutlet NSSlider *volumeSlider;

@property (strong, nonatomic) ASPlaylist *playlist;

@property (weak) IBOutlet NSSlider *progress;

- (IBAction)play:(NSButton *)sender;

- (IBAction)stop:(NSButton *)sender;

- (IBAction)next:(NSButton *)sender;

- (IBAction)volumeChanged:(NSSlider *)sender;

@end
