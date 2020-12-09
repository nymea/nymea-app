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

#include "devicesproxy.h"
#include "engine.h"
#include "tagsmanager.h"
#include "types/tag.h"

DevicesProxy::DevicesProxy(QObject *parent) :
    QSortFilterProxyModel(parent)
{
}

Engine *DevicesProxy::engine() const
{
    return m_engine;
}

void DevicesProxy::setEngine(Engine *engine)
{
    if (m_engine != engine) {
        m_engine = engine;
        connect(m_engine->tagsManager()->tags(), &Tags::countChanged, this, &DevicesProxy::invalidateFilter);
        emit engineChanged();

        if (!sourceModel()) {
            setSourceModel(m_engine->deviceManager()->devices());

            setSortRole(Devices::RoleName);
            sort(0);
            connect(sourceModel(), SIGNAL(countChanged()), this, SIGNAL(countChanged()));
            connect(sourceModel(), &QAbstractItemModel::dataChanged, this, [this]() {
                invalidateFilter();
                emit countChanged();
            });

        }
    }
}

DevicesProxy *DevicesProxy::parentProxy() const
{
    return m_parentProxy;
}

void DevicesProxy::setParentProxy(DevicesProxy *parentProxy)
{
    if (m_parentProxy != parentProxy) {
        m_parentProxy = parentProxy;
        setSourceModel(parentProxy);

        if (!m_engine) {
            return;
        }
        setSortRole(Devices::RoleName);
        sort(0);
        connect(m_parentProxy, SIGNAL(countChanged()), this, SIGNAL(countChanged()));
        connect(m_parentProxy, &QAbstractItemModel::dataChanged, this, [this]() {
            if (m_engine) {
                invalidateFilter();
                emit countChanged();
            }
        });

        if (m_engine) {
            invalidateFilter();
        }

        emit parentProxyChanged();
        emit countChanged();
    }
}

QString DevicesProxy::filterTagId() const
{
    return m_filterTagId;
}

void DevicesProxy::setFilterTagId(const QString &filterTag)
{
    if (m_filterTagId != filterTag) {
        m_filterTagId = filterTag;
        emit filterTagIdChanged();
        invalidateFilter();
        emit countChanged();
    }
}

QString DevicesProxy::filterTagValue() const
{
    return m_filterTagValue;
}

void DevicesProxy::setFilterTagValue(const QString &tagValue)
{
    if (m_filterTagValue != tagValue) {
        m_filterTagValue = tagValue;
        emit filterTagValueChanged();
        invalidateFilter();
        emit countChanged();
    }
}

QString DevicesProxy::filterDeviceClassId() const
{
    return m_filterDeviceClassId;
}

void DevicesProxy::setFilterDeviceClassId(const QString &filterDeviceClassId)
{
    if (m_filterDeviceClassId != filterDeviceClassId) {
        m_filterDeviceClassId = filterDeviceClassId;
        emit filterDeviceClassIdChanged();
        invalidateFilter();
        emit countChanged();
    }
}

QString DevicesProxy::filterDeviceId() const
{
    return m_filterDeviceId;
}

void DevicesProxy::setFilterDeviceId(const QString &filterDeviceId)
{
    if (m_filterDeviceId != filterDeviceId) {
        m_filterDeviceId = filterDeviceId;
        emit filterDeviceIdChanged();
        invalidateFilter();
        emit countChanged();
    }
}

QStringList DevicesProxy::shownInterfaces() const
{
    return m_shownInterfaces;
}

void DevicesProxy::setShownInterfaces(const QStringList &shownInterfaces)
{
    if (m_shownInterfaces != shownInterfaces) {
        m_shownInterfaces = shownInterfaces;
        emit shownInterfacesChanged();
        invalidateFilter();
        emit countChanged();
    }
}

QStringList DevicesProxy::hiddenInterfaces() const
{
    return m_hiddenInterfaces;
}

void DevicesProxy::setHiddenInterfaces(const QStringList &hiddenInterfaces)
{
    if (m_hiddenInterfaces != hiddenInterfaces) {
        m_hiddenInterfaces = hiddenInterfaces;
        emit hiddenInterfacesChanged();
        invalidateFilter();
        emit countChanged();
    }
}

QString DevicesProxy::nameFilter() const
{
    return m_nameFilter;
}

void DevicesProxy::setNameFilter(const QString &nameFilter)
{
    if (m_nameFilter != nameFilter) {
        m_nameFilter = nameFilter;
        emit nameFilterChanged();
        invalidateFilter();
        emit countChanged();
    }
}

QString DevicesProxy::requiredEventName() const
{
    return m_requiredEventName;
}

void DevicesProxy::setRequiredEventName(const QString &requiredEventName)
{
    if (m_requiredEventName != requiredEventName) {
        m_requiredEventName = requiredEventName;
        emit requiredEventNameChanged();
        invalidateFilter();
        emit countChanged();
    }
}

QString DevicesProxy::requiredStateName() const
{
    return m_requiredStateName;
}

void DevicesProxy::setRequiredStateName(const QString &requiredStateName)
{
    if (m_requiredStateName != requiredStateName) {
        m_requiredStateName = requiredStateName;
        emit requiredStateNameChanged();
        invalidateFilter();
        emit countChanged();
    }
}

