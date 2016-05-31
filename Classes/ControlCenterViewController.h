//
//  ControlCenterViewController.h
//  iBCNU
//
//  Created by David Ponevac on 5/10/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "CommonTools.h"
#import "GPS.h"
#import "Data.h"
#import "APRS.h"
#import "AFSK.h"


@interface ControlCenterViewController : UIViewController <CLLocationManagerDelegate, UITextFieldDelegate>
{
	// GUI
	IBOutlet UILabel *callsignLabel;
	IBOutlet UILabel *coordsLabel;
	IBOutlet UILabel *locatorLabel;
	IBOutlet UILabel *UTCLabel;
	IBOutlet UILabel *beaconsLabel;
	IBOutlet UILabel *cdownLabel;
	
	IBOutlet UIImageView *busyIndicator;
	IBOutlet UIImageView *linkIndicator;
	IBOutlet UIImageView *locIndicator;
	IBOutlet UIImageView *msgIndicator;
	IBOutlet UIImageView *posIndicator;
	IBOutlet UIActivityIndicatorView *loaderIndicator;
	IBOutlet UIImageView *speedIndicator;
	
	IBOutlet UIButton *beaconNowButton;
	IBOutlet UIButton *linkNowButton;
	IBOutlet UIButton *beaconOffButton;
	IBOutlet UIButton *int1Button;
	IBOutlet UIButton *int2Button;
	IBOutlet UIButton *int3Button;
	
	IBOutlet UIView *cDownBar;
	
	IBOutlet UIButton *settingsButton;
	IBOutlet UIButton *locButton;
	IBOutlet UIButton *posButton;
	IBOutlet UIButton *cintButton;
	IBOutlet UIButton *mapButton;
	IBOutlet UIButton *logButton;
	IBOutlet UIButton *dscrButton;
	IBOutlet UIButton *afskButton;
	IBOutlet UIButton *filButton;
	IBOutlet UIButton *gpsButton;
	IBOutlet UIButton *prsButton;
	
	// speed related
	UILabel *speedLabel;
	UILabel *speedUnitLabel;
	
	// timers
	NSTimer *UTCTimer;
	NSTimer *cDownTimer;
	
	// misc
	NSNumber *beaconInterval;
	NSNumber *customInterval;
	NSInteger cDownInterval;
	BOOL beaconOn;
	BOOL sendOnPos;
	BOOL scrDisabled;
	BOOL afskOut;
	BOOL metricOn;
	
	// CoreLocation
	CLLocationManager *locationManager;
	
	// External classes
	Data *dataClass;
	APRS *APRSClass;
}

// GUI
@property (nonatomic, retain) IBOutlet UILabel *callsignLabel;
@property (nonatomic, retain) IBOutlet UILabel *coordsLabel;
@property (nonatomic, retain) IBOutlet UILabel *locatorLabel;
@property (nonatomic, retain) IBOutlet UILabel *UTCLabel;
@property (nonatomic, retain) IBOutlet UILabel *beaconsLabel;
@property (nonatomic, retain) IBOutlet UILabel *cdownLabel;

@property (nonatomic, retain) IBOutlet UIImageView *busyIndicator;
@property (nonatomic, retain) IBOutlet UIImageView *linkIndicator;
@property (nonatomic, retain) IBOutlet UIImageView *locIndicator;
@property (nonatomic, retain) IBOutlet UIImageView *msgIndicator;
@property (nonatomic, retain) IBOutlet UIImageView *posIndicator;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *loaderIndicator;
@property (nonatomic, retain) IBOutlet UIImageView *speedIndicator;

@property (nonatomic, retain) IBOutlet UIButton *beaconNowButton;
@property (nonatomic, retain) IBOutlet UIButton *linkNowButton;
@property (nonatomic, retain) IBOutlet UIButton *beaconOffButton;
@property (nonatomic, retain) IBOutlet UIButton *int1Button;
@property (nonatomic, retain) IBOutlet UIButton *int2Button;
@property (nonatomic, retain) IBOutlet UIButton *int3Button;

@property (nonatomic, retain) IBOutlet UIView *cDownBar;

@property (nonatomic, retain) IBOutlet UIButton *settingsButton;
@property (nonatomic, retain) IBOutlet UIButton *locButton;
@property (nonatomic, retain) IBOutlet UIButton *posButton;
@property (nonatomic, retain) IBOutlet UIButton *cintButton;
@property (nonatomic, retain) IBOutlet UIButton *mapButton;
@property (nonatomic, retain) IBOutlet UIButton *logButton;
@property (nonatomic, retain) IBOutlet UIButton *dscrButton;
@property (nonatomic, retain) IBOutlet UIButton *afskButton;
@property (nonatomic, retain) IBOutlet UIButton *filButton;
@property (nonatomic, retain) IBOutlet UIButton *gpsButton;
@property (nonatomic, retain) IBOutlet UIButton *prsButton;

// speed related
@property (nonatomic, retain) UILabel *speedLabel;
@property (nonatomic, retain) UILabel *speedUnitLabel;

// timers
@property (nonatomic, assign) NSTimer *UTCTimer;
@property (nonatomic, assign) NSTimer *cDownTimer;

// misc
@property (nonatomic, retain) NSNumber *beaconInterval;
@property (nonatomic, retain) NSNumber *customInterval;
@property (nonatomic, assign) NSInteger cDownInterval;
@property (nonatomic, assign) BOOL beaconOn;
@property (nonatomic, assign) BOOL sendOnPos;
@property (nonatomic, assign) BOOL scrDisabled;
@property (nonatomic, assign) BOOL afskOut;
@property (nonatomic, assign) BOOL metricOn;

// external classes
@property (nonatomic, assign) Data *dataClass;
@property (nonatomic, assign) APRS *APRSClass;

// GUI methods
- (IBAction)sendBeaconNow:(UIButton *)sender;
- (IBAction)reconnectNow:(UIButton *)sender;
- (IBAction)toggleBeacon:(UIButton *)sender;
- (IBAction)toggleInterval:(UIButton *)sender;

- (IBAction)callSettings:(UIButton *)sender;
- (IBAction)callLoc:(UIButton *)sender;
- (IBAction)callPos:(UIButton *)sender;
- (IBAction)callCInt:(UIButton *)sender;
- (IBAction)callMap:(UIButton *)sender;
- (IBAction)callLog:(UIButton *)sender;
- (IBAction)callDScr:(UIButton *)sender;
- (IBAction)callAfsk:(UIButton *)sender;
- (IBAction)callFil:(UIButton *)sender;
- (IBAction)callGPS:(UIButton *)sender;
- (IBAction)callPrs:(UIButton *)sender;

// timer methods
- (void)fireUTCTimer:(NSTimer *)theTimer;

- (void)startCDownTimer;
- (void)stopCDownTimer;
- (void)fireCDownTimer:(NSTimer *)theTimer;


@end
