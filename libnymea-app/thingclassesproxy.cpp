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

#include "thingclassesproxy.h"

#include <QDebug>

ThingClassesProxy::ThingClassesProxy(QObject *parent) :
    QSortFilterProxyModel(parent)
{
    setSortRole(ThingClasses::RoleDisplayName);
}

Engine *ThingClassesProxy::engine() const
{
    return m_engine;
}

void ThingClassesProxy::setEngine(Engine *engine)
{
    if (m_engine != engine) {
        m_engine = engine;
        setSourceModel(engine->thingManager()->thingClasses());
        emit engineChanged();
        emit countChanged();
        sort(0);
    }
}


QString ThingClassesProxy::filterInterface() const
{
    return m_filterInterface;
}

void ThingClassesProxy::setFilterInterface(const QString &filterInterface)
{
    if (m_filterInterface != filterInterface) {
        m_filterInterface = filterInterface;
        emit filterInterfaceChanged();
        invalidateFilter();
        emit countChanged();
    }
}

QString ThingClassesProxy::filterDisplayName() const
{
    return m_filterDisplayName;
}

void ThingClassesProxy::setFilterDisplayName(const QString &filter)
{
    if (m_filterDisplayName != filter) {
        m_filterDisplayName = filter;
        emit filterDisplayNameChanged();
        invalidateFilter();
        emit countChanged();
    }
}

QUuid ThingClassesProxy::filterVendorId() const
{
    return m_filterVendorId;
}

void ThingClassesProxy::setFilterVendorId(const QUuid &filterVendorId)
{
    if (m_filterVendorId != filterVendorId) {
        m_filterVendorId = filterVendorId;
        emit filterVendorIdChanged();
        invalidateFilter();
        emit countChanged();
    }
}

QString ThingClassesProxy::filterVendorName() const
{
    return m_filterVendorName;
}

void ThingClassesProxy::setFilterVendorName(const QString &filterVendorName)
{
    if (m_filterVendorName != filterVendorName) {
        m_filterVendorName = filterVendorName;
        emit filterVendorNameChanged();
        invalidateFilter();
        emit countChanged();
    }
}

QString ThingClassesProxy::filterString() const
{
    return m_filterString;
}

void ThingClassesProxy::setFilterString(const QString &filterString)
{
    if (m_filterString != filterString) {
        m_filterString = filterString;
        emit filterStringChanged();
        invalidateFilter();
        emit countChanged();
    }
}

bool ThingClassesProxy::groupByInterface() const
{
    return m_groupByInterface;
}

void ThingClassesProxy::setGroupByInterface(bool groupByInterface)
{
    if (m_groupByInterface != groupByInterface) {
        m_groupByInterface = groupByInterface;
        emit groupByInterfaceChanged();
        invalidate();
    }
}

ThingClass *ThingClassesProxy::get(int index) const
{
    return m_engine->thingManager()->thingClasses()->get(mapToSource(this->index(index, 0)).row());
}


void ThingClassesProxy::resetFilter()
{
    m_filterVendorId = QUuid();
    m_filterInterface.clear();
    m_filterVendorName.clear();
    m_filterDisplayName.clear();
    invalidateFilter();
    emit countChanged();
}

bool ThingClassesProxy::filterAcceptsRow(int sourceRow, const QModelIndex &sourceParent) const
{
    Q_UNUSED(sourceParent)

    ThingClass *thingClass = m_engine->thingManager()->thingClasses()->get(sourceRow);

    // filter auto things
    if (thingClass->createMethods().count() == 1 && thingClass->createMethods().contains("CreateMethodAuto"))
        return false;

    if (!m_filterVendorId.isNull() && thingClass->vendorId() != m_filterVendorId)
        return false;

    if (!m_filterInterface.isEmpty() && !thingClass->interfaces().contains(m_filterInterface)) {
        return false;
    }

    if (!m_filterDisplayName.isEmpty() && !thingClass->displayName().toLower().contains(m_filterDisplayName.toLower())) {
        return false;
    }

    if (!m_filterVendorName.isEmpty()) {
        Vendor *vendor = m_engine->thingManager()->vendors()->getVendor(thingClass->vendorId());
        if (!vendor) {
            qWarning() << "Invalid vendor for thingClass:" << thingClass->name() << thingClass->vendorId();
            return false;
        }
        if (!vendor->displayName().toLower().contains(m_filterVendorName.toLower())) {
            return false;
        }
    }

    if (!m_filterString.isEmpty()) {
        Vendor *vendor = m_engine->thingManager()->vendors()->getVendor(thingClass->vendorId());
        if (!vendor) {
            qWarning() << "Invalid vendor for thingClass:" << thingClass->name() << thingClass->vendorId();
            return false;
        }
        if (!vendor->displayName().toLower().contains(m_filterString.toLower()) && !thingClass->displayName().toLower().contains(m_filterString.toLower())) {
            return false;
        }
    }

    return true;
}

bool ThingClassesProxy::lessThan(const QModelIndex &left, const QModelIndex &right) const
{
    if (m_groupByInterface) {
        QString leftBaseInterface = sourceModel()->data(left, ThingClasses::RoleBaseInterface).toString();
        QString rightBaseInterface = sourceModel()->data(right, ThingClasses::RoleBaseInterface).toString();
        if (leftBaseInterface != rightBaseInterface) {
            return QString::localeAwareCompare(leftBaseInterface, rightBaseInterface) < 0;
        }
    }
    QString leftName = sourceModel()->data(left, ThingClasses::RoleDisplayName).toString();
    QString rightName = sourceModel()->data(right, ThingClasses::RoleDisplayName).toString();

    return QString::localeAwareCompare(leftName, rightName) < 0;
}
