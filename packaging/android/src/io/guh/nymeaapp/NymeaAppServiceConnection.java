package io.guh.nymeaapp;

import java.util.List;
import java.util.ArrayList;
import java.util.UUID;
import java.util.HashMap;

import android.util.Log;

import android.os.IBinder;
import android.os.Parcel;
import android.os.RemoteException;

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
    private Context m_context;

    private boolean m_connected = false;
    private HashMap<UUID, NymeaHost> m_nymeaHosts = new HashMap<UUID, NymeaHost>();

    public NymeaAppServiceConnection(Context context) {
        super();
        m_context = context;
    }

    final public boolean connected() {
        return m_connected;
    }
    public void onConnectedChanged(boolean connected) {};

    final public boolean isReady(UUID nymeaId) {
        return m_nymeaHosts.get(nymeaId).isReady;
    }
    public void onReadyChanged(UUID nymeaId, boolean ready) {}

    public final HashMap<UUID, NymeaHost> getHosts() {
        return m_nymeaHosts;
    }

    final public Thing getThing(UUID thingId) {
        for (HashMap.Entry<UUID, NymeaHost> entry : m_nymeaHosts.entrySet()) {
            Thing thing = entry.getValue().things.get(thingId);
            if (thing != null) {
                return thing;
            }
        }
        return null;
    }
    final public UUID hostForThing(UUID thingId) {
        for (HashMap.Entry<UUID, NymeaHost> entry : m_nymeaHosts.entrySet()) {
            Thing thing = entry.getValue().things.get(thingId);
            if (thing != null) {
                return entry.getKey();
            }
        }
        return null;
    }

    public void onError() {}
    public void onUpdate(UUID nymeaId, UUID thingId) {}

    final public void executeAction(UUID nymeaId, UUID thingId, UUID actionTypeId, String paramValue) {
        try {
            JSONObject params = new JSONObject();
            params.put("nymeaId", nymeaId.toString());
            params.put("thingId", thingId.toString());
            params.put("actionTypeId", actionTypeId.toString());
            JSONArray actionParams = new JSONArray();
            JSONObject param = new JSONObject();
            param.put("paramTypeId", actionTypeId.toString());
            param.put("value", paramValue);
            actionParams.put(param);
            params.put("params", actionParams);
            Parcel parcel = createRequest("ExecuteAction", params);
            Parcel retParcel = Parcel.obtain();
            m_service.transact(1, parcel, retParcel, 0);
        } catch (Exception e) {
            Log.d(TAG, "Error calling executeAction on NymeaAppService");
        }
    }

    @Override public void onServiceConnected(ComponentName className, IBinder service) {
        Log.d(TAG, "Connected to NymeaAppService");
        m_service = service;

        registerServiceBroadcastReceiver();

        try {
            Parcel parcel = createRequest("GetInstances");
            Parcel retParcel = Parcel.obtain();

            m_service.transact(1, parcel, retParcel, 0);

            JSONObject reply = new JSONObject(retParcel.readString());
            Log.d(TAG, "Instaces received: " + reply.toString());
            JSONArray instances = reply.getJSONArray("instances");
            for (int i = 0; i < instances.length(); i++) {
                JSONObject instanceMap = instances.getJSONObject(i);
                NymeaHost nymeaHost = new NymeaHost();
                nymeaHost.id = UUID.fromString(instanceMap.getString("id"));
                nymeaHost.name = instanceMap.getString("name");
                nymeaHost.isReady = instanceMap.getBoolean("isReady");
                m_nymeaHosts.put(nymeaHost.id, nymeaHost);

            }
        } catch (JSONException e) {
            Log.d(TAG, "Error while processing JSON in communication with NymeaAppService: " + e.toString());
            onError();
            return;
        } catch (RemoteException e) {
            Log.d(TAG, "Error communicating with NymeaAppService: " + e.toString());
            onError();
            return;
        }

        m_connected = true;
        onConnectedChanged(m_connected);
    }

    @Override public void onServiceDisconnected(ComponentName arg0) {
        m_service = null;
        for (int i = 0; i < m_nymeaHosts.size(); i++) {
            m_nymeaHosts.get(i).isReady = false;
        }
        m_connected = false;
        onConnectedChanged(m_connected);
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
            Log.d(TAG, "In OnReceive broadcast receiver");
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
        Log.d(TAG, params.toString());

        if (data.getString("notification").equals("ThingStateChanged")) {
            UUID nymeaId = UUID.fromString(params.getString("nymeaId"));
            UUID thingId = UUID.fromString(params.getString("thingId"));
            UUID stateTypeId = UUID.fromString(params.getString("stateTypeId"));
            String value = params.getString("value");
            Log.d(TAG, "Thing state changed: " + thingId + " stateTypeId: " + stateTypeId + " value: " + value);

            Thing thing = getThing(thingId);
            if (thing != null) {
                thing.stateById(stateTypeId).value = value;
                onUpdate(nymeaId, thingId);
            } else {
                Log.d(TAG, "Got a state change notification for a thing we don't know!");
            }
        }

        if (data.getString("notification").equals("ReadyStateChanged")) {
            UUID nymeaId = UUID.fromString(params.getString("nymeaId"));
            NymeaHost host = m_nymeaHosts.get(nymeaId);
            host.isReady = params.getBoolean("isReady");
            if (host.isReady) {
                Log.d(TAG, "Host is ready. Fetching things...");
                fetchThings(nymeaId);
            } else {
                Log.d(TAG, "Host is not ready yet...");
            }
        }
    }

    private void fetchThings(UUID nymeaId) {
        Log.d(TAG, "Fetching things");
        String thingsList;
        try {
            JSONObject params = new JSONObject();
            params.put("nymeaId", nymeaId.toString());
            Parcel parcel = createRequest("GetThings", params);
            Parcel retParcel = Parcel.obtain();
            m_service.transact(1, parcel, retParcel, 0);
            thingsList = retParcel.readString();
        } catch (Exception e) {
            Log.d(TAG, "Error fetching things from NymeaAppService");
            onError();
            return;
        }

        try {
            JSONObject result = new JSONObject(thingsList);
            for (int i = 0; i < result.getJSONArray("things").length(); i++) {
                JSONObject entry = result.getJSONArray("things").getJSONObject(i);
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
                m_nymeaHosts.get(nymeaId).things.put(thing.id, thing);
            }

        } catch (Exception e) {
            Log.d(TAG, "Error parsing JSON from NymeaAppService: " + e.toString());
            Log.d(TAG, thingsList);
            m_service = null;
            onError();
            return;
        }

        Log.d(TAG, "Things fetched: " + m_nymeaHosts.get(nymeaId).things.size());
        m_nymeaHosts.get(nymeaId).isReady = true;
        onReadyChanged(nymeaId, true);
    }

    private Parcel createRequest(String method) throws JSONException {
        return createRequest(method, null);
    }
    private Parcel createRequest(String method, JSONObject params) throws JSONException {
        Parcel ret = Parcel.obtain();
        JSONObject payload = new JSONObject();
        payload.put("method", method);
        if (params != null) {
            payload.put("params", params);
        }
        Log.d(TAG, "Parcel payload: " + payload.toString());
        ret.writeString(payload.toString());
        return ret;
    }
}
