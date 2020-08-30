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

#ifndef CODECOMPLETION_H
#define CODECOMPLETION_H

#include <QObject>
#include <QQuickTextDocument>
#include <QTextCursor>
#include <QHash>

#include "completionmodel.h"

class Engine;

class CodeCompletion: public QObject
{
    Q_OBJECT
    Q_PROPERTY(Engine* engine READ engine WRITE setEngine NOTIFY engineChanged)
    Q_PROPERTY(QQuickTextDocument *document READ document WRITE setDocument NOTIFY documentChanged)
    Q_PROPERTY(int cursorPosition READ cursorPosition WRITE setCursorPosition NOTIFY cursorPositionChanged)
    Q_PROPERTY(CompletionProxyModel* model READ model CONSTANT)
    Q_PROPERTY(QString currentWord READ currentWord NOTIFY currentWordChanged)

public:
    enum MoveOperation {
        MoveOperationPreviousLine,
        MoveOperationNextLine,
        MoveOperationPreviousWord,
        MoveOperationNextWord,
    };
    Q_ENUM(MoveOperation)

    CodeCompletion(QObject *parent = nullptr);

    Engine* engine() const;
    void setEngine(Engine *engine);

    QQuickTextDocument* document() const;
    void setDocument(QQuickTextDocument *document);

    int cursorPosition() const;
    void setCursorPosition(int position);

    QString currentWord() const;

    CompletionProxyModel* model() const;

public slots:
    void update();

    void complete(int index);
    void newLine();
    void indent(int from, int to);
    void unindent(int from, int to);
    void closeBlock();
    void insertBeforeCursor(const QString &text);
    void insertAfterCursor(const QString &text);

    void moveCursor(MoveOperation moveOperation, int count = 1);

signals:
    void engineChanged();
    void documentChanged();
    void cursorPositionChanged();
    void currentWordChanged();
    void hint();

private:
    class BlockInfo {
    public:
        bool valid = false;
        QString name;
        QHash<QString, QString> properties;
        int start = -1;
        int end = -1;
    };

    class ClassInfo {
    public:
        ClassInfo(const QString &name = QString(), const QStringList &properties = QStringList(), const QStringList &methods = QStringList(), const QStringList &events = QStringList()):
            name(name), properties(properties), methods(methods), events(events) {}
        QString name;
        QStringList properties;
        QStringList methods;
        QStringList events;
    };

    int getBlockPosition(const QString &id) const;
    BlockInfo getBlockInfo(int postition) const;
    QList<CompletionModel::Entry> getIds() const;
    QHash<QString, QString> getIdTypes() const;

    int openingBlocksBefore(int position) const;
    int closingBlocksAfter(int position) const;

private:
    Engine *m_engine = nullptr;
    QQuickTextDocument* m_document = nullptr;
    CompletionModel *m_model = nullptr;
    CompletionProxyModel *m_proxy = nullptr;

    QTextCursor m_cursor;

    QHash<QString, ClassInfo> m_classes;
    QHash<QString, ClassInfo> m_attachedClasses;
    QHash<QString, ClassInfo> m_jsClasses;
    QHash<QString, QString> m_genericSyntax;
    QHash<QString, QString> m_genericJsSyntax;

};

#endif // CODECOMPLETION_H
