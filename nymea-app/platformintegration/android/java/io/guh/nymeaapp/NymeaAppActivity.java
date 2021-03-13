package io.guh.nymeaapp;

import java.io.File;

import android.util.Log;
import android.content.Intent;
import android.content.Context;
import android.os.Bundle;
import android.os.Build;
import android.telephony.TelephonyManager;
import android.provider.Settings.Secure;
import android.os.Vibrator;
import android.net.Uri;
import android.support.v4.content.FileProvider;

public class NymeaAppActivity extends org.qtproject.qt5.android.bindings.QtActivity
{
    private static final String TAG = "nymea-app: NymeaAppActivity";
    private static Context context = null;

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        this.context = getApplicationContext();
    }

    public static Context getAppContext() {
        return NymeaAppActivity.context;
    }

    public String deviceSerial()
    {
        return Secure.getString(getApplicationContext().getContentResolver(), Secure.ANDROID_ID);
    }

    public static String deviceManufacturer()
    {
        return Build.MANUFACTURER;
    }

    public static String deviceModel()
    {
        return Build.MODEL;
    }

    public static String device()
    {
        return Build.DEVICE;
    }

    public void vibrate(int duration)
    {
        Vibrator v = (Vibrator) getSystemService(Context.VIBRATOR_SERVICE);
        v.vibrate(duration);
    }

    public void shareFile(String fileName) {
        Intent sendIntent = new Intent();
        sendIntent.setAction(Intent.ACTION_SEND);
        sendIntent.setType("text/plain");
        Uri uri = FileProvider.getUriForFile(getApplicationContext(), getPackageName() + ".fileprovider", new File(fileName));
        sendIntent.putExtra(Intent.EXTRA_STREAM, uri);
        if (sendIntent.resolveActivity(getPackageManager()) != null) {
            startActivity(sendIntent);
        } else {
            Log.d(TAG, "Intent not resolved");
        }
    }
}
