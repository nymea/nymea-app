import QtQuick 2.0
import QtQuick.Controls 2.2
import Nymea 1.0
import QtQuick.Layouts 1.2
import QtQuick.Controls.Material 2.1
import "../components"
import "scripting"

Page {
    id: root

    property alias scriptId: d.scriptId

    Component.onCompleted: {
        if (scriptId !== undefined) {
            d.callId = engine.scriptManager.fetchScript(scriptId);
        } else {
            scriptEdit.text = "import QtQuick 2.0\nimport nymea 1.0\n\nItem {\n    \n}\n"
            d.callId = engine.scriptManager.addScript(scriptEdit.text);
        }
    }

    header: NymeaHeader {
        text: qsTr("Script editor")
        onBackPressed: {
            if (scriptEdit.text == d.oldContent) {
                pageStack.pop()
                return;
            }
            var comp = Qt.createComponent("../components/MeaDialog.qml");
            var popup = comp.createObject(root, {
                                              title: qsTr("Unsaved changes"),
                                              text: qsTr("There are unsaved changes in the script. Do you want to discard the changes?"),
                                              standardButtons: Dialog.Yes | Dialog.No
                                          })
            popup.onAccepted.connect(function() {
                pageStack.pop();
            });
            popup.open();

        }

        HeaderButton {
            imageSource: "../images/media-playback-start.svg"
            onClicked: {
                if (!d.scriptId) {
                    d.callId = engine.scriptManager.addScript(scriptEdit.text)
                } else {
                    print("editing script", d.scriptId, scriptEdit.text)
                    d.callId = engine.scriptManager.editScript(d.scriptId, scriptEdit.text)
                }
            }
        }
    }

    QtObject {
        id: d
        property int callId
        property var scriptId
        property string oldContent
    }

    Connections {
        target: engine.scriptManager
        onScriptAdded: {
            if (id == d.callId) {
                if (scriptError == "ScriptErrorNoError") {
                    d.scriptId = scriptId;
                }
                errorModel.update(errors);
            }
        }
        onScriptEdited: {
            if (id == d.callId) {
                errorModel.update(errors)
            }
        }
        onScriptFetched: {
            if (id == d.callId && scriptError == "ScriptErrorNoError") {
                scriptEdit.text = content;
                d.oldContent = content;
            }
        }
        onScriptMessage: {
            if (scriptId !== d.scriptId) {
                return;
            }
            messagesModel.append({type: type, message: message})
        }
    }

    // TODO: Make this a SplitView when we can use Qt 5.13
    ColumnLayout {
        anchors.fill: parent

        Flickable {
            id: scriptFlickable
            Layout.fillHeight: true
            Layout.fillWidth: true
            clip: true
            boundsBehavior: Flickable.StopAtBounds

            ScrollBar.vertical: ScrollBar { policy: ScrollBar.AlwaysOn }
            ScrollBar.horizontal: ScrollBar { policy: ScrollBar.AlwaysOn }

            LineNumbers {
                id: lineNumbers
            }

            TextArea.flickable: TextArea {
                id: scriptEdit
                leftPadding: lineNumbers.width + 2
                rightPadding: 20
                bottomPadding: 28

                font.family: "Monospace"
                font.pixelSize: app.extraSmallFont
                selectByMouse: true
                selectByKeyboard: true

                onCursorPositionChanged: {
                    if (completionBox.visible) {
                        completion.update();
                    }
                }

                Keys.onPressed: {
                    print("key", event.key, "Completion box visible:", completionBox.visible)
                    // Things to happen only when we're not autocompleting
                    if (!completionBox.visible) {
                        switch (event.key) {
                        case Qt.Key_Return:
                        case Qt.Key_Enter:
                            completion.newLine();
                            event.accepted = true;
                            return;
                        case Qt.Key_Space:
                            if (!completionBox.visible && (event.modifiers & Qt.ControlModifier)) {
                                completion.update();
                                completionBox.show();
                                return;
                            }
                        }
                    }

                    // things to happen in any case
                    switch (event.key) {
                    case Qt.Key_BraceLeft:
                        completion.insertAfterCursor("}");
                        return;

                    case Qt.Key_BraceRight:
                        completion.closeBlock();
                        event.accepted = true;
                        return;
                    case Qt.Key_Tab:
                        completion.indent(selectionStart, selectionEnd);
                        event.accepted = true;
                        return;
                    case Qt.Key_Backtab:
                        completion.unindent(selectionStart, selectionEnd);
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
                            completion.complete(completionBox.currentIndex)
                            completionBox.hide();
                            event.accepted = true;
                            break;
                        }
                    }
                }

                CompletionBox {
                    id: completionBox
                    model: completion.model
                    textArea: scriptEdit
                    onComplete: {
                        completion.complete(index)
                    }
                }
            }
        }

        EditorPane {
            Layout.fillWidth: true
            Layout.preferredHeight: Math.min(implicitHeight, root.height / 4)

            ScrollView {
                id: errorsPane
                anchors { fill: parent; margins: app.margins / 2 }
                property string title: qsTr("Errors")
                signal raise()

                ListView {
                    id: errorListView
                    model: ListModel {
                        id: errorModel
                        property var errorLines: []
                        function update(errors) {
                            clear();
                            var newErrorLines = []
                            errors.forEach( function(error) {
                                var parts = error.split(":")
                                append({line: parseInt(parts[0]), column: parseInt(parts[1]), message: parts[2].trim()})
                                newErrorLines.push(parseInt(parts[0]));
                            })
                            errorLines = newErrorLines;
                            if (errorModel.count > 0) {
                                errorsPane.raise();
                            }
                        }
                        function getError(lineNumber)  {
                            print("getting error for line", lineNumber, errorModel.count)
                            for (var i = 0; i < errorModel.count; i++) {
                                var entry = get(i);
                                print("i:", i, entry.message, entry.line)
                                if (entry.line === lineNumber) {
                                    return entry;
                                }
                            }
                        }
                    }

                    delegate: Label {
                        width: parent.width
                        text: model.line + ":" + model.column + ": " + model.message
                        font.pixelSize: app.extraSmallFont
                        font.family: "Monospace"
                    }
                }
            }

            ScrollView {
                id: consolePane
                anchors {fill: parent; margins: app.margins/ 2 }
                property string title: qsTr("Console")
                signal raise()

                ListView {
                    id: messagesListView
                    model: ListModel {
                        id: messagesModel
                        onCountChanged: {
                            if (count > 0) {
                                consolePane.raise();
                            }
                        }
                    }
                    property bool autoScroll: true
                    onCountChanged: {
                        if (autoScroll) {
                            messagesListView.positionViewAtEnd()
                        }
                    }
                    onMovementEnded: {
                        autoScroll = messagesListView.atYEnd;
                    }

                    delegate: Label {
                        width: parent.width
                        text: model.message
                        font.pixelSize: app.extraSmallFont
                        font.family: "Monospace"
                        color: model.type === "ScriptMessageTypeWarning" ? "red" : app.foregroundColor
                    }
                }
            }

        }
    }


    ScriptSyntaxHighlighter {
        id: syntax
        document: scriptEdit.textDocument
        backgroundColor: app.backgroundColor
    }

    CodeCompletion {
        id: completion
        engine: _engine
        document: scriptEdit.textDocument
        cursorPosition: scriptEdit.cursorPosition
        onCursorPositionChanged: scriptEdit.cursorPosition = cursorPosition
    }
}
