/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
*
* Copyright 2013 - 2020, nymea GmbH
* Contact: contact@nymea.io
*
* This file is part of nymea.
* This project including source code and documentation is protected by
* copyright law, and remains the property of nymea GmbH. All rights, including
* reproduction, publication, editing and translation, are reserved. The use of
* this project is subject to the terms of a license agreement to be concluded
* with nymea GmbH in accordance with the terms of use of nymea GmbH, available
* under https://nymea.io/license
*
* GNU General Public License Usage
* Alternatively, this project may be redistributed and/or modified under the
* terms of the GNU General Public License as published by the Free Software
* Foundation, GNU version 3. This project is distributed in the hope that it
* will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty
* of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General
* Public License for more details.
*
* You should have received a copy of the GNU General Public License along with
* this project. If not, see <https://www.gnu.org/licenses/>.
*
* For any further details and any questions please contact us under
* contact@nymea.io or see our FAQ/Licensing Information on
* https://nymea.io/license/faq
*
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

import QtQuick 2.4
import QtQuick.Controls 2.2
import Nymea 1.0
import QtQuick.Layouts 1.2
import QtQuick.Controls.Material 2.1
import Qt.labs.settings 1.0
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

        if ((Qt.platform.os == "android" || Qt.platform.os == "ios") && !popupCache.shown) {
            var component = Qt.createComponent(Qt.resolvedUrl("../components/MeaDialog.qml"));
            var infoPopup = component.createObject(root,
                                               {
                                                   title: qsTr("Did you know..."),
                                                   headerIcon: "../images/info.svg",
                                                   text: qsTr("nymea:app is available for all kinds of devices. In order to edit scripts we recommend to use nymea:app on your personal computer or connect a keyboard to your tablet.")
                                               })
            infoPopup.open();
            popupCache.shown = true
        }
    }

    Settings {
        id: popupCache
        property bool shown: false
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
            imageSource: "../images/question.svg"
            text: qsTr("Help")
            onClicked: {
                Qt.openUrlExternally("https://nymea.io/documentation/users/usage/scripting")
            }
        }

        HeaderButton {
            imageSource: "../images/save.svg"
            enabled: d.script && d.script.name !== nameTextField.text || d.oldContent !== scriptEdit.text
            color: enabled ? Style.accentColor : Style.iconColor
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

    ScriptAutoSaver {
        id: autoSaver
        scriptId: d.scriptId
        liveContent: scriptEdit.text
    }

    Connections {
        target: engine.scriptManager
        onAddScriptReply: deployReply(id, scriptError, errors)
        onEditScriptReply: deployReply(id, scriptError, errors)
        function deployReply(id, scriptError, errors) {
            if (id === d.callId) {
                d.callId = -1;
                if (scriptError === "ScriptErrorNoError") {
                    d.oldContent = scriptEdit.text;
                    infoPane.hide();
                    errorPane.hide();
                } else if (scriptError === "ScriptErrorInvalidScript") {
                    errorPane.show();
                }
                errorModel.update(errors)
            }
        }

        onFetchScriptReply: {
            if (id == d.callId && scriptError == "ScriptErrorNoError") {
                d.callId = -1;
                d.oldContent = content;

                if (autoSaver.cachedContent.length > 0 && autoSaver.cachedContent !== content) {
                    console.log("autosaved version available!");
                    scriptEdit.text = autoSaver.cachedContent;
                    infoPane.show();
                } else {
                    scriptEdit.text = content;
                }
                autoSaver.active = true;
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
            var str = "<font color=\"%1\">".arg(type == "ScriptMessageTypeWarning" ? Style.accentColor : Style.foregroundColor) + message + "</font>"
            consoleOutput.append(str)
        }
    }

    // TODO: Make this a SplitView when we can use Qt 5.13
    ColumnLayout {
        id: content
        spacing: 0
        anchors.fill: parent

        InfoPane {
            id: infoPane
            Layout.fillWidth: true
            text: qsTr("An autosaved version of this script has been loaded. Deploy to store this version or reload to restore the deployed version.")
            buttonText: qsTr("Reload")
            z: 1
            onButtonClicked: {
                scriptEdit.text = d.oldContent
                infoPane.hide();
                errorPane.hide();
                errorModel.update([])
            }
        }

        InfoPane {
            id: errorPane
            Layout.fillWidth: true
            color: "red"
            text: qsTr("The script has not been deployed because it contains errors.")
        }

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
                textArea: scriptEdit
            }

            TextArea.flickable: TextArea {
                id: scriptEdit
                leftPadding: lineNumbers.width + 2
                rightPadding: 20
                bottomPadding: 28
                inputMethodHints: Qt.ImhNoPredictiveText | Qt.ImhNoAutoUppercase

                font.family: "Monospace"
                font.pixelSize: app.extraSmallFont
                selectByMouse: true
                selectByKeyboard: true

                onCursorPositionChanged: {
                    if (completionBox.visible) {
                        completion.update();
                    }
                }

                function controlPressed(event) {
                    return event.modifiers & Qt.ControlModifier || event.modifiers & Qt.MetaModifier
                }

                function shiftPressed(event) {
                    return event.modifiers & Qt.ShiftModifier
                }

                Keys.onPressed: {
//                    print("key", event.key, "Completion box visible:", completionBox.visible)
                    // Things to happen only when we're not autocompleting
                    if (!completionBox.visible) {
                        switch (event.key) {
                        case Qt.Key_Return:
                        case Qt.Key_Enter:
                            completion.newLine();
                            event.accepted = true;
                            return;
                        case Qt.Key_Space:
                            if (!completionBox.visible && controlPressed(event)) {
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
                    case Qt.Key_Plus:
                        if (controlPressed(event)) {
                            scriptEdit.font.pixelSize++;
                            event.accepted = true;
                            return;
                        }
                        break;
                    case Qt.Key_Minus:
                        if (controlPressed(event)) {
                            scriptEdit.font.pixelSize--;
                            event.accepted = true;
                            return;
                        }
                    case Qt.Key_Slash:
                        if (controlPressed(event)) {
                            completion.toggleComment(selectionStart, selectionEnd);
                            event.accepted = true;
                            return;
                        }
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
                property bool clearEnabled: errorModel.count > 0
                signal raise()
                function clear() {
                    errorModel.clear();
                }

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
                                var line = parseInt(parts.shift());
                                var col = parseInt(parts.shift());
                                var message = parts.join(":").trim();
                                append({line: line, column: col, message: message})
                                newErrorLines.push(line);
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
                        font: scriptEdit.font
                    }
                }
            }

            ScrollView {
                id: consolePane
                anchors {fill: parent; margins: app.margins/ 2 }
                property string title: qsTr("Console")
                property bool clearEnabled: false
                signal raise()
                function clear() {
                    consoleOutput.text = "";
                    clearEnabled = false;
                }

                TextArea {
                    id: consoleOutput
                    onTextChanged: {
                        consolePane.raise();
                        print("text:", text)
                        consolePane.clearEnabled = true
                    }
                    selectByMouse: true
                    font: scriptEdit.font
                    textFormat: Qt.RichText
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
        backgroundColor: Style.backgroundColor
    }

    CodeCompletion {
        id: completion
        engine: _engine
        document: scriptEdit.textDocument
        cursorPosition: scriptEdit.cursorPosition
        onCursorPositionChanged: scriptEdit.cursorPosition = cursorPosition
        onHint: completionBox.show()
        onSelect: scriptEdit.select(from, to)
    }

    BusyOverlay {
        shown: d.callId != -1
    }
}
