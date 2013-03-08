//
//  PodcastViewController.m
//  PodcastManager
//
//  Created by Ivan Trifonov on 08.03.13.
//  Copyright (c) 2013 Ivan Trifonov. All rights reserved.
//

#import "PodcastViewController.h"
#import "PodcastEngine.h"
#import "PodcastInfoCell.h"
@interface PodcastViewController ()

@end

@implementation PodcastViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    podcastsInfo = [[NSMutableDictionary alloc] init];
    for (NSString *name in [[PodcastEngine sharedEngine] availablePodcasts])
    {
        podcastsInfo[name]=[[PodcastEngine sharedEngine] getInitialPodcastInfo:name];
        podcastsInfo[name][@"attempts"] = @3;
        [[PodcastEngine sharedEngine] testPodcastForAvailability:name target:self method:@selector(testResultsFetched:)];
    }
    keysInfo = [[PodcastEngine sharedEngine] availablePodcasts];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

-(void) reTest:(NSString*) name
{
    [[PodcastEngine sharedEngine] testPodcastForAvailability:name target:self method:@selector(testResultsFetched:)];
}

-(void) testResultsFetched:(NSDictionary*)data
{
    if (![data[@"availability"] intValue])
    {
        int att=[podcastsInfo[data[@"name"]][@"attempts"] intValue]-1;
        if (att)
        {
            podcastsInfo[data[@"name"]][@"attempts"]=@(att);
            [self performSelector:@selector(reTest:) withObject:data[@"name"] afterDelay:2];
            return;
        }
    }
    podcastsInfo[data[@"name"]][@"availability"]=data[@"availability"];
    PodcastInfoCell *cell = (PodcastInfoCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:[keysInfo indexOfObject:data[@"name"]] inSection:0]];
    if (cell)
        [cell updateAccordingToData:podcastsInfo[data[@"name"]]];
}

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 96;
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [[PodcastEngine sharedEngine] availablePodcasts].count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"PodcastCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
        {
            cell = [PodcastInfoCell cellFromNibNamed:@"PodcastInfoCell_iPhone"];
        }
        else
        {
            cell = [PodcastInfoCell cellFromNibNamed:@"PodcastInfoCell_iPad"];
        }
        
    }
    [(PodcastInfoCell*)cell setController:self];
    [(PodcastInfoCell*)cell updateAccordingToData:podcastsInfo[keysInfo[indexPath.row]]];
    // Configure the cell...
    
    return cell;
}

-(void)playClickedFor:(NSString*)name local:(BOOL)local download:(BOOL)download
{
    [[PodcastEngine sharedEngine] startPlayingPodcast:name local:local downloading:download];
    [[NSNotificationCenter defaultCenter] postNotificationName:PodcastPlayButtonClicked object:name];
}

-(void)stopClickedFor:(NSString*)name
{
    [[PodcastEngine sharedEngine] endCurrentPodcast];
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/  

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

@end
