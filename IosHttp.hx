package;

import haxe.Json;
import msignal.Signal;

class IosHttp
{
	public var url : String;
	public var responseData(default, null) : Null<String>;
	private var postData:String;
	private var isBinary:Bool;

	public function new(url:String, isBinary:Bool = false) {
		this.isBinary = isBinary;
		this.url = url;
	}

	public function setPostData(data:String):Void {
		postData = data;
	}

	public function cancel():Void
	{

	}

	public function request(?post:Bool):Void {
		if (!post) {
			if (!this.isBinary) {
				ConnectionManagerExtension.getText(url, onData, onError);
			} else {
				ConnectionManagerExtension.getBinary(url, onData, onError);
			}
		} else {
			ConnectionManagerExtension.postJson(url, postData, onData, onError);
		}
	}

	public dynamic function onData(data:String):Void {
	}

	public dynamic function onError(msg:String):Void {
	}
}