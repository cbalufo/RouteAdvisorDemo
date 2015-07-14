//
//  RoutesTableViewController.h
//  RouteAdvisorDemo
//
//  Created by cbalufo on 27/5/15.
//  Copyright (c) 2015 DAMA-UPC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RoutesTableViewController : UITableViewController

@property (nonatomic,strong) NSMutableArray *dataSource;

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;

@end