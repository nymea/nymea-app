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

#include "thingsproxy.h"
#include "engine.h"
#include "tagsmanager.h"
#include "types/tag.h"

ThingsProxy::ThingsProxy(QObject *parent) :
    QSortFilterProxyModel(parent)
{
}

Engine *ThingsProxy::engine() const
{
    return m_engine;
}

void ThingsProxy::setEngine(Engine *engine)
{
    if (m_engine != engine) {
        if (m_engine) {
            disconnect(m_engine->tagsManager()->tags(), &Tags::countChanged, this, &ThingsProxy::invalidateFilter);
        }
        m_engine = engine;
        emit engineChanged();
        if (!m_engine) {
            return;
        }

        connect(m_engine->tagsManager()->tags(), &Tags::countChanged, this, &ThingsProxy::invalidateFilter);

        if (!sourceModel()) {
            setSourceModel(m_engine->thingManager()->things());

            setSortRole(Things::RoleName);
            sort(0);
            connect(sourceModel(), SIGNAL(countChanged()), this, SIGNAL(countChanged()));
            connect(sourceModel(), &QAbstractItemModel::dataChanged, this, [this]() {
                invalidateFilter();
                emit countChanged();
            });

        }
    }
}

ThingsProxy *ThingsProxy::parentProxy() const
{
    return m_parentProxy;
}

