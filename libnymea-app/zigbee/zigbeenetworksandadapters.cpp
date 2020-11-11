#include "zigbeenetworksandadapters.h"

#include "zigbeemanager.h"

ZigbeeNetworksAndAdapters::ZigbeeNetworksAndAdapters(ZigbeeManager *manager):
    QAbstractListModel(manager),
    m_manager(manager)
{

}

int ZigbeeNetworksAndAdapters::rowCount(const QModelIndex &/*parent*/) const
{
//    return m_list.count();
    return 0;
}

QVariant ZigbeeNetworksAndAdapters::data(const QModelIndex &index, int role) const
{
    return QVariant();
}
