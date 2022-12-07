package io.guh.nymeaapp;

import android.util.Log;
import android.content.Context;
import android.content.Intent;
import android.app.PendingIntent;

import android.content.BroadcastReceiver;


public class NymeaAppBroadcastReceiver extends BroadcastReceiver
{
    private static final String TAG = "nymea-app: BroadcastReceiver";

    public void onReceive(Context context, Intent intent) {
        String action = intent.getAction();
        Log.d(TAG, "Broadcast received: " + action);

    }
}
