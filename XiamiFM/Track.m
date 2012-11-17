//
//  Track.m
//  XiamiFM
//
//  Created by Alex F on 11/11/12.
//  Copyright (c) 2012 Alex F. All rights reserved.
//

#import "Track.h"

// helper function to get around out of index error of array
NSRange makeRange(NSUInteger, NSUInteger, NSUInteger);

@implementation Track

- (NSString *)description {
    return [NSString stringWithFormat: @"Track<SongName='%@', SongID='%@', AlbumID='%@', AlbumCover='%@', AlbumName='%@', ArtistName='%@', ArtistID='%@', Grade='%@', Location='%@', RealLocation='%@'>",
            self.songName, self.songID, self.albumID, self.albumCover, self.albumName, self.artistName, self.artistID, self.grade, self.location, self.realLocation];
}

- (NSString *)realLocation {
    if (!_realLocation) {
        _realLocation = [self decode:self.location];
    }
    return _realLocation;
}

- (NSString *)decode:(NSString *)string {
    NSInteger totle = [[string substringWithRange:makeRange(0, 1, string.length)] integerValue];
    NSString *newString = [string substringFromIndex:1];
    NSInteger chu = (int)(floor(newString.length / (float)totle));
    NSInteger yu = newString.length % totle;
    NSMutableArray *stor = [NSMutableArray arrayWithCapacity:10];
    
    NSInteger i, j;
    for (i = 0; i < yu; i++) {
        [stor addObject:[newString substringWithRange:makeRange((chu+1)*i, chu+1, newString.length)]];
    }
    
    for (i = yu; i < totle; i++) {
        [stor addObject:[newString substringWithRange:makeRange(chu*(i-yu)+(chu+1)*yu, chu, newString.length)]];
    }

    NSString *pinString = @"";
    for (i = 0; i< [[stor objectAtIndex:0] length]; i++) {
        for (j = 0; j < stor.count; j++) {
            NSString *temp = [stor objectAtIndex:j];
            
            pinString = [pinString stringByAppendingString:
                         [temp substringWithRange:makeRange(i, 1, temp.length)]];
        }
    }

    NSString *returnString = @"";
    pinString = [pinString stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    for (i = 0; i < pinString.length; i++) {
        if ([[pinString substringWithRange:makeRange(i, 1, pinString.length)] isEqualToString:@"^"]) {
            returnString = [returnString stringByAppendingString:@"0"];
        } else {
            returnString = [returnString stringByAppendingString:[pinString substringWithRange:makeRange(i, 1, pinString.length)]];
        }
    }
    
    return returnString;
}

@end


NSRange makeRange(NSUInteger loc, NSUInteger len, NSUInteger count) {
    if (loc + len > count) {
        len = count - loc;
    }
    return NSMakeRange(loc, len);
}

