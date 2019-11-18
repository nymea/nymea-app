#include "scriptsyntaxhighlighter.h"

#include "engine.h"
#include "devicemanager.h"
#include "devices.h"

#include <QDebug>
#include <QMetaObject>
#include <QTextDocumentFragment>

class ScriptSyntaxHighlighterPrivate: public QSyntaxHighlighter
{
    Q_OBJECT
public:
    ScriptSyntaxHighlighterPrivate(QObject *parent);

protected:
    void highlightBlock(const QString &text) override;

signals:
    void contentChanged(const QString &text);

private:
    enum BlockState {
        BlockStateInvalid = -1,
        BlockStateNone = 0,
        BlockStateImport = 1,
        BlockStateAction,
        BlockstateDeviceId,
    };
    struct HighlightingRule
    {
        QRegExp pattern;
        QTextCharFormat format;
    };
    QVector<HighlightingRule> highlightingRules;

    QTextCharFormat keywordFormat;
    QTextCharFormat propertyFormat;
    QTextCharFormat lookupFormat;
    QTextCharFormat quotationFormat;
    QTextCharFormat itemFormat;
    QTextCharFormat cppObjectFormat;
};

ScriptSyntaxHighlighter::ScriptSyntaxHighlighter(QObject *parent) : QObject(parent)
{
    m_completionModel = new CompletionModel(this);
    m_proxyModel = new CompletionProxyModel(m_completionModel, this);
    m_highlighter = new ScriptSyntaxHighlighterPrivate(this);

    m_classes.insert("Action", {"id", "deviceId", "actionTypeId", "actionName"});
}

Engine *ScriptSyntaxHighlighter::engine() const
{
    return m_engine;
}

void ScriptSyntaxHighlighter::setEngine(Engine *engine)
{
    if (m_engine != engine) {
        m_engine = engine;
        emit engineChanged();
    }
}

QQuickTextDocument *ScriptSyntaxHighlighter::document() const
{
    return m_document;
}

void ScriptSyntaxHighlighter::setDocument(QQuickTextDocument *document)
{
    if (m_document != document) {
        m_document = document;
        m_highlighter->setDocument(m_document->textDocument());

        connect(document->textDocument(), &QTextDocument::cursorPositionChanged, this, &ScriptSyntaxHighlighter::onCursorPositionChanged);
        emit documentChanged();
    }
}

int ScriptSyntaxHighlighter::cursorPosition() const
{
    return m_currentCursor.position();
}

void ScriptSyntaxHighlighter::setCursorPosition(int cursorPosition)
{
    if (m_currentCursor.position() != cursorPosition) {
        m_currentCursor.setPosition(cursorPosition);
//        emit cursorPositionChanged();
        onCursorPositionChanged(m_currentCursor);
    }
}

CompletionProxyModel *ScriptSyntaxHighlighter::completionModel() const
{
    return m_proxyModel;
}

void ScriptSyntaxHighlighter::complete(int index)
{
    if (index < 0 || index >= m_proxyModel->rowCount()) {
        qWarning() << "Invalid index for completion";
        return;
    }
    CompletionModel::Entry entry = m_proxyModel->get(index);
    QString textToInsert = entry.text;

    if (entry.addTrailingQuote) {
        textToInsert.append("\"");
    }
    if (entry.addComment) {
        textToInsert.append(" // " + entry.displayText);
    }
//    textToInsert.append("\n");
    m_currentCursor.select(QTextCursor::WordUnderCursor);
    m_currentCursor.removeSelectedText();
    m_currentCursor.insertText(textToInsert);
}

void ScriptSyntaxHighlighter::newLine()
{
    QString line = m_currentCursor.block().text();
    QString trimmedLine = line;
    trimmedLine.remove(QRegExp("^[ ]+"));
    int indent = line.length() - trimmedLine.length();

    m_currentCursor.insertText(QString("\n").leftJustified(indent + 1, ' '));
    if (m_currentCursor.block().previous().text().endsWith("{")) {
        m_document->textDocument()->indentWidth();
        m_currentCursor.insertText("    ");
        m_currentCursor.insertText(QString("\n").leftJustified(indent + 1, ' '));
        m_currentCursor.insertText("}");
        m_currentCursor.movePosition(QTextCursor::PreviousBlock, QTextCursor::MoveAnchor, 1);
        m_currentCursor.movePosition(QTextCursor::EndOfLine, QTextCursor::MoveAnchor, 1);
        emit cursorPositionChanged();
    }
}

void ScriptSyntaxHighlighter::indent(int from, int to)
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

void ScriptSyntaxHighlighter::unindent(int from, int to)
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

void ScriptSyntaxHighlighter::closeBlock()
{
    m_currentCursor.insertText("}");
    if (m_currentCursor.block().text().trimmed() == "}") {
        unindent(m_currentCursor.position(), m_currentCursor.position());
    }
}

