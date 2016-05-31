//
//  AFSK.h
//  iBCNU
//
//  Created by David Ponevac on 6/2/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioQueue.h>
#import <AudioUnit/AudioUnit.h>
#import <math.h>

#define kOutputBus 0
#define kSampleRate 44100

#define kWaveform (M_PI * 2.0f / kSampleRate)

#define _MARK 2200
#define _SPACE 1200


@interface AFSK : NSObject
{
	int symbol;
	
	char fcsLo;
	char fcsHi;
	
	int stuffCount;
	
	bool TXing;
	bool flagTXing;
	bool fcsTXing;
	
	unsigned int currentSymbol;
	
	NSMutableData *message;
	
	NSMutableArray *symbolArray;
	
	AudioComponentInstance audioUnit;
	AudioStreamBasicDescription audioFormat;
	
	int phase;
}

@property (nonatomic, assign) int symbol;

@property (nonatomic, assign) char fcsLo;
@property (nonatomic, assign) char fcsHi;

@property (nonatomic, assign) int stuffCount;

@property (nonatomic, assign) bool TXing;
@property (nonatomic, assign) bool flagTXing;
@property (nonatomic, assign) bool fcsTXing;

@property (nonatomic, assign) unsigned int currentSymbol;

@property (nonatomic, retain) NSMutableData *message;

@property (nonatomic, retain) NSMutableArray *symbolArray;

@property (nonatomic, assign) AudioComponentInstance audioUnit;

@property (nonatomic, assign) int phase;

- (void)sendAFSKPacket;
- (void)sendByte:(unsigned char)inByte;
- (void)sendZero;
- (void)sendOne;
- (void)calculateFCS:(char)tByte;
- (NSData *)prepareAdrressField:(NSString *)call last:(int)last;
- (void)initAudio;
- (void)startAudio;
- (void)stopAudio;
- (void)buildPacket:(NSArray *)addresses control:(int)control pid:(int)pid payload:(NSString *)payload;

@end
