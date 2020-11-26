package;

#if cpp
import cpp.Lib;
#elseif neko
import neko.Lib;
#end

#if (android && openfl)
import nme.utils.JNI;
#end

import haxe.Json;
import haxe.crypto.Base64;
import haxe.io.Bytes;



typedef Callbacks = 
{
	onSuccess:String->Void,
	onError:String->Void,
	onProgress:Int->Void
};

@:headerCode('
	#include <android/log.h>
	#define ELOG(args...) __android_log_print(ANDROID_LOG_ERROR, "NME",args)
')
class ConnectionManagerExtension {
	private var requestId:Int = 0;
	private static var instance:ConnectionManagerExtension;

	#if ios
	private static var connectionmanagerextension_isConnected = Lib.load("connectionmanagerextension", "connectionmanagerextension_isConnected", 0);
	private static var connectionmanagerextension_getActiveConnectionType = Lib.load("connectionmanagerextension", "connectionmanagerextension_getActiveConnectionType", 0);
	private static var connectionmanagerextension_connectionStatusCallback = Lib.load("connectionmanagerextension", "connectionmanagerextension_connectionStatusCallback", 1);
	private static var connectionmanagerextension_getText = Lib.load("connectionmanagerextension", "connectionmanagerextension_getText", 5);
	private static var connectionmanagerextension_getBinary = Lib.load("connectionmanagerextension", "connectionmanagerextension_getBinary", -1);
	private static var connectionmanagerextension_postJson = Lib.load("connectionmanagerextension", "connectionmanagerextension_postJson", -1);
	#elseif (android)	
	private var connectionmanagerextension_isConnected_jni:Dynamic;
	private var connectionmanagerextension_getActiveConnectionType_jni:Dynamic;
	private var connectionmanagerextension_getBinary_jni:Dynamic;
	private var connectionmanagerextension_getText_jni:Dynamic;
	private var connectionmanagerextension_postText_jni:Dynamic;
	private var callbacks:Map<Int, Callbacks> = [];
	#end

	private function new()
	{
		init();
	}

	public static function getInstance():ConnectionManagerExtension
	{
		if (instance == null)
		{
			instance = new ConnectionManagerExtension();
		}
		untyped __cpp__('ELOG("CME hx instance: %p", &::ConnectionManagerExtension_obj::instance)');
		return instance;
	}

	private function init():Void
	{
		#if (android)
			connectionmanagerextension_isConnected_jni = JNI.createStaticMethod("org.haxe.extension.ConnectionManagerExtension", "isConnected", "()Z");
			connectionmanagerextension_getActiveConnectionType_jni = JNI.createStaticMethod("org.haxe.extension.ConnectionManagerExtension", "getActiveConnectionType", "()I");
			connectionmanagerextension_getBinary_jni = JNI.createStaticMethod("org.haxe.extension.ConnectionManagerExtension", "getBinary", "(Ljava/lang/String;ILorg/haxe/lime/HaxeObject;[Ljava/lang/String;)V");
			connectionmanagerextension_getText_jni = JNI.createStaticMethod("org.haxe.extension.ConnectionManagerExtension", "getText", "(Ljava/lang/String;ILorg/haxe/lime/HaxeObject;[Ljava/lang/String;)V");
			connectionmanagerextension_postText_jni = JNI.createStaticMethod("org.haxe.extension.ConnectionManagerExtension", "postText", "(Ljava/lang/String;ILorg/haxe/lime/HaxeObject;Ljava/lang/String;[Ljava/lang/String;)V");
		#end
	}

	public function isConnected():Bool
	{
		#if (android && openfl)
			return connectionmanagerextension_isConnected_jni();
		#elseif ios
			return connectionmanagerextension_isConnected();
		#else
			return true;
		#end
	}

	public function getConnectionType():ConnectionType
	{

		var type = 0;

		#if (android && openfl)
		type = connectionmanagerextension_getActiveConnectionType_jni();
		#elseif ios
		type = connectionmanagerextension_getActiveConnectionType();
		#end

		return getConnectionTypeFromInt(type);
	}

	private function getConnectionTypeFromInt (t: Int): ConnectionType
	{
		var res:ConnectionType = switch(t)
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

	public function connectionStatusCallback (callback:ConnectionType -> Void):Void
	{
		#if ios
		connectionmanagerextension_connectionStatusCallback(onConnectionChanged.bind(callback));
		#end
	}

	private function onConnectionChanged (callback:ConnectionType -> Void, status:Int):Void
	{
		callback(getConnectionTypeFromInt(status));
	}

	@:allow(CmeHttp)
	private function getText (url:String, onSuccess:String -> Void, onError:String -> Void, headers:Array<String>):Void
	{
		#if android
		addCallbacks(requestId, onSuccess, onError);
		connectionmanagerextension_getText_jni(url, requestId, getInstance(), headers);
		#elseif ios
		connectionmanagerextension_getText(url, requestId, onSuccess, onError, headers);
		#end
		requestId += 1;
	}

	@:allow(CmeHttp)
	private function getBinary (url:String, onSuccess:Bytes -> Void, onError:String -> Void, onProgress:Int -> Void, headers:Array<String>):Void
	{
		#if android
		addCallbacks(requestId, onBinarySuccess.bind(onSuccess), onError, onProgress);
		connectionmanagerextension_getBinary_jni(url, requestId, getInstance(), headers);
		#elseif ios
		connectionmanagerextension_getBinary(url, requestId, onBinarySuccess.bind(onSuccess), onProgress, onError, headers);
		#end
		requestId += 1;
	}

	@:allow(CmeHttp)
	private function postText (url:String, data:String, onSuccess:String -> Void, onError:String -> Void, headers:Array<String>):Void
	{
		#if android
		addCallbacks(requestId, onSuccess, onError);
		connectionmanagerextension_postText_jni(url, requestId, getInstance(), data, headers);
		#elseif ios
		connectionmanagerextension_postJson(url, data, requestId, onSuccess, onError, headers);
		#end
		requestId += 1;
	}

#if android
	private function addCallbacks(requestId:Int, onSuccess:String -> Void, onError:String -> Void, ?onProgress:Int -> Void):Void
	{
		var c:Callbacks =
		{
			onSuccess:onSuccess,
			onError:onError,
			onProgress:onProgress
		};
		callbacks[requestId] = c;
	}

	public function onProgress_jni(requestId:Int, progress:Int) {
		trace('onProgress_jni: $requestId');
		var c = callbacks[requestId];
		trace('requestId: $requestId, $c');
		if (c.onProgress != null) c.onProgress(progress);
	}

	public function onSuccess_jni(requestId:Int, data:String) {
		trace('onSuccess_jni: $requestId');
		trace('onSuccess_jni1: $callbacks');
		trace('onSuccess_jni2: ${callbacks.exists(requestId)}');
		var c = callbacks[requestId];
		trace('onSuccess_jni3:');
		trace('requestId: $requestId, $c');
		c.onSuccess(data);
	}

	public function onError_jni(requestId:Int, data:String) {
		trace('onError_jni: $requestId');
		var c = callbacks[requestId];
		trace('requestId: $requestId, $c');
		c.onError(data);
	}
#end

	private function onSuccessImpl (data:String):Void
	{
	}

	private function onErrorImpl (error:String):Void
	{
	}

	private function onBinarySuccess (onSuccess:Bytes -> Void, data:String):Void
	{
		try
		{
			var decoded:Bytes = Base64.decode(data);
			onSuccess(decoded);
		}
		catch (e:Dynamic)
		{
			
		}
	}
}

enum ConnectionType
{
	NONE;
	WIFI;
	MOBILE;
}

typedef CallbackObject =
{
	function onSuccess(data:String):Void;
	function onError(error:String):Void;
}
