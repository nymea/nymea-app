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

#ifndef COMPLETIONMODEL_H
#define COMPLETIONMODEL_H

#include <QAbstractListModel>
#include <QSortFilterProxyModel>

class CompletionModel: public QAbstractListModel
{
    Q_OBJECT
    Q_PROPERTY(int count READ rowCount NOTIFY countChanged)
public:
    class Entry {
    public:
        Entry(const QString &text, const QString &displayText, const QString &decoration, const QString &decorationProperty = QString(), const QString &trailingText = QString())
            : text(text), displayText(displayText), decoration(decoration), decorationProperty(decorationProperty), trailingText(trailingText) {}
        Entry(const QString &text): text(text), displayText(text) {}
        QString text;
        QString displayText;
        QString decoration;
        QString decorationProperty;
        QString trailingText;
        bool operator==(const Entry &other) const {
            return text == other.text && displayText == other.displayText;
        }
    };

    CompletionModel(QObject *parent = nullptr);

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QHash<int, QByteArray> roleNames() const override;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;

    void update(const QList<Entry> &entries);

    Entry get(int index);

signals:
    void countChanged();

private:
    QList<Entry> m_list;
};

class CompletionProxyModel: public QSortFilterProxyModel
{
    Q_OBJECT
    Q_PROPERTY(int count READ rowCount NOTIFY countChanged)
    Q_PROPERTY(QString filter READ filter NOTIFY filterChanged)
public:
    CompletionProxyModel(CompletionModel *model, QObject *parent = nullptr);
    CompletionModel::Entry get(int index);

    QString filter() const;
    void setFilter(const QString &filter, bool caseSensitive = true);

protected:
    bool filterAcceptsRow(int source_row, const QModelIndex &/*source_parent*/) const override;

    bool lessThan(const QModelIndex &source_left, const QModelIndex &source_right) const override;

signals:
    void countChanged();
    void filterChanged();

private:
    CompletionModel *m_model = nullptr;
    QString m_filter;
    bool m_filterCaseSensitive = true;

};

#endif // COMPLETIONMODEL_H
