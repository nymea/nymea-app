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

    @Override
    protected void onNewIntent(Intent intent) {
        Log.d(TAG, "*************** New intent");
        super.onNewIntent(intent);
        if (NfcAdapter.ACTION_NDEF_DISCOVERED.equals(intent.getAction())) {
            Parcelable[] rawMessages =
                intent.getParcelableArrayExtra(NfcAdapter.EXTRA_NDEF_MESSAGES);
            if (rawMessages != null) {
                NdefMessage[] messages = new NdefMessage[rawMessages.length];
                for (int i = 0; i < rawMessages.length; i++) {
                    messages[i] = (NdefMessage) rawMessages[i];
                    Log.d(TAG, messages[i].toString());
                }
                // Process the messages array.
            }
        }
    }

}
