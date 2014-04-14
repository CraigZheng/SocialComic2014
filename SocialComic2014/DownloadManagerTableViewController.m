//
//  DownloadManagerTableViewController.m
//  SocialComic2014
//
//  Created by Craig on 11/04/2014.
//  Copyright (c) 2014 Craig. All rights reserved.
//

#import "DownloadManagerTableViewController.h"
#import "ZIPCentre.h"


@interface DownloadManagerTableViewController ()
@property ZIPCentre *zipCenre;
@property NSMutableArray *comics;
@end

@implementation DownloadManagerTableViewController
@synthesize zipCenre;
@synthesize comics;

- (void)viewDidLoad
{
    [super viewDidLoad];
    zipCenre = [ZIPCentre getInstance];
    comics = [NSMutableArray arrayWithArray:zipCenre.downloadingZip.array];
    [comics addObjectsFromArray:zipCenre.downloadQueue.array];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return comics.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"comic_cell_identifier" forIndexPath:indexPath];
    
    if (cell) {
        UIImageView *coverImageView = (UIImageView*)[cell viewWithTag:1];
        UILabel *titleLabel = (UILabel*)[cell viewWithTag:2];
        UITextView *descriptionTextView = (UITextView*)[cell viewWithTag:3];
        
        //assign properties of comic to this cell
        //name
        Comic *comic = [comics objectAtIndex:indexPath.row];
        titleLabel.text = comic.name;
        //cover
        if (comic.cover) {
            coverImageView.image = comic.cover;
            [coverImageView setAlpha:1.0];
        } else {
            [coverImageView setAlpha:0.5];
            coverImageView.image = [UIImage imageNamed:@"icon_144"];
        }
        //description
        if (comic.description.length > 0) {
            descriptionTextView.text = comic.description;
        }

    }
    return cell;
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
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
