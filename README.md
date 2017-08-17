# ConnectionManagerExtension
Extension for OpenFl to check connection status (iOs, Android)

Additional: load/post data on iOS using `NSURLSession` class 

Usage:
`ConnectionManagerExtension.isConnected()` - Does the device has a active connection of any type.

`ConnectionManagerExtension.getConnectionType()` - Get the type of the active connection (NONE / WIFI / MOBILE)

`ConnectionManagerExtension.getText(url:String, onSuccess:String -> Void, onError:String -> Void)` - iOS only. Load text data from url, using `NSURLSession` class

`ConnectionManagerExtension.getBinary(url:String, onSuccess:String -> Void, onError:String -> Void)` - iOS only. Load binary data from url, using `NSURLSession` class

`ConnectionManagerExtension.postJson(url:String, data:Dynamic, onSuccess:String -> Void, onError:String -> Void)` - iOS only. Post data (JSON mainly) to url, using `NSURLSession` class