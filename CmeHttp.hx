package;

class CmeHttp
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
		if (!post)
		{
			if (!this.isBinary)
			{
				ConnectionManagerExtension.getInstance().getText(url, onData, onError);
			}
			else
			{
				ConnectionManagerExtension.getInstance().getBinary(url, onBinaryData, onError, onProgress);
			}
		}
		else
		{
			trace('CmeHttp postData: $postData');
			ConnectionManagerExtension.getInstance().postText(url, postData, onData, onError);
		}
		haxe.Timer.delay(stub, 0);
	}

	private function stub() {}

	public dynamic function onData(data:String):Void
	{

	}

	public dynamic function onBinaryData(data:haxe.io.Bytes):Void
	{

	}

	public dynamic function onError(msg:String):Void
	{
	}

	public dynamic function onProgress(bytes:Int):Void
	{
	}
}