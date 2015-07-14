//
//  RoutesTableViewController.m
//  RouteAdvisorDemo
//
//  Created by cbalufo on 27/5/15.
//  Copyright (c) 2015 DAMA-UPC. All rights reserved.
//

#import <RouteAdvisorFrameWork/RouteAdvisor.h>
#import "RoutesTableViewController.h"
#import "MapViewController.h"


@implementation RoutesTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView setDelegate:self];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
    self.tableView.backgroundColor = [UIColor colorWithRed:.8 green:.8 blue:1 alpha:1];
    
     RouteAdvisor *g =  [[RouteAdvisor alloc] init];
     _dataSource = [g getAllFixRoute];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return _dataSource.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    // Configure the cell...
    
     FixRoute *f = [_dataSource objectAtIndex:indexPath.row];
     
     cell.textLabel.text=[f getDescription];
     //cell.textLabel.textAlignment = NSTextAlignmentCenter;
     cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
     cell.backgroundColor = [UIColor colorWithRed:.8 green:.8 blue:1 alpha:1];
     
     if (([f getIdRoute] == 1 || [f getIdRoute] == 2 || [f getIdRoute] == 3 || [f getIdRoute] == 4 || [f getIdRoute] == 5 || [f getIdRoute] == 6)){
     cell.imageView.image = [UIImage imageNamed:@"i_museum.png"];
     }else if (([f getIdRoute] == 7 || [f getIdRoute] == 8 || [f getIdRoute] == 9 || [f getIdRoute] == 10)){
     cell.imageView.image = [UIImage imageNamed:@"i_architecture.png"];
     }else if (([f getIdRoute] == 11 || [f getIdRoute] == 12 || [f getIdRoute] == 13 || [f getIdRoute] == 14)){
     cell.imageView.image = [UIImage imageNamed:@"i_art.png"];
     }else if (([f getIdRoute] == 15 || [f getIdRoute] == 16)){
     cell.imageView.image = [UIImage imageNamed:@"i_leisure.png"];
     }else if (([f getIdRoute] == 17 || [f getIdRoute] == 18 || [f getIdRoute] == 19 || [f getIdRoute] == 20 || [f getIdRoute] == 21 || [f getIdRoute] == 22 )){
     cell.imageView.image = [UIImage imageNamed:@"i_restaurant.jpg"];
     }else if (([f getIdRoute] == 23 || [f getIdRoute] == 24)){
     cell.imageView.image = [UIImage imageNamed:@"i_shopping.jpg"];
     }
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self performSegueWithIdentifier:@"mapsegue" sender:[tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath]];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    if ([[segue identifier] isEqualToString:@"mapsegue"]) {
        NSIndexPath *indexPath = nil;
        
        indexPath = [self.tableView indexPathForSelectedRow];
         FixRoute *f = [_dataSource objectAtIndex:indexPath.row];
         
         [[segue destinationViewController] setIdRou:[NSString stringWithFormat:@"%ld", [f getIdRoute]]];
         [[segue destinationViewController] setTextRou:[f getDescription]];
         [[segue destinationViewController] setOrderRou:[f getPoiOrder]];
        
    }
}


@end
