#ifndef STATIC_LINK
#define IMPLEMENT_API
#endif

#if defined(HX_WINDOWS) || defined(HX_MACOS) || defined(HX_LINUX)
#define NEKO_COMPATIBLE
#endif


#include <hx/CFFI.h>
#include "Utils.h"


using namespace connectionmanagerextension;



static bool connectionmanagerextension_isConnected () {
	
	return isConnected();
	
}
DEFINE_PRIM (connectionmanagerextension_isConnected, 0);

static int connectionmanagerextension_getActiveConnectionType () {

	return getActiveConnectionType();

}
DEFINE_PRIM (connectionmanagerextension_getActiveConnectionType, 0);



extern "C" void connectionmanagerextension_main () {
	
	val_int(0); // Fix Neko init
	
}
DEFINE_ENTRY_POINT (connectionmanagerextension_main);



extern "C" int connectionmanagerextension_register_prims () { return 0; }