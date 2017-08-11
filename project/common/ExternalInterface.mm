#ifndef STATIC_LINK
#define IMPLEMENT_API
#endif

#if defined(HX_WINDOWS) || defined(HX_MACOS) || defined(HX_LINUX)
#define NEKO_COMPATIBLE
#endif


#include <hx/CFFI.h>
#include "UtilsIos.h"

using namespace connectionmanagerextension;



static value connectionmanagerextension_isConnected () {

	return alloc_bool(isConnected ());

}
DEFINE_PRIM (connectionmanagerextension_isConnected, 0);

static value connectionmanagerextension_getActiveConnectionType () {

	return alloc_int(getActiveConnectionType());

}
DEFINE_PRIM (connectionmanagerextension_getActiveConnectionType, 0);



extern "C" void connectionmanagerextension_main () {
	
	val_int(0); // Fix Neko init
	
}
DEFINE_ENTRY_POINT (connectionmanagerextension_main);



extern "C" int connectionmanagerextension_register_prims () { return 0; }