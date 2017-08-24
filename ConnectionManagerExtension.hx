package;

#if cpp
import cpp.Lib;
#elseif neko
import neko.Lib;
#end

#if (android && openfl)
import openfl.utils.JNI;
#end

import haxe.Json;
import haxe.crypto.Base64;
import haxe.io.Bytes;

class ConnectionManagerExtension {
	private static var requestId:Int = 0;

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
	@:allow(IosHttp)
	private static function getText (url:String, onSuccess:String -> Void, onError:String -> Void):Void
	{
		trace("getText",url);
		#if ios
		connectionmanagerextension_getText(url, requestId, onSuccess, onError);
		requestId += 1;
		#end
	}
	@:allow(IosHttp)
	private static function getBinary (url:String, onSuccess:String -> Void, onError:String -> Void):Void
	{
		trace("getBinary",url);
		#if ios
		connectionmanagerextension_getBinary(url, requestId, onBinarySuccess.bind(onSuccess), onError);
		requestId += 1;
		#end
	}
	private static function onBinarySuccess (onSuccess:String -> Void, data:String):Void
	{
		var decoded:Bytes = Base64.decode(data);
		var content:String = decoded.toString();
		onSuccess(content);
	}
	@:allow(IosHttp)
	private static function postJson (url:String, data:String, onSuccess:String -> Void, onError:String -> Void):Void
	{
		trace("postJson",url,data);
		#if ios
		connectionmanagerextension_postJson(url, data, requestId, onSuccess, onError);
		requestId += 1;
		#end
	}
	#if ios
	private static var connectionmanagerextension_isConnected = Lib.load("connectionmanagerextension", "connectionmanagerextension_isConnected", 0);
	private static var connectionmanagerextension_getActiveConnectionType = Lib.load("connectionmanagerextension", "connectionmanagerextension_getActiveConnectionType", 0);
	private static var connectionmanagerextension_getText = Lib.load("connectionmanagerextension", "connectionmanagerextension_getText", 4);
	private static var connectionmanagerextension_getBinary = Lib.load("connectionmanagerextension", "connectionmanagerextension_getBinary", 4);
	private static var connectionmanagerextension_postJson = Lib.load("connectionmanagerextension", "connectionmanagerextension_postJson", 5);
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