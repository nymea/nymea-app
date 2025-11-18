// SPDX-License-Identifier: LGPL-3.0-or-later

/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
*
* Copyright (C) 2013 - 2024, nymea GmbH
* Copyright (C) 2024 - 2025, chargebyte austria GmbH
*
* This file is part of libnymea-app.
*
* libnymea-app is free software: you can redistribute it and/or
* modify it under the terms of the GNU Lesser General Public License
* as published by the Free Software Foundation, either version 3
* of the License, or (at your option) any later version.
*
* libnymea-app is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
* GNU Lesser General Public License for more details.
*
* You should have received a copy of the GNU Lesser General Public License
* along with libnymea-app. If not, see <https://www.gnu.org/licenses/>.
*
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

#ifndef THINGCLASSESPROXY_H
#define THINGCLASSESPROXY_H

#include <QUuid>
#include <QObject>
#include <QSortFilterProxyModel>

#include "engine.h"
#include "thingclasses.h"
#include "types/thingclass.h"

class ThingClassesProxy : public QSortFilterProxyModel
{
    Q_OBJECT
    Q_PROPERTY(int count READ rowCount NOTIFY countChanged)
    Q_PROPERTY(Engine *engine READ engine WRITE setEngine NOTIFY engineChanged)

    Q_PROPERTY(QString filterInterface READ filterInterface WRITE setFilterInterface NOTIFY filterInterfaceChanged)
    Q_PROPERTY(bool includeProvidedInterfaces READ includeProvidedInterfaces WRITE setIncludeProvidedInterfaces NOTIFY includeProvidedInterfacesChanged)
    Q_PROPERTY(QString filterDisplayName READ filterDisplayName WRITE setFilterDisplayName NOTIFY filterDisplayNameChanged)
    Q_PROPERTY(QUuid filterVendorId READ filterVendorId WRITE setFilterVendorId NOTIFY filterVendorIdChanged)
    Q_PROPERTY(QString filterVendorName READ filterVendorName WRITE setFilterVendorName NOTIFY filterVendorNameChanged)

    Q_PROPERTY(QList<QUuid> shownThingClassIds READ shownThingClassIds WRITE setShownThingClassIds NOTIFY shownThingClassIdsChanged)
    Q_PROPERTY(QList<QUuid> hiddenThingClassIds READ hiddenThingClassIds WRITE setHiddenThingClassIds NOTIFY hiddenThingClassIdsChanged)

    // Filters by thingClass' displayName or vendor's displayName
    Q_PROPERTY(QString filterString READ filterString WRITE setFilterString NOTIFY filterStringChanged)

    Q_PROPERTY(bool groupByInterface READ groupByInterface WRITE setGroupByInterface NOTIFY groupByInterfaceChanged)

public:
    explicit ThingClassesProxy(QObject *parent = nullptr);

    Engine *engine() const;
    void setEngine(Engine *engine);

    QString filterInterface() const;
    void setFilterInterface(const QString &filterInterface);

    bool includeProvidedInterfaces() const;
    void setIncludeProvidedInterfaces(bool includeProvidedInterfaces);

    QString filterDisplayName() const;
    void setFilterDisplayName(const QString &filter);

    QUuid filterVendorId() const;
    void setFilterVendorId(const QUuid &filterVendorId);

    QString filterVendorName() const;
    void setFilterVendorName(const QString &filterVendorName);

    QString filterString() const;
    void setFilterString(const QString &filterString);

    QList<QUuid> shownThingClassIds() const;
    void setShownThingClassIds(const QList<QUuid> &shownThingClassIds);

    QList<QUuid> hiddenThingClassIds() const;
    void setHiddenThingClassIds(const QList<QUuid> &hiddenThingClassIds);

    bool groupByInterface() const;
    void setGroupByInterface(bool groupByInterface);

    Q_INVOKABLE ThingClass *get(int index) const;

    Q_INVOKABLE void resetFilter();

signals:
    void engineChanged();
    void filterInterfaceChanged();
    void includeProvidedInterfacesChanged();
    void filterDisplayNameChanged();
    void filterVendorIdChanged();
    void filterVendorNameChanged();
    void filterStringChanged();
    void shownThingClassIdsChanged();
    void hiddenThingClassIdsChanged();
    void groupByInterfaceChanged();
    void countChanged();

protected:
    bool filterAcceptsRow(int sourceRow, const QModelIndex &sourceParent) const Q_DECL_OVERRIDE;
    bool lessThan(const QModelIndex &left, const QModelIndex &right) const Q_DECL_OVERRIDE;

private:
    Engine *m_engine = nullptr;
    QString m_filterInterface;
    bool m_includeProvidedInterfaces = false;
    QString m_filterDisplayName;
    QUuid m_filterVendorId;
    QString m_filterVendorName;
    QList<QUuid> m_hiddenThingClassIds;
    QList<QUuid> m_shownThingClassIds;
    QString m_filterString;
    bool m_groupByInterface = false;
};

#endif // THINGCLASSESPROXY_H
