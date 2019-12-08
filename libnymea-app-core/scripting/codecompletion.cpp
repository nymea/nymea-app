#include "codecompletion.h"

#include "engine.h"

#include <QDebug>
#include <QQuickItem>
#include <QTextCursor>
#include <QTextBlock>

CodeCompletion::CodeCompletion(QObject *parent):
    QObject(parent)
{
    m_classes.insert("Item", ClassInfo("Item", {"id"}));
    m_classes.insert("DeviceAction", ClassInfo("DeviceAction", {"id", "deviceId", "actionTypeId", "actionName"}, {"execute"}));
    m_classes.insert("DeviceState", ClassInfo("DeviceState", {"id", "deviceId", "stateTypeId", "stateName", "value"}, {}, {"onValueChanged"}));
    m_classes.insert("DeviceEvent", ClassInfo("DeviceEvent", {"id", "deviceId", "eventTypeId", "eventName"}, {}, {"onTriggered"}));
    m_classes.insert("Timer", ClassInfo("Timer", {"id", "interval", "running", "repeat"}, {"start", "stop"}, {"onTriggered"}));
    m_classes.insert("PropertyAnimation", ClassInfo("PropertyAnimation", {"id", "target", "targets", "property", "properties", "value", "from", "to", "easing", "exclude", "duration", "alwaysRunToEnd", "loops", "paused", "running"}, {"start", "stop", "pause", "resume", "complete"}, {"onStarted", "onStopped", "onFinished", "onRunningChanged"}));
    m_classes.insert("ColorAnimation", ClassInfo("ColorAnimation", {"id", "target", "targets", "property", "properties", "value", "from", "to", "easing", "exclude", "duration", "alwaysRunToEnd", "loops", "paused", "running"}, {"start", "stop", "pause", "resume", "complete"}, {"onStarted", "onStopped", "onFinished", "onRunningChanged"}));
    m_classes.insert("SequentialAnimation", ClassInfo("SequentialAnimation", {"id", "alwaysRunToEnd", "loops", "paused", "running"}, {"start", "stop", "pause", "resume", "complete"}, {"onStarted", "onStopped", "onFinished", "onRunningChanged"}));
    m_classes.insert("ParallelAnimation", ClassInfo("ParallelAnimation", {"id", "alwaysRunToEnd", "loops", "paused", "running"}, {"start", "stop", "pause", "resume", "complete"}, {"onStarted", "onStopped", "onFinished", "onRunningChanged"}));
    m_classes.insert("PauseAnimation", ClassInfo("PauseAnimation", {"id", "duration", "alwaysRunToEnd", "loops", "paused", "running"}, {"start", "stop", "pause", "resume", "complete"}, {"onStarted", "onStopped", "onFinished", "onRunningChanged"}));

    m_attachedClasses.insert("Component", ClassInfo("Component", {}, {}, {"onCompleted", "onDestruction", "onDestroyed"}));

    m_genericSyntax.insert("property", "property ");
    m_genericSyntax.insert("function", "function ");

    m_genericJsSyntax.insert("for", "for");
    m_genericJsSyntax.insert("var", "var");
    m_genericJsSyntax.insert("while", "while ");
    m_genericJsSyntax.insert("do", "do ");
    m_genericJsSyntax.insert("if", "if ");
    m_genericJsSyntax.insert("else", "else ");
    m_genericJsSyntax.insert("print", "print");

    m_jsClasses.insert("console", ClassInfo("console", {}, {"log", "warn"}));
    m_jsClasses.insert("JSON", ClassInfo("JSON", {}, {"stringify", "parse", "hasOwnProperty", "isPrototypeOf", "toString", "valueOf", "toLocaleString", "propertyIsEnumerable"}));

    m_model = new CompletionModel(this);
    m_proxy = new CompletionProxyModel(m_model, this);
    connect(m_proxy, &CompletionProxyModel::filterChanged, this, &CodeCompletion::currentWordChanged);
}

Engine *CodeCompletion::engine() const
{
    return m_engine;
}

void CodeCompletion::setEngine(Engine *engine)
{
    if (m_engine != engine) {
        m_engine = engine;
        emit engineChanged();
    }
}

QQuickTextDocument *CodeCompletion::document() const
{
    return m_document;
}

