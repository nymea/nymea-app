// SPDX-License-Identifier: LGPL-3.0-or-later

/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
*
* Copyright (C) 2013 - 2024, nymea GmbH
* Copyright (C) 2024 - 2025, chargebyte austria GmbH
*
* This file is part of libnymea-app.
*
* libnymea-app is free software: you can redistribute it and/or
* modify it under the terms of the GNU Lesser General Public License
* as published by the Free Software Foundation, either version 3
* of the License, or (at your option) any later version.
*
* libnymea-app is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
* GNU Lesser General Public License for more details.
*
* You should have received a copy of the GNU Lesser General Public License
* along with libnymea-app. If not, see <https://www.gnu.org/licenses/>.
*
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

#ifndef CODECOMPLETION_H
#define CODECOMPLETION_H

#include <QObject>
#include <QQuickTextDocument>
#include <QTextCursor>
#include <QHash>

#include "engine.h"
#include "completionmodel.h"

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
        MoveOperationAbsoluteLine,
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
    void toggleComment(int from, int to);

    void moveCursor(MoveOperation moveOperation, int count = 1);

signals:
    void engineChanged();
    void documentChanged();
    void cursorPositionChanged();
    void currentWordChanged();
    void hint();
    void select(int from, int to);

private:
    class BlockInfo {
    public:
        bool valid = false;
        QString name;
        QHash<QString, QString> properties;
        QStringList functions;
        int start = -1;
        int end = -1;
    };

    class ClassInfo {
    public:
        ClassInfo(const QString &name = QString(), const QStringList &properties = QStringList(), const QStringList &readOnlyProperties = QStringList(), const QStringList &methods = QStringList(), const QStringList &events = QStringList()):
            name(name), properties(properties), readOnlyProperties(readOnlyProperties), methods(methods), events(events) {}
        QString name;
        QStringList properties;
        QStringList readOnlyProperties;
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
