#include "interfacesmodel.h"

#include "engine.h"


InterfacesModel::InterfacesModel(QObject *parent) : QAbstractListModel(parent)
{
}

int InterfacesModel::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent)
    return m_interfaces.count();
}

QVariant InterfacesModel::data(const QModelIndex &index, int role) const
{
    switch (role) {
    case RoleName:
        return m_interfaces.at(index.row());
    }
    return QVariant();
}

QHash<int, QByteArray> InterfacesModel::roleNames() const
{
    QHash<int, QByteArray> roles;
    roles.insert(RoleName, "name");
    return roles;
}

Devices *InterfacesModel::devices() const
{
    return m_devices;
}

void InterfacesModel::setDevices(Devices *devices)
{
    if (m_devices != devices) {
        m_devices = devices;
        emit devicesChanged();
        syncInterfaces();

        connect(devices, &Devices::rowsInserted, this, &InterfacesModel::rowsChanged);
        connect(devices, &Devices::rowsRemoved, this, &InterfacesModel::rowsChanged);
    }
}

QStringList InterfacesModel::shownInterfaces() const
{
    return m_shownInterfaces;
}

void InterfacesModel::setShownInterfaces(const QStringList &shownInterfaces)
{
    if (m_shownInterfaces != shownInterfaces) {
        m_shownInterfaces = shownInterfaces;
        emit shownInterfacesChanged();

        syncInterfaces();
    }
}

void InterfacesModel::syncInterfaces()
{
    if (!m_devices) {
        return;
    }

    QStringList interfacesInSource;
    for (int i = 0; i < m_devices->count(); i++) {
        DeviceClass *dc = Engine::instance()->deviceManager()->deviceClasses()->getDeviceClass(m_devices->get(i)->deviceClassId());
//        qDebug() << "device" <<dc->name() << "has interfaces" << dc->interfaces();

        foreach (const QString &interface, dc->interfaces()) {
            if (!m_shownInterfaces.contains(interface)) {
                continue;
            }

            if (!interfacesInSource.contains(interface)) {
                interfacesInSource.append(interface);
            }
        }
    }
    QStringList interfacesToAdd = interfacesInSource;

    for (QStringList::iterator i = m_interfaces.begin(); i != m_interfaces.end();) {
        if (!interfacesInSource.contains(*i)) {
            int idx = m_interfaces.indexOf(*i);
            beginRemoveRows(QModelIndex(), idx, idx);
            m_interfaces.takeAt(idx);
            endRemoveRows();
            continue;
        }
        interfacesToAdd.removeAll(*i);
        ++i;
    }
    if (!interfacesToAdd.isEmpty()) {
        beginInsertRows(QModelIndex(), m_interfaces.count(), m_interfaces.count() + interfacesToAdd.count() - 1);
        m_interfaces.append(interfacesToAdd);
        endInsertRows();
    }
}

void InterfacesModel::rowsChanged(const QModelIndex &index, int first, int last)
{
    Q_UNUSED(index)
    Q_UNUSED(first)
    Q_UNUSED(last)

    syncInterfaces();
}