void CodeCompletion::setDocument(QQuickTextDocument *document)
{
    if (m_document != document) {
        m_document = document;
        emit documentChanged();
        m_cursor = QTextCursor(m_document->textDocument());
        emit cursorPositionChanged();

        connect(m_document->textDocument(), &QTextDocument::cursorPositionChanged, this, [this](const QTextCursor &cursor){
            m_cursor = cursor;
            update();
        });
    }
}

int CodeCompletion::cursorPosition() const
{
    return m_cursor.position();
}

void CodeCompletion::setCursorPosition(int position)
{
    // This is a bit tricky: As our cursor works on the same textDocument as the view,
    // our cursor will already have the position set to the new one by the time we
    // receive the update from the View when the document is changed.
    // But we can't just connect to our cursor's updates as that will miss out events
    // generated in the UI without changing the document (e.g. move cursor with kbd/mouse)

    if (m_cursor.position() != position) {
        m_cursor.setPosition(position);
        // NOTE: Don't emit cursorPositionChanged here, it will break selections
        // because the view thinks we've edited the document.
        // If we actually edit the document, the view will sync up automatically
        // through the document. So we must *only* emit cursorPositionChanged when
        // we actually want to move it without changing the document.
    }
}

QString CodeCompletion::currentWord() const
{
    return m_proxy->filter();
}

CompletionProxyModel *CodeCompletion::model() const
{
    return m_proxy;
}