void ThingsProxy::setParentProxy(ThingsProxy *parentProxy)
{
    if (m_parentProxy != parentProxy) {
        m_parentProxy = parentProxy;
        setSourceModel(parentProxy);

        if (!m_engine) {
            return;
        }
        setSortRole(Things::RoleName);
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

QString ThingsProxy::filterTagId() const
{
    return m_filterTagId;
}

void ThingsProxy::setFilterTagId(const QString &filterTag)
{
    if (m_filterTagId != filterTag) {
        m_filterTagId = filterTag;
        emit filterTagIdChanged();
        invalidateFilter();
        emit countChanged();
    }
}

QString ThingsProxy::filterTagValue() const
{
    return m_filterTagValue;
}

void ThingsProxy::setFilterTagValue(const QString &tagValue)
{
    if (m_filterTagValue != tagValue) {
        m_filterTagValue = tagValue;
        emit filterTagValueChanged();
        invalidateFilter();
        emit countChanged();
    }
}

QString ThingsProxy::filterThingClassId() const
{
    return m_filterThingClassId;
}

void ThingsProxy::setFilterThingClassId(const QString &filterThingClassId)
{
    if (m_filterThingClassId != filterThingClassId) {
        m_filterThingClassId = filterThingClassId;
        emit filterThingClassIdChanged();
        invalidateFilter();
        emit countChanged();
    }
}

QString ThingsProxy::filterThingId() const
{
    return m_filterThingId;
}

void ThingsProxy::setFilterThingId(const QString &filterThingId)
{
    if (m_filterThingId != filterThingId) {
        m_filterThingId = filterThingId;
        emit filterThingIdChanged();
        invalidateFilter();
        emit countChanged();
    }
}

QStringList ThingsProxy::shownInterfaces() const
{
    return m_shownInterfaces;
}

void ThingsProxy::setShownInterfaces(const QStringList &shownInterfaces)
{
    if (m_shownInterfaces != shownInterfaces) {
        m_shownInterfaces = shownInterfaces;
        emit shownInterfacesChanged();
        invalidateFilter();
        emit countChanged();
    }
}

QStringList ThingsProxy::hiddenInterfaces() const
{
    return m_hiddenInterfaces;
}

void ThingsProxy::setHiddenInterfaces(const QStringList &hiddenInterfaces)
{
    if (m_hiddenInterfaces != hiddenInterfaces) {
        m_hiddenInterfaces = hiddenInterfaces;
        emit hiddenInterfacesChanged();
        invalidateFilter();
        emit countChanged();
    }
}

QString ThingsProxy::nameFilter() const
{
    return m_nameFilter;
}

void ThingsProxy::setNameFilter(const QString &nameFilter)
{
    if (m_nameFilter != nameFilter) {
        m_nameFilter = nameFilter;
        emit nameFilterChanged();
        invalidateFilter();
        emit countChanged();
    }
}

QString ThingsProxy::requiredEventName() const
{
    return m_requiredEventName;
}

void ThingsProxy::setRequiredEventName(const QString &requiredEventName)
{
    if (m_requiredEventName != requiredEventName) {
        m_requiredEventName = requiredEventName;
        emit requiredEventNameChanged();
        invalidateFilter();
        emit countChanged();
    }
}

QString ThingsProxy::requiredStateName() const
{
    return m_requiredStateName;
}

void ThingsProxy::setRequiredStateName(const QString &requiredStateName)
{
    if (m_requiredStateName != requiredStateName) {
        m_requiredStateName = requiredStateName;
        emit requiredStateNameChanged();
        invalidateFilter();
        emit countChanged();
    }
}

QString ThingsProxy::requiredActionName() const
{
    return m_requiredActionName;
}

void ThingsProxy::setRequiredActionName(const QString &requiredActionName)
{
    if (m_requiredActionName != requiredActionName) {
        m_requiredActionName = requiredActionName;
        emit requiredActionNameChanged();
        invalidateFilter();
        emit countChanged();
    }
}

bool ThingsProxy::showDigitalInputs() const
{
    return m_showDigitalInputs;
}

void ThingsProxy::setShowDigitalInputs(bool showDigitalInputs)
{
    if (m_showDigitalInputs != showDigitalInputs) {
        m_showDigitalInputs = showDigitalInputs;
        emit showDigitalInputsChanged();
        invalidateFilter();
        emit countChanged();
    }
}

bool ThingsProxy::showDigitalOutputs() const
{
    return m_showDigitalOutputs;
}

void ThingsProxy::setShowDigitalOutputs(bool showDigitalOutputs)
{
    if (m_showDigitalOutputs != showDigitalOutputs) {
        m_showDigitalOutputs = showDigitalOutputs;
        emit showDigitalOutputsChanged();
        invalidateFilter();
        emit countChanged();
    }
}

bool ThingsProxy::showAnalogInputs() const
{
    return m_showAnalogInputs;
}

void ThingsProxy::setShowAnalogInputs(bool showAnalogInputs)
{
    if (m_showAnalogInputs != showAnalogInputs) {
        m_showAnalogInputs = showAnalogInputs;
        emit showAnalogInputsChanged();
        invalidateFilter();
        emit countChanged();
    }
}

bool ThingsProxy::showAnalogOutputs() const
{
    return m_showDigitalOutputs;
}

void ThingsProxy::setShowAnalogOutputs(bool showAnalogOutputs)
{
    if (m_showAnalogOutputs != showAnalogOutputs) {
        m_showAnalogOutputs = showAnalogOutputs;
        emit showAnalogOutputsChanged();
        invalidateFilter();
        emit countChanged();
    }
}

bool ThingsProxy::filterBatteryCritical() const
{
    return m_filterBatteryCritical;
}

void ThingsProxy::setFilterBatteryCritical(bool filterBatteryCritical)
{
    if (m_filterBatteryCritical != filterBatteryCritical) {
        m_filterBatteryCritical = filterBatteryCritical;
        emit filterBatteryCriticalChanged();
        invalidateFilter();
        emit countChanged();
    }
}

bool ThingsProxy::filterDisconnected() const
{
    return m_filterDisconnected;
}

void ThingsProxy::setFilterDisconnected(bool filterDisconnected)
{
    if (m_filterDisconnected != filterDisconnected) {
        m_filterDisconnected = filterDisconnected;
        emit filterDisconnectedChanged();
        invalidateFilter();
        emit countChanged();
    }
}

bool ThingsProxy::filterSetupFailed() const
{
    return m_filterSetupFailed;
}

void ThingsProxy::setFilterSetupFailed(bool filterSetupFailed)
{
    if (m_filterSetupFailed != filterSetupFailed) {
        m_filterSetupFailed = filterSetupFailed;
        emit filterSetupFailedChanged();
        invalidateFilter();
        emit countChanged();
    }
}

bool ThingsProxy::filterUpdates() const
{
    return m_filterUpdates;
}

void ThingsProxy::setFilterUpdates(bool filterUpdates)
{
    if (m_filterUpdates != filterUpdates) {
        m_filterUpdates = filterUpdates;
        emit filterUpdatesChanged();
        invalidateFilter();
        emit countChanged();
    }
}

bool ThingsProxy::groupByInterface() const
{
    return m_groupByInterface;
}

void ThingsProxy::setGroupByInterface(bool groupByInterface)
{
    if (m_groupByInterface != groupByInterface) {
        m_groupByInterface = groupByInterface;
        emit groupByInterfaceChanged();
        invalidate();
        emit countChanged();
    }
}

Thing *ThingsProxy::get(int index) const
{
    return getInternal(mapToSource(this->index(index, 0)).row());
}

Thing *ThingsProxy::getThing(const QUuid &thingId) const
{
    Things *d = qobject_cast<Things*>(sourceModel());
    if (d) {
        return d->getThing(thingId);
    }
    ThingsProxy *dp = qobject_cast<ThingsProxy*>(sourceModel());
    if (dp) {
        return dp->getThing(thingId);
    }
    return nullptr;
}

Thing *ThingsProxy::getInternal(int source_index) const
{
    Things* d = qobject_cast<Things*>(sourceModel());
    if (d) {
        return d->get(source_index);
    }
    ThingsProxy *dp = qobject_cast<ThingsProxy*>(sourceModel());
    if (dp) {
        return dp->get(source_index);
    }
    return nullptr;
}

bool ThingsProxy::lessThan(const QModelIndex &left, const QModelIndex &right) const
{
    if (m_groupByInterface) {
        QString leftBaseInterface = sourceModel()->data(left, Things::RoleBaseInterface).toString();
        QString rightBaseInterface = sourceModel()->data(right, Things::RoleBaseInterface).toString();
        if (leftBaseInterface != rightBaseInterface) {
            return QString::localeAwareCompare(leftBaseInterface, rightBaseInterface) < 0;
        }
    }
    QString leftName = sourceModel()->data(left, Things::RoleName).toString();
    QString rightName = sourceModel()->data(right, Things::RoleName).toString();

    int comparison = QString::localeAwareCompare(leftName, rightName);
    if (comparison == 0) {
        // If there are 2 identically named things we don't want undefined behavor as it may cause items
        // to reorder randomly. Use something static like thingId as fallback
        QString leftThingId = sourceModel()->data(left, Things::RoleId).toString();
        QString rightThingId = sourceModel()->data(right, Things::RoleId).toString();
        comparison = QString::localeAwareCompare(leftThingId, rightThingId);
    }
    return comparison < 0;
}

bool ThingsProxy::filterAcceptsRow(int source_row, const QModelIndex &source_parent) const
{
    Thing *thing = getInternal(source_row);
    if (!m_filterTagId.isEmpty()) {
        Tag *tag = m_engine->tagsManager()->tags()->findThingTag(thing->id().toString(), m_filterTagId);
        if (!tag) {
            return false;
        }
        if (!m_filterTagValue.isEmpty() && tag->value() != m_filterTagValue) {
            return false;
        }
    }
    if (!m_filterThingClassId.isEmpty()) {
        if (thing->thingClassId() != QUuid(m_filterThingClassId)) {
            return false;
        }
    }
    if (!m_filterThingId.isEmpty()) {
        if (thing->id() != QUuid(m_filterThingId)) {
            return false;
        }
    }
    ThingClass *thingClass = m_engine->thingManager()->thingClasses()->getThingClass(thing->thingClassId());
//    qDebug() << "Checking thing" << thingClass->name() << thingClass->interfaces();
    if (!m_shownInterfaces.isEmpty()) {
        bool foundMatch = false;
        foreach (const QString &filterInterface, m_shownInterfaces) {
            if (thingClass->interfaces().contains(filterInterface)) {
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
            if (thingClass->interfaces().contains(filterInterface)) {
                return false;
            }
        }
    }

    if (m_showDigitalInputs || m_showDigitalOutputs || m_showAnalogInputs || m_showAnalogOutputs) {
        if (m_showDigitalInputs && thingClass->stateTypes()->ioStateTypes(Types::IOTypeDigitalInput).isEmpty()) {
            return false;
        }
        if (m_showDigitalOutputs && thingClass->stateTypes()->ioStateTypes(Types::IOTypeDigitalOutput).isEmpty()) {
            return false;
        }
        if (m_showAnalogInputs && thingClass->stateTypes()->ioStateTypes(Types::IOTypeAnalogInput).isEmpty()) {
            return false;
        }
        if (m_showAnalogOutputs && thingClass->stateTypes()->ioStateTypes(Types::IOTypeAnalogOutput).isEmpty()) {
            return false;
        }
    }

    if (m_filterBatteryCritical) {
        if (!thingClass->interfaces().contains("battery") || thing->stateValue(thingClass->stateTypes()->findByName("batteryCritical")->id()).toBool() == false) {
            return false;
        }
    }

    if (m_filterDisconnected) {
        if (!thingClass->interfaces().contains("connectable") || thing->stateValue(thingClass->stateTypes()->findByName("connected")->id()).toBool() == true) {
            return false;
        }
    }

    if (m_filterSetupFailed) {
        if (thing->setupStatus() != Thing::ThingSetupStatusFailed) {
            return false;
        }
    }

    if (m_filterUpdates) {
        if (!thingClass->interfaces().contains("update")) {
            return false;
        }
        if (thing->stateValue(thingClass->stateTypes()->findByName("updateStatus")->id()).toString() == "idle") {
            return false;
        }
    }

    if (!m_nameFilter.isEmpty()) {
        if (!thing->name().toLower().contains(m_nameFilter.toLower().trimmed())) {
            return false;
        }
    }

    if (!m_requiredEventName.isEmpty()) {
        if (!thing->thingClass()->eventTypes()->findByName(m_requiredEventName)) {
            return false;
        }
    }
    if (!m_requiredStateName.isEmpty()) {
        if (!thing->thingClass()->stateTypes()->findByName(m_requiredStateName)) {
            return false;
        }
    }
    if (!m_requiredActionName.isEmpty()) {
        if (!thing->thingClass()->actionTypes()->findByName(m_requiredActionName)) {
            return false;
        }
    }

    return QSortFilterProxyModel::filterAcceptsRow(source_row, source_parent);
}
