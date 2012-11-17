//
//  Track.h
//  XiamiFM
//
//  Created by Alex F on 11/11/12.
//  Copyright (c) 2012 Alex F. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Track : NSObject

@property (strong) NSString *songName;

@property (strong) NSString *songID;

@property (strong) NSString *albumID;

@property (strong) NSString *albumCover;

@property (strong) NSString *albumName;

@property (strong) NSString *artistName;

@property (strong) NSString *artistID;

@property (strong) NSString *grade;

@property (strong) NSString *location;

@property (strong, nonatomic) NSString *realLocation;

@end