void CodeCompletion::update()
{
    if (!m_engine || !m_document) {
        return;
    }

    static int lastUpdatePos = -1;
    if (lastUpdatePos == m_cursor.position()) {
        return;
    }
    lastUpdatePos = m_cursor.position();

    QTextCursor tmp = m_cursor;
    tmp.movePosition(QTextCursor::StartOfBlock, QTextCursor::KeepAnchor);
    QString blockText = tmp.selectedText();

    QList<CompletionModel::Entry> entries;

    QRegExp deviceIdExp(".*deviceId: \"[a-zA-Z0-9- ]*");
    if (deviceIdExp.exactMatch(blockText)) {
        for (int i = 0; i < m_engine->deviceManager()->devices()->rowCount(); i++) {
            Device *dev = m_engine->deviceManager()->devices()->get(i);
            entries.append(CompletionModel::Entry(dev->id().toString() + "\" // " + dev->name(), dev->name(), "thing", dev->deviceClass()->interfaces().join(",")));
        }
        blockText.remove(QRegExp(".*deviceId: \""));
        m_model->update(entries);
        m_proxy->setFilter(blockText);
        emit hint();
        return;
    }

    QRegExp stateTypeIdExp(".*stateTypeId: \"[a-zA-Z0-9-]*");
    if (stateTypeIdExp.exactMatch(blockText)) {
        BlockInfo info = getBlockInfo(m_cursor.position());
        if (!info.properties.contains("deviceId")) {
            return;
        }
        QString deviceId = info.properties.value("deviceId");

        qDebug() << "selected deviceId" << deviceId;
        Device *device = m_engine->deviceManager()->devices()->getDevice(deviceId);
        if (!device) {
            return;
        }

        for (int i = 0; i < device->deviceClass()->stateTypes()->rowCount(); i++) {
            StateType *stateType = device->deviceClass()->stateTypes()->get(i);
            entries.append(CompletionModel::Entry(stateType->id().toString() + "\" // " + stateType->name(), stateType->name(), "stateType"));
        }
        blockText.remove(QRegExp(".*stateTypeId: \""));
        m_model->update(entries);
        m_proxy->setFilter(blockText);
        emit hint();
        return;
    }

    QRegExp stateNameExp(".*stateName: \"[a-zA-Z0-9-]*");
    qDebug() << "block text" << blockText << stateNameExp.exactMatch(blockText);
    if (stateNameExp.exactMatch(blockText)) {
        BlockInfo info = getBlockInfo(m_cursor.position());
        qDebug() << "stateName block info" << info.name << info.properties;
        if (!info.properties.contains("deviceId")) {
            return;
        }
        QString deviceId = info.properties.value("deviceId");

        qDebug() << "selected deviceId" << deviceId;
        Device *device = m_engine->deviceManager()->devices()->getDevice(deviceId);
        if (!device) {
            return;
        }

        for (int i = 0; i < device->deviceClass()->stateTypes()->rowCount(); i++) {
            StateType *stateType = device->deviceClass()->stateTypes()->get(i);
            entries.append(CompletionModel::Entry(stateType->name() + "\"", stateType->name(), "stateType"));
        }
        blockText.remove(QRegExp(".*stateName: \""));
        m_model->update(entries);
        m_proxy->setFilter(blockText);
        emit hint();
        return;
    }

    QRegExp actionTypeIdExp(".*actionTypeId: \"[a-zA-Z0-9-]*");
    if (actionTypeIdExp.exactMatch(blockText)) {
        BlockInfo info = getBlockInfo(m_cursor.position());
        if (!info.properties.contains("deviceId")) {
            return;
        }
        QString deviceId = info.properties.value("deviceId");

        qDebug() << "selected deviceId" << deviceId;
        Device *device = m_engine->deviceManager()->devices()->getDevice(deviceId);
        if (!device) {
            return;
        }

        for (int i = 0; i < device->deviceClass()->actionTypes()->rowCount(); i++) {
            ActionType *actionType = device->deviceClass()->actionTypes()->get(i);
            entries.append(CompletionModel::Entry(actionType->id().toString() + "\" // " + actionType->name(), actionType->name(), "actionType"));
        }
        blockText.remove(QRegExp(".*actionTypeId: \""));
        m_model->update(entries);
        m_proxy->setFilter(blockText);
        emit hint();
        return;
    }

    QRegExp actionNameExp(".*actionName: \"[a-zA-Z0-9-]*");
    if (actionNameExp.exactMatch(blockText)) {
        BlockInfo info = getBlockInfo(m_cursor.position());
        if (!info.properties.contains("deviceId")) {
            return;
        }
        QString deviceId = info.properties.value("deviceId");

        qDebug() << "selected deviceId" << deviceId;
        Device *device = m_engine->deviceManager()->devices()->getDevice(deviceId);
        if (!device) {
            return;
        }

        for (int i = 0; i < device->deviceClass()->actionTypes()->rowCount(); i++) {
            ActionType *actionType = device->deviceClass()->actionTypes()->get(i);
            entries.append(CompletionModel::Entry(actionType->name() + "\"", actionType->name(), "actionType"));
        }
        blockText.remove(QRegExp(".*actionName: \""));
        m_model->update(entries);
        m_proxy->setFilter(blockText);
        emit hint();
        return;
    }

    QRegExp eventTypeIdExp(".*eventTypeId: \"[a-zA-Z0-9-]*");
    if (eventTypeIdExp.exactMatch(blockText)) {
        BlockInfo info = getBlockInfo(m_cursor.position());
        if (!info.properties.contains("deviceId")) {
            return;
        }
        QString deviceId = info.properties.value("deviceId");

        Device *device = m_engine->deviceManager()->devices()->getDevice(deviceId);
        if (!device) {
            return;
        }

        for (int i = 0; i < device->deviceClass()->eventTypes()->rowCount(); i++) {
            EventType *eventType = device->deviceClass()->eventTypes()->get(i);
            entries.append(CompletionModel::Entry(eventType->id().toString() + "\" // " + eventType->name(), eventType->name(), "eventType"));
        }
        blockText.remove(QRegExp(".*eventTypeId: \""));
        m_model->update(entries);
        m_proxy->setFilter(blockText);
        emit hint();
        return;
    }

    QRegExp eventNameExp(".*eventName: \"[a-zA-Z0-9-]*");
    if (eventNameExp.exactMatch(blockText)) {
        BlockInfo info = getBlockInfo(m_cursor.position());
        if (!info.properties.contains("deviceId")) {
            return;
        }
        QString deviceId = info.properties.value("deviceId");

        Device *device = m_engine->deviceManager()->devices()->getDevice(deviceId);
        if (!device) {
            return;
        }

        for (int i = 0; i < device->deviceClass()->eventTypes()->rowCount(); i++) {
            EventType *eventType = device->deviceClass()->eventTypes()->get(i);
            entries.append(CompletionModel::Entry(eventType->name() + "\"", eventType->name(), "eventType"));
        }
        blockText.remove(QRegExp(".*eventName: \""));
        m_model->update(entries);
        m_proxy->setFilter(blockText);
        emit hint();
        return;
    }

    QRegExp importExp("imp(o|or)?");
    if (importExp.exactMatch(blockText)) {
        entries.append(CompletionModel::Entry("import ", "import", "keyword", ""));
        m_model->update(entries);
        m_proxy->setFilter(blockText);
        return;
    }

    QRegExp importExp2("import [a-zA-Z]*");
    if (importExp2.exactMatch(blockText)) {
        entries.append(CompletionModel::Entry("QtQuick 2.0"));
        entries.append(CompletionModel::Entry("nymea 1.0"));
        m_model->update(entries);
        blockText.remove("import ");
        m_proxy->setFilter(blockText);
        return;
    }

    QRegExp rValueExp(" *[\\.a-zA-Z0-0]+:[ a-zA-Z0-0]*");
    if (rValueExp.exactMatch(blockText)) {
        QTextCursor tmp = m_cursor;
        tmp.movePosition(QTextCursor::StartOfWord, QTextCursor::KeepAnchor);
        QString word = tmp.selectedText();

        tmp.movePosition(QTextCursor::PreviousWord, QTextCursor::MoveAnchor, 2);
        tmp.movePosition(QTextCursor::EndOfWord, QTextCursor::KeepAnchor);
        QString previousWord = tmp.selectedText();

        if (previousWord.isEmpty()) {
            m_model->update({});
            return;
        }

        qDebug() << "rValue" << previousWord << word;
        entries.append(getIds());
        foreach (const QString &s, m_jsClasses.keys()) {
            entries.append(CompletionModel::Entry(s, s, "type"));
        }
        foreach (const QString &s, m_attachedClasses.keys()) {
            entries.append(CompletionModel::Entry(s, s, "type"));
        }

        m_model->update(entries);
        m_proxy->setFilter(word);
        return;
    }

    QRegExp dotExp(".*[a-zA-Z0-9]+\\.[a-zA-Z0-9]*");
    if (dotExp.exactMatch(blockText)) {
        QString id = blockText;
        id.remove(QRegExp(".* ")).remove(QRegExp("\\.[a-zA-Z0-9]*"));
        QString type = getIdTypes().value(id);
        qDebug() << "dot expression:" << id << type;
        // Classes
        foreach (const QString &property, m_classes.value(type).properties) {
            entries.append(CompletionModel::Entry(property, property, "property"));
        }
        foreach (const QString &method, m_classes.value(type).methods) {
            entries.append(CompletionModel::Entry(method + "(", method, "method", "", ")"));
        }
        // Attached classes/properties
        foreach (const QString &property, m_attachedClasses.value(id).properties) {
            entries.append(CompletionModel::Entry(property, property, "property"));
        }
        foreach (const QString &method, m_attachedClasses.value(id).methods) {
            entries.append(CompletionModel::Entry(method + "(", method, "method", "", ")"));
        }
        foreach (const QString &event, m_attachedClasses.value(id).events) {
            entries.append(CompletionModel::Entry(event + ": ", event, "event"));
        }
        // JS global objects
        foreach (const QString &property, m_jsClasses.value(id).properties) {
            entries.append(CompletionModel::Entry(property, property, "property"));
        }
        foreach (const QString &method, m_jsClasses.value(id).methods) {
            entries.append(CompletionModel::Entry(method + "(", method, "method", "", ")"));
        }
        m_model->update(entries);
        m_proxy->setFilter(blockText.remove(QRegExp(".*\\.")));
        return;
    }

    // Are we in a JS block?
    int pos = m_cursor.position();
    BlockInfo jsBlock = getBlockInfo(pos);
    bool isImperative = jsBlock.name.endsWith(":") || jsBlock.name.endsWith("()");
    bool atStart = false;
    while (!isImperative && jsBlock.valid && !atStart) {
        qDebug() << "is imperative block?" << isImperative << jsBlock.name << "blockText" << blockText;
        BlockInfo tmp = getBlockInfo(jsBlock.start - 1);
        if (tmp.valid) {
            jsBlock = tmp;
            isImperative = jsBlock.name.endsWith(":") || jsBlock.name.endsWith("()");
        } else {
            atStart = true;
        }
    }
    if (isImperative) {
        // Starting a new expression?
        QRegExp newExpressionExp("(.*; [a-zA-Z0-9]*| *[a-zA-Z0-9]*)");
        if (newExpressionExp.exactMatch(blockText)) {
            // Add generic qml syntax
            foreach (const QString &s, m_genericJsSyntax.keys()) {
                entries.append(CompletionModel::Entry(m_genericJsSyntax.value(s), s, "keyword", ""));
            }
            // Add js global objects
            foreach (const QString &s, m_jsClasses.keys()) {
                entries.append(CompletionModel::Entry(s, s, "type"));
            }

            entries.append(getIds());
        }

        m_model->update(entries);
        m_proxy->setFilter(blockText.remove(QRegExp(".* ")));
        return;
    }

    QRegExp lValueStartExp(" *[a-zA-Z0-9]*");
    if (lValueStartExp.exactMatch(blockText)) {
        BlockInfo blockInfo = getBlockInfo(m_cursor.position());

        // If we're inside a class, add properties
        qDebug() << "Block name" << blockInfo.name;

        if (!blockInfo.name.isEmpty()) {
            foreach (const QString &s, m_classes.value(blockInfo.name).properties) {
                if (!blockInfo.properties.contains(s)) {
                    entries.append(CompletionModel::Entry(s + ": ", s, "property"));
                }
            }
            foreach (const QString &s, m_classes.value(blockInfo.name).events) {
                if (!blockInfo.properties.contains(s)) {
                    entries.append(CompletionModel::Entry(s + ": ", s, "event"));
                }
            }
        }
        // Always append class names
        foreach (const QString &s, m_classes.keys()) {
            entries.append(CompletionModel::Entry(s + " {", s, "type", "", "}"));
        }
        // Always append attached class names
        foreach (const QString &s, m_attachedClasses.keys()) {
            entries.append(CompletionModel::Entry(s, s, "type"));
        }

        // Add generic qml syntax
        foreach (const QString &s, m_genericSyntax.keys()) {
            entries.append(CompletionModel::Entry(m_genericSyntax.value(s), s, "keyword", ""));
        }

        m_model->update(entries);
        blockText.remove(QRegExp(".* "));
        m_proxy->setFilter(blockText);
        qDebug() << "Model has" << m_model->rowCount() << "Filtered:" << m_proxy->rowCount() << "filter:" << blockText;
        return;
    }


    m_model->update({});
    m_proxy->setFilter(QString());
}

