pragma Singleton
import QtQuick 2.0

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

    mainMenuLinks: [
        {
            text: qsTr("Help"),
            iconName: "../images/help.svg",
            url: "https://nymea.io/documentation/users/usage/first-steps"
        },
        {
            text: qsTr("Forum"),
            iconName: "../images/discourse.svg",
            url: "https://forum.nymea.io"
        },
        {
            text: qsTr("Telegram"),
            iconName: "../images/telegram.svg",
            url: "https://t.me/nymeacommunity"
        },
        {
            text: qsTr("Discord"),
            iconName: "../images/discord.svg",
            url: "https://discord.gg/tX9YCpD"
        }
    ]
}
