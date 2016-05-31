//
//  AFSK.m
//  iBCNU
//
//  Created by David Ponevac on 6/2/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "AFSK.h"


@implementation AFSK

@synthesize symbol;

@synthesize fcsLo;
@synthesize fcsHi;

@synthesize stuffCount;

@synthesize TXing;
@synthesize flagTXing;
@synthesize fcsTXing;

@synthesize currentSymbol;

@synthesize message;
@synthesize symbolArray;

@synthesize audioUnit;

@synthesize phase;

#pragma mark ---------------------------------------------------------------------------------------------
#pragma mark class methods

- (id)init
{
	if (self = [super init])
	{
		[self initAudio];
	}//if

	return self;
}//func

- (void)dealloc
{	
	AudioUnitUninitialize(audioUnit);
	
	[super dealloc];
}

#pragma mark ---------------------------------------------------------------------------------------------
#pragma mark AFSK methods

- (void)sendAFSKPacket
{
	symbolArray = [[NSMutableArray alloc] initWithCapacity:0];
	[self setSymbol:_SPACE];
	
	[self setCurrentSymbol:0];
	
	[self setTXing:NO];

	[self setFcsLo:0xFF];
	[self setFcsHi:0xFF];
	
	[self setStuffCount:0];
	
	[self setFlagTXing:YES];
	[self setFcsTXing:NO];
	
	for (int i=0; i<20; i++)
	{
		[self sendByte:0x7E];
	}//for
	
	[self setFlagTXing:NO];
	
	// TX main message
	unsigned char* bufferBytes[2048];
	[self.message getBytes:bufferBytes];
	
	for (int i=0; i < [self.message length]/4; i++)
	{
		unsigned char tt = (unsigned char)bufferBytes[i];
		[self sendByte:tt];
	}//for
	
	// about to send FCS bytes
	[self setFcsTXing:YES];
	
	// XOR them with 0xFF
	[self setFcsLo:self.fcsLo^0xFF];
	[self setFcsHi:self.fcsHi^0xFF];
	
	[self sendByte:fcsLo];
	[self sendByte:fcsHi];
	
	[self setFcsTXing:NO];
	[self setFlagTXing:YES];
	
	[self sendByte:0x7E];
	
	[self startAudio];
}//func

- (void)sendByte:(unsigned char)inByte
{
	int k, bt;
	
	for (k = 0; k < 8; k++)
	{
		bt = inByte & 0x01;
		
		if (([self fcsTXing] == NO) && ([self flagTXing] == NO))
		{
			[self calculateFCS:bt];
		}//if
		
		if (bt == 0)
		{
			[self setStuffCount:0];
			[self sendZero];
		}
		else
		{
			self.stuffCount++;
			[self sendOne];
			
			if (([self flagTXing] == NO) && (self.stuffCount == 5))
			{
				[self setStuffCount:0];
				[self sendZero];
			}//if
		}//if
		
		inByte = inByte >> 1;
	}//for
}//func

- (void)sendZero
{
	int sym;

	if (self.symbol == _SPACE)
	{
		sym = _MARK;
	}
	else
	{
		sym = _SPACE;
	}//if
	
	[self.symbolArray addObject:[NSNumber numberWithInt:sym]];
	[self setSymbol:sym];
}//func

- (void)sendOne
{
	[self.symbolArray addObject:[NSNumber numberWithInt:self.symbol]];
}//func

- (void)calculateFCS:(char)tByte
{
	self.fcsHi = self.fcsHi >> (1 % (8 * sizeof(int)));
	int shiftOff = self.fcsHi << ((8 * sizeof(int)) - 1 % (8 * sizeof(int)));
	self.fcsHi |= shiftOff;
	
	self.fcsLo = self.fcsLo >> (1 % (8 * sizeof(int)));
	shiftOff = self.fcsLo << ((8 * sizeof(int)) - 1 % (8 * sizeof(int)));
	self.fcsLo |= shiftOff;
	
	if (((shiftOff & 0x01)^(tByte)) == 0x01)
	{
		self.fcsHi = self.fcsHi ^ 0x84;
		self.fcsLo = self.fcsLo ^ 0x08;
	}//if
}//func

