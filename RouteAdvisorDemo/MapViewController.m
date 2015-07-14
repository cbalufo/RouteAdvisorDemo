//
//  MapViewController.m
//  RouteAdvisorDemo
//
//  Created by cbalufo on 27/5/15.
//  Copyright (c) 2015 DAMA-UPC. All rights reserved.
//
#import "MapViewController.h"
#import <MapKit/MapKit.h>
#import "Pin.h"
#import <RouteAdvisorFrameWork/RouteAdvisor.h>

@interface MapViewController ()

@property (strong, nonatomic) IBOutlet MKMapView *mymap;
@property (nonatomic, strong) NSMutableArray *allPins;
@property (nonatomic, strong) MKPolylineView *lineView;
@property (nonatomic, strong) MKPolyline *polyline;
@property (nonatomic, strong) RouteAdvisor *ra;
@property (nonatomic, strong) NSMutableArray *allAnnotations;
@property (nonatomic, strong) NSMutableArray *allInstructions;

@end

@implementation Information

-(void) setDescription:(NSString *) descrip {
    description = [[NSString alloc]initWithString: descrip];
}
-(NSString *)getDescription{
    return description;
}

-(void) setTypePoi:(long) type {
    typePoi = type;
}
-(long) getTypePoi{
    return typePoi;
}

@end

@implementation MapViewController

#define IS_OS_8_OR_LATER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
#define FROM_TEXT @"From POI: "
#define TO_TEXT @"To POI: "
#define LANGUAGE @"en"
#define ROUTE_TEXT @"Route: "


+(NSMutableArray *)orderPoiFixRoute:(NSMutableArray *) arrayFixRoutes: (NSString *) orderForNodes{
    
    NSMutableArray *orderNodes = [[NSMutableArray alloc]init];
    NSMutableArray *arrayOrder = [orderForNodes componentsSeparatedByString:@"-"];

    for (NSString* idN in arrayOrder) {
        for (FixRoute* rou in arrayFixRoutes) {
            //NSString *i = [NSString stringWithFormat:@"%ld",[rou getIdRoute]];
            long l = [idN longLongValue];
            long l2 = [rou getIdRoute];
            if (l == l2){
                [orderNodes addObject:rou];
            }
        }
    }
    
    return orderNodes;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = [NSString stringWithFormat:@"%@ %@", ROUTE_TEXT, self.textRou];
    
    self.allPins = [[NSMutableArray alloc]init];
    self.allInstructions = [[NSMutableArray alloc]init];
    
     RouteAdvisor *g =  [[RouteAdvisor alloc] init];
     // init the graph dataBase
     [g initGraph];
     _ra=g;
     
     // get the list of POI for selected Route
     NSMutableArray *fixRouteNotOrder = [_ra getFixRoute:[self.idRou longLongValue]];
    
    
    NSMutableArray *fixRoute = [[NSMutableArray alloc]init];
    NSMutableArray *arrayOrder = [self.orderRou componentsSeparatedByString:@"-"];
    
    for (NSString* idN in arrayOrder) {
        for (POI* rou in fixRouteNotOrder) {
            //NSString *i = [NSString stringWithFormat:@"%ld",[rou getIdRoute]];
            long l = [idN longLongValue];
            long l2 = [rou getIdPOI];
            if (l == l2){
                [fixRoute addObject:rou];
            }
        }
    }

    
    
    
    
   // NSMutableArray *fixRoute2 = [MapViewController orderPoiFixRoute:fixRoute :self.orderRou];
    
     //dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
     
     if ([fixRoute count]>1){
     
     _allAnnotations = fixRoute;
     
     //TODO cambiar el idPoi por el nombre del POI
     // The name of first poi of selected route
     NSString *OrigText = [NSString stringWithFormat:@"%@ %@", FROM_TEXT, [NSString stringWithFormat: @"%@",[[fixRoute objectAtIndex:0] getTitle]]];
     
     Information *OrigInfo = [[Information alloc] init];
     [OrigInfo setDescription:OrigText];
     [OrigInfo setTypePoi:0];
     [self.allInstructions addObject:OrigInfo];
     
     for (NSUInteger i = 0 ; i < [fixRoute count]-1; i++) {
     //use each pair of pois
     POI *pStart = [fixRoute objectAtIndex:i];
     POI *pEnd = [fixRoute objectAtIndex:i+1];
     
     NSMutableArray *a = [_ra getDrawPoi:[pStart getLatitude] :[pStart getLongitude] :[pEnd getLatitude] :[pEnd getLongitude]];
     NSMutableArray *i = [_ra getInstructions:[pStart getLatitude] :[pStart getLongitude] :[pEnd getLatitude] :[pEnd getLongitude]:LANGUAGE];
     
     for (Coordinate* coord in a) {
     CLLocationCoordinate2D c = CLLocationCoordinate2DMake([coord getLatitude], [coord getLongitude]);
     Pin *newPin = [[Pin alloc]initWithCoordinate:c];
     [self.allPins addObject:newPin];
     }
     
     for (InstructionMap* inst in i) {
     Information *info = [[Information alloc] init];
     [info setDescription:[inst getDescription]];
     [info setTypePoi:1];
     [self.allInstructions addObject:info];
     }
     
     // The name of destination poi of selected route
     NSString *DestText = [NSString stringWithFormat:@"%@ %@", TO_TEXT,
     [NSString stringWithFormat: @"%@",[pEnd getTitle]]];
     
     Information *DestInfo = [[Information alloc] init];
     [DestInfo setDescription:DestText];
     [DestInfo setTypePoi:0];
     [self.allInstructions addObject:DestInfo];
     
     }
     
     }
    
    [self drawLineSubroutine];
    
    _mymap.delegate = self;
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    
#ifdef __IPHONE_8_0
    if(IS_OS_8_OR_LATER) {
        [self.locationManager requestAlwaysAuthorization];
    }
#endif
    
    [self.locationManager startUpdatingLocation];
    
    _mymap.showsUserLocation = YES;
    [_mymap setMapType:MKMapTypeStandard];
    [_mymap setZoomEnabled:YES];
    [_mymap setScrollEnabled:YES];
    
    self.tableInstructions.dataSource = self;
    self.tableInstructions.delegate = self;
    
    
    [self.tableInstructions registerClass:[UITableViewCell class] forCellReuseIdentifier:@"CellInst"];
    
    [self.tableInstructions reloadData];
}

