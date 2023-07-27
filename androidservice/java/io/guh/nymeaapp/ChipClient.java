package io.guh.nymeaapp;

import android.content.Context;

import chip.devicecontroller.*;
import chip.platform.AndroidBleManager;
import chip.platform.AndroidChipPlatform;
import chip.platform.ChipMdnsCallbackImpl;
import chip.platform.DiagnosticDataProviderImpl;
import chip.platform.NsdManagerServiceBrowser;
import chip.platform.NsdManagerServiceResolver;
import chip.platform.PreferencesConfigurationManager;
import chip.platform.PreferencesKeyValueStoreManager;


import android.util.Log;


public class ChipClient {

    private static final String TAG = "nymea-app: ChipClient";

    /* 0xFFF4 is a test vendor ID, replace with your assigned company ID */
    private int VENDOR_ID = 0xFFF4;

    private int DEFAULT_TIMEOUT = 1000;

    private ChipDeviceController m_chipDeviceController;
    private AndroidChipPlatform m_androidPlatform;

    public ChipClient(Context context) {
        super();

        Log.d(TAG, "Loading JNI");
        ChipDeviceController.loadJni();
        Log.d(TAG, "JNI loaded");

        m_androidPlatform = new AndroidChipPlatform(
            new AndroidBleManager(),
            new PreferencesKeyValueStoreManager(context),
            new PreferencesConfigurationManager(context),
            new NsdManagerServiceResolver(context),
            new NsdManagerServiceBrowser(context),
            new ChipMdnsCallbackImpl(),
            new DiagnosticDataProviderImpl(context));

        m_chipDeviceController = new ChipDeviceController(ControllerParams.newBuilder().setUdpListenPort(0).setControllerVendorId(VENDOR_ID).build());

        Log.d(TAG, "Chip Device controller created");

    }

    public void establishPaseConnection(long deviceId, String ipAddress, int port, long pinCode) {
        m_chipDeviceController.setCompletionListener(
            new ChipDeviceController.CompletionListener() {
                @Override
                public void onConnectDeviceComplete() {
                    Log.d(TAG, "Device connected!");
                }
                @Override
                public void onOpCSRGenerationComplete(byte[] data) {
                    Log.d(TAG, "OpCSR generation connected: " + data);
                }
                @Override
                public void onError(Throwable err) {
                    Log.d(TAG, "Error: " + err.toString());
                }
                @Override
                public void onCloseBleComplete() {
                    Log.d(TAG, "Ble closed!");
                }
                @Override
                public void onNotifyChipConnectionClosed() {
                    Log.d(TAG, "CHIP connection closed!");
                }
                @Override
                public void onCommissioningStatusUpdate(long nodeId, String stage, int error) {
                    Log.d(TAG, "Commissioning status update: NodeID: " + nodeId + ", Stage: " + stage + ", Error: " + error);
                }
                @Override
                public void onReadCommissioningInfo(int vendorId, int productId, int wifiEndpoint, int threadEndpoint) {
                    Log.d(TAG, "Commissioning info: VendorID: " + vendorId + ", ProductId: " + productId + ", WiFi endpoint: " + wifiEndpoint + ", Thread endpoint: " + threadEndpoint);
                }
                @Override
                public void onCommissioningComplete(long nodeId, int errorCode) {
                    Log.d(TAG, "Commissioning completed: NodeID: " + nodeId + ", Error: " + errorCode);
                }
                @Override
                public void onPairingDeleted(int nodeId) {
                    Log.d(TAG, "Pairing deleted for node: " + nodeId);
                }
                @Override
                public void onPairingComplete(int nodeId) {
                    Log.d(TAG, "Pairing complete for node: " + nodeId);
                }
                @Override
                public void onStatusUpdate(int status) {
                    Log.d(TAG, "Status update: " + status);
                }
          });

          // Temporary workaround to remove interface indexes from ipAddress
          // due to https://github.com/project-chip/connectedhomeip/pull/19394/files
          String strippedIp = ipAddress.replaceAll("%.*", "");
          Log.d(TAG, "Establishing PASE connection: " + deviceId + ", IP: " + strippedIp + ":" + port + ", PIN: " + pinCode);

          m_chipDeviceController.establishPaseConnection(deviceId, strippedIp, port, pinCode);
    }

//    val chipDeviceController: ChipDeviceController by lazy {
//      AndroidChipPlatform(
//          AndroidBleManager(),
//          PreferencesKeyValueStoreManager(context),
//          PreferencesConfigurationManager(context),
//          NsdManagerServiceResolver(context),
//          NsdManagerServiceBrowser(context),
//          ChipMdnsCallbackImpl(),
//          DiagnosticDataProviderImpl(context))
//    }



}
