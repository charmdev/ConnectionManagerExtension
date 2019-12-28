package;

class CmeHttp
{
	public var url : String;
	public var responseData(default, null) : Null<String>;
	private var postData:String;
	private var isBinary:Bool;
	private var headers:Array<String>;

	public function new(url:String, isBinary:Bool = false) {
		this.isBinary = isBinary;
		this.url = url;
		headers = [];
	}

	public function setPostData(data:String):Void {
		postData = data;
	}

	public function addHeader(name:String, value:String):Void
	{
		headers.push(name);
		headers.push(value);
	}

	public function cancel():Void
	{

	}

	public function request(?post:Bool):Void {
        trace('------------------------------> CME REQUEST HEADERS ${headers}');
		if (!post)
		{
			if (!this.isBinary)
			{
				ConnectionManagerExtension.getInstance().getText(url, onData, onError, headers);
			}
			else
			{
				ConnectionManagerExtension.getInstance().getBinary(url, onBinaryData, onError, onProgress, headers);
			}
		}
		else
		{
			ConnectionManagerExtension.getInstance().postText(url, postData, onData, onError, headers);
		}
		haxe.Timer.delay(stub, 16);
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