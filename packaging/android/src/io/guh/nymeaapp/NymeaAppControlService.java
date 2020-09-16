package io.guh.nymeaapp;

import android.util.Log;
import android.content.Intent;
import android.content.ServiceConnection;
import android.content.ComponentName;
import android.app.PendingIntent;
import android.net.Uri;
import android.content.Context;
import android.service.controls.ControlsProviderService;
import android.service.controls.actions.*;
import android.service.controls.Control;
import android.service.controls.DeviceTypes;
import android.service.controls.templates.*;
import android.os.Binder;
import android.os.IBinder;
import android.os.Parcel;

import java.util.concurrent.Flow.Publisher;
import java.util.function.Consumer;
import java.util.List;
import java.util.ArrayList;
import java.util.HashMap;
import io.reactivex.Flowable;
import io.reactivex.processors.ReplayProcessor;
import org.reactivestreams.FlowAdapters;
import org.json.*;

// Android device controls service

// This service is instantiated by the android device controls on demand. It will
// connect to the NymeaAppService and interact with nymea through that.

public class NymeaAppControlService extends ControlsProviderService {
    private String TAG = "nymea-app: NymeaAppControlService";
    private NymeaAppServiceConnection m_serviceConnection;

    private ReplayProcessor m_publisherForAll;
    private ReplayProcessor m_updatePublisher;
    private List m_activeControlIds;


    private void ensureServiceConnection() {
        if (m_serviceConnection == null) {
            m_serviceConnection = new NymeaAppServiceConnection(getBaseContext()) {
                @Override public void onReady() {
                    process();
                }
                @Override public void onUpdate(String thingId) {
                    if (m_updatePublisher != null && m_activeControlIds.contains(thingId)) {
                        Thing thing = m_serviceConnection.getThing(thingId);
                        Log.d(TAG, "Updating publisher for thing: " + thing.name + " id: " + thing.id);
                        m_updatePublisher.onNext(thingToControl(thing));
//                        m_updatePublisher.onComplete();
                    }
                }
            };
        }
        if (!m_serviceConnection.isConnected()) {
            Intent serviceIntent = new Intent(this, NymeaAppService.class);
            bindService(serviceIntent, m_serviceConnection, Context.BIND_AUTO_CREATE);
        }
    }

    private void process() {
        Log.d(TAG, "Processing...");
        ensureServiceConnection();
        if (!m_serviceConnection.isReady()) {
            Log.d(TAG, "Service connection is not ready yet...");
            return;
        }

        for (Thing thing : m_serviceConnection.getThings()) {
            Log.d(TAG, "Processing thing: " + thing.name);

            if (m_publisherForAll != null) {
                Log.d(TAG, "Adding stateless");
                m_publisherForAll.onNext(thingToControl(thing));
            }

            if (m_updatePublisher != null) {
                if (m_activeControlIds.contains(thing.id)) {
                    Log.d(TAG, "Adding stateful");
                    m_updatePublisher.onNext(thingToControl(thing));
                }
            }
        }

        // The publisher for all needs to be completed when done
        if (m_publisherForAll != null) {
            Log.d(TAG, "Completing all publisher");
            m_publisherForAll.onComplete();
        }

        Log.d(TAG, "Done processing");
        // We never close the update publisher as we need that one to send updates
    }


    @Override
    public Publisher createPublisherForAllAvailable() {
        Log.d(TAG, "Creating publishers for all");
        m_publisherForAll = ReplayProcessor.create();
        process();
        return FlowAdapters.toFlowPublisher(m_publisherForAll);
    }

    @Override
    public Publisher createPublisherFor(List controlIds) {
        Log.d(TAG, "Creating publishers for " + Integer.toString(controlIds.size()));
        m_updatePublisher = ReplayProcessor.create();
        m_activeControlIds = controlIds;
        process();
        return FlowAdapters.toFlowPublisher(m_updatePublisher);
    }

    @Override
    public void performControlAction(String controlId, ControlAction action, Consumer consumer) {
        Log.d(TAG, "Performing control action: " + controlId);
////         PendingAction pendingAction = new PendingAction();
////         pendingAction.thingId = controlId;
////         pendingAction.actionTypeId = "";
////         pendingAction.consumer = consumer;
////         m_pendingActions.put(

        Thing thing = m_serviceConnection.getThing(controlId);
        if (thing == null) {
            Log.d(TAG, "Thing not found for id: " + controlId);
            consumer.accept(ControlAction.RESPONSE_FAIL);
            return;
        }

        String actionTypeId;
        String param;
        if (thing.interfaces.contains("dimmablelight") && action instanceof FloatAction) {
            actionTypeId = thing.stateByName("brightness").typeId;
            FloatAction fAction = (FloatAction) action;
            param = String.valueOf(Math.round(fAction.getNewValue()));
        } else if (thing.interfaces.contains("power") && action instanceof BooleanAction) {
            actionTypeId = thing.stateByName("power").typeId;
            BooleanAction bAction = (BooleanAction) action;
            param = bAction.getNewState() == true ? "true" : "false";
        } else if (thing.interfaces.contains("closable") && action instanceof BooleanAction) {
            BooleanAction bAction = (BooleanAction) action;
            if (bAction.getNewState()) {
                Log.d(TAG, "executing open");
                actionTypeId = thing.actionByName("open").typeId;
            } else {
                Log.d(TAG, "executing close");
                actionTypeId = thing.actionByName("close").typeId;
            }
            param = "";
        } else if (thing.interfaces.contains("extendedvolumecontroller")) {
            actionTypeId = thing.stateByName("volume").typeId;
            FloatAction fAction = (FloatAction) action;
            param = String.valueOf(Math.round(fAction.getNewValue()));
        } else {
            Log.d(TAG, "Unhandled action for: " + thing.name);
            consumer.accept(ControlAction.RESPONSE_FAIL);
            return;
        }

        m_serviceConnection.executeAction(thing.id, actionTypeId, param);
        consumer.accept(ControlAction.RESPONSE_OK);

    }

