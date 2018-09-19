package io.guh.nymeaapp;
import android.util.Log;
import android.content.Intent;
import android.content.Context;
import android.os.Bundle;
import android.os.Build;
import android.telephony.TelephonyManager;
//import com.google.firebase.messaging.MessageForwardingService;


public class NymeaAppActivity extends org.qtproject.qt5.android.bindings.QtActivity
{
    public String deviceSerial()
    {
        TelephonyManager TM = (TelephonyManager) getSystemService(Context.TELEPHONY_SERVICE);

            // IMEI No.
            String imeiNo = TM.getDeviceId();

            // IMSI No.
            String imsiNo = TM.getSubscriberId();

            // SIM Serial No.
            String simSerialNo  = TM.getSimSerialNumber();

            // Android Unique ID
//            String androidId = System.getString(this.getContentResolver(),Settings.Secure.ANDROID_ID);

        return imeiNo;
    }

public static String deviceManufacturer()
{
    return Build.MANUFACTURER;
}

public static String deviceModel()
{
    return Build.MODEL;
}

//    // The key in the intent's extras that maps to the incoming message's message ID. Only sent by
//    // the server, GmsCore sends EXTRA_MESSAGE_ID_KEY below. Server can't send that as it would get
//    // stripped by the client.
//    private static final String EXTRA_MESSAGE_ID_KEY_SERVER = "message_id";

//    // An alternate key value in the intent's extras that also maps to the incoming message's message
//    // ID. Used by upstream, and set by GmsCore.
//    private static final String EXTRA_MESSAGE_ID_KEY = "google.message_id";

//    // The key in the intent's extras that maps to the incoming message's sender value.
//    private static final String EXTRA_FROM = "google.message_id";


//    @Override
//    protected void onNewIntent(Intent intent)
//    {
//        Bundle extras = intent.getExtras();
//        String from = extras.getString(EXTRA_FROM);
//        String messageId = extras.getString(EXTRA_MESSAGE_ID_KEY);
//        Log.d("*************** messageid", messageId);
////        Log.d("Bundle", extras);

//        if (messageId == null) {
//            messageId = extras.getString(EXTRA_MESSAGE_ID_KEY_SERVER);
//        }
//  //      if (from != null && messageId != null) {
//            Intent message = new Intent(this, MessageForwardingService.class);
//            message.setAction(MessageForwardingService.ACTION_REMOTE_INTENT);
//            message.putExtras(intent);
//            message.setData(intent.getData());
//            startService(message);
// //       }
//        setIntent(intent);
//    }
}
