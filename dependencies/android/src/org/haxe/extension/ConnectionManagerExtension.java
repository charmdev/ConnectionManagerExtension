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
import android.os.AsyncTask;
import java.util.*;
import java.util.regex.Pattern;
import java.lang.System;
import java.net.URL;
import java.net.URLConnection;
import java.net.HttpURLConnection;
import javax.net.ssl.HttpsURLConnection;
import java.io.InputStream;
import java.io.OutputStream;
import java.io.InputStreamReader;
import java.io.DataOutputStream;
import java.io.BufferedInputStream;
import java.io.ByteArrayOutputStream;
import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.OutputStreamWriter;
import java.io.IOException;
import java.lang.Exception;
import java.lang.StringBuffer;
import java.net.MalformedURLException;
import java.net.URLEncoder;

import android.net.ConnectivityManager;
import android.net.wifi.WifiManager;
import android.net.NetworkInfo;
import android.util.Base64;

import android.opengl.GLSurfaceView;
import org.haxe.lime.HaxeObject;



public class ConnectionManagerExtension extends Extension {

	private static class LoadingParams {
		public String requestUrl;
		public int requestId;
		public HaxeObject callbackObject;
		public boolean isBinary;
		public String postData;
		public String[] headers;

		public LoadingParams(String requestUrl, int requestId, HaxeObject callbackObject, boolean isBinary, String postData, String[] headers) {
			this.requestUrl = requestUrl;
			this.requestId = requestId;
			this.callbackObject = callbackObject;
			this.isBinary = isBinary;
			this.postData = postData;
			this.headers = headers;
		}
	}

	private static class LoadingTask extends AsyncTask<LoadingParams, Integer, String> {

		private LoadingParams loadingParams;
		private Exception error=null;

		@Override
		protected void onPreExecute() {

		}

		@Override
		protected String doInBackground(LoadingParams... params) {
			loadingParams = params[0];

			String result = "";

			HttpURLConnection connection = null;
			try {
				URL url = new URL(loadingParams.requestUrl);

				if (isHttps(loadingParams.requestUrl)) {
					connection = (HttpsURLConnection) url.openConnection();
				}
				else {
					connection = (HttpURLConnection) url.openConnection();
				}
				connection.setConnectTimeout(5000);
				connection.setReadTimeout(30000);

				for (int i = 0; i < loadingParams.headers.length; i += 2)
				{
					connection.setRequestProperty(loadingParams.headers[i], loadingParams.headers[i + 1]);
					Log.i(TAG, "add header " + loadingParams.headers[i] + ":" + loadingParams.headers[i + 1]);
				}
				if (loadingParams.postData != null) 
				{
					Log.i(TAG, "is post");
					sendDataForResponse(connection, loadingParams.postData);
				}

				int respCode = connection.getResponseCode();
				Log.i(TAG, "post response code "+String.valueOf(respCode));
				Log.i(TAG , "post response message "+connection.getResponseMessage());
					
				if (respCode == HttpURLConnection.HTTP_OK)
				{
					result = readData(connection, loadingParams.isBinary);
				}
				else if (respCode == HttpURLConnection.HTTP_NO_CONTENT)
				{
					result = "";
				}
				else 
				{
					throw new Exception(String.valueOf(respCode));
				}
				Log.i(TAG, "success" + loadingParams.requestUrl);
			}
			catch (IOException e) {
				Log.i(TAG, "io error " + e.toString());
				error = e;
			}
			catch (Exception e) {
				Log.i(TAG, "error " + e.toString());
				error = e;
			}
			finally {
				connection.disconnect();
			}
			return result;
		}

		@Override
		protected void onProgressUpdate(Integer... values) {
			if (loadingParams != null) {
				final int progress = values[0];
				final int requestId = loadingParams.requestId;
				final HaxeObject callbackObject = loadingParams.callbackObject;

				Extension.sendHaxe(new Runnable() {
					@Override
					public void run() {
						callbackObject.call2("onProgress_jni", requestId, progress);
					}
				});
			}
		}

		@Override
		protected void onPostExecute(final String result) {
			super.onPostExecute(result);

			final int requestId = loadingParams.requestId;
			final HaxeObject callbackObject = loadingParams.callbackObject;
			if (error != null) {
				final String errorMesage = error.getMessage();

				Extension.sendHaxe(new Runnable() {
					@Override
					public void run() {
						callbackObject.call2("onError_jni", requestId, errorMesage);
					}
				});
			}
			else {
				Extension.sendHaxe(new Runnable() {
					@Override
					public void run() {
						callbackObject.call2("onSuccess_jni", requestId, result);
					}
				});
			}
			loadingParams = null;
		}

		private int sendDataForResponse(HttpURLConnection connection, String data) throws Exception {
			int respCode = -1;
			connection.setRequestMethod("POST");
			connection.setRequestProperty("Content-Type", "application/json; charset=UTF-8");
			connection.setDoOutput(true);
			connection.setDoInput(true);
			connection.connect();
			OutputStream os = connection.getOutputStream();
			BufferedWriter writer = new BufferedWriter(new OutputStreamWriter(os, "UTF-8"));

			writer.write(data);
			writer.flush();
			writer.close();
			os.close();

			respCode = connection.getResponseCode();

			return  respCode;
		}

		private String readData(HttpURLConnection connection, boolean isBinary) throws Exception{
			String result;
			InputStream in = new BufferedInputStream(connection.getInputStream());

			if (isBinary){
				result = readBinaryStream(in);
			}
			else {
				result = readTextStream(in);
			}

			in.close();

			return result;
		}


		private String readBinaryStream(InputStream in) throws Exception{

			byte[] data;
			int progress = 0;
			ByteArrayOutputStream bo = new ByteArrayOutputStream();
			int i;
			while((i = in.read()) != -1){
				bo.write((char) i);
				progress ++;
				if (progress % 512 == 0) {
					publishProgress(progress);
				}
				//Log.i(TAG, "progress:" + progress);// + " of " + length + " loaded");
			}

			data = bo.toByteArray();

			return Base64.encodeToString(data, Base64.NO_PADDING | Base64.NO_WRAP);
		}

		private String readTextStream(InputStream in) throws Exception{
			String data = "";

			StringBuffer sb = new StringBuffer();
			BufferedReader br = new BufferedReader(new InputStreamReader(in));
			String i = "";
			while((i = br.readLine()) != null){
				sb.append(i);
			}

			data = sb.toString();

			return data;
		}

		private static boolean isHttps(String url)
		{
			return Pattern.matches("^https:", url);
		}
	}

	private static final String TAG = "CME trace hx";
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

	public static void getBinary(String requestUrl, int requestId, HaxeObject callbackObject, String[] headers){
		sendRequest(requestUrl, requestId, callbackObject, true,  null, headers);
	}

	public static void getText(String requestUrl, int requestId, HaxeObject callbackObject, String[] headers){
		sendRequest(requestUrl, requestId, callbackObject, false, null, headers);
	}

	public static void postText(String requestUrl, int requestId, HaxeObject callbackObject, String data, String[] headers){
		sendRequest(requestUrl, requestId, callbackObject, false, data, headers);
	}

	private static void sendRequest(String requestUrl, int requestId, HaxeObject callbackObject, boolean isBinary, String postData, String[] headers) {
		LoadingParams p = new LoadingParams(requestUrl, requestId, callbackObject, isBinary, postData, headers);
		AsyncTask task = new LoadingTask().executeOnExecutor(AsyncTask.THREAD_POOL_EXECUTOR, p);
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