QString DevicesProxy::requiredActionName() const
{
    return m_requiredActionName;
}

void DevicesProxy::setRequiredActionName(const QString &requiredActionName)
{
    if (m_requiredActionName != requiredActionName) {
        m_requiredActionName = requiredActionName;
        emit requiredActionNameChanged();
        invalidateFilter();
        emit countChanged();
    }
}

bool DevicesProxy::showDigitalInputs() const
{
    return m_showDigitalInputs;
}

void DevicesProxy::setShowDigitalInputs(bool showDigitalInputs)
{
    if (m_showDigitalInputs != showDigitalInputs) {
        m_showDigitalInputs = showDigitalInputs;
        emit showDigitalInputsChanged();
        invalidateFilter();
        emit countChanged();
    }
}

bool DevicesProxy::showDigitalOutputs() const
{
    return m_showDigitalOutputs;
}

void DevicesProxy::setShowDigitalOutputs(bool showDigitalOutputs)
{
    if (m_showDigitalOutputs != showDigitalOutputs) {
        m_showDigitalOutputs = showDigitalOutputs;
        emit showDigitalOutputsChanged();
        invalidateFilter();
        emit countChanged();
    }
}

bool DevicesProxy::showAnalogInputs() const
{
    return m_showAnalogInputs;
}

void DevicesProxy::setShowAnalogInputs(bool showAnalogInputs)
{
    if (m_showAnalogInputs != showAnalogInputs) {
        m_showAnalogInputs = showAnalogInputs;
        emit showAnalogInputsChanged();
        invalidateFilter();
        emit countChanged();
    }
}

bool DevicesProxy::showAnalogOutputs() const
{
    return m_showDigitalOutputs;
}

void DevicesProxy::setShowAnalogOutputs(bool showAnalogOutputs)
{
    if (m_showAnalogOutputs != showAnalogOutputs) {
        m_showAnalogOutputs = showAnalogOutputs;
        emit showAnalogOutputsChanged();
        invalidateFilter();
        emit countChanged();
    }
}

bool DevicesProxy::filterBatteryCritical() const
{
    return m_filterBatteryCritical;
}

void DevicesProxy::setFilterBatteryCritical(bool filterBatteryCritical)
{
    if (m_filterBatteryCritical != filterBatteryCritical) {
        m_filterBatteryCritical = filterBatteryCritical;
        emit filterBatteryCriticalChanged();
        invalidateFilter();
        emit countChanged();
    }
}

bool DevicesProxy::filterDisconnected() const
{
    return m_filterDisconnected;
}

void DevicesProxy::setFilterDisconnected(bool filterDisconnected)
{
    if (m_filterDisconnected != filterDisconnected) {
        m_filterDisconnected = filterDisconnected;
        emit filterDisconnectedChanged();
        invalidateFilter();
        emit countChanged();
    }
}

bool DevicesProxy::filterSetupFailed() const
{
    return m_filterSetupFailed;
}

void DevicesProxy::setFilterSetupFailed(bool filterSetupFailed)
{
    if (m_filterSetupFailed != filterSetupFailed) {
        m_filterSetupFailed = filterSetupFailed;
        emit filterSetupFailedChanged();
        invalidateFilter();
        emit countChanged();
    }
}

bool DevicesProxy::filterUpdates() const
{
    return m_filterUpdates;
}

void DevicesProxy::setFilterUpdates(bool filterUpdates)
{
    if (m_filterUpdates != filterUpdates) {
        m_filterUpdates = filterUpdates;
        emit filterUpdatesChanged();
        invalidateFilter();
        emit countChanged();
    }
}

bool DevicesProxy::groupByInterface() const
{
    return m_groupByInterface;
}

void DevicesProxy::setGroupByInterface(bool groupByInterface)
{
    if (m_groupByInterface != groupByInterface) {
        m_groupByInterface = groupByInterface;
        emit groupByInterfaceChanged();
        invalidate();
        emit countChanged();
    }
}

Device *DevicesProxy::get(int index) const
{
    return getInternal(mapToSource(this->index(index, 0)).row());
}

Device *DevicesProxy::getDevice(const QUuid &deviceId) const
{
    return getThing(deviceId);
}

Device *DevicesProxy::getThing(const QUuid &thingId) const
{
    Devices *d = qobject_cast<Devices*>(sourceModel());
    if (d) {
        return d->getThing(thingId);
    }
    DevicesProxy *dp = qobject_cast<DevicesProxy*>(sourceModel());
    if (dp) {
        return dp->getThing(thingId);
    }
    return nullptr;
}

Device *DevicesProxy::getInternal(int source_index) const
{
    Devices* d = qobject_cast<Devices*>(sourceModel());
    if (d) {
        return d->get(source_index);
    }
    DevicesProxy *dp = qobject_cast<DevicesProxy*>(sourceModel());
    if (dp) {
        return dp->get(source_index);
    }
    return nullptr;
}

