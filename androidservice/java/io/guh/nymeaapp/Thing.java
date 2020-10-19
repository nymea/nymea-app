package io.guh.nymeaapp;

import android.util.Log;

import java.util.List;
import java.util.ArrayList;
import java.util.UUID;


public class Thing {
    static final public String TAG = "nymea-app: Thing";
    public UUID id;
    public String name;
    public String className;
    public List interfaces = new ArrayList<State>();

    public ArrayList<State> states = new ArrayList<State>();
    public ArrayList<Action> actions = new ArrayList<Action>();

    public State stateByName(String name) {
        for (int i = 0; i < states.size(); i++) {
            if (states.get(i).name.equals(name)) {
                return states.get(i);
            }
        }
        return null;
    }

    public State stateById(UUID stateTypeId) {
        for (int i = 0; i < states.size(); i++) {
            if (states.get(i).typeId.equals(stateTypeId)) {
                return states.get(i);
            }
        }
        return null;
    }

    public Action actionByName(String name) {
        for (int i = 0; i < actions.size(); i++) {
            Log.d(TAG, "Thing has action: " + actions.get(i).name);
            if (actions.get(i).name.equals(name)) {
                return actions.get(i);
            }
        }
        return null;
    }

    public Action actionById(UUID actionTypeId) {
        for (int i = 0; i < actions.size(); i++) {
            if (actions.get(i).typeId.equals(actionTypeId)) {
                return actions.get(i);
            }
        }
        return null;
    }
}
