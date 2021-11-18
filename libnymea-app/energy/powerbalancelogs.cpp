#include "powerbalancelogs.h"

PowerBalanceLogEntry::PowerBalanceLogEntry(const QDateTime &timestamp, double consumption, double production, double acquisition, double storage, QObject *parent):
    QObject(parent),
    m_timestamp(timestamp),
    m_consumption(consumption),
    m_production(production),
    m_acquisition(acquisition),
    m_storage(storage)
{

}

QDateTime PowerBalanceLogEntry::timestamp() const
{
    return m_timestamp;
}

double PowerBalanceLogEntry::consumption() const
{
    return m_consumption;
}

double PowerBalanceLogEntry::production() const
{
    return m_production;
}

double PowerBalanceLogEntry::acquisition() const
{
    return m_acquisition;
}

double PowerBalanceLogEntry::storage() const
{
    return m_storage;
}


PowerBalanceLogs::PowerBalanceLogs(QObject *parent) : QAbstractListModel(parent)
{

}

int PowerBalanceLogs::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent)
    return m_list.count();
}

QVariant PowerBalanceLogs::data(const QModelIndex &index, int role) const
{
    return QVariant();
}

QHash<int, QByteArray> PowerBalanceLogs::roleNames() const
{
    QHash<int, QByteArray> roles;
    return roles;
}

double PowerBalanceLogs::minValue() const
{
    return m_minValue;
}

double PowerBalanceLogs::maxValue() const
{
    return m_maxValue;
}

void PowerBalanceLogs::addEntry(PowerBalanceLogEntry *entry)
{
    entry->setParent(this);
    beginInsertRows(QModelIndex(), m_list.count(), m_list.count());
    m_list.append(entry);
    endInsertRows();
    emit entryAdded(entry);
    emit countChanged();

    if (entry->consumption() < m_minValue) {
        m_minValue = entry->consumption();
        emit minValueChanged();
    }
    if (entry->consumption() > m_maxValue) {
        m_maxValue = entry->consumption();
        emit maxValueChanged();
    }

    if (entry->production() < m_minValue) {
        m_minValue = entry->production();
        emit minValueChanged();
    }
    if (entry->production() > m_maxValue) {
        m_maxValue = entry->production();
        emit maxValueChanged();
    }
    if (entry->acquisition() < m_minValue) {
        m_minValue = entry->acquisition();
        emit minValueChanged();
    }
    if (entry->acquisition() > m_maxValue) {
        m_maxValue = entry->acquisition();
        emit maxValueChanged();
    }
    if (entry->storage() < m_minValue) {
        m_minValue = entry->storage();
        emit minValueChanged();
    }
    if (entry->storage() > m_maxValue) {
        m_maxValue = entry->storage();
        emit maxValueChanged();
    }

}

PowerBalanceLogs *PowerBalanceLogsProxy::powerBalanceLogs() const
{
    return m_powerBalanceLogs;
}

void PowerBalanceLogsProxy::setPowerBalanceLogs(PowerBalanceLogs *powerBalanceLogs)
{
    if (m_powerBalanceLogs != powerBalanceLogs) {
        m_powerBalanceLogs = powerBalanceLogs;
        setSourceModel(powerBalanceLogs);
        emit powerBalanceLogsChanged();
    }
}
