#include "UtilsIos.h"
#import <UIKit/UIKit.h>

namespace connectionmanagerextension {

	bool isConnected() {
		NSLog(@"connectionmanagerextension isConnected");
		return true;
	}
	int getActiveConnectionType() {
		NSLog(@"connectionmanagerextension getActiveConnectionType");
		return 0;
    }
	
	
}