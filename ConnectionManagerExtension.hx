package;

#if cpp
import cpp.Lib;
#elseif neko
import neko.Lib;
#end

#if (android && openfl)
import openfl.utils.JNI;
#end

class ConnectionManagerExtension {

	public static function isConnected():Bool
	{
		#if (android && openfl)
			if (connectionmanagerextension_isConnected_jni == null) connectionmanagerextension_isConnected_jni = JNI.createStaticMethod("org.haxe.extension.ConnectionManagerExtension", "isConnected", "()Z");
			return connectionmanagerextension_isConnected_jni();
		#elseif ios
			return connectionmanagerextension_isConnected();
		#else
			return true;
		#end
	}

	public static function getConnectionType():ConnectionType
	{

		var type = 0;

		#if (android && openfl)
			if (connectionmanagerextension_getActiveConnectionType_jni == null) connectionmanagerextension_getActiveConnectionType_jni = JNI.createStaticMethod("org.haxe.extension.ConnectionManagerExtension", "getActiveConnectionType", "()I");
			type = connectionmanagerextension_getActiveConnectionType_jni();
		#elseif ios
			type = connectionmanagerextension_getActiveConnectionType();
		#end

		var res:ConnectionType = switch(type)
		{
			case 0:
				ConnectionType.NONE;

			case 1:
				ConnectionType.WIFI;

			case 2:
				ConnectionType.MOBILE;

			case _:
				ConnectionType.NONE;
		}

		return res;
	}



	#if ios
	private static var connectionmanagerextension_isConnected = Lib.load("connectionmanagerextension", "connectionmanagerextension_isConnected", 0);
	private static var connectionmanagerextension_getActiveConnectionType = Lib.load("connectionmanagerextension", "connectionmanagerextension_getActiveConnectionType", 0);
	#end

	#if (android && openfl)
	private static var connectionmanagerextension_isConnected_jni:Dynamic;
	private static var connectionmanagerextension_getActiveConnectionType_jni:Dynamic;
	#end

}

enum ConnectionType
{
	NONE;
	WIFI;
	MOBILE;
}