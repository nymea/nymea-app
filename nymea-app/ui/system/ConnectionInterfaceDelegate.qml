import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import Nymea 1.0
import "../components"

NymeaListItemDelegate {
    text: qsTr("Interface: %1").arg(model.address === "0.0.0.0" ? qsTr("Any") : model.address === "127.0.0.1" ? qsTr("localhost") : model.address)
    subText: qsTr("Port: %1").arg(model.port)
    iconName: "../images/network-vpn.svg"
    progressive: false
    iconColor: {
        if ((engine.connection.hostAddress === model.address || model.address === "0.0.0.0")
                && engine.connection.port === model.port) {
            return app.accentColor
        }
        return iconKeyColor
    }

    secondaryIconName: "../images/account.svg"
    secondaryIconColor: model.authenticationEnabled ? app.accentColor : secondaryIconKeyColor
    tertiaryIconName: "../images/network-secure.svg"
    tertiaryIconColor: model.sslEnabled ? app.accentColor : tertiaryIconKeyColor

//    canDelete: true
}
