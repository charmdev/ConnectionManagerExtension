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



	private var requestId:Int = 0;
	private static var instance:ConnectionManagerExtension;

	#if ios
	private var connectionmanagerextension_isConnected;
	private var connectionmanagerextension_getActiveConnectionType;
	private var connectionmanagerextension_connectionStatusCallback;
	private var connectionmanagerextension_getText;
	private var connectionmanagerextension_getBinary;
	private var connectionmanagerextension_postJson;
	#elseif (android && openfl)
	public var onSuccess_jni:String -> Void;
	public var onError_jni:String -> Void;
	public var onProgress_jni:Int -> Void;
	private var connectionmanagerextension_isConnected_jni:Dynamic;
	private var connectionmanagerextension_getActiveConnectionType_jni:Dynamic;
	private var connectionmanagerextension_getBinary_jni:Dynamic;
	private var connectionmanagerextension_getText_jni:Dynamic;
	private var connectionmanagerextension_postText_jni:Dynamic;
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

		return instance;
	}

	private function init():Void
	{
		#if ios
		connectionmanagerextension_isConnected = Lib.load("connectionmanagerextension", "connectionmanagerextension_isConnected", 0);
		connectionmanagerextension_getActiveConnectionType = Lib.load("connectionmanagerextension", "connectionmanagerextension_getActiveConnectionType", 0);
		connectionmanagerextension_connectionStatusCallback = Lib.load("connectionmanagerextension", "connectionmanagerextension_connectionStatusCallback", 1);
		connectionmanagerextension_getText = Lib.load("connectionmanagerextension", "connectionmanagerextension_getText", 4);
		connectionmanagerextension_getBinary = Lib.load("connectionmanagerextension", "connectionmanagerextension_getBinary", 4);
		connectionmanagerextension_postJson = Lib.load("connectionmanagerextension", "connectionmanagerextension_postJson", 5);
		#elseif (android && openfl)
		connectionmanagerextension_isConnected_jni = JNI.createStaticMethod("org.haxe.extension.ConnectionManagerExtension", "isConnected", "()Z");
		connectionmanagerextension_getActiveConnectionType_jni = JNI.createStaticMethod("org.haxe.extension.ConnectionManagerExtension", "getActiveConnectionType", "()I");
		connectionmanagerextension_getBinary_jni = JNI.createStaticMethod("org.haxe.extension.ConnectionManagerExtension", "getBinary", "(Ljava/lang/String;ILorg/haxe/lime/HaxeObject;)V");
		connectionmanagerextension_getText_jni = JNI.createStaticMethod("org.haxe.extension.ConnectionManagerExtension", "getText", "(Ljava/lang/String;ILorg/haxe/lime/HaxeObject;)V");
		connectionmanagerextension_postText_jni = JNI.createStaticMethod("org.haxe.extension.ConnectionManagerExtension", "postText", "(Ljava/lang/String;ILorg/haxe/lime/HaxeObject;Ljava/lang/String;)V");
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
		trace("connectionStatusCallback");
		#if ios
		connectionmanagerextension_connectionStatusCallback(onConnectionChanged.bind(callback));
		#end
	}

	private function onConnectionChanged (callback:ConnectionType -> Void, status:Int):Void
	{
		callback(getConnectionTypeFromInt(status));
	}

	@:allow(CmeHttp)
	private function getText (url:String, onSuccess:String -> Void, onError:String -> Void):Void
	{
		trace("getText",url);
		#if android
		onSuccess_jni = onSuccess;
		onError_jni = onError;
		connectionmanagerextension_getText_jni(url, requestId, getInstance());
		#elseif ios
		connectionmanagerextension_getText(url, requestId, onSuccess, onError);
		#end
		requestId += 1;
	}

	@:allow(CmeHttp)
	private function getBinary (url:String, onSuccess:String -> Void, onError:String -> Void, onProgress:Int -> Void):Void
	{
		trace("getBinary",url);
		#if android
		onSuccess_jni = onBinarySuccess.bind(onSuccess);
		onError_jni = onError;
		onProgress_jni = onProgress;
		connectionmanagerextension_getBinary_jni(url, requestId, getInstance());
		#elseif ios
		connectionmanagerextension_getBinary(url, requestId, onBinarySuccess.bind(onSuccess), onError);
		#end
		requestId += 1;
	}

	@:allow(CmeHttp)
	private function postText (url:String, data:String, onSuccess:String -> Void, onError:String -> Void):Void
	{
		trace("postText",url,data);
		#if android
		onSuccess_jni = onSuccess;
		onError_jni = onError;
		connectionmanagerextension_postText_jni(url, requestId, getInstance(), data);
		#elseif ios
		connectionmanagerextension_postJson(url, data, requestId, onSuccess, onError);
		requestId += 1;
		#end
	}

	private function onSuccessImpl (data:String):Void
	{
		trace('hx success!!! ${data}');
	}

	private function onErrorImpl (error:String):Void
	{
		trace("hx serror!!!");
	}

	private function onBinarySuccess (onSuccess:String -> Void, data:String):Void
	{
		try
		{
			var decoded:Bytes = Base64.decode(data);
			var content:String = decoded.toString();
			onSuccess(content);
		}
		catch (e:Dynamic)
		{
			trace('error! ${e}');
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