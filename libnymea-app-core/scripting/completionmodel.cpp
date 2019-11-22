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
    return roles;
}

QVariant CompletionModel::data(const QModelIndex &index, int role) const
{
    switch (role) {
    case Qt::UserRole:
        return m_list.at(index.row()).text;
    case Qt::DisplayRole:
        return m_list.at(index.row()).displayText;
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

void CompletionProxyModel::setFilter(const QString &filter)
{
    if (m_filter != filter) {
        qDebug() << "Setting filter" << filter;
        m_filter = filter;
        emit filterChanged();
        invalidateFilter();
        emit countChanged();
    }
}

bool CompletionProxyModel::filterAcceptsRow(int source_row, const QModelIndex &) const
{
    if (!m_filter.isEmpty()) {
        CompletionModel::Entry entry = m_model->get(source_row);
        if (!entry.displayText.startsWith(m_filter) && !entry.text.startsWith(m_filter)) {
            return false;
        }
    }
    return true;
}
