#include "UtilsIos.h"
#import "Reachability.h"
#import <UIKit/UIKit.h>

extern "C" void runEvent(int id, const char* data);
extern "C" void runBinaryEvent(int id, const char* data);
extern "C" void runBinaryErrorEvent(int id, const char* data);
extern "C" void runBinaryProgressEvent (int id, int bytes);
extern "C" void runPostJsonEvent(int id, const char* data);
extern "C" void runConnectionCallback(int);

@interface NetworkInfos:NSObject

@property (retain, nonatomic)  Reachability* reach;
@property (atomic, atomic)  BOOL statusCallbackSetted;

+(NetworkInfos *) getInstance;

-(bool)isConnected;
-(int)getActiveConnectionType;
-(void)connectionStatusCallbackSet;
@end

@implementation NetworkInfos

@synthesize reach;
@synthesize statusCallbackSetted;

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
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNetworkChange:) name:kReachabilityChangedNotification object:nil];
		self.reach = [Reachability reachabilityForInternetConnection];
		[self.reach startNotifier];
		self.statusCallbackSetted = NO;
	}
	return self;
}
- (void) handleNetworkChange:(NSNotification *)notice
{
	if (self.statusCallbackSetted == YES) {
    	runConnectionCallback([self getActiveConnectionType]);
    }
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
-(void)connectionStatusCallbackSet
{
	self.statusCallbackSetted = YES;
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

@interface HttpConnection: NSObject <NSURLSessionDelegate>
@property(nonatomic, assign) NSMutableDictionary *mapIds;

+(HttpConnection *) getInstance;
-(void)getText:(NSString*)url withId:(int)id withHeaders:(NSMutableArray*)headers;
-(void)getBinary:(NSString*)url withId:(int)id;// withHeaders:(NSArray*)headers;
@end

@implementation HttpConnection
@synthesize mapIds;

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
        mapIds = [[NSMutableDictionary alloc] init];
	}
	return self;
}

-(void)addHeaders:(NSArray*)headers toRequest:(NSMutableURLRequest*)request
{
    NSLog(@"headaers count %i", [headers count]);
    for (int i = 0; i < [headers count]; i += 2)
    {
        NSLog(@"add header: %i : %f", [headers objectAtIndex:(i + 1)], [headers objectAtIndex:1]);
        [request addValue:[headers objectAtIndex:(i + 1)] forHTTPHeaderField:[headers objectAtIndex:1]];
    }
}

