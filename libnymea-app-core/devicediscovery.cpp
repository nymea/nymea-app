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
    case RoleDeviceId:
        return m_foundDevices.at(index.row())->deviceId();
    }

    return QVariant();
}

QHash<int, QByteArray> DeviceDiscovery::roleNames() const
{
    QHash<int, QByteArray> roles;
    roles.insert(RoleId, "id");
    roles.insert(RoleDeviceId, "deviceId");
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
                                                   descriptorVariant.toMap().value("deviceId").toString(),
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

DeviceDescriptor::DeviceDescriptor(const QUuid &id, const QUuid &deviceId, const QString &name, const QString &description, QObject *parent):
    QObject(parent),
    m_id(id),
    m_deviceId(deviceId),
    m_name(name),
    m_description(description),
    m_params(new Params(this))
{

}

QUuid DeviceDescriptor::id() const
{
    return m_id;
}

QUuid DeviceDescriptor::deviceId() const
{
    return m_deviceId;
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

DeviceDiscoveryProxy::DeviceDiscoveryProxy(QObject *parent):
    QSortFilterProxyModel (parent)
{

}

DeviceDiscovery *DeviceDiscoveryProxy::deviceDiscovery() const
{
    return m_deviceDiscovery;
}

void DeviceDiscoveryProxy::setDeviceDiscovery(DeviceDiscovery *deviceDiscovery)
{
    if (m_deviceDiscovery != deviceDiscovery) {
        m_deviceDiscovery = deviceDiscovery;
        setSourceModel(deviceDiscovery);
        emit deviceDiscoveryChanged();
        emit countChanged();
        connect(m_deviceDiscovery, &DeviceDiscovery::countChanged, this, &DeviceDiscoveryProxy::countChanged);
        invalidateFilter();
    }
}

bool DeviceDiscoveryProxy::showAlreadyAdded() const
{
    return m_showAlreadyAdded;
}

void DeviceDiscoveryProxy::setShowAlreadyAdded(bool showAlreadyAdded)
{
    if (m_showAlreadyAdded != showAlreadyAdded) {
        m_showAlreadyAdded = showAlreadyAdded;
        emit showAlreadyAddedChanged();
        invalidateFilter();
        emit countChanged();
    }
}

bool DeviceDiscoveryProxy::showNew() const
{
    return m_showNew;
}

void DeviceDiscoveryProxy::setShowNew(bool showNew)
{
    if (m_showNew != showNew) {
        m_showNew = showNew;
        emit showNewChanged();
        invalidateFilter();
        emit countChanged();
    }
}

QUuid DeviceDiscoveryProxy::filterDeviceId() const
{
    return m_filterDeviceId;
}

void DeviceDiscoveryProxy::setFilterDeviceId(const QUuid &filterDeviceId)
{
    if (m_filterDeviceId != filterDeviceId) {
        m_filterDeviceId = filterDeviceId;
        emit filterDeviceIdChanged();
        invalidateFilter();
        emit countChanged();
    }
}

DeviceDescriptor *DeviceDiscoveryProxy::get(int index) const
{
    return m_deviceDiscovery->get(mapToSource(this->index(index, 0)).row());
}

bool DeviceDiscoveryProxy::filterAcceptsRow(int sourceRow, const QModelIndex &sourceParent) const
{
    Q_UNUSED(sourceParent)
    DeviceDescriptor* dev = m_deviceDiscovery->get(sourceRow);
    if (!m_showAlreadyAdded && !dev->deviceId().isNull()) {
        return false;
    }
    if (!m_showNew && dev->deviceId().isNull()) {
        return false;
    }
    if (!m_filterDeviceId.isNull() && dev->deviceId() != m_filterDeviceId) {
        return false;
    }
    return true;
}
