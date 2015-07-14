//
//  Pin.m
//  RouteAdvisorDemo
//
//  Created by cbalufo on 27/5/15.
//  Copyright (c) 2015 DAMA-UPC. All rights reserved.
//

#import "Pin.h"

@implementation Pin

- (id)initWithCoordinate:(CLLocationCoordinate2D)newCoordinate {
    
    self = [super init];
    if (self) {
        _coordinate = newCoordinate;
        _title = @"Hello";
        _subtitle = @"Are you still there?";
    }
    return self;
}

@end
