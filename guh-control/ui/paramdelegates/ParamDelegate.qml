import QtQuick 2.8
import QtQuick.Controls 2.1

Loader {
    id: loader

    property var paramType: null
    property var value: null
    source: {
        var comp;
        switch (loader.paramType.type) {
        case "bool":
            comp = "Bool";
            break;
        case "String":
            comp = "String";
            break;
        case "Int":
            comp = "Int";
            break;
        default:
            print("unhandled param type:", paramType.type)
        }
        return Qt.resolvedUrl(comp + "ParamDelegate.qml")
    }

    onStatusChanged: {
        if (status == Loader.Ready) {
            loader.item.value = root.value
        }
    }

    Binding {
        target: loader.item
        when: loader.item
        property: "paramType"
        value: loader.paramType
    }

    Binding {
        target: loader
        when: loader.item
        property: "value"
        value: loader.item.value
    }
}