    private HashMap<String, Integer> m_intents = new HashMap<String, Integer>();

    private Control thingToControl(Thing thing) {
//        Log.d(TAG, "Creating control for thing: " + thing.name + " id: " + thing.id);

        // NOTE: intentId 1 doesn't work for some reason I don't understand yet... so let's make sure we never add "1" to it by always added 100
        int intentId = m_intents.size() + 100;
        PendingIntent pi;
        if (m_intents.containsKey(thing.id)) {
            intentId = m_intents.get(thing.id);
        } else {
            m_intents.put(thing.id, intentId);
        }

        Context context = getBaseContext();
        Intent intent = new Intent(context, NymeaAppControlsActivity.class);
        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK | Intent.FLAG_ACTIVITY_MULTIPLE_TASK);
        intent.putExtra("thingId", thing.id);
        pi = PendingIntent.getActivity(context, intentId, intent, PendingIntent.FLAG_UPDATE_CURRENT);
        Log.d(TAG, "Created pendingintent for " + thing.name + " with id " + intentId + " and extra " + thing.id);

        Control.StatefulBuilder builder = new Control.StatefulBuilder(thing.id, pi)
        .setTitle(thing.name)
        .setSubtitle(thing.className)
        .setStructure(m_serviceConnection.nymeaName());

        if (thing.interfaces.contains("impulsebasedgaragedoor")) {
            builder.setDeviceType(DeviceTypes.TYPE_GARAGE);
            builder.setControlTemplate(new StatelessTemplate(thing.id));
        } else if (thing.interfaces.contains("statefulgaragedoor")) {
            builder.setDeviceType(DeviceTypes.TYPE_GARAGE);
            State stateState = thing.stateByName("state");
            ControlButton controlButton = new ControlButton(stateState.value.equals("open"), stateState.displayName);
            builder.setControlTemplate(new ToggleTemplate(thing.id, controlButton));

//        } else if (thing.interfaces.contains("extendedstatefulgaragedoor")) {
//            builder.setDeviceTyoe(DeviceTypes.TYPE_GARAGE);

        } else if (thing.interfaces.contains("light")) {
            builder.setDeviceType(DeviceTypes.TYPE_LIGHT);
            State powerState = thing.stateByName("power");
            ControlButton controlButton = new ControlButton(powerState.value.equals("true"), powerState.displayName);

            if (thing.interfaces.contains("dimmablelight")) {
                State brightnessState = thing.stateByName("brightness");
                RangeTemplate rangeTemplate = new RangeTemplate(thing.id, 0, 100, Float.parseFloat(brightnessState.value), 1, brightnessState.displayName);
                builder.setControlTemplate(new ToggleRangeTemplate(thing.id, controlButton, rangeTemplate));
            } else {
                builder.setControlTemplate(new ToggleTemplate(thing.id, controlButton));
            }
        } else if (thing.interfaces.contains("powersocket")) {
            builder.setDeviceType(DeviceTypes.TYPE_OUTLET);
            State powerState = thing.stateByName("power");
            ControlButton controlButton = new ControlButton(powerState.value.equals("true"), powerState.displayName);
            builder.setControlTemplate(new ToggleTemplate(thing.id, controlButton));
        } else if (thing.interfaces.contains("mediaplayer")) {
            if (thing.stateByName("playerType").value == "video") {
                builder.setDeviceType(DeviceTypes.TYPE_TV);
            } else {
                // FIXME: There doesn't seem to be a speaker DeviceType!?!
                builder.setDeviceType(DeviceTypes.TYPE_TV);
            }
            if (thing.interfaces.contains("extendedvolumecontroller")) {
                State volumeState = thing.stateByName("volume");
                RangeTemplate rangeTemplate = new RangeTemplate(thing.id, 0, 100, Float.parseFloat(volumeState.value), 1, volumeState.displayName);
                builder.setControlTemplate(rangeTemplate);
            }
        } else {
            builder.setDeviceType(DeviceTypes.TYPE_GENERIC_ON_OFF);
        }
        builder.setStatus(Control.STATUS_OK);

//        Log.d(TAG, "Created control for thing: " + thing.name + " id: " + thing.id);
        return builder.build();
    }
}
