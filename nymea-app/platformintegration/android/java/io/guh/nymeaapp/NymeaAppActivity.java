package io.guh.nymeaapp;

import java.io.File;

import android.util.Log;
import android.content.Intent;
import android.content.Context;
import android.os.Bundle;
import android.os.Build;
import android.telephony.TelephonyManager;
import android.provider.Settings;
import android.provider.Settings.Secure;
import android.os.Vibrator;
import android.net.Uri;
import android.content.res.Configuration;
import android.content.IntentFilter;
import android.content.BroadcastReceiver;
import android.location.LocationManager;
import android.nfc.NfcAdapter;
import android.nfc.Tag;
import androidx.core.content.FileProvider;

import android.content.pm.ApplicationInfo;
import android.content.pm.PackageManager;
import android.content.res.Resources;

import org.qtproject.qt.android.bindings.QtActivity;

public class NymeaAppActivity extends QtActivity
{
    private static final String TAG = "nymea-app: NymeaAppActivity";
    private static Context context = null;

    private static native void darkModeEnabledChangedJNI();
    private static native void notificationActionReceivedJNI(String data);
    private static native void locationServicesEnabledChangedJNI();

    private BroadcastReceiver m_gpsSwitchStateReceiver = new BroadcastReceiver() {
        @Override
        public void onReceive(Context context, Intent intent) {
            Log.i(TAG, "**** Intent received!!!" + intent.getAction());
            if (LocationManager.MODE_CHANGED_ACTION.equals(intent.getAction())) {
                locationServicesEnabledChangedJNI();
            }
        }
    };

    @Override
    public void onCreate(Bundle savedInstanceState) {
        Log.w(TAG, "Create activity");
        int themeId = resolveStyleResource("NormalTheme");
        if (themeId != 0) {
            setTheme(themeId);
        } else {
            Log.w(TAG, "NormalTheme style missing, falling back to system theme");
            setTheme(android.R.style.Theme_DeviceDefault_DayNight);
        }
        super.onCreate(savedInstanceState);
        this.context = getApplicationContext();
    }

    @Override
    public void onNewIntent(Intent intent) {
        Log.d(TAG, "New intent: " + intent);
        logNfcIntent(intent);

        // QtActivityBase forwards the intent to QtNative. In particular, the Qt NFC
        // backend relies on this call to receive foreground-dispatch NFC intents.
        super.onNewIntent(intent);
        Log.d(TAG, "Intent forwarded to Qt");

        String notificationData = intent.getStringExtra("notificationData");
        if (notificationData != null) {
            Log.d(TAG, "Intent data: " + notificationData);
            notificationActionReceivedJNI(notificationData);
        }
    }

    private void logNfcIntent(Intent intent) {
        String action = intent.getAction();
        if (!NfcAdapter.ACTION_NDEF_DISCOVERED.equals(action)
                && !NfcAdapter.ACTION_TECH_DISCOVERED.equals(action)
                && !NfcAdapter.ACTION_TAG_DISCOVERED.equals(action)) {
            return;
        }

        Tag tag = nfcTagFromIntent(intent);
        if (tag == null) {
            Log.w(TAG, "NFC intent has no android.nfc.extra.TAG; action=" + action
                    + ", extras=" + (intent.getExtras() == null
                            ? "none" : intent.getExtras().keySet()));
            return;
        }

        Log.d(TAG, "NFC intent details: action=" + action
                + ", uid=" + bytesToHex(tag.getId())
                + ", technologies=" + java.util.Arrays.toString(tag.getTechList())
                + ", flags=0x" + Integer.toHexString(intent.getFlags()));
    }

    @SuppressWarnings("deprecation")
    private Tag nfcTagFromIntent(Intent intent) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            return intent.getParcelableExtra(NfcAdapter.EXTRA_TAG, Tag.class);
        }
        return intent.getParcelableExtra(NfcAdapter.EXTRA_TAG);
    }

    private String bytesToHex(byte[] bytes) {
        if (bytes == null || bytes.length == 0) {
            return "<empty>";
        }

        StringBuilder result = new StringBuilder(bytes.length * 3 - 1);
        for (int index = 0; index < bytes.length; ++index) {
            if (index > 0) {
                result.append(':');
            }
            result.append(String.format(java.util.Locale.ROOT, "%02X", bytes[index] & 0xff));
        }
        return result.toString();
    }

    @Override
    public void onResume() {
        super.onResume();

        IntentFilter filter = new IntentFilter(LocationManager.MODE_CHANGED_ACTION);
        // filter.addAction(Intent.ACTION_PROVIDER_CHANGED);
        registerReceiver(m_gpsSwitchStateReceiver, filter);
    }

    @Override
    public void onPause() {
        super.onPause();
        unregisterReceiver(m_gpsSwitchStateReceiver);
    }

    @Override
    public void onConfigurationChanged(Configuration newConfig) {
        super.onConfigurationChanged(newConfig);
        NymeaAppActivity.darkModeEnabledChangedJNI();
    }

    public String notificationData() {
        return getIntent().getStringExtra("notificationData");
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

    public boolean darkModeEnabled() {
        return (getResources().getConfiguration().uiMode & Configuration.UI_MODE_NIGHT_MASK) == Configuration.UI_MODE_NIGHT_YES;
    }

    public boolean locationServicesEnabled() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
            // This is a new method provided in API 28
            LocationManager lm = (LocationManager) getApplicationContext().getSystemService(Context.LOCATION_SERVICE);
            return lm.isLocationEnabled();
        }

        // This was deprecated in API 28
        int mode = Settings.Secure.getInt(getApplicationContext().getContentResolver(), Settings.Secure.LOCATION_MODE, Settings.Secure.LOCATION_MODE_OFF);
        return (mode != Settings.Secure.LOCATION_MODE_OFF);
    }

    private void logStaticInitClassesMetadata() {
        try {
            ApplicationInfo appInfo = getPackageManager().getApplicationInfo(getPackageName(), PackageManager.GET_META_DATA);
            if (appInfo.metaData == null || !appInfo.metaData.containsKey("android.app.static_init_classes")) {
                 Log.w(TAG, "No android.app.static_init_classes meta-data present in the manifest");
                 return;
            }

            Object value = appInfo.metaData.get("android.app.static_init_classes");
            if (!(value instanceof Integer)) {
            Log.w(TAG, "android.app.static_init_classes meta-data is not a resource reference: " + value);
            return;
            }

            int resId = (Integer) value;
            if (resId == 0) {
            Log.e(TAG, "android.app.static_init_classes meta-data resolves to resource id 0");
            return;
            }

            try {
             String resName = getResources().getResourceName(resId);
             String resValue = getResources().getString(resId);
             Log.i(TAG, "android.app.static_init_classes -> " + resName + " = " + resValue);
            } catch (Resources.NotFoundException notFoundException) {
             Log.e(TAG, "android.app.static_init_classes references missing resource 0x" + Integer.toHexString(resId), notFoundException);
            }
        } catch (PackageManager.NameNotFoundException exception) {
            Log.e(TAG, "Failed to inspect android.app.static_init_classes meta-data", exception);
        }
    }

    private int resolveStyleResource(String resourceName) {
        // Resolve app resources dynamically to support branded package names.
        return getResources().getIdentifier(resourceName, "style", getPackageName());
    }
}