-(void)getText:(NSString*)url withId:(int)id withHeaders:(NSMutableArray*)headers
{
    NSLog(@"connectionmanagerextension getText");
    NSURL *nurl = [NSURL URLWithString:url];

    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:nurl];
    request.HTTPMethod = @"GET";
    [self addHeaders:headers toRequest:request];

    NSURLSessionDataTask *downloadTask = [[NSURLSession sharedSession]
      dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
      	NSLog(@"connectionmanagerextension getText completionHandler");
      	NSString *strData = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
      	if(error)
      	{
      	    [[NSOperationQueue mainQueue] addOperationWithBlock:^ {
                    	runBinaryErrorEvent(id, [[error localizedDescription] UTF8String]);
                    }];
      	}
      	else
      	{
      	    [[NSOperationQueue mainQueue] addOperationWithBlock:^ {
                	runEvent(id, [strData UTF8String]);
                }];
      	}
    }];
    [downloadTask resume];
}
-(void)getBinary:(NSString*)url withId:(int)id withHeaders:(NSMutableArray*)headers
{
    //NSLog(@"Download start, requestId: %i", id);
    NSURL *nurl = [NSURL URLWithString:url];

    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:nurl];
    request.HTTPMethod = @"GET";
    [self addHeaders:headers toRequest:request];

    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    NSURLSessionTask *downloadTask = [session downloadTaskWithRequest:request];
    //self.mapIds[@(id)] = downloadTask;
    
    NSString *strX = [NSString stringWithFormat:@"%i", id];
    [mapIds setObject:downloadTask forKey:strX];
    
    [downloadTask resume];
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location {
    
    int requestId = [self getRequestIdByTask:downloadTask];
    //NSLog(@"Download complete, requestId: %i", requestId);
    
    NSData *ddata = [NSData dataWithContentsOfURL: location];
    NSString *strData = [[NSString alloc]initWithData:ddata encoding:NSUTF8StringEncoding];
    if (strData == nil) {
        NSString *encodedString = [ddata base64Encoding];
        
        [[NSOperationQueue mainQueue] addOperationWithBlock:^ {
            runBinaryEvent(requestId, [encodedString UTF8String]);  // todo ids not zero
        }];
    } else {
        [[NSOperationQueue mainQueue] addOperationWithBlock:^ {
            runEvent(requestId, [strData UTF8String]);
        }];
    }
    //self.downloadTask = nil;
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite
{
    int requestId = [self getRequestIdByTask:downloadTask];
    
    double progress = (double)totalBytesWritten / (double)totalBytesExpectedToWrite;
    NSLog(@"download requestId: %i progress: %f", requestId, progress);
    
    runBinaryProgressEvent(requestId, (int)totalBytesWritten);
}

 - (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
 {
     int requestId = [self getRequestIdByTask:task];
     if (error) {
        NSLog(@"URLSession error: %@ - %@", task, error);
        [[NSOperationQueue mainQueue] addOperationWithBlock:^ {
                            	runBinaryErrorEvent(requestId, [[error localizedDescription] UTF8String]);
                            }];
     } else {
        NSLog(@"URLSession success: %@", task);
     }
 }

-(void)postJson:(NSString*)url withData:(NSString*)data withId:(int)id withHeaders:(NSMutableArray*)headers
{
    NSURL *nurl = [NSURL URLWithString:url];

    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:config];

    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:nurl];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json; charset=UTF-8" forHTTPHeaderField:@"Content-Type"];

    [self addHeaders:headers toRequest:request];

	NSData *dictionary = [data dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];

 NSURLSessionUploadTask *uploadTask = [session uploadTaskWithRequest:request
   fromData:dictionary completionHandler:^(NSData *pdata,NSURLResponse *response,NSError *error) {
		NSString *strData = [[NSString alloc]initWithData:pdata encoding:NSUTF8StringEncoding];
        if(error)
        {
            [[NSOperationQueue mainQueue] addOperationWithBlock:^ {
                    	runBinaryErrorEvent(id, [[error localizedDescription] UTF8String]);
                    }];
        }
        else
        {
            [[NSOperationQueue mainQueue] addOperationWithBlock:^ {
            			runPostJsonEvent(id, [strData UTF8String]);
            		}];
        }

   }];

   [uploadTask resume];

}

-(int)getRequestIdByTask:(NSURLSessionTask*)task
{
    NSArray *arr = [mapIds allKeysForObject:task];
    NSString *key = [arr objectAtIndex:0];
    return [key intValue];
}

@end

namespace connectionmanagerextension {

	NSMutableArray* vectorToArray(std::vector<std::string> strings) {
	    id nsstrings = [NSMutableArray new];
    	std::for_each(strings.begin(), strings.end(), ^(std::string str) {
    		id nsstr = [NSString stringWithUTF8String:str.c_str()];
    		[nsstrings addObject:nsstr];
    	});
        return nsstrings;
	}

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
    void connectionStatusCallbackSet () {
    	[[NetworkInfos getInstance] connectionStatusCallbackSet];
    }
    void getText (std::string url, int rId, std::vector<std::string> headers) {
    	NSLog(@"connectionmanagerextension getText");
    	NSString* nsurl = [[NSString alloc] initWithUTF8String:url.c_str()];
    	NSMutableArray* nsheaders = vectorToArray(headers);
		[[HttpConnection getInstance] getText:nsurl withId:rId withHeaders:nsheaders];
    }
	void getBinary(std::string url, int rId, std::vector<std::string> headers) {
		NSLog(@"connectionmanagerextension getBinary");
		NSString* nsurl = [[NSString alloc] initWithUTF8String:url.c_str()];
		NSMutableArray* nsheaders = vectorToArray(headers);
		[[HttpConnection getInstance] getBinary:nsurl withId:rId withHeaders:nsheaders];
	}
	void postJson(std::string url, std::string data, int rId, std::vector<std::string> headers) {
		NSLog(@"connectionmanagerextension postJson");
		NSString* nsurl = [[NSString alloc] initWithUTF8String:url.c_str()];
		NSString* ndata = [[NSString alloc] initWithUTF8String:data.c_str()];
		NSMutableArray* nsheaders = vectorToArray(headers);
		[[HttpConnection getInstance] postJson:nsurl withData:ndata withId:rId withHeaders:nsheaders];
	}
}
