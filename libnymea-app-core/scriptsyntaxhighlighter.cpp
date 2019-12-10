#include "scriptsyntaxhighlighter.h"

#include "engine.h"
#include "devicemanager.h"
#include "devices.h"

#include <QDebug>
#include <QMetaObject>
#include <QTextDocumentFragment>
#include <QQuickItem>

class ScriptSyntaxHighlighterPrivate: public QSyntaxHighlighter
{
    Q_OBJECT
public:
    ScriptSyntaxHighlighterPrivate(QObject *parent);

    void update(bool dark);
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
};

ScriptSyntaxHighlighter::ScriptSyntaxHighlighter(QObject *parent) : QObject(parent)
{
    m_highlighter = new ScriptSyntaxHighlighterPrivate(this);
    m_highlighter->update(false);
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
        emit documentChanged();
    }
}

QColor ScriptSyntaxHighlighter::backgroundColor() const
{
    return m_backgroundColor;
}

void ScriptSyntaxHighlighter::setBackgroundColor(const QColor &backgroundColor)
{
    if (m_backgroundColor != backgroundColor) {
        m_backgroundColor = backgroundColor;
        emit backgroundColorChanged();

        double y = 0.2126 * backgroundColor.red() + 0.7152 * backgroundColor.green() + 0.0722 * backgroundColor.blue();
        m_highlighter->update(y < 128);
    }
}



ScriptSyntaxHighlighterPrivate::ScriptSyntaxHighlighterPrivate(QObject *parent):
    QSyntaxHighlighter(parent)
{
}

void ScriptSyntaxHighlighterPrivate::update(bool dark)
{
    HighlightingRule rule;
    QTextCharFormat format;

    // ClassNames
    format.setForeground(dark ? QColor("#55fc49") : QColor("#800080"));
    rule.pattern =  QRegExp("\\b[A-Z][a-zA-Z0-9_]+\\b");
    rule.format = format;
    highlightingRules.append(rule);

    // Property bindings
    format.setForeground(dark ? QColor("#ff5555") : QColor("#800000"));
    rule.pattern = QRegExp("[a-zA-Z][a-zA-Z0-9_.]+:");
    rule.format = format;
    highlightingRules.append(rule);

    // imports
    format.clearForeground();
    rule.pattern = QRegExp("import .*$");
    rule.format = format;
    highlightingRules.append(rule);

    // keywords
    QStringList keywordPatterns {
        "\\bif\\b",
        "\\belse\\b" ,
        "\\breturn\\b",
        "\\bimport\\b",
        "\\bsignal\\b",
        "\\bproperty\\b",
        "\\bfunction\\b",
        "\\breadonly\\b",
        "\\balias\\b",
        "\\bfor\\b",
        "\\bwhile\\b",
        "\\bbreak\\b",
        "\\bswitch\\b",
        "\\bcase\\b",
        "\\bdefault\\b",
        "\\bvar\\b",
        "\\bnull\\b",
        "\\bundefined\\b",
        "\\bstring\\b",
        "\\bbool\\b",
        "\\bint\\b",
        "\\breal\\b",
        "\\bdate\\b",
        "\\btrue\\b",
        "\\bfalse\\b",
    };
    format.setForeground(dark ? Qt::yellow : QColor("#80831a"));
    foreach (const QString &pattern, keywordPatterns) {
        rule.pattern = QRegExp(pattern);
        rule.format = format;
        highlightingRules.append(rule);
    }

    // String literals
    format.setForeground(dark ? QColor("#e64ad7") : Qt::darkGreen);
    rule.format = format;
    rule.pattern = QRegExp("\".[^\"]*\"");
    highlightingRules.append(rule);
    rule.pattern = QRegExp("'.[^']*'");
    highlightingRules.append(rule);

    // comments
    format.setForeground(dark ? Qt::cyan : Qt::darkGray);
    rule.format = format;
    rule.pattern = QRegExp("//.*$");
    highlightingRules.append(rule);
    rule.pattern = QRegExp("/*.*\\*/");
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
            if (text.mid(index, length).endsWith(':')) {
                length--;
            }
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
