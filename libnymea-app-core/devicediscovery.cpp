#include "devicediscovery.h"

#include "engine.h"

DeviceDiscovery::DeviceDiscovery(QObject *parent) :
    QAbstractListModel(parent)
{
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
        return m_foundDevices.at(index.row())->id();
    case RoleName:
        return m_foundDevices.at(index.row())->name();
    case RoleDescription:
        return m_foundDevices.at(index.row())->description();
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

void DeviceDiscovery::discoverDevices(const QUuid &deviceClassId, const QVariantList &discoveryParams)
{
    if (m_busy) {
        qWarning() << "Busy... not restarting discovery";
        return;
    }
    beginResetModel();
    m_foundDevices.clear();
    endResetModel();
    emit countChanged();

    if (!m_engine) {
        qWarning() << "Cannot discover devices. No Engine set";
        return;
    }
    if (!m_engine->jsonRpcClient()->connected()) {
        qWarning() << "Cannot discover devices. Not connected.";
        return;
    }

    QVariantMap params;
    params.insert("deviceClassId", deviceClassId.toString());
    if (!discoveryParams.isEmpty()) {
        params.insert("discoveryParams", discoveryParams);
    }
    m_engine->jsonRpcClient()->sendCommand("Devices.GetDiscoveredDevices", params, this, "discoverDevicesResponse");
    m_busy = true;
    emit busyChanged();
}

DeviceDescriptor *DeviceDiscovery::get(int index) const
{
    if (index < 0 || index >= m_foundDevices.count()) {
        return nullptr;
    }
    return m_foundDevices.at(index);
}

Engine *DeviceDiscovery::engine() const
{
    return m_engine;
}

void DeviceDiscovery::setEngine(Engine *engine)
{
    if (m_engine != engine) {
        m_engine = engine;
        emit engineChanged();
    }
}

bool DeviceDiscovery::busy() const
{
    return m_busy;
}

void DeviceDiscovery::discoverDevicesResponse(const QVariantMap &params)
{
    m_busy = false;
    emit busyChanged();

//    qDebug() << "response received" << params;
    QVariantList descriptors = params.value("params").toMap().value("deviceDescriptors").toList();
    foreach (const QVariant &descriptorVariant, descriptors) {
        qDebug() << "Found device. Descriptor:" << descriptorVariant;
        if (!contains(descriptorVariant.toMap().value("id").toUuid())) {
            beginInsertRows(QModelIndex(), m_foundDevices.count(), m_foundDevices.count());
            DeviceDescriptor *descriptor = new DeviceDescriptor(descriptorVariant.toMap().value("id").toUuid(),
                                                   descriptorVariant.toMap().value("title").toString(),
                                                   descriptorVariant.toMap().value("description").toString());
            foreach (const QVariant &paramVariant, descriptorVariant.toMap().value("deviceParams").toList()) {
                qDebug() << "Adding param:" << paramVariant.toMap().value("paramTypeId").toString() << paramVariant.toMap().value("value");
                Param* p = new Param(paramVariant.toMap().value("paramTypeId").toString(), paramVariant.toMap().value("value"));
                descriptor->params()->addParam(p);
            }
            m_foundDevices.append(descriptor);
            endInsertRows();
            emit countChanged();
        }
    }
}

bool DeviceDiscovery::contains(const QUuid &deviceDescriptorId) const
{
    foreach (DeviceDescriptor *descriptor, m_foundDevices) {
        if (descriptor->id() == deviceDescriptorId) {
            return true;
        }
    }
    return false;
}

DeviceDescriptor::DeviceDescriptor(const QUuid &id, const QString &name, const QString &description, QObject *parent):
    QObject(parent),
    m_id(id),
    m_name(name),
    m_description(description),
    m_params(new Params(this))
{

}

QUuid DeviceDescriptor::id() const
{
    return m_id;
}

QString DeviceDescriptor::name() const
{
    return m_name;
}

QString DeviceDescriptor::description() const
{
    return m_description;
}

Params* DeviceDescriptor::params() const
{
    return m_params;
}