CodeCompletion::BlockInfo CodeCompletion::getBlockInfo(int position) const
{
    BlockInfo info;

    QTextCursor blockStart = m_document->textDocument()->find("{", position, QTextDocument::FindBackward);
    QTextCursor blockEnd = m_document->textDocument()->find("}", position, QTextDocument::FindBackward);
    while (blockEnd.position() > blockStart.position() && !blockStart.isNull()) {
        blockStart = m_document->textDocument()->find("{", blockStart, QTextDocument::FindBackward);
        blockEnd = m_document->textDocument()->find("}", blockEnd, QTextDocument::FindBackward);
    }

    if (blockStart.isNull()) {
        return info;
    }

    info.start = blockStart.position();
    info.end = m_document->textDocument()->find("}", position).position();
    info.valid = true;


    info.name = blockStart.block().text();
    info.name.remove(QRegExp(" *\\{"));
    while (info.name.contains(" ")) {
        info.name.remove(QRegExp(".* "));
    }

    int childBlocks = 0;
    while (!blockStart.isNull() && blockStart.position() < position) {
        QString line = blockStart.block().text();
        if (line.endsWith("{")) {
            childBlocks++;
            if (!blockStart.movePosition(QTextCursor::NextBlock)) {
                break;
            }
            continue;
        }
        if (line.trimmed().startsWith("}")) {
            childBlocks--;
            if (!blockStart.movePosition(QTextCursor::NextBlock)) {
                break;
            }
            continue;
        }
        // \n
        if (childBlocks > 1) { // Skip all stuff in child blocks
            blockStart.movePosition(QTextCursor::NextBlock);
            continue;
        }
        foreach (const QString &statement, blockStart.block().text().split(";")) {
            qDebug() << "Have statement" << statement;
            QStringList parts = statement.split(":");
            if (parts.length() != 2) {
                continue;
            }
            QString propName = parts.first().trimmed();
            QString propValue = parts.last().split("//").first().trimmed().remove("\"");
            qDebug() << "inserting:" << propName << "->" << propValue;
            info.properties.insert(propName, propValue);
        }
        if (!blockStart.movePosition(QTextCursor::NextBlock)) {
            break;
        }
    }

    return info;
}

