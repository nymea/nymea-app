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
