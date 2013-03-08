//
//  PodcastInfoCell.m
//  PodcastManager
//
//  Created by Ivan Trifonov on 08.03.13.
//  Copyright (c) 2013 Ivan Trifonov. All rights reserved.
//

#import "PodcastInfoCell.h"
#import "PodcastViewController.h"
@implementation PodcastInfoCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setup];
    }
    return self;
}

- (id)init
{
    self = [super init];
    if (self) {
        [self setup];
    }
    return self;
}

-(id) initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setup];        
    }
    return self;
   
}

-(id) initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setup
{
    self.playingState = NO;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(otherPlayed:) name:PodcastPlayButtonClicked object:nil];
}

-(void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:PodcastPlayButtonClicked object:nil];
}

-(void) otherPlayed:(NSNotification*) ntf
{
    if ([_currentData[@"name"] isEqualToString:ntf.object])
    {
        self.playingState = YES;
        [_playBtn setTitle:@"stop" forState:UIControlStateNormal];
    }
    else
    {
        self.playingState = NO;
        [_playBtn setTitle:@"play" forState:UIControlStateNormal];
    }
}

-(IBAction)buttonPressed:(id)sender
{
    if (!self.playingState)
    {
        [self.controller playClickedFor:_currentData[@"name"] local:_local.on download:_downloadable.on];
    }
    else
    {
        self.playingState = NO;
        [_playBtn setTitle:@"play" forState:UIControlStateNormal];
        [self.controller stopClickedFor:_currentData[@"name"]];
    }
}
-(IBAction)downChecked:(id)sender
{
    _local.enabled = !_downloadable.enabled;
}
-(IBAction)localChecked:(id)sender
{
    _downloadable.enabled = !_local.on;
}

-(void) setPlayingState:(BOOL)playingState
{
    _playingState = playingState;
    if (playingState)
    {
        _local.enabled = NO;
        _downloadable.enabled = NO;
    }
}
-(void) updateAccordingToData:(NSDictionary*)data
{
    _currentData = data;
    self.name.text = data[@"name"];
    int a = [data[@"localtime"] intValue];
    self.duration.text = [NSString stringWithFormat:@"%02d:%02d", a/60, a%60];
    switch ([data[@"availability"] intValue]) {
        case -1:
            self.state.text = @"0";
            break;
        case 0:
            self.state.text = @"-";
            break;
        case 1:
            self.state.text = @"+";
            break;
            
        default:
            break;
    }
}


+ (PodcastInfoCell *)cellFromNibNamed:(NSString *)nibName
{
    NSArray *nibContents = [[NSBundle mainBundle] loadNibNamed:nibName owner:self options:NULL];
    NSEnumerator *nibEnumerator = [nibContents objectEnumerator];
    PodcastInfoCell *customCell = nil;
    NSObject* nibItem = nil;
    while ((nibItem = [nibEnumerator nextObject]) != nil)
    {
        if ([nibItem isKindOfClass:[PodcastInfoCell class]])
        {
            customCell = (PodcastInfoCell *)nibItem;
            break; // we have a winner
        }
    }
    return customCell;
}

@end