QList<CompletionModel::Entry> CodeCompletion::getIds() const
{
    // Find all ids in the doc
    QList<CompletionModel::Entry> entries;
    QTextCursor tmp = QTextCursor(m_document->textDocument());
    while (!tmp.atEnd()) {
        tmp.movePosition(QTextCursor::StartOfWord, QTextCursor::MoveAnchor);
        tmp.movePosition(QTextCursor::EndOfWord, QTextCursor::KeepAnchor);
        QString word = tmp.selectedText();
        if (word == "id") {
            tmp.movePosition(QTextCursor::NextWord, QTextCursor::MoveAnchor);
            tmp.movePosition(QTextCursor::EndOfWord, QTextCursor::KeepAnchor);
            QString idName = tmp.selectedText();
            entries.append(CompletionModel::Entry(idName, idName, "id", ""));
        }
        tmp.movePosition(QTextCursor::NextWord);
    }
    return entries;
}

QHash<QString, QString> CodeCompletion::getIdTypes() const
{
    QHash<QString, QString> ret;
    QTextCursor tmp = QTextCursor(m_document->textDocument());
    while (!tmp.atEnd()) {
        tmp.movePosition(QTextCursor::StartOfWord, QTextCursor::MoveAnchor);
        tmp.movePosition(QTextCursor::EndOfWord, QTextCursor::KeepAnchor);
        QString word = tmp.selectedText();
        if (word == "id") {
            tmp.movePosition(QTextCursor::NextWord, QTextCursor::MoveAnchor);
            tmp.movePosition(QTextCursor::EndOfWord, QTextCursor::KeepAnchor);
            QString idName = tmp.selectedText();
            BlockInfo info = getBlockInfo(tmp.position());
            if (!info.name.isEmpty()) {
                ret.insert(idName, info.name);
            }
        }
        tmp.movePosition(QTextCursor::NextWord);
    }
    return ret;
}

