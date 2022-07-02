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
    setSortRole(Things::RoleName);
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

        connect(m_engine->tagsManager()->tags(), &Tags::countChanged, this, &ThingsProxy::invalidateFilterInternal);

        if (!sourceModel()) {
            setSourceModel(m_engine->thingManager()->things());

            setSortRole(Things::RoleName);
            sort(0, sortOrder());
            connect(sourceModel(), SIGNAL(countChanged()), this, SIGNAL(countChanged()));
            connect(sourceModel(), &QAbstractItemModel::dataChanged, this, [this]() {
                // Only invalidate the filter if we're actually interested in state changes
                if (!m_sortStateName.isEmpty() || m_filterBatteryCritical || m_filterDisconnected || m_filterUpdates) {
                    invalidateFilterInternal();
                }
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
        connect(m_parentProxy, SIGNAL(countChanged()), this, SIGNAL(countChanged()));

        connect(m_parentProxy, &QAbstractItemModel::dataChanged, this, [this]() {
            if (m_engine &&
                    // Only invalidate the filter if we're actually interested in state changes
                    (!m_sortStateName.isEmpty() || m_filterBatteryCritical || m_filterDisconnected || m_filterUpdates)) {
                invalidateFilterInternal();
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
        invalidateFilterInternal();
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
        invalidateFilterInternal();
    }
}

QString ThingsProxy::hideTagId() const
{
    return m_hideTagId;
}

void ThingsProxy::setHideTagId(const QString &tagId)
{
    if (m_hideTagId != tagId) {
        m_hideTagId = tagId;
        emit hideTagIdChanged();
        invalidateFilterInternal();
    }
}

QString ThingsProxy::hideTagValue() const
{
    return m_hideTagValue;
}

void ThingsProxy::setHideTagValue(const QString &tagValue)
{
    if (m_hideTagValue != tagValue) {
        m_hideTagValue = tagValue;
        emit hideTagValueChanged();
        invalidateFilterInternal();
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
        invalidateFilterInternal();
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
        invalidateFilterInternal();
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
        invalidateFilterInternal();
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
        invalidateFilterInternal();
    }
}

QStringList ThingsProxy::shownThingClassIds() const
{
    QStringList ret;
    foreach (const QUuid &id, m_shownThingClassIds) {
        ret << id.toString();
    }
    return ret;
}

void ThingsProxy::setShownThingClassIds(const QStringList &shownThingClassIds)
{
    QList<QUuid> uuids;
    foreach (const QString &str, shownThingClassIds) {
        uuids << QUuid(str);
    }
    if (m_shownThingClassIds != uuids) {
        m_shownThingClassIds = uuids;
        emit shownThingClassIdsChanged();
        invalidateFilterInternal();
    }
}

QStringList ThingsProxy::hiddenThingClassIds() const
{
    QStringList ret;
    foreach (const QUuid &uuid, m_hiddenThingClassIds) {
        ret << uuid.toString();
    }
    return ret;
}

void ThingsProxy::setHiddenThingClassIds(const QStringList &hiddenThingClassIds)
{
    QList<QUuid> uuids;
    foreach (const QString &str, hiddenThingClassIds) {
        uuids << str;
    }
    if (m_hiddenThingClassIds != uuids) {
        m_hiddenThingClassIds = uuids;
        emit hiddenThingClassIdsChanged();
        invalidateFilterInternal();
    }
}

QStringList ThingsProxy::hiddenThingIds() const
{
    QStringList ret;
    foreach (const QUuid &uuid, m_hiddenThingIds) {
        ret << uuid.toString();
    }
    return ret;
}

void ThingsProxy::setHiddenThingIds(const QStringList &hiddenThingIds)
{
    QList<QUuid> uuids;
    foreach (const QString &str, hiddenThingIds) {
        uuids << str;
    }
    if (m_hiddenThingIds != uuids) {
        m_hiddenThingIds = uuids;
        emit hiddenThingIdsChanged();
        invalidateFilterInternal();
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
        invalidateFilterInternal();
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
        invalidateFilterInternal();
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
        invalidateFilterInternal();
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
        invalidateFilterInternal();
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
        invalidateFilterInternal();
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
        invalidateFilterInternal();
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
        invalidateFilterInternal();
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
        invalidateFilterInternal();
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
        invalidateFilterInternal();
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
        invalidateFilterInternal();
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
        invalidateFilterInternal();
    }
}

QVariantMap ThingsProxy::paramsFilter() const
{
    return m_paramsFilter;
}

void ThingsProxy::setParamsFilter(const QVariantMap &paramsFilter)
{
    if (m_paramsFilter != paramsFilter) {
        m_paramsFilter = paramsFilter;
        emit paramsFilterChanged();

        invalidateFilterInternal();
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

QString ThingsProxy::sortStateName() const
{
    return m_sortStateName;
}

void ThingsProxy::setSortStateName(const QString &sortStateName)
{
    if (m_sortStateName != sortStateName) {
        m_sortStateName = sortStateName;
        emit sortStateNameChanged();
        invalidate();
    }
}

void ThingsProxy::setSortOrder(Qt::SortOrder sortOrder)
{
    sort(0, sortOrder);
    emit sortOrderChanged();
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

int ThingsProxy::indexOf(Thing *thing) const
{
    Things *t = qobject_cast<Things*>(sourceModel());
    ThingsProxy *tp = qobject_cast<ThingsProxy*>(sourceModel());
    int idx = -1;
    if (t) {
        idx = t->indexOf(thing);
    } else if (tp) {
        idx = tp->indexOf(thing);
    } else {
        return -1;
    }
    QModelIndex sourceIndex = sourceModel()->index(idx, 0);
    return mapFromSource(sourceIndex).row();
}

void ThingsProxy::invalidateFilterInternal()
{
    int oldCount = rowCount();
    invalidateFilter();
    if (oldCount != rowCount()) {
        emit countChanged();
    }
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

    if (!m_sortStateName.isEmpty()) {
        Thing *leftThing = nullptr;
        Thing *rightThing = nullptr;
        if (m_parentProxy) {
            leftThing = m_parentProxy->get(left.row());
            rightThing = m_parentProxy->get(right.row());
        } else {
            leftThing = m_engine->thingManager()->things()->get(left.row());
            rightThing = m_engine->thingManager()->things()->get(right.row());
        }
        if (!leftThing || !rightThing) {
            // This should never happen, but apparently some very rare stack traces indicate it does happen. Bug in Qt?
            qCWarning(dcThingManager()) << "Thing not found in source model!" << leftThing << rightThing << m_parentProxy << m_parentProxy->rowCount() << left << right;
            Q_ASSERT(false);
            return false;
        }
        State *leftState = leftThing->stateByName(m_sortStateName);
        State *rightState = rightThing->stateByName(m_sortStateName);
        QVariant leftStateValue = leftState ? leftState->value() : 0;
        QVariant rightStateValue = rightState ? rightState->value() : 0;
        return leftStateValue < rightStateValue;
    }

    QString leftName = sourceModel()->data(left, sortRole()).toString();
    QString rightName = sourceModel()->data(right, sortRole()).toString();

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
    if (!m_hideTagId.isEmpty()) {
        Tag *tag = m_engine->tagsManager()->tags()->findThingTag(thing->id().toString(), m_hideTagId);
        if (tag && m_hideTagValue.isEmpty()) {
            return false;
        }
        if (tag && tag->value() == m_hideTagValue) {
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


    if (!m_shownThingClassIds.isEmpty()) {
        if (!m_shownThingClassIds.contains(thing->thingClassId())) {
            return false;
        }
    }

    if (m_hiddenThingClassIds.contains(thing->thingClassId())) {
        return false;
    }

    if (m_hiddenThingIds.contains(thing->id())) {
        return false;
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

    if (!m_paramsFilter.isEmpty()) {
        foreach (const QString &paramName, m_paramsFilter.keys()) {
            Param *param = thing->paramByName(paramName);
            if (!param || param->value() != m_paramsFilter.value(paramName)) {
                return false;
            }
        }
    }

    return QSortFilterProxyModel::filterAcceptsRow(source_row, source_parent);
}
