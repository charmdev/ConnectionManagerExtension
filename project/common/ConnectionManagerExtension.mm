#include "UtilsIos.h"
#import "Reachability.h"
#import <UIKit/UIKit.h>

extern "C" void runEvent(int id, const char* data);
extern "C" void runBinaryEvent(int id, const char* data);
extern "C" void runPostJsonEvent(int id, const char* data);

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

@interface HttpConnection:NSObject
+(HttpConnection *) getInstance;

-(void)getText:(NSString*)url withId:(int)id;
-(void)getBinary:(NSString*)url withId:(int)id;
@end

@implementation HttpConnection
+(HttpConnection *)getInstance
{
	static HttpConnection *instance;
	@synchronized(self)
	{
		if(!instance)
		{
			instance = [[HttpConnection alloc] init];
		}
		return instance;
	}
}
-(id)init
{
	if( self == [super init])
	{

	}
	return self;
}
-(void)getText:(NSString*)url withId:(int)id
{
    NSURL *nurl = [NSURL URLWithString:url];

    NSURLSessionDataTask *downloadTask = [[NSURLSession sharedSession]
      dataTaskWithURL:nurl completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
      	NSLog(@"connectionmanagerextension completionHandler");
      	NSString *strData = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
      	[[NSOperationQueue mainQueue] addOperationWithBlock:^ {
        	runEvent(id, [strData UTF8String]);
        }];

    }];
    [downloadTask resume];
}
-(void)getBinary:(NSString*)url withId:(int)id
{
    NSURL *nurl = [NSURL URLWithString:url];

    NSURLSessionDataTask *downloadTask = [[NSURLSession sharedSession]
      dataTaskWithURL:nurl completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
      	NSLog(@"connectionmanagerextension completionHandler");
      	NSString *strData = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
      	[[NSOperationQueue mainQueue] addOperationWithBlock:^ {
        	runBinaryEvent(id, [strData UTF8String]);
        }];

    }];
    [downloadTask resume];
}
-(void)postJson:(NSString*)url withData:(NSString*)data withId:(int)id
{
    NSURL *nurl = [NSURL URLWithString:url];

    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:config];

    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:nurl];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json; charset=UTF-8" forHTTPHeaderField:@"Content-Type"];

	NSData *dictionary = [data dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];

 NSURLSessionUploadTask *uploadTask = [session uploadTaskWithRequest:request
   fromData:dictionary completionHandler:^(NSData *pdata,NSURLResponse *response,NSError *error) {
		NSString *strData = [[NSString alloc]initWithData:pdata encoding:NSUTF8StringEncoding];
		[[NSOperationQueue mainQueue] addOperationWithBlock:^ {
			runPostJsonEvent(id, [strData UTF8String]);
		}];
   }];

   [uploadTask resume];

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
    void getText (std::string url, int rId) {
    	NSLog(@"connectionmanagerextension getText");
    	NSString* nsurl = [[NSString alloc] initWithUTF8String:url.c_str()];
		[[HttpConnection getInstance] getText:nsurl withId:rId];
    }
	void getBinary(std::string url, int rId) {
		NSLog(@"connectionmanagerextension getBinary");
		NSString* nsurl = [[NSString alloc] initWithUTF8String:url.c_str()];
		[[HttpConnection getInstance] getBinary:nsurl withId:rId];
	}
	void postJson(std::string url, std::string data, int rId) {
		NSLog(@"connectionmanagerextension postJson");
		NSString* nsurl = [[NSString alloc] initWithUTF8String:url.c_str()];
		NSString* ndata = [[NSString alloc] initWithUTF8String:data.c_str()];
		[[HttpConnection getInstance] postJson:nsurl withData:ndata withId:rId];
	}
	
}