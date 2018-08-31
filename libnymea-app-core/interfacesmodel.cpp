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

void InterfacesModel::syncInterfaces()
{
    if (!m_deviceManager) {
        return;
    }
    QStringList interfacesInSource;
    for (int i = 0; i < m_deviceManager->devices()->rowCount(); i++) {
        DeviceClass *dc = m_deviceManager->deviceClasses()->getDeviceClass(m_deviceManager->devices()->get(i)->deviceClassId());
//        qDebug() << "device" <<dc->name() << "has interfaces" << dc->interfaces();

        bool isInShownIfaces = false;
        foreach (const QString &interface, dc->interfaces()) {
            if (!m_shownInterfaces.contains(interface)) {
                continue;
            }

            if (!interfacesInSource.contains(interface)) {
                interfacesInSource.append(interface);
            }
            isInShownIfaces = true;
        }
        if (!isInShownIfaces && !interfacesInSource.contains("uncategorized")) {
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
