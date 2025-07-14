package io.guh.nymeaapp;

import com.google.firebase.messaging.RemoteMessage;
import com.google.firebase.messaging.FirebaseMessagingService;
import com.google.android.gms.common.ConnectionResult;
import com.google.android.gms.common.GooglePlayServicesUtil;

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

import androidx.core.app.NotificationCompat;

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
    public void onNewToken(String token) {
        Log.d(TAG, "Refreshed token: " + token);
    }

    @Override
    public void onMessageReceived(RemoteMessage remoteMessage) {

        // https://firebase.google.com/docs/reference/android/com/google/firebase/messaging/RemoteMessage

        super.onMessageReceived(remoteMessage);

        Log.d(TAG, "Notification from: " + remoteMessage.getFrom());
        Log.d(TAG, "Notification title: " + remoteMessage.getNotification().getTitle());
        Log.d(TAG, "Notification body: " + remoteMessage.getNotification().getBody());
        Log.d(TAG, "Notification priority: " + remoteMessage.getPriority());
        Log.d(TAG, "Notification data: " + remoteMessage.getData());
        Log.d(TAG, "Notification message ID: " + remoteMessage.getMessageId());

        Intent intent = new Intent(this, NymeaAppActivity.class);
        //intent.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP);
        intent.setAction(Intent.ACTION_SEND);
        intent.putExtra("notificationData", remoteMessage.getData().get("nymeaData"));

        PendingIntent pendingIntent = PendingIntent.getActivity(this, 0, intent, PendingIntent.FLAG_CANCEL_CURRENT | PendingIntent.FLAG_IMMUTABLE);

        // We can't directly access R.drawable.notificationicon from here:
        // When the package is branded, the package name is not "io.guh.nymeaapp" and resources in
        // the res/ folder are built into the app's package which isn't the same as this files package.
        // Because of this, we need to dynamically fetch the resource from the package resources
        int resId = getResources().getIdentifier("notificationicon", "drawable", getPackageName());
        Log.d(TAG, "Notification icon resource: " + resId + " Package:" + getPackageName());

        NotificationManager notificationManager = (NotificationManager) getSystemService(Context.NOTIFICATION_SERVICE);

        // Since android Oreo notification channel is needed.
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            NotificationChannel channel = new NotificationChannel("default-channel", "Default notification channel for nymea-app", NotificationManager.IMPORTANCE_HIGH);
            notificationManager.createNotificationChannel(channel);
        }

        NotificationCompat.Builder notificationBuilder = new NotificationCompat.Builder(this)
                .setContentTitle(remoteMessage.getNotification().getTitle())
                .setContentText(remoteMessage.getNotification().getBody())
                .setSmallIcon(resId)
                .setAutoCancel(true)
                .setContentIntent(pendingIntent);

        boolean sound = remoteMessage.getData().get("sound") == null || remoteMessage.getData().get("sound").equals("true");
        Log.d(TAG, "Notification sound enabled: " + (sound ? "true" : "false"));
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
        notificationManager.notify(0, notificationBuilder.build());
    }
}
