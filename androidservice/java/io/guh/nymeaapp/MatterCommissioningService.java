package io.guh.nymeaapp;

import android.content.Context;
import android.content.Intent;
import android.util.Log;

import android.app.Service;
import android.os.IBinder;

import androidx.activity.*;
import android.window.OnBackInvokedDispatcher;
import android.window.OnBackInvokedCallback;

import com.google.android.gms.home.matter.commissioning.CommissioningCompleteMetadata;
import com.google.android.gms.home.matter.commissioning.CommissioningRequestMetadata;
import com.google.android.gms.home.matter.commissioning.CommissioningService;
import com.google.android.gms.home.matter.commissioning.CommissioningService.CommissioningError;

import chip.devicecontroller.*;


public class MatterCommissioningService extends Service implements CommissioningService.Callback
{
    private static final String TAG = "nymea-app: MatterCommissioningService";

    private ChipClient m_chipClient;
    private CommissioningService m_commissioningServiceDelegate;

    @Override
    public void onCreate() {
        Log.i(TAG, "Creating Service 1");
        super.onCreate();
        Log.i(TAG, "Creating Service 2");

        m_chipClient = new ChipClient(this);

        Log.d(TAG, "Chip client created");

        m_commissioningServiceDelegate = new CommissioningService.Builder(this).setCallback(this).build();

        Log.d(TAG, "Commissioning service created");

    }

    public void onCommissioningRequested(CommissioningRequestMetadata metaData) {
        Log.d(TAG, "Commissioning\n" +
        "\tdeviceDescriptor: " +
        "deviceType " + metaData.getDeviceDescriptor().getDeviceType() +
        "vendorId " + metaData.getDeviceDescriptor().getVendorId() +
        "productId " + metaData.getDeviceDescriptor().getProductId() +
        "\tnetworkLocation: " +
        "IP address toString() " + metaData.getNetworkLocation().getIpAddress() +
        "IP address hostAddress " + metaData.getNetworkLocation().getIpAddress().getHostAddress() +
        "port " +  metaData.getNetworkLocation().getPort() +
        "\tpassCode " + metaData.getPasscode());

        long deviceId = 1234567;

        m_chipClient.establishPaseConnection(deviceId, metaData.getNetworkLocation().getIpAddress().toString(), metaData.getNetworkLocation().getPort(), metaData.getPasscode());

//        chipClient.awaitEstablishPaseConnection(
//                    deviceId,
//                    metaData.getNetworkLocation().getIpAddress().getHostAddress(),
//                    metaData.getNetworkLocation().getPort(),
//                    metaData.getPasscode());

    }

    @Override
    public void onDestroy() {
        super.onDestroy();
        Log.i(TAG, "Destroying Service");
    }

    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {
        int ret = super.onStartCommand(intent, flags, startId);

        Log.d(TAG, "*************** Service started");

        return ret;
    }

    public IBinder onBind(Intent intent) {
        Log.d(TAG, "****** on bind: " + intent.toString());
        return m_commissioningServiceDelegate.asBinder();
    }

}
