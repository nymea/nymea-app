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

void CompletionProxyModel::setFilter(const QString &filter)
{
    if (m_filter != filter) {
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

bool CompletionProxyModel::lessThan(const QModelIndex &source_left, const QModelIndex &source_right) const
{
    CompletionModel::Entry left = m_model->get(source_left.row());
    CompletionModel::Entry right = m_model->get(source_right.row());

    static QStringList ordering = {"property", "method", "event", "type", "keyword" };

    int leftOrder = ordering.indexOf(left.decoration);
    int rightOrder = ordering.indexOf(right.decoration);

    if (leftOrder != rightOrder) {
        return leftOrder < rightOrder;
    }

    return left.displayText < right.displayText;
}
