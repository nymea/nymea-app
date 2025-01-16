import QtQuick 2.0

Item {
    property string systemName: ""
    property string appName: ""
    property string appId: ""

    property string company: ""

    property string connectionWizard: ""

    property string tunnelProxyUrl: ""
    property int tunnelProxyPort: 2213

    property string privacyPolicyUrl: ""

    // Enable/disable certain features
    property bool magicEnabled: false
    property bool networkSettingsEnabled: false
    property bool apiSettingsEnabled: false
    property bool mqttSettingsEnabled: false
    property bool webServerSettingsEnabled: false
    property bool zigbeeSettingsEnabled: false
    property bool zwaveSettingsEnabled: false
    property bool modbusSettingsEnabled: false
    property bool pluginSettingsEnabled: false

    property string defaultMainView: "things"

    property var mainMenuLinks: null
    property bool closedSource: false

    property var additionalImrintLinks: null
    property var additionalLicenses: null
}
