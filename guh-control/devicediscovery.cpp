#include "devicediscovery.h"

#include "engine.h"

DeviceDiscovery::DeviceDiscovery(QObject *parent) :
    QAbstractListModel(parent)
{

    connect(Engine::instance()->jsonRpcClient(), &JsonRpcClient::responseReceived, this, &DeviceDiscovery::responseReceived);
}

int DeviceDiscovery::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent)
    return m_foundDevices.count();
}

QVariant DeviceDiscovery::data(const QModelIndex &index, int role) const
{
    switch (role) {
    case RoleId:
        return m_foundDevices.at(index.row()).m_id;
    case RoleName:
        return m_foundDevices.at(index.row()).m_name;
    case RoleDescription:
        return m_foundDevices.at(index.row()).m_description;
    }

    return QVariant();
}

QHash<int, QByteArray> DeviceDiscovery::roleNames() const
{
    QHash<int, QByteArray> roles;
    roles.insert(RoleId, "id");
    roles.insert(RoleName, "name");
    roles.insert(RoleDescription, "description");
    return roles;
}

void DeviceDiscovery::discoverDevices(const QUuid &deviceClassId, const QVariantList &params)
{
    int request = Engine::instance()->jsonRpcClient()->discoverDevices(deviceClassId, params);
    m_requests.append(request);
    emit busyChanged();
    emit countChanged();
}

bool DeviceDiscovery::busy() const
{
    return m_requests.count() > 0;
}

void DeviceDiscovery::responseReceived(int id, const QVariantMap &params)
{
    if (!m_requests.contains(id)) {
        return;
    }
    m_requests.removeAll(id);
    emit busyChanged();

    qDebug() << "response received" << params;
    QVariantList descriptors = params.value("deviceDescriptors").toList();
    foreach (const QVariant &descriptor, descriptors) {
        if (!contains(descriptor.toMap().value("id").toUuid())) {
            beginInsertRows(QModelIndex(), m_foundDevices.count(), m_foundDevices.count());
            m_foundDevices.append(DeviceDescriptor(descriptor.toMap().value("id").toUuid(),
                                                   descriptor.toMap().value("title").toString(),
                                                   descriptor.toMap().value("description").toString()));
            endInsertRows();
            emit countChanged();
        }
    }
}

bool DeviceDiscovery::contains(const QUuid &deviceDescriptorId) const
{
    foreach (const DeviceDescriptor &descriptor, m_foundDevices) {
        if (descriptor.m_id == deviceDescriptorId) {
            return true;
        }
    }
    return false;
}
