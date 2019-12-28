#ifndef CONNECTIONMANAGEREXTENSION_H
#define CONNECTIONMANAGEREXTENSION_H
#include <string>
#include <vector>

namespace connectionmanagerextension {
	
	
	bool isConnected();
	int getActiveConnectionType();
	void connectionStatusCallbackSet();
	void getText(std::string url, int rId, std::vector<std::string> headers);
	void getBinary(std::string url, int rId);
	void postJson(std::string url, std::string data, int rId);

	
}


#endif