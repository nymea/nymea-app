#include "codecompletion.h"

#include "completionmodel.h"
#include "engine.h"

#include <QDebug>
#include <QQuickItem>
#include <QTextCursor>
#include <QTextBlock>

CodeCompletion::CodeCompletion(QObject *parent):
    QObject(parent)
{
    registerType<QQuickItem>("Item");
    m_classes.insert("DeviceAction", {"id", "deviceId", "actionTypeId", "actionName"});
    m_classes.insert("DeviceState", {"id", "deviceId", "stateTypeId", "stateName", "value", "onValueChanged"});
    m_classes.insert("DeviceEvent", {"id", "deviceId", "eventTypeId", "eventName", "onTriggered"});
    m_classes.insert("Timer", {"id", "interval", "running", "repeat", "onTriggered"});

    m_genericSyntax.insert("property", "property ");

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
            qDebug() << "text cursor changed" << cursor.position();
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
    qDebug() << "setCursorPos" << position << m_cursor.position();
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

    QString blockText = m_cursor.block().text();

    QList<CompletionModel::Entry> entries;

    QRegExp deviceIdExp(".*deviceId: \"[a-zA-Z0-9-]*");
    if (deviceIdExp.exactMatch(blockText)) {
        for (int i = 0; i < m_engine->deviceManager()->devices()->rowCount(); i++) {
            Device *dev = m_engine->deviceManager()->devices()->get(i);
            entries.append(CompletionModel::Entry(dev->id().toString(), dev->name(), true, true));

        }
        blockText.remove(QRegExp(".*deviceId: \""));
        m_model->update(entries);
        m_proxy->setFilter(blockText);
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
            entries.append(CompletionModel::Entry(stateType->id(), stateType->name(), true, true));
        }
        blockText.remove(QRegExp(".*stateTypeId: \""));
        m_model->update(entries);
        m_proxy->setFilter(blockText);
        return;
    }

    QRegExp stateNameExp(".*stateName: \"[a-zA-Z0-9-]*");
    if (stateNameExp.exactMatch(blockText)) {
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
            entries.append(CompletionModel::Entry(stateType->name(), stateType->name(), true, false));
        }
        blockText.remove(QRegExp(".*stateName: \""));
        m_model->update(entries);
        m_proxy->setFilter(blockText);
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
            entries.append(CompletionModel::Entry(actionType->id(), actionType->name(), true, true));
        }
        blockText.remove(QRegExp(".*actionTypeId: \""));
        m_model->update(entries);
        m_proxy->setFilter(blockText);
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
            entries.append(CompletionModel::Entry(actionType->name(), actionType->name(), true, false));
        }
        blockText.remove(QRegExp(".*actionName: \""));
        m_model->update(entries);
        m_proxy->setFilter(blockText);
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
            entries.append(CompletionModel::Entry(eventType->id(), eventType->name(), true, true));
        }
        blockText.remove(QRegExp(".*eventTypeId: \""));
        m_model->update(entries);
        m_proxy->setFilter(blockText);
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
            entries.append(CompletionModel::Entry(eventType->name(), eventType->name(), true, false));
        }
        blockText.remove(QRegExp(".*eventName: \""));
        m_model->update(entries);
        m_proxy->setFilter(blockText);
        return;
    }

    QRegExp importExp("imp(o|or)?");
    if (importExp.exactMatch(blockText)) {
        entries.append(CompletionModel::Entry("import ", "import"));
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

    QRegExp rValueExp(" *[a-zA-Z0-0]+:[ a-zA-Z0-0]*");
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
        // Find all ids in the doc
        tmp = QTextCursor(m_document->textDocument());
        while (!tmp.atEnd()) {
            tmp.movePosition(QTextCursor::StartOfWord, QTextCursor::MoveAnchor);
            tmp.movePosition(QTextCursor::EndOfWord, QTextCursor::KeepAnchor);
            QString word = tmp.selectedText();
            if (word == "id") {
                tmp.movePosition(QTextCursor::NextWord, QTextCursor::MoveAnchor);
                tmp.movePosition(QTextCursor::EndOfWord, QTextCursor::KeepAnchor);
                QString idName = tmp.selectedText();
                entries.append(CompletionModel::Entry(idName, idName));
            }
            tmp.movePosition(QTextCursor::NextWord);
        }
        m_model->update(entries);
        m_proxy->setFilter(word);
        return;
    }

    QRegExp lValueStartExp(" *[a-zA-Z0-9]*");
    if (lValueStartExp.exactMatch(blockText)) {
        qDebug() << "matching";
        QTextCursor blockStartCursor = m_document->textDocument()->find("{", m_cursor, QTextDocument::FindBackward);
        QTextCursor blockEndCursor = m_document->textDocument()->find("}", m_cursor, QTextDocument::FindBackward);
        while (!blockEndCursor.isNull() && blockEndCursor.position() > blockStartCursor.position()) {
            blockStartCursor = m_document->textDocument()->find("{", blockStartCursor, QTextDocument::FindBackward);
            blockEndCursor = m_document->textDocument()->find("}", blockEndCursor, QTextDocument::FindBackward);
        }
        QString className = blockStartCursor.block().text();
        className.remove(QRegExp(" *\\{"));
        while (className.contains(" ")) {
            className.remove(QRegExp(".* "));
        }

        // If we're inside a class, add properties
        if (!className.isEmpty()) {
            foreach (const QString &s, m_classes.value(className)) {
                entries.append(CompletionModel::Entry(s + ": ", s));
            }
        }

        // Always append class names
        foreach (const QString &s, m_classes.keys()) {
            entries.append(CompletionModel::Entry(s + " {", s));
        }

        // Add generic  syntax
        foreach (const QString &s, m_genericSyntax.keys()) {
            entries.append(CompletionModel::Entry(m_genericSyntax.value(s), s));
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

CodeCompletion::BlockInfo CodeCompletion::getBlockInfo(int position)
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

    qDebug() << "Block strats at" << blockStart.position();

    info.name = blockStart.block().text();
    info.name.remove(QRegExp(" *\\{"));
    while (info.name.contains(" ")) {
        info.name.remove(QRegExp(".* "));
    }

    qDebug() << "Block name:" << info.name;

    while (blockStart.position() < position) {
        qDebug() << "current pos:" << blockStart.position() << blockStart.block().text();
        QTextCursor tmp = m_document->textDocument()->find("\n", blockStart);
        foreach (const QString &statement, blockStart.block().text().split(";")) {
            qDebug() << "statement:" << statement;
            QStringList parts = statement.split(":");
            if (parts.length() != 2) {
                continue;
            }
            QString propName = parts.first().trimmed();
            QString propValue = parts.last().split("//").first().trimmed().remove("\"");
            qDebug() << "inserting:" << propName << "->" << propValue;
            info.properties.insert(propName, propValue);
        }
        blockStart.movePosition(QTextCursor::NextBlock);
    }

    return info;
}

void CodeCompletion::complete(int index)
{
    if (index < 0 || index >= m_proxy->rowCount()) {
        qWarning() << "Invalid index for completion";
        return;
    }
    CompletionModel::Entry entry = m_proxy->get(index);
    QString textToInsert = entry.text;

    if (entry.addTrailingQuote) {
        textToInsert.append("\"");
    }
    if (entry.addComment) {
        textToInsert.append(" // " + entry.displayText);
    }
//    textToInsert.append("\n");
    m_cursor.select(QTextCursor::WordUnderCursor);
    m_cursor.removeSelectedText();
    m_cursor.insertText(textToInsert);
    if (textToInsert.endsWith("{")) {
        insertAfterCursor("}");
    }
}

void CodeCompletion::newLine()
{
    qDebug() << "Newline" << m_cursor.position();
    QString line = m_cursor.block().text();
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

void CodeCompletion::insertAfterCursor(const QString &text)
{
    m_cursor.insertText(text);
    m_cursor.movePosition(QTextCursor::PreviousCharacter);
    emit cursorPositionChanged();
}

template<typename T>
void CodeCompletion::registerType(const QString &qmlName)
{
    QMetaObject metaObject = T::staticMetaObject;
    QStringList properties;
    for (int i = 0; i < metaObject.propertyCount(); i++) {
        qDebug() << "Adding prop" << metaObject.property(i).name() << metaObject.property(i).type();
        if (metaObject.property(i).isWritable()) {
            properties.append(metaObject.property(i).name());
        }
    }
    m_classes.insert(qmlName, properties);
}