- (NSData *)prepareAdrressField:(NSString *)call last:(int)last
{
	// ssid byte 011SSSSx
	int baseSSID = 0x60;
	int SSID = 0;
	NSString *strippedCall;
	NSMutableData *data = [NSMutableData dataWithCapacity:0];
	
	// find "-"
	NSRange dashRange = [call rangeOfString:@"-" options:NSLiteralSearch];
	if (dashRange.location == NSNotFound)
	{
		strippedCall = call;
	}
	else
	{
		SSID = [[call substringFromIndex:dashRange.location + 1] intValue];
		strippedCall = [call substringToIndex:dashRange.location];
	}//if
	
	// prepare SSID byte
	baseSSID |= last;
	SSID = SSID << 1;
	baseSSID |= SSID;
	
	// process address first by padding
	NSString *paddedCall = [NSString stringWithFormat:@"%-6s", [strippedCall cStringUsingEncoding:NSUTF8StringEncoding]];
	
	// shift each letter by one
	const char *paddedCall_c = [paddedCall cStringUsingEncoding:NSUTF8StringEncoding];
	unsigned char *shiftedChar[7];
	
	for (int i = 0; i < 6; i++)
	{
		shiftedChar[i] = (unsigned char *)(paddedCall_c[i] << 1);
	}//for
	
	shiftedChar[6] = (unsigned char *)baseSSID;
	
	[data appendBytes:shiftedChar length:sizeof(shiftedChar)];
	
	return data;
}//func

- (void)buildPacket:(NSArray *)addresses control:(int)control pid:(int)pid payload:(NSString *)payload
{
	self.message = [[NSMutableData alloc] initWithCapacity:0];
	
	for (int i = 0; i < [addresses count]; i++)
	{
		[self.message appendData:[self prepareAdrressField:[addresses objectAtIndex:i] last:(i+1 == [addresses count] ? 1 : 0)]];
	}// for
	
	int payloadLen = [payload length] + 2;
	unsigned char *moreData[payloadLen];
	
	moreData[0] = (unsigned char *)control;
	moreData[1] = (unsigned char *)pid;
	
	const char *payload_c = [payload cStringUsingEncoding:NSUTF8StringEncoding];
	
	for (int i = 0; i < sizeof(payload_c); i++)
	{
		moreData[i+2] = (unsigned char *)payload_c[i];
	}//if
	
	[self.message appendBytes:moreData length:sizeof(moreData)];
	
	NSLog(@"%@", self.message);
}//if

#pragma mark ---------------------------------------------------------------------------------------------
#pragma mark Audio methods

