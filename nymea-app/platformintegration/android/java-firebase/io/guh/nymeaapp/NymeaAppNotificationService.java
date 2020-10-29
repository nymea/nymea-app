package io.guh.nymeaapp;

import com.google.firebase.messaging.RemoteMessage;
import com.google.firebase.messaging.FirebaseMessagingService;
import com.google.android.gms.common.GooglePlayServicesUtil;
import com.google.android.gms.common.ConnectionResult;

import android.util.Log;
import android.content.Intent;
import android.graphics.drawable.Drawable;
import android.app.PendingIntent;
import android.app.Notification;
import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.net.Uri;
import android.content.Context;
import android.provider.Settings.System;
import android.os.Build;
import android.content.pm.PackageManager;
import android.content.res.Resources;
import android.support.v4.app.NotificationCompat;

import java.util.Random;


public class NymeaAppNotificationService extends FirebaseMessagingService {

    private static final String TAG = "nymea-app: NymeaAppNotificationService";

    public static boolean checkPlayServices() {
        Log.d(TAG, "Checking for Google Play services");
        try {
            Context context = NymeaAppActivity.getAppContext();
            int resultCode = GooglePlayServicesUtil.isGooglePlayServicesAvailable(context);
            return resultCode == ConnectionResult.SUCCESS;
        } catch (Exception e) {
            Log.d(TAG, e.toString());
        }
        return true;
    }

    @Override
    public void onMessageReceived(RemoteMessage remoteMessage) {
        Intent intent = new Intent(this, NymeaAppActivity.class);
//        intent.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP);
//        PendingIntent pendingIntent = PendingIntent.getActivity(this, 0 /* Request code */, intent, PendingIntent.FLAG_ONE_SHOT);
        PendingIntent pendingIntent = PendingIntent.getActivity(this, 0 /* Request code */, intent, 0);

        // We can't directly access R.drawable.ic_stat_notification from here:
        // When the package is branded, the package name is not "io.guh.nymeaapp" and resources in
        // the res/ folder are built into the app's package which isn't the same as this files package.
        // Because of this, we need to dynamically fetch the resource from the package resources
        int resId = getResources().getIdentifier("ic_stat_notificationicon", "drawable", getPackageName());

        Log.d(TAG, "notification icon resource: " + resId + " Package:" + getPackageName());

        NotificationCompat.Builder notificationBuilder = new NotificationCompat.Builder(this, "notify_001")
                .setSmallIcon(resId)
                .setColor(0xFF57BAAE)
                .setContentTitle(remoteMessage.getData().get("title"))
                .setContentText(remoteMessage.getData().get("body"))
                .setAutoCancel(true)
                .setSound(android.provider.Settings.System.DEFAULT_RINGTONE_URI)
                .setContentIntent(pendingIntent);

        NotificationManager notificationManager = (NotificationManager) getSystemService(Context.NOTIFICATION_SERVICE);

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            NotificationChannel channel = new NotificationChannel("notify_001", "Channel human readable title", NotificationManager.IMPORTANCE_HIGH);
            notificationManager.createNotificationChannel(channel);
        }


        int notificationId = new Random().nextInt(60000);

        Log.d(TAG, "Posting Notification: " + remoteMessage.getMessageId());
        notificationManager.notify(notificationId, notificationBuilder.build());

    }

}
