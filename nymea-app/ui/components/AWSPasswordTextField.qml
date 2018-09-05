import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.2

ColumnLayout {
    id: root

    readonly property alias password: passwordTextField.text

    readonly property bool isValidPassword: isLongEnough && hasLower && hasUpper && hasNumbers && hasSpecialChar && confirmationMatches

    readonly property bool isLongEnough: passwordTextField.text.length >= 12
    readonly property bool hasLower: passwordTextField.text.search(/[a-z]/) >= 0
    readonly property bool hasUpper: passwordTextField.text.search(/[A-Z/]/) >= 0
    readonly property bool hasNumbers: passwordTextField.text.search(/[0-9]/) >= 0
    readonly property bool hasSpecialChar: passwordTextField.text.search(/[\*!"$%&/()=?`'+#'¡^°²³¼\[\]|{}\\@]/) >= 0
    readonly property bool confirmationMatches: passwordTextField.text === confirmationPasswordTextField.text

    TextField {
        id: passwordTextField
        Layout.fillWidth: true
        echoMode: TextInput.Password
        placeholderText: qsTr("Pick a password")
    }

    Label {
        Layout.fillWidth: true
        wrapMode: Text.WordWrap

        // TRANSLATORS: %1 will be replaced with the normal text color, %2 the color for the length check
        text: qsTr("<font color=\"%1\">The password needs to be </font><font color=\"%2\">least 12 characters long</font><font color=\"%1\">, contain </font><font color=\"%3\">lowercase</font><font color=\"%1\">, </font><font color=\"%4\">uppercase</font><font color=\"%1\"> letters as well as </font><font color=\"%5\">numbers</font><font color=\"%1\"> and </font><font color=\"%6\">special characters</font><font color=\"%1\">.</font>")
        .arg(app.accentColor)
        .arg(!root.isLongEnough ? "red" : app.accentColor)
        .arg(!root.hasLower ? "red" : app.accentColor)
        .arg(!root.hasUpper ? "red" : app.accentColor)
        .arg(!root.hasNumbers ? "red" : app.accentColor)
        .arg(!root.hasSpecialChar ? "red" : app.accentColor)
        font.pixelSize: app.smallFont
    }

    TextField {
        id: confirmationPasswordTextField
        Layout.fillWidth: true
        echoMode: TextInput.Password
        placeholderText: qsTr("Confirm password")
    }

    Label {
        Layout.fillWidth: true
        wrapMode: Text.WordWrap

        text: root.confirmationMatches ? qsTr("<font color=\"%1\">The passwords match.</font>").arg(app.accentColor) : qsTr("<font color=\"%1\">The passwords </font><font color=\"%2\">do not</font><font color=\"%1\"> match.</font>").arg(app.accentColor).arg("red")
        font.pixelSize: app.smallFont
    }
}
