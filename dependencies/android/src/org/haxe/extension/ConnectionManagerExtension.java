package org.haxe.extension;


import android.app.Activity;
import android.content.res.AssetManager;
import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;
import android.view.View;
import android.util.Log;
import android.app.Application;
import java.util.*;
import java.lang.System;

import android.net.ConnectivityManager;
import android.net.wifi.WifiManager;
import android.net.NetworkInfo;

public class ConnectionManagerExtension extends Extension {

	public static boolean isConnected () {
		
		Log.v("ConnectionManagerExtension", "isConnected");
		int r = ConnectionManagerExtension.getActiveConnectionType();
		return r != 0;
	}

	public static int getActiveConnectionType () {

		Log.v("ConnectionManagerExtension", "getActiveConnectionType");
		ConnectivityManager connMgr = (ConnectivityManager)
				mainActivity.getSystemService(Context.CONNECTIVITY_SERVICE);

		NetworkInfo activeInfo = connMgr.getActiveNetworkInfo();
		if (activeInfo != null && activeInfo.isConnected())
		{
			if (activeInfo.getType() == ConnectivityManager.TYPE_WIFI) return 1;
			if (activeInfo.getType() == ConnectivityManager.TYPE_MOBILE) return 2;
		}
		return 0;
	}


	/**
	 * Called when an activity you launched exits, giving you the requestCode 
	 * you started it with, the resultCode it returned, and any additional data 
	 * from it.
	 */
	public boolean onActivityResult (int requestCode, int resultCode, Intent data) {
		
		return true;
		
	}
	
	
	/**
	 * Called when the activity is starting.
	 */
	public void onCreate (Bundle savedInstanceState) {

		//Log.v("AppsFlyerExtension", "onCreate");
	}
	
	
	/**
	 * Perform any final cleanup before an activity is destroyed.
	 */
	public void onDestroy () {
		
		
		
	}
	
	
	/**
	 * Called as part of the activity lifecycle when an activity is going into
	 * the background, but has not (yet) been killed.
	 */
	public void onPause () {
		
		
		
	}
	
	
	/**
	 * Called after {@link #onStop} when the current activity is being 
	 * re-displayed to the user (the user has navigated back to it).
	 */
	public void onRestart () {
		
		
		
	}
	
	
	/**
	 * Called after {@link #onRestart}, or {@link #onPause}, for your activity 
	 * to start interacting with the user.
	 */
	public void onResume () {
		
		
		
	}
	
	
	/**
	 * Called after {@link #onCreate} &mdash; or after {@link #onRestart} when  
	 * the activity had been stopped, but is now again being displayed to the 
	 * user.
	 */
	public void onStart () {
		
		
		
	}
	
	
	/**
	 * Called when the activity is no longer visible to the user, because 
	 * another activity has been resumed and is covering this one. 
	 */
	public void onStop () {
		
		
		
	}
	
	
}