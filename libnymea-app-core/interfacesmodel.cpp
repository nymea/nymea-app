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

#include "interfacesmodel.h"

#include "engine.h"

InterfacesModel::InterfacesModel(QObject *parent):
    QAbstractListModel(parent)
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

DeviceManager *InterfacesModel::deviceManager() const
{
    return m_deviceManager;
}

void InterfacesModel::setDeviceManager(DeviceManager *deviceManager)
{
    if (m_deviceManager != deviceManager) {
        m_deviceManager = deviceManager;
        emit deviceManagerChanged();
        connect(m_deviceManager->devices(), &Devices::countChanged, this, [this]() {
            syncInterfaces();
        });
        connect(m_deviceManager->deviceClasses(), &DeviceClasses::countChanged, this, [this]() {
            syncInterfaces();
        });
        syncInterfaces();
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

bool InterfacesModel::onlyConfiguredDevices() const
{
    return m_onlyConfiguredDevices;
}

void InterfacesModel::setOnlyConfiguredDevices(bool onlyConfigured)
{
    if (m_onlyConfiguredDevices != onlyConfigured) {
        m_onlyConfiguredDevices = onlyConfigured;
        emit onlyConfiguredDevicesChanged();
        syncInterfaces();
    }
}

bool InterfacesModel::showUncategorized() const
{
    return m_showUncategorized;
}

void InterfacesModel::setShowUncategorized(bool showUncategorized)
{
    if (m_showUncategorized != showUncategorized) {
        m_showUncategorized = showUncategorized;
        emit showUncategorizedChanged();
        syncInterfaces();
    }
}

QString InterfacesModel::get(int index) const
{
    if (index < 0 || index > m_interfaces.count()) {
        return QString();
    }
    return m_interfaces.at(index);
}

void InterfacesModel::syncInterfaces()
{
    if (!m_deviceManager) {
        return;
    }
    QList<DeviceClass*> deviceClasses;
    if (m_onlyConfiguredDevices) {
        for (int i = 0; i < m_deviceManager->devices()->rowCount(); i++) {
            deviceClasses << m_deviceManager->deviceClasses()->getDeviceClass(m_deviceManager->devices()->get(i)->deviceClassId());
        }
    } else {
        for (int i = 0; i < m_deviceManager->deviceClasses()->rowCount(); i++) {
            deviceClasses << m_deviceManager->deviceClasses()->get(i);
        }
    }

    QStringList interfacesInSource;
    foreach (DeviceClass *dc, deviceClasses) {
//        qDebug() << "device" <<dc->name() << "has interfaces" << dc->interfaces();

        bool isInShownIfaces = false;
        foreach (const QString &interface, dc->interfaces()) {
            if (!m_shownInterfaces.isEmpty() && !m_shownInterfaces.contains(interface)) {
                continue;
            }

            if (!interfacesInSource.contains(interface)) {
                interfacesInSource.append(interface);
            }
            isInShownIfaces = true;
        }
        if (m_showUncategorized && !isInShownIfaces && !interfacesInSource.contains("uncategorized")) {
            interfacesInSource.append("uncategorized");
        }
    }
    QStringList interfacesToAdd = interfacesInSource;
    QStringList interfacesToRemove;

    foreach (const QString &interface, m_interfaces) {
        if (!interfacesInSource.contains(interface)) {
            interfacesToRemove.append(interface);
        }
        interfacesToAdd.removeAll(interface);
    }
    foreach (const QString &interface, interfacesToRemove) {
        int idx = m_interfaces.indexOf(interface);
        beginRemoveRows(QModelIndex(), idx, idx);
        m_interfaces.takeAt(idx);
        endRemoveRows();
    }
    if (!interfacesToAdd.isEmpty()) {
        beginInsertRows(QModelIndex(), m_interfaces.count(), m_interfaces.count() + interfacesToAdd.count() - 1);
        m_interfaces.append(interfacesToAdd);
        endInsertRows();
    }
    emit countChanged();
}

void InterfacesModel::rowsChanged(const QModelIndex &index, int first, int last)
{
    Q_UNUSED(index)
    Q_UNUSED(first)
    Q_UNUSED(last)

    syncInterfaces();
}

InterfacesSortModel::InterfacesSortModel(QObject *parent):
    QSortFilterProxyModel(parent)
{
}

InterfacesModel *InterfacesSortModel::interfacesModel() const
{
    return m_interfacesModel;
}

void InterfacesSortModel::setInterfacesModel(InterfacesModel *interfacesModel)
{
    if (m_interfacesModel != interfacesModel) {
        m_interfacesModel = interfacesModel;
        setSourceModel(interfacesModel);
        connect(interfacesModel, &InterfacesModel::countChanged, this, &InterfacesSortModel::countChanged);
        setSortRole(Devices::RoleName);
        sort(0);
        emit interfacesModelChanged();
    }
}

bool InterfacesSortModel::lessThan(const QModelIndex &left, const QModelIndex &right) const
{
    QVariant leftName = sourceModel()->data(left, InterfacesModel::RoleName);
    QVariant rightName = sourceModel()->data(right, InterfacesModel::RoleName);

    if (leftName == "uncategorized") {
        return false;
    }
    if (rightName == "uncategorized") {
        return true;
    }
    return m_interfacesModel->shownInterfaces().indexOf(leftName.toString()) < m_interfacesModel->shownInterfaces().indexOf(rightName.toString());
}

QString InterfacesSortModel::get(int index) const
{
    return m_interfacesModel->get(mapToSource(this->index(index, 0)).row());
}
