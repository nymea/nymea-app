package io.guh.nymeaapp;

import java.io.File;

import android.util.Log;
import android.content.Intent;
import android.content.Context;
import android.content.IntentSender;
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
import androidx.core.content.FileProvider;
import chip.devicecontroller.*;
import androidx.annotation.NonNull;
import com.google.android.gms.home.matter.Matter;
import com.google.android.gms.home.matter.commissioning.CommissioningRequest;

import com.google.android.gms.tasks.OnSuccessListener;
import com.google.android.gms.tasks.OnFailureListener;

import android.content.ComponentName;
import androidx.lifecycle.MutableLiveData;
import androidx.core.content.FileProvider;
import androidx.core.app.ActivityCompat;
import androidx.activity.result.contract.*;

import androidx.activity.result.ActivityResult;
import androidx.activity.result.ActivityResultCallback;
import androidx.activity.result.ActivityResultLauncher;
import androidx.activity.result.contract.ActivityResultContracts;
//import androidx.appcompat.app.AppCompatActivity;

public class NymeaAppActivity extends org.qtproject.qt5.android.bindings.QtActivity
{
    private static final String TAG = "nymea-app: NymeaAppActivity";
    private static Context context = null;

    private static native void darkModeEnabledChangedJNI();
    private static native void notificationActionReceivedJNI(String data);
    private static native void locationServicesEnabledChangedJNI();

    private MutableLiveData m_commissionDeviceIntentSender = new MutableLiveData<IntentSender>();
//    private ActivityResultLauncher<Intent> m_activityResultLauncher = registerForActivityResult(ActivityResultContracts.StartIntentSenderForResult());


@Override
protected void onActivityResult (int requestCode, int resultCode, Intent data) {
    Log.d(TAG, "************************ Activity result " + requestCode + " - " + resultCode);
//    if (resultCode == Activity.RESULT_OK && requestCode == 123) {
//        doSomeOperations();
//    }
}


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
        super.onCreate(savedInstanceState);
        this.context = getApplicationContext();

        ChipDeviceController.loadJni();


//        m_activityResultLauncher = registerForActivityResult(new ActivityResultContracts.StartIntentSenderForResult(),
//        new ActivityResultCallback<Uri>() {
//                @Override
//                public void onActivityResult(Uri uri) {
//                    // Handle the returned Uri
//    //            // handle intent result here
//    //            if (result.getResultCode() == RESULT_OK) {
//    //                SignInCredential credential = null;
//    //                try {
//    //                    credential = oneTapClient.getSignInCredentialFromIntent(result.getData());
//    //                    String idToken = credential.getGoogleIdToken();
//    //                    String username = credential.getId();
//    //                    String password = credential.getPassword();
//    //                    if (idToken != null) {
//    //                        // Got an ID token from Google. Use it to authenticate
//    //                        // with your backend.
//    //                        Log.d(TAG, "Got ID token.");
//    //                    } else if (password != null) {
//    //                        // Got a saved username and password. Use them to authenticate
//    //                        // with your backend.
//    //                        Log.d(TAG, "Got password.");
//    //                    }
//    //                } catch (ApiException e) {
//    //                    e.printStackTrace();
//    //                }
//    //            }
//    //            else {
//    //                //...
//    //            }
//                }
//            });

    }

    public void onNewIntent (Intent intent) {
        Log.d(TAG, "New intent: " + intent);
        String notificationData = intent.getStringExtra("notificationData");
        if (notificationData != null) {
            Log.d(TAG, "Intent data: " + notificationData);
            notificationActionReceivedJNI(notificationData);
        }
    }

    @Override
    public void onResume() {
        super.onResume();

        IntentFilter filter = new IntentFilter(LocationManager.MODE_CHANGED_ACTION);
//        filter.addAction(Intent.ACTION_PROVIDER_CHANGED);
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

    public void startMatterCommissioning() {
        Log.d(TAG, "startMatterCommissioning");


        CommissioningRequest commissionDeviceRequest =
            CommissioningRequest.builder()
//                .setCommissioningService(new ComponentName(context, NymeaAppService.class))
                .build();

        Matter.getCommissioningClient(context)
        .commissionDevice(commissionDeviceRequest)
        .addOnSuccessListener(this, new OnSuccessListener<IntentSender>() {
            @Override
            public void onSuccess(IntentSender result) {
                Log.d(TAG, "Matter commissioning started!");
                m_commissionDeviceIntentSender.postValue(result);
//                IntentSenderRequest request = IntentSenderRequest.Builder(result).build();
//                m_activityResultLauncher.launch(request);

                    Intent intent = new Intent(context, NymeaAppActivity.class);
                    startActivityForResult(intent, 123);
            }
        })
        .addOnFailureListener(this, new OnFailureListener() {
            @Override
            public void onFailure(@NonNull Exception e) {
                Log.d(TAG, "Matter commissioning failed!");
                Log.e(TAG, e.toString());
            }
        });
    }
}