int CodeCompletion::openingBlocksBefore(int position) const
{
    int opening = 0;
    int closing = 0;
    QTextCursor tmp = m_cursor;
    tmp.setPosition(position);
    do {
        tmp = m_document->textDocument()->find(QRegExp("[{}]"), tmp, QTextDocument::FindBackward);
        if (tmp.selectedText() == "{")
            opening++;
        if (tmp.selectedText() == "}")
            closing++;
    } while (!tmp.isNull());

    return opening - closing;
}

int CodeCompletion::closingBlocksAfter(int position) const
{
    int opening = 0;
    int closing = 0;
    QTextCursor tmp = m_cursor;
    tmp.setPosition(position);
    do {
        tmp = m_document->textDocument()->find(QRegExp("[{}]"), tmp);
        if (tmp.selectedText() == "{")
            opening++;
        if (tmp.selectedText() == "}")
            closing++;
    } while (!tmp.isNull());

    return closing - opening;
}

void CodeCompletion::complete(int index)
{
    if (index < 0 || index >= m_proxy->rowCount()) {
        qWarning() << "Invalid index for completion";
        return;
    }
    CompletionModel::Entry entry = m_proxy->get(index);

    m_cursor.select(QTextCursor::WordUnderCursor);
    m_cursor.removeSelectedText();
    qDebug() << "inserting:" << entry.text;
    m_cursor.insertText(entry.text);

    qDebug() << "inserting after cursor:" << entry.trailingText;
    insertAfterCursor(entry.trailingText);
}

