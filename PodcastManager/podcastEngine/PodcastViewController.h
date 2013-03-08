//
//  PodcastViewController.h
//  PodcastManager
//
//  Created by Ivan Trifonov on 08.03.13.
//  Copyright (c) 2013 Ivan Trifonov. All rights reserved.
//

#import <UIKit/UIKit.h>

#define PodcastPlayButtonClicked @"podcast_play_button_clicked"

@interface PodcastViewController : UITableViewController
{
    NSMutableDictionary *podcastsInfo;
    NSArray *keysInfo;
}

-(void)playClickedFor:(NSString*)name local:(BOOL)local download:(BOOL)download;
-(void)stopClickedFor:(NSString*)name;
@end
