pragma Singleton
import QtQuick

ConfigurationBase {
    systemName: "nymea"
    appName: "nymea:app"
    appId: "io.guh.nymeaapp"
    company: "chargebyte GmbH"

    connectionWizard: "/ui/connection/ConnectionWizard.qml"

    magicEnabled: true
    networkSettingsEnabled: true
    apiSettingsEnabled: true
    mqttSettingsEnabled: true
    webServerSettingsEnabled: true
    zigbeeSettingsEnabled: true
    zwaveSettingsEnabled: true
    modbusSettingsEnabled: true
    pluginSettingsEnabled: true

    tunnelProxyUrl: "tunnelproxy.nymea.io"
    privacyPolicyUrl: "https://nymea.io/privacy-statement/en/nymea_privacy.html"

    mainMenuLinks: [
        {
            text: qsTr("Help"),
            iconName: "qrc:/icons/help.svg",
            url: "https://nymea.io/documentation/users/usage/first-steps"
        },
        {
            text: qsTr("Telegram"),
            iconName: "qrc:/icons/telegram.svg",
            url: "https://t.me/nymeacommunity"
        }
    ]
}
