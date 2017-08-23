#ifndef CONNECTIONMANAGEREXTENSION_H
#define CONNECTIONMANAGEREXTENSION_H
#include <string>

namespace connectionmanagerextension {
	
	
	bool isConnected();
	int getActiveConnectionType();
	void getText(std::string url, int rId);
	void getBinary(std::string url, int rId);
	void postJson(std::string url, std::string data, int rId);

	
}


#endif