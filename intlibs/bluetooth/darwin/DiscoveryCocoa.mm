#import <unistd.h>
#include <IOBluetooth/objc/IOBluetoothDeviceInquiry.h>
#import "DiscoveryCocoa.h"



@implementation DiscoveryCocoa
@synthesize _foundDevices;
@synthesize _status;
@synthesize _callback;

//===========================================================================================================================
// startInquiry
//===========================================================================================================================

-(IOReturn)startInquiry:(BOOL)withNames
{
	
	
	IOReturn	status;
	
	//[self	stopInquiry];
	
	_inquiry = [IOBluetoothDeviceInquiry	inquiryWithDelegate:self];
	[_inquiry setUpdateNewDeviceNames:withNames];
	
	status = [_inquiry	start];
	if( status == kIOReturnSuccess )
	{
		
		[_inquiry	retain];
		//_busy = TRUE;
		_status = 0;
	}
	else
	{
		//[_messageText setObjectValue:@"Idle (Search Failed)."];
	}
	
	return( status );
}

//===========================================================================================================================
// deviceInquiryComplete
//===========================================================================================================================

- (void)	deviceInquiryComplete:(IOBluetoothDeviceInquiry*)sender	error:(IOReturn)error	aborted:(BOOL)aborted
{

	
	if( error )
	{
		_status = -1;
		
	}
	else
	{
		_status = 1;
		_callback ( );
	}
	
	//[_progressBar 	stopAnimation:self];
	//[_searchButton 	setTitle:@"Search"];
	//[_searchButton 	setEnabled:TRUE];
	
	//_busy = FALSE;
}

//===========================================================================================================================
// deviceInquiryDeviceFound
//===========================================================================================================================

- (void)	deviceInquiryDeviceFound:(IOBluetoothDeviceInquiry*)sender	device:(IOBluetoothDevice*)device
{

	
	[self addDeviceToList:device];
	//[_messageText setObjectValue:[NSString stringWithFormat:@"Found %d devices...", [[sender foundDevices] count]]];
}

//===========================================================================================================================
// deviceInquiryDeviceNameUpdated
//===========================================================================================================================

- (void)	deviceInquiryDeviceNameUpdated:(IOBluetoothDeviceInquiry*)sender	device:(IOBluetoothDevice*)device devicesRemaining:(uint32_t)devicesRemaining
{

	//[_messageText setObjectValue:[NSString stringWithFormat:@"Refreshing %d device names...", devicesRemaining]];
	
	//[self	updateDeviceInfoInList:device];
}

//===========================================================================================================================
// deviceInquiryUpdatingDeviceNamesStarted
//===========================================================================================================================

- (void)	deviceInquiryUpdatingDeviceNamesStarted:(IOBluetoothDeviceInquiry*)sender	devicesRemaining:(uint32_t)devicesRemaining
{
	
	//[_messageText setObjectValue:[NSString stringWithFormat:@"Refreshing %d device names...", devicesRemaining]];
}

//===========================================================================================================================
// deviceInquiryStarted
//===========================================================================================================================

- (void)	deviceInquiryStarted:(IOBluetoothDeviceInquiry*)sender
{
	//[_messageText 	setObjectValue:@"Searching for Devices..."];
	//[_progressBar 	startAnimation:self];
}


//===========================================================================================================================
//	saveNewDeviceIfAcceptable
//===========================================================================================================================

-(BOOL)saveNewDeviceIfAcceptable:(IOBluetoothDevice*)inNewDevice
{
	
	
	NSEnumerator*					enumerator;
	IOBluetoothDevice*				tmpDevice;
	const BluetoothDeviceAddress* 	newDeviceAddress = [inNewDevice getAddress];
	
	if( !_foundDevices )
	{
		_foundDevices = [[NSMutableArray alloc] initWithCapacity:1];
		if( !_foundDevices ) return( FALSE );
		[_foundDevices retain];
	}
	
	// walk the devices in the array.
	
	enumerator = [_foundDevices objectEnumerator];
	if( enumerator )
	{
		const BluetoothDeviceAddress* tempAddress = NULL;
		
		while( (tmpDevice = [enumerator nextObject]) )
		{
			tempAddress = [tmpDevice getAddress];
			
			if( memcmp( newDeviceAddress, tempAddress, sizeof( BluetoothDeviceAddress ) ) == 0 )
			{
				// Already have it.
				return( FALSE );
			}
		}
	}
	
	[_foundDevices addObject:inNewDevice];
	
	// Return that we haven't seen it.
	
	return( TRUE );
}

//===========================================================================================================================
//	addDeviceToList
//===========================================================================================================================

-(void)addDeviceToList:(IOBluetoothDevice*)inDevice
{

	
	if( ![self saveNewDeviceIfAcceptable:inDevice] )
	{
		// Already have seen it. Bail.
		
		return;
	}
}

//===========================================================================================================================
// stopInquiry
//===========================================================================================================================
- (IOReturn) stopInquiry
{
	IOReturn ret = kIOReturnNotOpen;
	
	if( _inquiry )
	{
		ret = [_inquiry stop];
		[_inquiry release];
		_inquiry = nil;
	}
	
	return ret;
}


@end