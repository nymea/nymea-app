/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 *                                                                         *
 *  Copyright (C) 2017 Simon Stuerz <simon.stuerz@guh.io>                  *
 *                                                                         *
 *  This file is part of nymea:app                                         *
 *                                                                         *
 *  This library is free software; you can redistribute it and/or          *
 *  modify it under the terms of the GNU Lesser General Public             *
 *  License as published by the Free Software Foundation; either           *
 *  version 2.1 of the License, or (at your option) any later version.     *
 *                                                                         *
 *  This library is distributed in the hope that it will be useful,        *
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of         *
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU      *
 *  Lesser General Public License for more details.                        *
 *                                                                         *
 *  You should have received a copy of the GNU Lesser General Public       *
 *  License along with this library; If not, see                           *
 *  <http://www.gnu.org/licenses/>.                                        *
 *                                                                         *
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

#ifndef DEVICECLASSFILERMODEL_H
#define DEVICECLASSFILERMODEL_H

#include <QUuid>
#include <QObject>
#include <QSortFilterProxyModel>

#include "deviceclasses.h"
#include "types/deviceclass.h"

class DeviceClassesProxy : public QSortFilterProxyModel
{
    Q_OBJECT
    Q_PROPERTY(QUuid vendorId READ vendorId WRITE setVendorId NOTIFY vendorIdChanged)
    Q_PROPERTY(DeviceClasses *deviceClasses READ deviceClasses WRITE setDeviceClasses NOTIFY deviceClassesChanged)

    Q_PROPERTY(QString filterInterface READ filterInterface WRITE setFilterInterface NOTIFY filterInterfaceChanged)
    Q_PROPERTY(QString filterDisplayName READ filterDisplayName WRITE setFilterDisplayName NOTIFY filterDisplayNameChanged)

    Q_PROPERTY(bool groupByInterface READ groupByInterface WRITE setGroupByInterface NOTIFY groupByInterfaceChanged)

public:
    explicit DeviceClassesProxy(QObject *parent = nullptr);

    QUuid vendorId() const;
    void setVendorId(const QUuid &vendorId);

    DeviceClasses *deviceClasses();
    void setDeviceClasses(DeviceClasses *deviceClasses);

    QString filterInterface() const;
    void setFilterInterface(const QString &filterInterface);

    QString filterDisplayName() const;
    void setFilterDisplayName(const QString &filter);

    bool groupByInterface() const;
    void setGroupByInterface(bool groupByInterface);

    Q_INVOKABLE DeviceClass *get(int index) const;

    Q_INVOKABLE void resetFilter();

signals:
    void vendorIdChanged();
    void deviceClassesChanged();
    void filterInterfaceChanged();
    void filterDisplayNameChanged();
    void groupByInterfaceChanged();

protected:
    bool filterAcceptsRow(int sourceRow, const QModelIndex &sourceParent) const Q_DECL_OVERRIDE;
    bool lessThan(const QModelIndex &left, const QModelIndex &right) const Q_DECL_OVERRIDE;

private:
    QUuid m_vendorId;
    DeviceClasses *m_deviceClasses;
    QString m_filterInterface;
    QString m_filterDisplayName;
    bool m_groupByInterface = false;
};

#endif // DEVICECLASSFILERMODEL_H