void ScriptSyntaxHighlighter::onCursorPositionChanged(const QTextCursor &cursor)
{
    m_currentCursor = cursor;
    QTextCursor word = cursor;
    word.select(QTextCursor::WordUnderCursor);

    QString blockText = cursor.block().text();
    m_completionModel->clear();
    m_proxyModel->setFilter(QString());
    if (!m_engine) {
        return;
    }
    QRegExp deviceIdExp(".*deviceId: \"[a-zA-Z0-9-]*");
    if (deviceIdExp.exactMatch(blockText)) {
        for (int i = 0; i < m_engine->deviceManager()->devices()->rowCount(); i++) {
            Device *dev = m_engine->deviceManager()->devices()->get(i);
            m_completionModel->append(CompletionModel::Entry(dev->id().toString(), dev->name(), true, true));

        }
        blockText.remove(QRegExp(".*deviceId: \""));
        m_proxyModel->setFilter(blockText);
        return;
    }

    QRegExp importExp("imp(o|or)?");
    if (importExp.exactMatch(blockText)) {
        m_completionModel->append(CompletionModel::Entry("import ", "import"));
        m_proxyModel->setFilter(blockText);
        return;
    }

    QRegExp importExp2("import [a-zA-Z]*");
    if (importExp2.exactMatch(blockText)) {
        m_completionModel->append(CompletionModel::Entry("QtQuick 2.0"));
        m_completionModel->append(CompletionModel::Entry("nymea 1.0"));
        blockText.remove("import ");
        m_proxyModel->setFilter(blockText);
        return;
    }

    QRegExp expressionStartExp(" *[a-zA-Z0-9]*");
    if (expressionStartExp.exactMatch(blockText)) {
        QTextCursor blockStartCursor = m_document->textDocument()->find("{", m_currentCursor, QTextDocument::FindBackward);
        QTextCursor blockEndCursor = m_document->textDocument()->find("}", m_currentCursor, QTextDocument::FindBackward);
        while (!blockEndCursor.isNull() && blockEndCursor.position() > blockStartCursor.position()) {
            blockStartCursor = m_document->textDocument()->find("{", blockStartCursor, QTextDocument::FindBackward);
            blockEndCursor = m_document->textDocument()->find("}", blockEndCursor, QTextDocument::FindBackward);
        }
        QString className = blockStartCursor.block().text();
        className.remove(QRegExp(" *\\{"));
        while (className.contains(" ")) {
            className.remove(QRegExp(".* "));
        }
        qDebug() << "ClassName" << className << m_classes.value(className);
        foreach (const QString &s, m_classes.value(className)) {
            m_completionModel->append(CompletionModel::Entry(s + ": ", s));
        }
        blockText.remove(QRegExp(".* "));
        m_proxyModel->setFilter(blockText);
    }

}

ScriptSyntaxHighlighterPrivate::ScriptSyntaxHighlighterPrivate(QObject *parent):
    QSyntaxHighlighter(parent)
{
    HighlightingRule rule;

    keywordFormat.setForeground(Qt::blue);

    QStringList keywordPatterns;
    keywordPatterns << "\\bif\\b" << "\\belse\\b" << "\\breturn\\b"<< "\\bimport\\b" << "\\bsignal\\b" << "\\bproperty\\b";
    foreach (const QString &pattern, keywordPatterns) {
        rule.pattern = QRegExp(pattern);
        rule.format = keywordFormat;
        highlightingRules.append(rule);
    }

    propertyFormat.setForeground(Qt::darkRed);
    rule.pattern = QRegExp("[A-z]+:");
    rule.format = propertyFormat;
    highlightingRules.append(rule);

    lookupFormat.setForeground(Qt::magenta);
    //lookupFormat.setBackground(Qt::black);
    rule.pattern = QRegExp("\\b[0-9]+\\b");
    rule.format = lookupFormat;
    highlightingRules.append(rule);

    quotationFormat.setForeground(Qt::darkGreen);
    rule.pattern = QRegExp("\".*\"");
    rule.format = quotationFormat;
    highlightingRules.append(rule);
    rule.pattern = QRegExp("'.*'");
    rule.format = quotationFormat;
    highlightingRules.append(rule);

    itemFormat.setForeground(QColor(Qt::red));
    //itemFormat.setFontWeight(QFont::Bold);
    rule.pattern =  QRegExp("[A-Z][a-z]+ ");
    rule.format = itemFormat;
    highlightingRules.append(rule);

    cppObjectFormat.setForeground(QColor(Qt::blue).lighter());
    cppObjectFormat.setFontItalic(true);
    rule.pattern =  QRegExp("_[A-z]+");
    rule.format = cppObjectFormat;
    highlightingRules.append(rule);
}

void ScriptSyntaxHighlighterPrivate::highlightBlock(const QString &text)
{
//    qDebug() << "hightlightBlock called for" << text << previousBlockState() << currentBlock().text();

    foreach(const HighlightingRule &rule, highlightingRules){
        QRegExp expression(rule.pattern);
        int index = expression.indexIn(text);
        while (index >= 0) {
            int length = expression.matchedLength();
            setFormat(index, length, rule.format);
            index = expression.indexIn(text, index + length);
        }
    }
    if (text.trimmed().startsWith("import")) {
        setCurrentBlockState(BlockStateImport);
    } else if (text.trimmed().startsWith("Action")) {
        setCurrentBlockState(BlockStateAction);
    } else if (text.trimmed().startsWith("deviceId:")) {
        setCurrentBlockState(BlockstateDeviceId);
    } else {
        setCurrentBlockState(0);
    }

    emit contentChanged(text);
}

#include "scriptsyntaxhighlighter.moc"
