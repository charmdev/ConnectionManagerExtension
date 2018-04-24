#ifndef STATIC_LINK
#define IMPLEMENT_API
#endif

#if defined(HX_WINDOWS) || defined(HX_MACOS) || defined(HX_LINUX)
#define NEKO_COMPATIBLE
#endif


#include <hx/CFFI.h>
#include <stdio.h>
#include <map>
#include "UtilsIos.h"

#define safe_val_string(str) str==NULL ? "" : std::string(val_string(str))
#define safe_alloc_string(a) (a!=NULL?alloc_string(a):NULL)

using namespace connectionmanagerextension;

struct Handler {
    AutoGCRoot* onSuccess;
    AutoGCRoot* onProgress;
    AutoGCRoot* onError;
} ;

std::map<int,Handler> handlers;
AutoGCRoot* connectionCallback;

static value connectionmanagerextension_isConnected () {

	return alloc_bool(isConnected ());

}
DEFINE_PRIM (connectionmanagerextension_isConnected, 0);

static value connectionmanagerextension_getActiveConnectionType () {

	return alloc_int(getActiveConnectionType());

}
DEFINE_PRIM (connectionmanagerextension_getActiveConnectionType, 0);

static void connectionmanagerextension_connectionStatusCallback (value callback) {

	connectionCallback = new AutoGCRoot(callback);
	connectionStatusCallbackSet();
}
DEFINE_PRIM (connectionmanagerextension_connectionStatusCallback, 1);

static void connectionmanagerextension_getText (value url, value rId, value onSuccess, value onError) {

	Handler h;
	h.onSuccess = new AutoGCRoot(onSuccess);
	h.onError = new AutoGCRoot(onError);
	handlers.insert(std::make_pair(val_int(rId), h));
	getText(safe_val_string(url), val_int(rId));
}
DEFINE_PRIM (connectionmanagerextension_getText, 4);

static void connectionmanagerextension_getBinary (value url, value rId, value onSuccess, value onProgress, value onError) {

	Handler h;
	h.onSuccess = new AutoGCRoot(onSuccess);
    h.onProgress = new AutoGCRoot(onProgress);
	h.onError = new AutoGCRoot(onError);
	handlers.insert(std::make_pair(val_int(rId), h));
	getBinary(safe_val_string(url), val_int(rId));
}
DEFINE_PRIM (connectionmanagerextension_getBinary, 5);

static void connectionmanagerextension_postJson (value url, value data, value rId, value onSuccess, value onError) {

	Handler h;
	h.onSuccess = new AutoGCRoot(onSuccess);
	h.onError = new AutoGCRoot(onError);
	handlers.insert(std::make_pair(val_int(rId), h));
	postJson(safe_val_string(url), safe_val_string(data), val_int(rId));
}
DEFINE_PRIM (connectionmanagerextension_postJson, 5);


extern "C" void connectionmanagerextension_main () {

	val_int(0); // Fix Neko init

}
DEFINE_ENTRY_POINT (connectionmanagerextension_main);



extern "C" int connectionmanagerextension_register_prims () { return 0; }

extern "C" void runEvent (int id, const char* data)
{
	if (handlers.find(id) != handlers.end()) {
		val_call1(handlers[id].onSuccess->get(), safe_alloc_string(data));
		handlers.erase(id);
	}
}
extern "C" void runBinaryEvent (int id, const char* data)
{
	if (handlers.find(id) != handlers.end()) {
		val_call1(handlers[id].onSuccess->get(), safe_alloc_string(data));
		handlers.erase(id);
	}
}

extern "C" void runBinaryErrorEvent (int id, const char* data)
{
    if (handlers.find(id) != handlers.end()) {
        val_call1(handlers[id].onError->get(), safe_alloc_string(data));
        handlers.erase(id);
    }
}

extern "C" void runBinaryProgressEvent (int id, int bytes)
{
    if (handlers.find(id) != handlers.end()) {
        val_call1(handlers[id].onProgress->get(), alloc_int(bytes));
    }
}

extern "C" void runPostJsonEvent(int id, const char* data)
{
	if (handlers.find(id) != handlers.end()) {
		val_call1(handlers[id].onSuccess->get(), safe_alloc_string(data));
		handlers.erase(id);
	}
}
extern "C" void runConnectionCallback(int status)
{
	val_call1(connectionCallback->get(), alloc_int(status));
}
