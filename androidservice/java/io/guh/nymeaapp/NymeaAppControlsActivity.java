package io.guh.nymeaapp;
import android.util.Log;
import android.content.Intent;
import android.content.Context;
import android.os.Bundle;
import android.os.Build;
import android.telephony.TelephonyManager;
import android.provider.Settings.Secure;
import android.os.Vibrator;
import android.os.Process;
import android.nfc.NfcAdapter;
import android.nfc.NdefMessage;
import android.os.Parcelable;

// An activity spawned by android device controls on demand.

public class NymeaAppControlsActivity extends org.qtproject.qt5.android.bindings.QtActivity
{
    private static final String TAG = "nymea-app: NymeaAppControlActivity";


    @Override public void onPause() {
        Log.d(TAG, "Pausing...");
        System.exit(0);
    }

    @Override public void onResume() {
        super.onResume();
        Log.d(TAG, "Resuming...");
    }

    @Override public void onDestroy() {
        Log.d(TAG, "Destroying...");
    }

    public boolean startedByNfc() {
        return NfcAdapter.ACTION_NDEF_DISCOVERED.equals(getIntent().getAction());
    }

    public String nymeaId()
    {
        return getIntent().getStringExtra("nymeaId");
    }

    public String thingId()
    {
        return getIntent().getStringExtra("thingId");
    }

    public void vibrate(int duration)
    {
        Vibrator v = (Vibrator) getSystemService(Context.VIBRATOR_SERVICE);
        v.vibrate(duration);
    }
}
