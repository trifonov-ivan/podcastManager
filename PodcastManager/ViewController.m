//
//  ViewController.m
//  PodcastManager
//
//  Created by Ivan Trifonov on 08.03.13.
//  Copyright (c) 2013 Ivan Trifonov. All rights reserved.
//

#import "ViewController.h"
#import "PodcastViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
//    for (NSString *name in [[PodcastEngine sharedEngine] availablePodcasts])
//    {
//        [[PodcastEngine sharedEngine] testPodcastForAvailability:name target:self method:@selector(test:)];
//    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction) buttonPressed
{
    PodcastViewController *vc = nil;
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
    {
        vc = [[PodcastViewController alloc] initWithNibName:@"PodcastViewController_iPhone" bundle:nil];
    }
    else
    {
        vc = [[PodcastViewController alloc] initWithNibName:@"PodcastViewController_iPad" bundle:nil];        
    }
    [self.navigationController pushViewController:vc animated:YES];
}

@end