OSStatus playbackCallback(void *inRefCon,
						  AudioUnitRenderActionFlags *ioActionFlags,
						  const AudioTimeStamp *inTimeStamp,
						  UInt32 inBusNumber, 
						  UInt32 inNumberFrames,
						  AudioBufferList *ioData)
{	
	AFSK *me = (AFSK *)inRefCon;
	
	if ([me currentSymbol] >= [me.symbolArray count])
	{
		AudioOutputUnitStop(me.audioUnit);
		return noErr;
	}
	
	double freq = [[[me symbolArray] objectAtIndex:me.currentSymbol] floatValue];
	
	/*for(UInt32 i = 0; i < ioData->mNumberBuffers; i++)
	{
		int samples = ioData->mBuffers[i].mDataByteSize;// / sizeof(SInt16);
		
		SInt16 values[samples];
		
		float waves;
		
		for(int j = 0; j < samples; j+=2)
		{
			waves = 0;
			waves += sin(kWaveform * (freq == 1200 ? 1200 : 0) * me.phase);
			waves += sin(kWaveform * (freq == 2200 ? 2200 : 0) * me.phase);
			waves *= 32500 / 2;
			
			values[j] = (SInt16)waves;
			values[j] += values[j] << 16;
			values[j+1] = values[j];
			
			me.phase++;
		}

		memcpy(ioData->mBuffers[i].mData, values, samples);
	}*/
	
	//loop through all the buffers that need to be filled
	for (int i = 0 ; i < ioData->mNumberBuffers; i++){
		//get the buffer to be filled
		AudioBuffer buffer = ioData->mBuffers[i];
		
		float waves;
		
		//if needed we can get the number of bytes that will fill the buffer using
		// int numberOfSamples = ioData->mBuffers[i].mDataByteSize;
		
		//get the buffer and point to it as an UInt32 (as we will be filling it with 32 bit samples)
		//if we wanted we could grab it as a 16 bit and put in the samples for left and right seperately
		//but the loop below would be for(j = 0; j < inNumberFrames * 2; j++) as each frame is a 32 bit number
		UInt32 *frameBuffer = buffer.mData;
		UInt32 value;
		
		//loop through the buffer and fill the frames
		for (int j = 0; j < inNumberFrames/2; j++){
			waves = 0;
			waves += sin(kWaveform * freq * me.phase);
			waves *= 32500;
			
			value = (UInt32)waves;
			//value += value << 32;
			// get NextPacket returns a 32 bit value, one frame.
			frameBuffer[j] = value;
			//frameBuffer[j+1] = value;
			
			me.phase++;
		}
	}

	me.currentSymbol++;	
	return noErr;
}


- (void)initAudio
{
	[self setPhase:0];
	OSStatus status;
	
	
	// Describe audio component
	AudioComponentDescription desc;
	desc.componentType = kAudioUnitType_Output;
	desc.componentSubType = kAudioUnitSubType_RemoteIO;
	desc.componentFlags = 0;
	desc.componentFlagsMask = 0;
	desc.componentManufacturer = kAudioUnitManufacturer_Apple;
	
	// Get component
	AudioComponent inputComponent = AudioComponentFindNext(NULL, &desc);
	
	// Get audio units
	status = AudioComponentInstanceNew(inputComponent, &audioUnit);
	
	UInt32 flag = 1;
	// Enable IO for playback
	status = AudioUnitSetProperty(audioUnit, 
								  kAudioOutputUnitProperty_EnableIO, 
								  kAudioUnitScope_Output, 
								  kOutputBus,
								  &flag, 
								  sizeof(flag));
	
	// Describe format
	audioFormat.mSampleRate			= kSampleRate;
	audioFormat.mFormatID			= kAudioFormatLinearPCM;
	audioFormat.mFormatFlags		= kAudioFormatFlagIsSignedInteger | kAudioFormatFlagIsPacked;
	audioFormat.mFramesPerPacket	= 1;
	audioFormat.mChannelsPerFrame	= 2;
	audioFormat.mBitsPerChannel		= 16;
	audioFormat.mBytesPerPacket		= 4;
	audioFormat.mBytesPerFrame		= 4;
	
	//Apply format
	status = AudioUnitSetProperty(audioUnit, 
								  kAudioUnitProperty_StreamFormat, 
								  kAudioUnitScope_Input, 
								  kOutputBus, 
								  &audioFormat, 
								  sizeof(audioFormat));
	
	// Set up the playback  callback
	AURenderCallbackStruct callbackStruct;
	callbackStruct.inputProc = playbackCallback;
	//set the reference to "self" this becomes *inRefCon in the playback callback
	callbackStruct.inputProcRefCon = self;
	
	status = AudioUnitSetProperty(audioUnit, 
								  kAudioUnitProperty_SetRenderCallback, 
								  kAudioUnitScope_Global, 
								  kOutputBus,
								  &callbackStruct, 
								  sizeof(callbackStruct));
	
	// Initialise
	status = AudioUnitInitialize(audioUnit);
}//func

- (void)startAudio
{
	OSStatus status;
	
	status = AudioOutputUnitStart(audioUnit);	
}

- (void)stopAudio
{	
	OSStatus status;
	
	status = AudioOutputUnitStop(audioUnit);	
}

@end
