# ConnectionManagerExtension
Extension OpenFl/NME for networking using Android and IOS SDK.

Additional: load/post data on iOS using `NSURLSession` class 

Usage:
`ConnectionManagerExtension.isConnected()` - Does the device has a active connection of any type.

`ConnectionManagerExtension.getConnectionType()` - Get the type of the active connection (NONE / WIFI / MOBILE)

`ConnectionManagerExtension.getText(url:String, onSuccess:String -> Void, onError:String -> Void)` - Load text data from url.

`ConnectionManagerExtension.getBinary(url:String, onSuccess:String -> Void, onError:String -> Void)` - Load binary data from url.

`ConnectionManagerExtension.postJson(url:String, data:Dynamic, onSuccess:String -> Void, onError:String -> Void)` - Post data (JSON mainly) to url.
