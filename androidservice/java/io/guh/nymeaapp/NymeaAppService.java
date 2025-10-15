package io.guh.nymeaapp;

import android.content.Intent;
import android.os.Binder;
import android.os.IBinder;
import android.os.Parcel;
import android.os.RemoteException;
import android.util.Log;

import org.qtproject.qt.android.bindings.QtService;

// Background service establishing a connection to nymea and providing data on android specific interfaces
// such as IBinder and BroadcastListener

// This service loads the service_main Qt entry point and does most of its work in C++/Qt

public class NymeaAppService extends QtService
{
    public static final String NYMEA_APP_BROADCAST = "io.guh.nymeaapp.NymeaAppService.broadcast";

    private static final String TAG = "nymea-app: NymeaAppService";

    private static native String handleBinderRequest(String payload);

    static {
        System.loadLibrary("service");
    }

    private final IBinder mBinder = new Binder() {
        @Override
        protected boolean onTransact(int code, Parcel data, Parcel reply, int flags) throws RemoteException {
            String request = data.readString();
            String response = NymeaAppService.handleBinderRequest(request);
            if (response != null && !response.isEmpty()) {
                reply.writeString(response);
            }
            return true;
        }
    };

    @Override
    public void onCreate() {
        super.onCreate();
        Log.i(TAG, "Creating Service");
    }

    @Override
    public void onDestroy() {
        super.onDestroy();
        Log.i(TAG, "Destroying Service");
    }

    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {
        int ret = super.onStartCommand(intent, flags, startId);

        // Do some work

        Log.d(TAG, "*************** Service started");

        return ret;
    }

    @Override
    public IBinder onBind(Intent intent) {
        return mBinder;
    }

    public void sendBroadcast(String payload) {
        Intent sendToUiIntent = new Intent();
        sendToUiIntent.setAction(NYMEA_APP_BROADCAST);
        sendToUiIntent.putExtra("data", payload);
//        Log.d(TAG, "Service sending broadcast");
        sendBroadcast(sendToUiIntent);
    }
}
