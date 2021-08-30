import QtQuick 2.8
import QtQuick.Controls 2.2
import QtQuick.Controls.Material 2.1
import QtQuick.Layouts 1.2
import Qt.labs.settings 1.0
import Nymea 1.0
import "qrc:/ui/devicepages/"

ApplicationWindow {
    id: app
    visible: true
    visibility: ApplicationWindow.FullScreen
    color: Material.background
    title: appName

    Material.theme: NymeaUtils.isDark(Style.backgroundColor) ? Material.Dark : Material.Light
    Material.background: Style.backgroundColor
    Material.accent: Style.accentColor
    Material.foreground: Style.foregroundColor

    font.pixelSize: mediumFont
    font.weight: Font.Normal
    font.capitalization: Font.MixedCase
    font.family: Style.fontFamily

    property string appName: "appBranding" in app ? app.appBranding : "nymea:app"
    property string systemName: "coreBranding" in app ? app.coreBranding : "nymea"

    property int margins: 16
    property int bigMargins: 20

    property int extraSmallFont: 10
    property int smallFont: 13
    property int mediumFont: 16
    property int largeFont: 20

    property int smallIconSize: 16
    property int iconSize: 24
    property int bigIconSize: 40
    property int hugeIconSize: 64

    property int delegateHeight: 60

    readonly property bool landscape: app.width > app.height

    ThingsProxy {
        id: thingProxy
        engine: _engine
        filterThingId: controlledThingId
    }

    property Thing controlledThing: engine.thingManager.fetchingData ? null : engine.thingManager.things.getThing(controlledThingId)

    onControlledThingChanged: {
        loader.setSource("qrc:/ui/devicepages/" + NymeaUtils.interfaceListToDevicePage(controlledThing.thingClass.interfaces), {thing: controlledThing, header: null})
        PlatformHelper.hideSplashScreen();
    }

    Loader {
        id: loader
        anchors.fill: parent
        anchors.bottomMargin: app.margins // For some reason the bottom edge seems a bit off in the overlay
    }

    onClosing: {
        print("************* Control View closing")
    }

}
