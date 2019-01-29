import QtQuick 2.9
import QtQuick.Controls 2.2

ListView {
    id: root

    ScrollBar.vertical: ScrollBar {}

    clip: true
    section.property: "baseInterface"
    section.criteria: ViewSection.FullString
    section.delegate: ListSectionHeader {
        text: app.interfaceToString(section)
    }

    SwipeDelegateGroup {}
}
