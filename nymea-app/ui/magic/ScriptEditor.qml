import QtQuick 2.0
import QtQuick.Controls 2.2
import "../components"
import Nymea 1.0
import QtQuick.Layouts 1.2

Page {
    id: root

    header: NymeaHeader {
        text: qsTr("Script editor")
        onBackPressed: pageStack.pop()

        HeaderButton {
            imageSource: "../images/tick.svg"
            onClicked: {
                if (!d.scriptId) {
                    d.callId = engine.scriptManager.addScript(scriptEdit.text)
                } else {
                    print("editing script", d.scriptId)
                    d.callId = engine.scriptManager.editScript(d.scriptId, scriptEdit.text)
                }
            }
        }
    }

    QtObject {
        id: d
        property int callId
        property var scriptId
    }

    Component.onCompleted: {
        d.callId = engine.scriptManager.addScript(scriptEdit.text);
    }

    Connections {
        target: engine.scriptManager
        onScriptAdded: {
            if (id == d.callId) {
                if (scriptError == "ScriptErrorNoError") {
                    d.scriptId = scriptId;
                }
                errorListView.model = errors
            }
        }
        onScriptEdited: {
            if (id == d.callId) {
                errorListView.model = errors
            }
        }
    }

    ColumnLayout {
        anchors.fill: parent

        Rectangle {
            color: "white"
            Layout.fillWidth: true
            Layout.fillHeight: true

            TextEdit {
                id: scriptEdit
                anchors.fill: parent
                font.family: "Monospace"
                Keys.onPressed: {
                    print("key", event.key)
                    // Things only to happen when we're not autocompleting
                    if (!completionBox.visible) {
                        switch (event.key) {
                        case Qt.Key_Return:
                        case Qt.Key_Enter:
                            syntax.newLine();
                            event.accepted = true;
                            return;
                        case Qt.Key_Tab:
                            syntax.indent(selectionStart, selectionEnd);
                            event.accepted = true;
                            return;
                        case Qt.Key_Backtab:
                            syntax.unindent(selectionStart, selectionEnd);
                            event.accepted = true;
                            return;
                        }
                    }

                    // things to happen in any case
                    switch (event.key) {
                    case Qt.Key_BraceRight:
                        syntax.closeBlock();
                        event.accepted = true;
                        return;
                    }

                    // Things to do only when we're autocompleting
                    if (completionBox.visible) {
                        switch (event.key) {
                        case Qt.Key_Escape:
                            completionBox.hide();
                            event.accepted = true;
                            break;
                        case Qt.Key_Down:
                            completionBox.next();
                            event.accepted = true;
                            break;
                        case Qt.Key_Up:
                            completionBox.previous();
                            event.accepted = true;
                            break;
                        case Qt.Key_Enter:
                        case Qt.Key_Return:
                            syntax.complete(completionBox.currentIndex)
                            event.accepted = true;
                            break;
                        }
                    }
                }

                Rectangle {
                    id: completionBox
                    border.width: 1
                    border.color: "black"
                    height: syntax.completionModel.count * 30
                    width: 200
                    x: scriptEdit.cursorRectangle.x
                    y: scriptEdit.cursorRectangle.y + scriptEdit.cursorRectangle.height
                    visible: syntax.completionModel.count > 0 && !hidden
                    property bool hidden: false
                    Connections {
                        target: syntax.completionModel
                        onCountChanged: {
                            completionBox.hidden = false;
                            completionBox.currentIndex = 0;
                        }
                    }

                    property int currentIndex: 0
                    function next() { currentIndex = (currentIndex + 1) % syntax.completionModel.count}
                    function previous() {
                        currentIndex--;
                        if (currentIndex < 0) {
                            currentIndex = syntax.completionModel.count - 1
                        }
                    }
                    function hide() {
                        hidden = true;
                    }

                    ListView {
                        anchors.fill: parent
                        model: syntax.completionModel
                        delegate: Rectangle {
                            height: 30
                            width: parent.width
                            color: index == completionBox.currentIndex ? "blue" : "white"
                            Label {
                                text: model.displayText
                                color: "black"
                                width: parent.width
                                elide: Text.ElideRight
                            }
                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    syntax.complete(index)
                                }
                            }
                        }
                    }
                }
            }
        }

        ListView {
            id: errorListView
            Layout.fillWidth: true
            Layout.preferredHeight: 100
            delegate: Label {
                width: parent.width
                text: modelData
            }
        }
    }


    ScriptSyntaxHighlighter {
        id: syntax
        engine: _engine
        document: scriptEdit.textDocument
        cursorPosition: scriptEdit.cursorPosition
        onCursorPositionChanged: scriptEdit.cursorPosition = cursorPosition
    }
}
