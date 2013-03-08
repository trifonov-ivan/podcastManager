//
//  PodcastInfoCell.h
//  PodcastManager
//
//  Created by Ivan Trifonov on 08.03.13.
//  Copyright (c) 2013 Ivan Trifonov. All rights reserved.
//

#import <UIKit/UIKit.h>
@class PodcastViewController;
@interface PodcastInfoCell : UITableViewCell

@property (nonatomic,strong) IBOutlet UILabel *name;
@property (nonatomic,strong) IBOutlet UILabel *duration;
@property (nonatomic,strong) IBOutlet UILabel *state;
@property (nonatomic,strong) IBOutlet UIButton *playBtn;
@property (nonatomic,strong) IBOutlet UISwitch *downloadable;
@property (nonatomic,strong) IBOutlet UISwitch *local;

@property (nonatomic) PodcastViewController *controller;
@property (nonatomic,strong) NSDictionary *currentData;
@property (nonatomic,readwrite) BOOL playingState;

-(IBAction)buttonPressed:(id)sender;
-(IBAction)downChecked:(id)sender;
-(IBAction)localChecked:(id)sender;
-(void) updateAccordingToData:(NSDictionary*)data;
+ (PodcastInfoCell *)cellFromNibNamed:(NSString *)nibName;
@end
