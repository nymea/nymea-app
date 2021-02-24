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

#include "scriptsyntaxhighlighter.h"

#include "engine.h"
#include "thingmanager.h"
#include "things.h"

#include <QDebug>
#include <QMetaObject>
#include <QTextDocumentFragment>
#include <QQuickItem>
#include <QRegularExpression>

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
        BlockstateThingId,
    };
    struct HighlightingRule
    {
        QRegularExpression pattern;
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
    rule.pattern =  QRegularExpression("\\b[A-Z][a-zA-Z0-9_]+\\b");
    rule.format = format;
    highlightingRules.append(rule);

    // Property bindings
    format.setForeground(dark ? QColor("#ff5555") : QColor("#800000"));
    rule.pattern = QRegularExpression("[a-zA-Z][a-zA-Z0-9_.]+:");
    rule.format = format;
    highlightingRules.append(rule);

    // imports
    format.clearForeground();
    rule.pattern = QRegularExpression("import .*$");
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
        "\\bdouble\\b",
        "\\bdate\\b",
        "\\btrue\\b",
        "\\bfalse\\b",
    };
    format.setForeground(dark ? Qt::yellow : QColor("#80831a"));
    foreach (const QString &pattern, keywordPatterns) {
        rule.pattern = QRegularExpression(pattern);
        rule.format = format;
        highlightingRules.append(rule);
    }

    // String literals
    format.setForeground(dark ? QColor("#e64ad7") : Qt::darkGreen);
    rule.format = format;
    rule.pattern = QRegularExpression(R"**((?<!\\)([\"'])(.*?)(?<!\\)\1)**", QRegularExpression::DotMatchesEverythingOption | QRegularExpression::MultilineOption);
    highlightingRules.append(rule);

    // comments
    format.setForeground(dark ? Qt::cyan : Qt::darkGray);
    rule.format = format;
    rule.pattern = QRegularExpression("//.*$");
    highlightingRules.append(rule);
    rule.pattern = QRegularExpression("/*.*\\*/");
    highlightingRules.append(rule);
}

void ScriptSyntaxHighlighterPrivate::highlightBlock(const QString &text)
{
//    qDebug() << "hightlightBlock called for" << text << previousBlockState() << currentBlock().text();

    foreach(const HighlightingRule &rule, highlightingRules){
        QRegularExpression expression(rule.pattern);
        QRegularExpressionMatchIterator matches = expression.globalMatch(text);
        while (matches.hasNext()) {
            QRegularExpressionMatch match = matches.next();
            setFormat(match.capturedStart(), match.capturedLength(), rule.format);
        }
    }
    if (text.trimmed().startsWith("import")) {
        setCurrentBlockState(BlockStateImport);
    } else if (text.trimmed().startsWith("Action")) {
        setCurrentBlockState(BlockStateAction);
    } else if (text.trimmed().startsWith("thingId:")) {
        setCurrentBlockState(BlockstateThingId);
    } else {
        setCurrentBlockState(0);
    }

    emit contentChanged(text);
}


#include "scriptsyntaxhighlighter.moc"
