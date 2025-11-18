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

#ifndef SCRIPTSYNTAXHIGHLIGHTER_H
#define SCRIPTSYNTAXHIGHLIGHTER_H

#include <QObject>
#include <QSyntaxHighlighter>
#include <QQuickTextDocument>

class ScriptSyntaxHighlighterPrivate;
class CompletionModel;
class CompletionProxyModel;

class ScriptSyntaxHighlighter : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QQuickTextDocument* document READ document WRITE setDocument NOTIFY documentChanged)
    Q_PROPERTY(QColor backgroundColor READ backgroundColor WRITE setBackgroundColor NOTIFY backgroundColorChanged)
public:

    explicit ScriptSyntaxHighlighter(QObject *parent = nullptr);

    QQuickTextDocument* document() const;
    void setDocument(QQuickTextDocument *document);

    QColor backgroundColor() const;
    void setBackgroundColor(const QColor &backgroundColor);

signals:
    void documentChanged();
    void backgroundColorChanged();

private:
    ScriptSyntaxHighlighterPrivate *m_highlighter = nullptr;
    QQuickTextDocument* m_document = nullptr;
    QColor m_backgroundColor;
};

#endif // SCRIPTSYNTAXHIGHLIGHTER_H
