import QtQuick 2.4
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
        if (scriptId !== undefined) {;
            d.callId = engine.scriptManager.fetchScript(scriptId);
        } else {
            scriptEdit.text = "import QtQuick 2.0\nimport nymea 1.0\n\nItem {\n    \n}\n"
        }
    }

    header: NymeaHeader {

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

        TextField {
            id: nameTextField
            Layout.fillWidth: true
            text: d.script ? d.script.name : ""
            placeholderText: qsTr("Script name")
        }

        HeaderButton {
            imageSource: "../images/save.svg"
            enabled: d.script.name !== nameTextField.text || d.oldContent !== scriptEdit.text
            color: enabled ? app.accentColor : keyColor
            hoverEnabled: true
            ToolTip.text: qsTr("Deploy script")
            ToolTip.visible: hovered
            onClicked: {
                if (!d.scriptId) {
                    d.callId = engine.scriptManager.addScript(nameTextField.text, scriptEdit.text);
                } else {
                    print("editing script", d.scriptId)
                    if (d.script.name != nameTextField.text) {
                        engine.scriptManager.renameScript(d.scriptId, nameTextField.text)
                    }
                    if (d.oldContent != scriptEdit.text) {
                        d.callId = engine.scriptManager.editScript(d.scriptId, scriptEdit.text)
                        print("called edit", d.callId)
                    }
                }
            }
        }
    }

    QtObject {
        id: d
        property int callId: -1
        property var scriptId
        property string oldContent

        property Script script: engine.scriptManager.scripts.getScript(d.scriptId)
    }

    FontMetrics {
        id: fontMetrics
        font: scriptEdit.font
    }

    Connections {
        target: engine.scriptManager
        onAddScriptReply: {
            if (id == d.callId) {
                d.callId = -1;
                if (scriptError == "ScriptErrorNoError") {
                    d.scriptId = scriptId;
                }
                errorModel.update(errors);
            }
        }
        onEditScriptReply: {
            print("edit reply", id, d.callId)
            if (id == d.callId) {
                d.oldContent = scriptEdit.text;
                d.callId = -1;
                errorModel.update(errors)
            }
        }
        onFetchScriptReply: {
            if (id == d.callId && scriptError == "ScriptErrorNoError") {
                d.callId = -1;
                scriptEdit.text = content;
                d.oldContent = content;
            }
        }
        onRenameScriptReply: {
            if (id == d.callId) {
                d.callId = -1;
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
        id: content
        anchors.fill: parent

        Flickable {
            id: scriptFlickable
            Layout.fillHeight: true
            Layout.fillWidth: true
            clip: true
            interactive: !completionBox.visible
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
                            break;
                        case Qt.Key_PageUp:
                            var oldSelectionStart = scriptEdit.selectionStart;
                            completion.moveCursor(CodeCompletion.MoveOperationPreviousLine, scriptFlickable.height / (fontMetrics.lineSpacing + 2));
                            if (event.modifiers & Qt.ShiftModifier) {
                                scriptEdit.select(oldSelectionStart, scriptEdit.cursorPosition)
                            }
                            return;
                        case Qt.Key_PageDown:
                            var oldSelectionStart = scriptEdit.selectionStart;
                            completion.moveCursor(CodeCompletion.MoveOperationNextLine, scriptFlickable.height / (fontMetrics.lineSpacing + 2));
                            if (event.modifiers & Qt.ShiftModifier) {
                                scriptEdit.select(oldSelectionStart, scriptEdit.cursorPosition)
                            }
                            return;
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
                    case Qt.Key_Period:
                        completion.insertBeforeCursor(".");
                        completionBox.show();
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

    CompletionBox {
        id: completionBox
        property var editorPosition: scriptFlickable.mapToItem(root, 0, 0)
        property int scrollOffsetX: scriptFlickable.contentX + scriptFlickable.originX
        property int scrollOffsetY: scriptFlickable.contentY + scriptFlickable.originY
        property int cursorXOnPage: scriptEdit.cursorRectangle.x + editorPosition.x - scrollOffsetX
        property int cursorYOnPage: scriptEdit.cursorRectangle.y + editorPosition.y - scrollOffsetY
        property int cursorHeight: scriptEdit.cursorRectangle.height
        x: cursorXOnPage - Math.max(0, cursorXOnPage + width - root.width)
        y: cursorYOnPage + cursorHeight + height < content.height ?
               cursorYOnPage + cursorHeight
             : cursorYOnPage - height

        model: completion.model
        textArea: scriptEdit
        font: scriptEdit.font
        onComplete: {
            completion.complete(index)
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

    BusyOverlay {
        shown: d.callId != -1
    }

}
