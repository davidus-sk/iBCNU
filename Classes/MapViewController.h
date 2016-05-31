//
//  MapViewController.h
//  iBCNU
//
//  Created by David Ponevac on 5/24/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "APRS.h"


@interface MapViewController : UIViewController
{
	IBOutlet MKMapView *mapView;
	
	APRS *APRSClass;
	
	// loading indicator
	UIActivityIndicatorView *progress;
}

@property (nonatomic, retain) MKMapView *mapView;
@property (nonatomic, assign) APRS *APRSClass;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil APRSFeed:(APRS *)APRSFeed;

@end
