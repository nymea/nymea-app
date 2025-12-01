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
    private static final String DEFAULT_CHANNEL_ID = "default-channel";
    private static final String DEFAULT_CHANNEL_NAME = "nymea notifications";

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

        RemoteMessage.Notification notification = remoteMessage.getNotification();
        String title = notification != null ? notification.getTitle() : null;
        String body = notification != null ? notification.getBody() : null;
        if (title == null) {
            title = remoteMessage.getData().get("title");
        }
        if (body == null) {
            body = remoteMessage.getData().get("body");
        }

        Log.d(TAG, "Notification from: " + remoteMessage.getFrom());
        Log.d(TAG, "Notification title: " + title);
        Log.d(TAG, "Notification body: " + body);
        Log.d(TAG, "Notification priority: " + remoteMessage.getPriority());
        Log.d(TAG, "Notification data: " + remoteMessage.getData());
        Log.d(TAG, "Notification message ID: " + remoteMessage.getMessageId());

        if (title == null && body == null && remoteMessage.getData().isEmpty()) {
            Log.w(TAG, "No notification payload received, skipping notification creation.");
            return;
        }

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
        if (resId == 0) {
            resId = getApplicationInfo().icon;
            Log.w(TAG, "Notification icon resource missing, using application icon: " + resId);
        }

        NotificationManager notificationManager = (NotificationManager) getSystemService(Context.NOTIFICATION_SERVICE);
        if (notificationManager == null) {
            Log.w(TAG, "NotificationManager not available, cannot display notification.");
            return;
        }

        String channelId = resolveStringResource("notification_channel_id", DEFAULT_CHANNEL_ID);
        String channelName = resolveStringResource("notification_channel_name", DEFAULT_CHANNEL_NAME);

        // Since android Oreo notification channel is needed.
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            NotificationChannel existingChannel = notificationManager.getNotificationChannel(channelId);
            if (existingChannel == null) {
                NotificationChannel channel = new NotificationChannel(channelId, channelName, NotificationManager.IMPORTANCE_HIGH);
                notificationManager.createNotificationChannel(channel);
            }
        }

        NotificationCompat.Builder notificationBuilder = new NotificationCompat.Builder(this, channelId)
                .setContentTitle(title)
                .setContentText(body)
                .setSmallIcon(resId)
                .setAutoCancel(true)
                .setContentIntent(pendingIntent)
                .setPriority(NotificationCompat.PRIORITY_HIGH);

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

    private String resolveStringResource(String resourceName, String fallback) {
        int resId = getResources().getIdentifier(resourceName, "string", getPackageName());
        if (resId != 0) {
            try {
                String resolved = getString(resId);
                if (resolved != null && !resolved.isEmpty()) {
                    return resolved;
                }
            } catch (Resources.NotFoundException e) {
                Log.w(TAG, "String resource not found for " + resourceName + ", using fallback");
            }
        }
        return fallback;
    }
}
