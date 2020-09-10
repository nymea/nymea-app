package io.guh.nymeaapp;

import android.util.Log;
import android.content.Intent;
import android.app.PendingIntent;
import android.net.Uri;
import android.content.Context;
import android.service.controls.ControlsProviderService;
import android.service.controls.actions.ControlAction;
import android.service.controls.actions.BooleanAction;
import android.service.controls.Control;
import android.service.controls.DeviceTypes;

import java.util.concurrent.Flow.Publisher;
import java.util.function.Consumer;
import java.util.List;
import java.util.ArrayList;
import io.reactivex.Flowable;
import io.reactivex.processors.ReplayProcessor;
import org.reactivestreams.FlowAdapters;

public class NymeaAppControlService extends ControlsProviderService {

    private ReplayProcessor updatePublisher;

    @Override
    public Publisher createPublisherForAllAvailable() {
        Log.d("********************************* Creating publishers for all ****************************", "fff");

        Context context = getBaseContext();
        Intent i = new Intent();
        PendingIntent pi = PendingIntent.getActivity(context, 1, i, PendingIntent.FLAG_UPDATE_CURRENT);
//        pi = PendingIntent.getActivity(context, 1, i, PendingIntent.FLAG_UPDATE_CURRENT);
        List controls = new ArrayList<>();
        Control control = new Control.StatelessBuilder("e24b0d95-9982-4f9b-ad8b-2aa6b9aba8fd", pi)
          // Required: The name of the control
          .setTitle("TestControl")
          // Required: Usually the room where the control is located
          .setSubtitle("TestSubtitle")
          // Optional: Structure where the control is located, an example would be a house
          .setStructure("TestLocation")
          // Required: Type of device, i.e., thermostat, light, switch
          .setDeviceType(DeviceTypes.TYPE_GENERIC_ON_OFF) // For example, DeviceTypes.TYPE_THERMOSTAT
          .build();
        controls.add(control);
        // Create more controls here if needed and add it to the ArrayList

        // Uses the RxJava 2 library
        return FlowAdapters.toFlowPublisher(Flowable.fromIterable(controls));
    }


    @Override
    public Publisher createPublisherFor(List controlIds) {
        Log.d("********************************* Creating publishers for one ****************************", "..");
//        for(int i = 0; i < controlIds.size(); i++) {
//            Log.d("requested control id:", controlIds.get(i));
//        }
        Context context = getBaseContext();
        /* Fill in details for the activity related to this device. On long press,
         * this Intent will be launched in a bottomsheet. Please design the activity
         * accordingly to fit a more limited space (about 2/3 screen height).
         */
        Intent i = new Intent();
        PendingIntent pi = PendingIntent.getActivity(context, 1, i, PendingIntent.FLAG_UPDATE_CURRENT);

        updatePublisher = ReplayProcessor.create();

        // For each controlId in controlIds

        if (controlIds.contains("e24b0d95-9982-4f9b-ad8b-2aa6b9aba8fd")) {
            Log.d("**", "control asked");
            Control control = new Control.StatefulBuilder("e24b0d95-9982-4f9b-ad8b-2aa6b9aba8fd", pi)
            // Required: The name of the control
            .setTitle("TestTitle")
            // Required: Usually the room where the control is located
            .setSubtitle("TestSubTitle")
            // Optional: Structure where the control is located, an example would be a house
            .setStructure("TestStructure")
            // Required: Type of device, i.e., thermostat, light, switch
            .setDeviceType(DeviceTypes.TYPE_GENERIC_ON_OFF) // For example, DeviceTypes.TYPE_THERMOSTAT
            // Required: Current status of the device
            .setStatus(Control.STATUS_OK) // For example, Control.STATUS_OK
            .build();

            updatePublisher.onNext(control);
        }
        // Uses the Reactive Streams API
        return FlowAdapters.toFlowPublisher(updatePublisher);
    }

    @Override
    public void performControlAction(String controlId, ControlAction action, Consumer consumer) {
        /* First, locate the control identified by the controlId. Once it is located, you can
         * interpret the action appropriately for that specific device. For instance, the following
         * assumes that the controlId is associated with a light, and the light can be turned on
         * or off.
         */
        if (action instanceof BooleanAction) {

            // Inform SystemUI that the action has been received and is being processed
            consumer.accept(ControlAction.RESPONSE_OK);

            BooleanAction bAction = (BooleanAction) action;
            // In this example, action.getNewState() will have the requested action: true for “On”,
            // false for “Off”.

            /* This is where application logic/network requests would be invoked to update the state of
             * the device.
             * After updating, the application should use the publisher to update SystemUI with the new
             * state.
             */
//            Control control = new Control.StatefulBuilder("123", pi)
//                // Required: The name of the control
//                .setTitle("TestControl")
//                // Required: Usually the room where the control is located
//                .setSubtitle("TestSubTitle")
//                // Optional: Structure where the control is located, an example would be a house
//                .setStructure("TestStructure")
//                // Required: Type of device, i.e., thermostat, light, switch
//                .setDeviceType(DeviceTypes.TYPE_GENERIC_ON_OFF) // For example, DeviceTypes.TYPE_THERMOSTAT
//                // Required: Current status of the device
//                .setStatus(Control.STATUS_OK) // For example, Control.STATUS_OK
//                .build();

//            // This is the publisher the application created during the call to createPublisherFor()
//            updatePublisher.onNext(control);
        }
    }
}
