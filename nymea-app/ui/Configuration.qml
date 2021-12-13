pragma Singleton
import QtQuick 2.0

ConfigurationBase {
    systemName: "nymea"
    appName: "nymea:app"
    appId: "io.guh.nymeaapp"

    connectionWizard: "/ui/connection/NewConnectionWizard.qml"

    showCommunityLinks: true

    networkSettingsEnabled: true
    apiSettingsEnabled: true
    mqttSettingsEnabled: true
    webServerSettingsEnabled: true
    zigbeeSettingsEnabled: true
    modbusSettingsEnabled: true
}
