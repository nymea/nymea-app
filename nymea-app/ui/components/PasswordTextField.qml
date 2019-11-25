import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.2

ColumnLayout {
    id: root

    property bool signup: true

    // Only used when signup is true
    property int minPasswordLength: 12
    property bool requireSpecialChar: true
    property bool requireNumber: true
    property bool requireUpperCaseLetter: true
    property bool requireLowerCaseLetter: true

    readonly property alias password: passwordTextField.text

    readonly property bool isValidPassword:
        isLongEnough &&
        (hasLower || !requireLowerCaseLetter) &&
        (hasUpper || !requireUpperCaseLetter) &&
        (hasNumbers || !requireNumber) &&
        (hasSpecialChar || !requireSpecialChar)

    readonly property bool isValid: !signup || (isValidPassword && confirmationMatches)

    readonly property bool isLongEnough: passwordTextField.text.length >= minPasswordLength
    readonly property bool hasLower: passwordTextField.text.search(/[a-z]/) >= 0
    readonly property bool hasUpper: passwordTextField.text.search(/[A-Z/]/) >= 0
    readonly property bool hasNumbers: passwordTextField.text.search(/[0-9]/) >= 0    
    readonly property bool hasSpecialChar: passwordTextField.text.search(/(?=.*?[$*.\[\]{}()?\-'"!@#%&/\\,><':;|_~`^])/) >= 0
    readonly property bool confirmationMatches: passwordTextField.text === confirmationPasswordTextField.text

    property bool hiddenPassword: true

    RowLayout {
        Layout.fillWidth: true

        TextField {
            id: passwordTextField
            Layout.fillWidth: true
            echoMode: root.hiddenPassword ? TextInput.Password : TextInput.Normal
            placeholderText: root.signup ? qsTr("Pick a password") : ""

            ToolTip.visible: root.signup && focus && !root.isValidPassword
            ToolTip.delay: 1000
            ToolTip.onVisibleChanged: print("Tooltip visible changed:", ToolTip.visible, focus, root.isValidPassword)
            ToolTip.text: {
                var texts = []
                var checks = []
                texts.push(qsTr("Minimum %1 characters").arg(root.minPasswordLength))
                checks.push(root.isLongEnough)
                if (root.requireLowerCaseLetter) {
                    texts.push(qsTr("Lowercase letters"))
                    checks.push(root.hasLower)
                }
                if (root.requireUpperCaseLetter) {
                    texts.push(qsTr("Uppercase letters"))
                    checks.push(root.hasUpper)
                }
                if (root.requireNumber) {
                    texts.push(qsTr("Numbers"))
                    checks.push(root.hasNumbers)
                }
                if (root.requireSpecialChar) {
                    texts.push(qsTr("Special characters"))
                    checks.push(root.hasSpecialChar)
                }
                var ret = []
                for (var i = 0; i < texts.length; i++) {
                    var entry = "<font color=\"%1\">• ".arg(checks[i] ? app.foregroundColor : app.accentColor)
                    entry += texts[i]
                    entry += "</font>"
                    ret.push(entry)
                }
                return ret.join("<br>")
            }

        }
        ColorIcon {
            Layout.preferredHeight: app.iconSize
            Layout.preferredWidth: app.iconSize
            name: "../images/eye.svg"
            color: root.hiddenPassword ? keyColor : app.accentColor
            MouseArea {
                anchors.fill: parent
                onClicked: {
                    root.hiddenPassword = !root.hiddenPassword
                }
            }
        }
    }

    RowLayout {
        visible: root.signup

        TextField {
            id: confirmationPasswordTextField
            Layout.fillWidth: true
            echoMode: root.hiddenPassword ? TextInput.Password : TextInput.Normal
            placeholderText: qsTr("Confirm password")
        }
    }
}
