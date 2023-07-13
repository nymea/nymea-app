package io.guh.nymeaapp;

import android.content.Context;
import android.content.Intent;
import android.util.Log;

import org.qtproject.qt5.android.bindings.QtService;


import com.google.android.gms.home.matter.commissioning.CommissioningCompleteMetadata;
import com.google.android.gms.home.matter.commissioning.CommissioningRequestMetadata;
import com.google.android.gms.home.matter.commissioning.CommissioningService;
import com.google.android.gms.home.matter.commissioning.CommissioningService.CommissioningError;


// Background service establishing a connection to nymea and providing data on android specific interfaces
// such as IBinder and BroadcastListener

// This service loads the service_main Qt entry point and does most of its work in C++/Qt

public class NymeaAppService extends QtService implements CommissioningService.Callback
{
    public static final String NYMEA_APP_BROADCAST = "io.guh.nymeaapp.NymeaAppService.broadcast";

    private static final String TAG = "nymea-app: NymeaAppService";

    @Override
    public void onCreate() {
        super.onCreate();
        Log.i(TAG, "Creating Service");



        CommissioningService commissioningService = new CommissioningService.Builder(this).setCallback(this).build();

    }

    public void onCommissioningRequested(CommissioningRequestMetadata metaData) {
        Log.d(TAG, "Commissioning requested!");
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

    public void sendBroadcast(String payload) {
        Intent sendToUiIntent = new Intent();
        sendToUiIntent.setAction(NYMEA_APP_BROADCAST);
        sendToUiIntent.putExtra("data", payload);
//        Log.d(TAG, "Service sending broadcast");
        sendBroadcast(sendToUiIntent);
    }
}
