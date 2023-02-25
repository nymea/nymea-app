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

    private int hashId(String id) {
        int hash = 7;
        for (int i = 0; i < id.length(); i++) {
            hash = hash * 31 + id.charAt(i);
        }
        return hash;
    }

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

        NotificationManager notificationManager = (NotificationManager) getSystemService(Context.NOTIFICATION_SERVICE);

        // Make sure channels exist
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            NotificationChannel alertChannel = new NotificationChannel("alert", "Alerts about your nymea system", NotificationManager.IMPORTANCE_HIGH);
            notificationManager.createNotificationChannel(alertChannel);
            NotificationChannel infoChannel = new NotificationChannel("info", "Information about your nymea system", NotificationManager.IMPORTANCE_LOW);
            notificationManager.createNotificationChannel(infoChannel);
        }


        Intent intent = new Intent(this, NymeaAppActivity.class);
        Log.d(TAG, "Notification data: " + remoteMessage.getData());

        String notificationIdString = remoteMessage.getData().get("notificationId");
        Log.d(TAG, "NotificationID " + notificationIdString);
        int notificationId = new Random().nextInt(60000);;
        if (notificationIdString != null) {
            notificationId = hashId(notificationIdString);
        }

        boolean sound = remoteMessage.getData().get("sound") == null || remoteMessage.getData().get("sound").equals("true");
        boolean remove = remoteMessage.getData().get("remove") != null && remoteMessage.getData().get("remove").equals("true");
        Log.d(TAG, "NotificationID " + notificationIdString + " int " + notificationId + " remove: " + (remove ? "yes" : "no") + " sound: " + (sound ? "yes" : "no"));

        if (remove) {
            notificationManager.cancel(notificationId);
            return;
        }

        intent.setAction(Intent.ACTION_SEND);
        intent.putExtra("notificationData", remoteMessage.getData().get("nymeaData"));

        PendingIntent pendingIntent = PendingIntent.getActivity(this, 0 /* Request code */, intent, PendingIntent.FLAG_CANCEL_CURRENT | PendingIntent.FLAG_MUTABLE);

        // We can't directly access R.drawable.notificationicon from here:
        // When the package is branded, the package name is not "io.guh.nymeaapp" and resources in
        // the res/ folder are built into the app's package which isn't the same as this files package.
        // Because of this, we need to dynamically fetch the resource from the package resources
        int resId = getResources().getIdentifier("notificationicon", "drawable", getPackageName());

        Log.d(TAG, "notification icon resource: " + resId + " Package:" + getPackageName());

        NotificationCompat.Builder notificationBuilder = new NotificationCompat.Builder(this, sound ? "alert" : "info")
                .setSmallIcon(resId)
                .setColor(0xFF57BAAE)
                .setContentTitle(remoteMessage.getData().get("title"))
                .setContentText(remoteMessage.getData().get("body"))
                .setAutoCancel(true)
                .setContentIntent(pendingIntent);

        if (sound) {
            notificationBuilder.setSound(android.provider.Settings.System.DEFAULT_RINGTONE_URI);
        }


        // Action tests
//        Intent actionIntent = new Intent(this, NymeaAppActivity.class);
//        actionIntent.setAction(Intent.ACTION_SEND);
//        actionIntent.putExtra("foobar", "baz");
//        PendingIntent actionPendingIntent = PendingIntent.getActivity(this, 0 /* Request code */, actionIntent, PendingIntent.FLAG_CANCEL_CURRENT);

//        notificationBuilder.addAction(resId, "30%", actionPendingIntent);
//        notificationBuilder.addAction(resId, "50%", actionPendingIntent);
//        notificationBuilder.addAction(resId, "70%", actionPendingIntent);
        // Action tests end


        Log.d(TAG, "Posting Notification: " + remoteMessage.getMessageId());
        notificationManager.notify(notificationId, notificationBuilder.build());

    }

}