void CodeCompletion::newLine()
{
    qDebug() << "Newline" << m_cursor.position();
    QString line = m_cursor.block().text();

    if (line.endsWith("{") && openingBlocksBefore(m_cursor.position()) > closingBlocksAfter(m_cursor.position())) {
        m_cursor.insertText("}");
        m_cursor.movePosition(QTextCursor::PreviousCharacter);
    }

    QString trimmedLine = line;
    trimmedLine.remove(QRegExp("^[ ]+"));
    int indent = line.length() - trimmedLine.length();

    m_cursor.insertText(QString("\n").leftJustified(indent + 1, ' '));
    if (m_cursor.block().previous().text().endsWith("{")) {
        m_cursor.insertText("    ");
        if (m_cursor.block().text().trimmed().endsWith("}")) {
            m_cursor.insertText(QString("\n").leftJustified(indent + 1, ' '));
            m_cursor.movePosition(QTextCursor::PreviousBlock, QTextCursor::MoveAnchor, 1);
            m_cursor.movePosition(QTextCursor::EndOfLine, QTextCursor::MoveAnchor, 1);
            emit cursorPositionChanged();
        }
    }
}

void CodeCompletion::indent(int from, int to)
{
    QTextCursor tmp = QTextCursor(m_document->textDocument());
    tmp.setPosition(from);
    if (from == to) {
        tmp.insertText("    ");
    } else {
        while (tmp.position() < to) {
            tmp.insertText("    ");
            to += 4;
            if (!tmp.movePosition(QTextCursor::NextBlock)) {
                break;
            }
        }
    }
}

void CodeCompletion::unindent(int from, int to)
{
    QTextCursor tmp = QTextCursor(m_document->textDocument());
    tmp.setPosition(from);
    tmp.movePosition(QTextCursor::StartOfLine);
    if (from == to) {
        if (tmp.block().text().startsWith("    ")) {
            tmp.movePosition(QTextCursor::NextCharacter, QTextCursor::KeepAnchor, 4);
            tmp.removeSelectedText();
        }
    } else {
        // Make sure all selected lines start with 4 empty spaces before we start editing
        bool ok = true;
        while (tmp.position() < to) {
            if (!tmp.block().text().startsWith("    ")) {
                ok = false;
                break;
            }
            if (!tmp.movePosition(QTextCursor::NextBlock)) {
                ok = false;
                break;
            }
        }
        if (ok) {
            tmp.setPosition(from);
            tmp.movePosition(QTextCursor::StartOfLine);
            while (tmp.position() < to) {
                tmp.movePosition(QTextCursor::NextCharacter, QTextCursor::KeepAnchor, 4);
                tmp.removeSelectedText();
                to -= 4;
                if (!tmp.movePosition(QTextCursor::NextBlock)) {
                    break;
                }
            }
        }
    }
}

void CodeCompletion::closeBlock()
{
    m_cursor.insertText("}");
    if (m_cursor.block().text().trimmed() == "}") {
        unindent(m_cursor.position(), m_cursor.position());
    }
}

void CodeCompletion::insertBeforeCursor(const QString &text)
{
    m_cursor.insertText(text);
}

void CodeCompletion::insertAfterCursor(const QString &text)
{
    m_cursor.insertText(text);
    m_cursor.movePosition(QTextCursor::PreviousCharacter, QTextCursor::MoveAnchor, text.length());
    emit cursorPositionChanged();
}

void CodeCompletion::moveCursor(CodeCompletion::MoveOperation moveOperation, int count)
{
    switch (moveOperation) {
    case MoveOperationPreviousLine:
        m_cursor.movePosition(QTextCursor::PreviousBlock, QTextCursor::MoveAnchor, count);
        emit cursorPositionChanged();
        return;
    case MoveOperationNextLine:
        m_cursor.movePosition(QTextCursor::NextBlock, QTextCursor::MoveAnchor, count);
        emit cursorPositionChanged();
        return;
    case MoveOperationPreviousWord: {
        // We're not using the cursors next/previos word because we want camelCase word fragments
        QTextCursor tmp = m_document->textDocument()->find(QRegExp("[A-Z\\.:\"'\\(\\)\\[\\]^ ]"), m_cursor.position() - 1, QTextDocument::FindBackward);
        qWarning() << "found at" << tmp.position() << "starting at" << m_cursor.position();
        m_cursor.setPosition(tmp.position());
        emit cursorPositionChanged();
        return;
    }
    case MoveOperationNextWord: {
        // We're not using the cursors next/previos word because we want camelCase word fragments
        QTextCursor tmp = m_document->textDocument()->find(QRegExp("[A-Z\\.:\"'\\(\\)\\[\\]$ ]"), m_cursor.position() + 1);
        m_cursor.setPosition(tmp.position() - 1);
        emit cursorPositionChanged();
        return;
    }
    }
}
