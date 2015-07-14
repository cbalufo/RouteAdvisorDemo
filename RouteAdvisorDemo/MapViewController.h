//
//  MapViewController.h
//  RouteAdvisorDemo
//
//  Created by cbalufo on 27/5/15.
//  Copyright (c) 2015 DAMA-UPC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface MapViewController : UIViewController

@property (strong,nonatomic) NSString *idRou;
@property (strong, nonatomic) NSString *textRou;
@property (strong, nonatomic) NSString *orderRou;
@property(nonatomic, retain) CLLocationManager *locationManager;
@property (weak, nonatomic) IBOutlet UITableView *tableInstructions;

@end

@interface Information:NSObject
{
    NSString *description;
    long typePoi;
}

-(void) setDescription:(NSString *) descrip;
-(NSString *)getDescription;
-(void) setTypePoi:(long) type;
-(long) getTypePoi;

@end