- (void)addPin:(UIGestureRecognizer *)recognizer {
    
    if (recognizer.state != UIGestureRecognizerStateBegan) {
        return;
    }
    
    // convert touched position to map coordinate
    CGPoint userTouch = [recognizer locationInView:self.mymap];
    CLLocationCoordinate2D mapPoint = [self.mymap convertPoint:userTouch toCoordinateFromView:self.mymap];
    
    // and add it to our view and our array
    Pin *newPin = [[Pin alloc]initWithCoordinate:mapPoint];
    [self.mymap addAnnotation:newPin];
    [self.allPins addObject:newPin];
    
    [self drawLines:self];
    
}

- (IBAction)drawLines:(id)sender {
    
    [self drawLineSubroutine];
    
}

- (IBAction)undoLastPin:(id)sender {
    
    // grab the last Pin and remove it from our map view
    Pin *latestPin = [self.allPins lastObject];
    [self.mymap removeAnnotation:latestPin];
    [self.allPins removeLastObject];
    
    // redraw the polyline
    [self drawLines:self];
}

- (void)drawLineSubroutine {
    
    // remove polyline if one exists
    [self.mymap removeOverlay:self.polyline];
    
    // create an array of coordinates from allPins
    CLLocationCoordinate2D coordinates[self.allPins.count];
    int i = 0;
    for (Pin *currentPin in self.allPins) {
        coordinates[i] = currentPin.coordinate;
        i++;
    }
    
    // create a polyline with all cooridnates
    MKPolyline *polyline = [MKPolyline polylineWithCoordinates:coordinates count:self.allPins.count];
    [self.mymap addOverlay:polyline];
    self.polyline = polyline;
    
    // create an MKPolylineView and add it to the map view
    self.lineView = [[MKPolylineView alloc]initWithPolyline:self.polyline];
    self.lineView.strokeColor = [UIColor redColor];
    self.lineView.lineWidth = 3;
    
    //   // number of polyline draw
    // self.title = [[NSString alloc]initWithFormat:@"%lu", (unsigned long)self.mymap.overlays.count];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:YES];
    
    self.locationManager.distanceFilter = kCLDistanceFilterNone;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [self.locationManager startUpdatingLocation];
    
     for (POI* p in _allAnnotations) {
     CLLocationCoordinate2D point;
     point.latitude = [p getLatitude];
     point.longitude = [p getLongitude];
     MKPointAnnotation *annotationPoint = [[MKPointAnnotation alloc] init];
     annotationPoint.coordinate = point;
     //TODO fill with the information of POI
     annotationPoint.title = [p getTitle];
     annotationPoint.subtitle = [p getSubtitle];
     [_mymap addAnnotation:annotationPoint];
     }
     
     if ([_allAnnotations count]>0){
     
     // center the map  in the first annotation
     POI *firstPoi = [_allAnnotations objectAtIndex:0];
     
     MKCoordinateRegion region = { { 0.0, 0.0 }, { 0.0, 0.0 } };
     region.center.latitude = [firstPoi getLatitude];
     region.center.longitude = [firstPoi getLongitude];
     region.span.longitudeDelta = 0.05f;
     region.span.longitudeDelta = 0.05f;
     [_mymap setRegion:region animated:YES];
     }else{
     // center the map  in the user location
     MKCoordinateRegion region = { { 0.0, 0.0 }, { 0.0, 0.0 } };
     region.center.latitude = self.locationManager.location.coordinate.latitude;
     region.center.longitude = self.locationManager.location.coordinate.longitude;
     region.span.longitudeDelta = 0.05f;
     region.span.longitudeDelta = 0.05f;
     [_mymap setRegion:region animated:YES];
     }
     
}

- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id<MKOverlay>)overlay {
    
    return self.lineView;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return _allInstructions.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *simpleTableIdentifier = @"CellInst";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if (cell == nil) {
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
        
    }
    
    Information *i = [_allInstructions objectAtIndex:indexPath.row];
    
    cell.textLabel.text = [i getDescription];
    if ([i getTypePoi] == 0){
        cell.backgroundColor = [UIColor colorWithRed:0.902 green:0.902 blue:0.902 alpha:1];
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
    }else{
        cell.backgroundColor = [UIColor whiteColor];
        cell.textLabel.textAlignment = NSTextAlignmentLeft;
    }
    return cell;
}

@end
