package io.guh.nymeaapp;

import java.util.List;
import java.util.ArrayList;
import java.util.UUID;

import android.util.Log;

import android.os.IBinder;
import android.os.Parcel;

import android.content.Intent;
import android.content.IntentFilter;
import android.content.BroadcastReceiver;
import android.content.ServiceConnection;
import android.content.ComponentName;
import android.content.Context;

import android.service.controls.Control;
import android.service.controls.DeviceTypes;

import io.reactivex.processors.ReplayProcessor;

import org.json.*;

// Helper class to establish a connection to the NymeaAppService and interact
// with that using IBinder and ServiceBroadcastListener

public class NymeaAppServiceConnection implements ServiceConnection {
    private static final String TAG = "nymea-app: NymeaAppServiceConnection";
    private IBinder m_service;
    private boolean m_isConnectedToNymea = false;
    private boolean m_isReady = false;
    private Context m_context;

    private String m_nymeaName = "nymea";
    private ArrayList<Thing> m_things = new ArrayList<>();

    public NymeaAppServiceConnection(Context context) {
        super();
        m_context = context;
    }

    final public boolean isConnected() {
        return m_service != null;
    }

    final public boolean isConnectedToNymea() {
        return m_isConnectedToNymea;
    }

    final public String nymeaName() {
        return m_nymeaName;
    }

    final public boolean isReady() {
        return m_isReady;
    }

    final public ArrayList<Thing> getThings() {
        return m_things;
    }
    final public Thing getThing(UUID thingId) {
        for (int i = 0; i < m_things.size(); i++) {
            if (m_things.get(i).id.equals(thingId)) {
                return m_things.get(i);
            }
        }
        return null;
    }

    public void onReady() {}
    public void onError() {}
    public void onUpdate(UUID thingId) {}

    final public void executeAction(UUID thingId, UUID actionTypeId, String param) {
        try {
            Parcel parcel = Parcel.obtain();
            parcel.writeByteArray(thingId.toString().getBytes());
            parcel.writeByteArray(actionTypeId.toString().getBytes());
            parcel.writeByteArray(param.getBytes());
            Parcel retParcel = Parcel.obtain();
            m_service.transact(2, parcel, retParcel, 0);
//            thingsList = retParcel.readString();
        } catch (Exception e) {
            Log.d(TAG, "Error calling executeAction on NymeaAppService");
        }
    }

    @Override public void onServiceConnected(ComponentName className, IBinder service) {
        Log.d(TAG, "Connected to NymeaAppService");
        m_service = service;

        registerServiceBroadcastReceiver();

        try {
            Parcel parcel = Parcel.obtain();
            Parcel retParcel = Parcel.obtain();
            m_service.transact(0, parcel, retParcel, 0);
            m_isReady = retParcel.readBoolean();
            if (!m_isReady) {
                m_nymeaName = retParcel.readString();
                m_isConnectedToNymea = true;
                Log.d(TAG, "Service is ready!");
                fetchThings();
            } else {
                Log.d(TAG, "Service is not ready yet!");
            }
        } catch (Exception e) {
            Log.d(TAG, "Error while waiting for service to be connected to nymea");
            m_service = null;
            onError();
            return;
        }
    }

    @Override public void onServiceDisconnected(ComponentName arg0) {
        m_service = null;
        m_isConnectedToNymea = false;
        m_isReady = false;
    }

    public void registerServiceBroadcastReceiver() {
        IntentFilter intentFilter = new IntentFilter();
        intentFilter.addAction(NymeaAppService.NYMEA_APP_BROADCAST);
        m_context.registerReceiver(serviceMessageReceiver, intentFilter);
        Log.d(TAG, "Registered broadcast receiver");
    }

    private BroadcastReceiver serviceMessageReceiver = new BroadcastReceiver() {
        @Override
        public void onReceive(Context context, Intent intent) {
//            Log.d(TAG, "In OnReceive broadcast receiver");
            if (NymeaAppService.NYMEA_APP_BROADCAST.equals(intent.getAction())) {
                String payload = intent.getStringExtra("data");
                try {
                    processBroadcast(payload);
                } catch(JSONException e) {
                    Log.d(TAG, "Error parsing broadcast JSON: " + e.toString());
                }
            }
        }
    };

    private void processBroadcast(String payload) throws JSONException
    {
        JSONObject data = new JSONObject(payload);
        JSONObject params = data.getJSONObject("params");
        Log.d(TAG, "Broadcast received from NymeaAppService: " + data.getString("notification"));

        if (data.getString("notification").equals("ThingStateChanged")) {
            UUID thingId = UUID.fromString(params.getString("thingId"));
            UUID stateTypeId = UUID.fromString(params.getString("stateTypeId"));
            String value = params.getString("value");
            Log.d(TAG, "Thing state changed: " + thingId + " stateTypeId: " + stateTypeId + " value: " + value);

            for (int i = 0; i < m_things.size(); i++) {
                if (m_things.get(i).id.equals(thingId)) {
                    m_things.get(i).stateById(stateTypeId).value = value;
                    onUpdate(thingId);
                }
            }
        }

        if (data.getString("notification").equals("ReadyStateChanged")) {
            m_isReady = params.getBoolean("isReady");
            if (m_isReady) {
                m_nymeaName = params.getString("systemName");
                fetchThings();
            }
        }
    }

    private void fetchThings() {
        String thingsList;
        try {
            Log.d(TAG, "Fetching things");
            Parcel parcel = Parcel.obtain();
            Parcel retParcel = Parcel.obtain();
            m_service.transact(1, parcel, retParcel, 0);
            thingsList = retParcel.readString();
            Log.d(TAG, "Things fetched");
        } catch (Exception e) {
            Log.d(TAG, "Error fetching things from NymeaAppService");
            m_service = null;
            m_isConnectedToNymea = false;
            onError();
            return;
        }

        try {
            Log.d(TAG, "Parsing JSON");
            JSONArray arr = new JSONArray(thingsList);
            for (int i = 0; i < arr.length(); i++) {
                JSONObject entry = arr.getJSONObject(i);
                Thing thing = new Thing();
                thing.id = UUID.fromString(entry.getString("id"));
                thing.name = entry.getString("name");
                thing.className = entry.getString("className");
                JSONArray ifaces = entry.getJSONArray("interfaces");
                for (int j = 0; j < ifaces.length(); j++) {
                    thing.interfaces.add(ifaces.get(j));
                }
                JSONArray states = entry.getJSONArray("states");
                for (int j = 0; j < states.length(); j++) {
                    JSONObject stateMap = states.getJSONObject(j);
                    State s = new State();
                    s.typeId = UUID.fromString(stateMap.getString("stateTypeId"));
                    s.name = stateMap.getString("name");
                    s.displayName = stateMap.getString("displayName");
                    s.value = stateMap.getString("value");
                    thing.states.add(s);
                }
                JSONArray actions = entry.getJSONArray("actions");
                for (int j = 0; j < actions.length(); j++) {
                    JSONObject actionMap = actions.getJSONObject(j);
                    Action a = new Action();
                    a.typeId = UUID.fromString(actionMap.getString("actionTypeId"));
                    a.name = actionMap.getString("name");
                    a.displayName = actionMap.getString("displayName");
                    thing.actions.add(a);
                }
                m_things.add(thing);
            }

        } catch (Exception e) {
            Log.d(TAG, "Error parsing JSON from NymeaAppService: " + e.toString());
            m_service = null;
            m_isConnectedToNymea = false;
            onError();
            return;
        }

        Log.d(TAG, "Fetched things");
        m_isReady = true;
        onReady();
    }
}
