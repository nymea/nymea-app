import QtQuick 2.0

Item {
    property string systemName: ""
    property string appName: ""
    property string appId: ""

    property string connectionWizard: ""

    property bool showCommunityLinks: false

    // Enable/disable certain features
    property bool magicEnabled: false
    property bool networkSettingsEnabled: false
    property bool apiSettingsEnabled: false
    property bool mqttSettingsEnabled: false
    property bool webServerSettingsEnabled: false
    property bool zigbeeSettingsEnabled: false
    property bool modbusSettingsEnabled: false
    property bool pluginSettingsEnabled: false
}
