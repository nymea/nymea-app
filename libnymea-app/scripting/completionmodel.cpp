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

#include "completionmodel.h"

#include <QDebug>

CompletionModel::CompletionModel(QObject *parent): QAbstractListModel(parent)
{

}

int CompletionModel::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent)
    return m_list.count();
}

QHash<int, QByteArray> CompletionModel::roleNames() const
{
    QHash<int, QByteArray> roles;
    roles.insert(Qt::UserRole, "text");
    roles.insert(Qt::DisplayRole, "displayText");
    roles.insert(Qt::DecorationRole, "decoration");
    roles.insert(Qt::DecorationPropertyRole, "decorationProperty");
    return roles;
}

QVariant CompletionModel::data(const QModelIndex &index, int role) const
{
    switch (role) {
    case Qt::UserRole:
        return m_list.at(index.row()).text;
    case Qt::DisplayRole:
        return m_list.at(index.row()).displayText;
    case Qt::DecorationRole:
        return m_list.at(index.row()).decoration;
    case Qt::DecorationPropertyRole:
        return m_list.at(index.row()).decorationProperty;
    }
    return QVariant();
}

void CompletionModel::update(const QList<CompletionModel::Entry> &entries)
{
    beginResetModel();
    m_list = entries;
    endResetModel();
    emit countChanged();
}

CompletionModel::Entry CompletionModel::get(int index)
{
    return m_list.at(index);
}


//************************************************
// CompletionProxyModel
//************************************************

CompletionProxyModel::CompletionProxyModel(CompletionModel *model, QObject *parent):
    QSortFilterProxyModel(parent),
    m_model(model)
{
    setSourceModel(m_model);
    connect(m_model, &CompletionModel::countChanged, this, &CompletionProxyModel::countChanged);
    setSortCaseSensitivity(Qt::CaseInsensitive);
    sort(0);
}

CompletionModel::Entry CompletionProxyModel::get(int index)
{
    return m_model->get(mapToSource(this->index(index, 0)).row());
}

QString CompletionProxyModel::filter() const
{
    return m_filter;
}

void CompletionProxyModel::setFilter(const QString &filter, bool caseSensitive)
{
    if (m_filter != filter || m_filterCaseSensitive != caseSensitive) {
        m_filter = filter;
        m_filterCaseSensitive = caseSensitive;
        emit filterChanged();
        invalidateFilter();
        emit countChanged();
    }
}

bool CompletionProxyModel::filterAcceptsRow(int source_row, const QModelIndex &) const
{
    if (!m_filter.isEmpty()) {
        CompletionModel::Entry entry = m_model->get(source_row);
        if (m_filterCaseSensitive) {
            if (!entry.displayText.startsWith(m_filter) && !entry.text.startsWith(m_filter)) {
                return false;
            }
        } else {
            if (!entry.displayText.toLower().startsWith(m_filter.toLower()) && !entry.text.toLower().startsWith(m_filter.toLower())) {
                return false;
            }
        }
    }
    return true;
}

bool CompletionProxyModel::lessThan(const QModelIndex &source_left, const QModelIndex &source_right) const
{
    CompletionModel::Entry left = m_model->get(source_left.row());
    CompletionModel::Entry right = m_model->get(source_right.row());

    static QStringList ordering = {"property", "method", "event", "type", "attachedProperty", "keyword" };

    int leftOrder = ordering.indexOf(left.decoration);
    int rightOrder = ordering.indexOf(right.decoration);

    if (leftOrder != rightOrder) {
        return leftOrder < rightOrder;
    }

    return left.displayText < right.displayText;
}
