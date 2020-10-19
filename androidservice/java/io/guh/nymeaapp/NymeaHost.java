package io.guh.nymeaapp;

import java.util.HashMap;
import java.util.ArrayList;
import java.util.UUID;

public class NymeaHost {

    UUID id;
    boolean isReady = false;
    String name = "";
    HashMap<UUID, Thing> things = new HashMap<UUID, Thing>();
}