bool DevicesProxy::lessThan(const QModelIndex &left, const QModelIndex &right) const
{
    if (m_groupByInterface) {
        QString leftBaseInterface = sourceModel()->data(left, Devices::RoleBaseInterface).toString();
        QString rightBaseInterface = sourceModel()->data(right, Devices::RoleBaseInterface).toString();
        if (leftBaseInterface != rightBaseInterface) {
            return QString::localeAwareCompare(leftBaseInterface, rightBaseInterface) < 0;
        }
    }
    QString leftName = sourceModel()->data(left, Devices::RoleName).toString();
    QString rightName = sourceModel()->data(right, Devices::RoleName).toString();

    int comparison = QString::localeAwareCompare(leftName, rightName);
    if (comparison == 0) {
        // If there are 2 identically named things we don't want undefined behavor as it may cause items
        // to reorder randomly. Use something static like thingId as fallback
        QString leftThingId = sourceModel()->data(left, Devices::RoleId).toString();
        QString rightThingId = sourceModel()->data(right, Devices::RoleId).toString();
        comparison = QString::localeAwareCompare(leftThingId, rightThingId);
    }
    return comparison < 0;
}

bool DevicesProxy::filterAcceptsRow(int source_row, const QModelIndex &source_parent) const
{
    Device *device = getInternal(source_row);
    if (!m_filterTagId.isEmpty()) {
        Tag *tag = m_engine->tagsManager()->tags()->findDeviceTag(device->id().toString(), m_filterTagId);
        if (!tag) {
            return false;
        }
        if (!m_filterTagValue.isEmpty() && tag->value() != m_filterTagValue) {
            return false;
        }
    }
    if (!m_filterDeviceClassId.isEmpty()) {
        if (device->deviceClassId() != QUuid(m_filterDeviceClassId)) {
            return false;
        }
    }
    if (!m_filterDeviceId.isEmpty()) {
        if (device->id() != QUuid(m_filterDeviceId)) {
            return false;
        }
    }
    DeviceClass *deviceClass = m_engine->deviceManager()->deviceClasses()->getDeviceClass(device->deviceClassId());
//    qDebug() << "Checking device" << deviceClass->name() << deviceClass->interfaces();
    if (!m_shownInterfaces.isEmpty()) {
        bool foundMatch = false;
        foreach (const QString &filterInterface, m_shownInterfaces) {
            if (deviceClass->interfaces().contains(filterInterface)) {
                foundMatch = true;
                continue;
            }
        }
        if (!foundMatch) {
            return false;
        }
    }

    if (!m_hiddenInterfaces.isEmpty()) {
        foreach (const QString &filterInterface, m_hiddenInterfaces) {
            if (deviceClass->interfaces().contains(filterInterface)) {
                return false;
            }
        }
    }

    if (m_showDigitalInputs || m_showDigitalOutputs || m_showAnalogInputs || m_showAnalogOutputs) {
        if (m_showDigitalInputs && deviceClass->stateTypes()->ioStateTypes(Types::IOTypeDigitalInput).isEmpty()) {
            return false;
        }
        if (m_showDigitalOutputs && deviceClass->stateTypes()->ioStateTypes(Types::IOTypeDigitalOutput).isEmpty()) {
            return false;
        }
        if (m_showAnalogInputs && deviceClass->stateTypes()->ioStateTypes(Types::IOTypeAnalogInput).isEmpty()) {
            return false;
        }
        if (m_showAnalogOutputs && deviceClass->stateTypes()->ioStateTypes(Types::IOTypeAnalogOutput).isEmpty()) {
            return false;
        }
    }

    if (m_filterBatteryCritical) {
        if (!deviceClass->interfaces().contains("battery") || device->stateValue(deviceClass->stateTypes()->findByName("batteryCritical")->id()).toBool() == false) {
            return false;
        }
    }

    if (m_filterDisconnected) {
        if (!deviceClass->interfaces().contains("connectable") || device->stateValue(deviceClass->stateTypes()->findByName("connected")->id()).toBool() == true) {
            return false;
        }
    }

    if (m_filterSetupFailed) {
        if (device->setupStatus() != Device::ThingSetupStatusFailed) {
            return false;
        }
    }

    if (m_filterUpdates) {
        if (!deviceClass->interfaces().contains("update")) {
            return false;
        }
        if (device->stateValue(deviceClass->stateTypes()->findByName("updateStatus")->id()).toString() == "idle") {
            return false;
        }
    }

    if (!m_nameFilter.isEmpty()) {
        if (!device->name().toLower().contains(m_nameFilter.toLower().trimmed())) {
            return false;
        }
    }

    if (!m_requiredEventName.isEmpty()) {
        if (!device->thingClass()->eventTypes()->findByName(m_requiredEventName)) {
            return false;
        }
    }
    if (!m_requiredStateName.isEmpty()) {
        if (!device->thingClass()->stateTypes()->findByName(m_requiredStateName)) {
            return false;
        }
    }
    if (!m_requiredActionName.isEmpty()) {
        if (!device->thingClass()->actionTypes()->findByName(m_requiredActionName)) {
            return false;
        }
    }

    return QSortFilterProxyModel::filterAcceptsRow(source_row, source_parent);
}
