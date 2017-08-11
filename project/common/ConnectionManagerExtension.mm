#include "UtilsIos.h"
#import "Reachability.h"
#import <UIKit/UIKit.h>

@interface NetworkInfos:NSObject

@property (retain, nonatomic)  Reachability* reach;

+(NetworkInfos *) getInstance;

-(bool)isConnected;
-(int)getActiveConnectionType;
@end

@implementation NetworkInfos

@synthesize reach;

+(NetworkInfos *)getInstance
{
	static NetworkInfos *instance;
	@synchronized(self)
	{
		if(!instance)
		{
			instance = [[NetworkInfos alloc] init];
		}
		return instance;
	}
}

-(id)init
{
	if( self == [super init])
	{
		self.reach = [Reachability reachabilityForInternetConnection]; //retain reach
	}
	return self;
}

-(NetworkStatus)getStatus
{
	NSLog(@"check getStatus 0");
	NetworkStatus networkStatus = [self.reach currentReachabilityStatus];
	NSLog(@"check getStatus 1");
	return networkStatus;
}

-(bool)isConnected
{
	NetworkStatus networkStatus = [self getStatus];
	return networkStatus != NotReachable;
}

-(int)getActiveConnectionType
{
	NSLog(@"check getActiveConnectionType 0");
	int res;
	NSLog(@"check getActiveConnectionType 1");
	NetworkStatus networkStatus = [self getStatus];
	NSLog(@"check getActiveConnectionType 2");
	switch(networkStatus)
	{
		case ReachableViaWWAN:
			NSLog(@"check getActiveConnectionType 3");
			res = 2;
			break;

		case ReachableViaWiFi:
			NSLog(@"check getActiveConnectionType 4");
			res = 1;
			break;

		case NotReachable:
			NSLog(@"check getActiveConnectionType 5");
			res = 0;
			break;
	}
	NSLog(@"check getActiveConnectionType 6");
	return res;
}

@end

namespace connectionmanagerextension {

	bool isConnected() {
		NSLog(@"connectionmanagerextension isConnected");
		bool result = [[NetworkInfos getInstance] isConnected];
        return result;
	}
	int getActiveConnectionType() {
		NSLog(@"connectionmanagerextension getActiveConnectionType");
		int result = [[NetworkInfos getInstance] getActiveConnectionType];
        return result;
    }
	
	
}