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

#ifndef DEVICESPROXY_H
#define DEVICESPROXY_H

#include <QUuid>
#include <QObject>
#include <QSortFilterProxyModel>

#include "devices.h"

class DevicesProxy : public QSortFilterProxyModel
{
    Q_OBJECT
    Q_PROPERTY(int count READ rowCount NOTIFY countChanged)
    Q_PROPERTY(QAbstractItemModel *devices READ devices WRITE setDevices NOTIFY devicesChanged)
    Q_PROPERTY(QString filterTagId READ filterTagId WRITE setFilterTagId NOTIFY filterTagIdChanged)
    Q_PROPERTY(QStringList shownInterfaces READ shownInterfaces WRITE setShownInterfaces NOTIFY shownInterfacesChanged)
    Q_PROPERTY(QStringList hiddenInterfaces READ hiddenInterfaces WRITE setHiddenInterfaces NOTIFY hiddenInterfacesChanged)

    // Setting this to true will imply filtering for "battery" interface
    Q_PROPERTY(bool filterBatteryCritical READ filterBatteryCritical WRITE setFilterBatteryCritical NOTIFY filterBatteryCriticalChanged)

    // Setting this to true will imply filtering for "connectable" interface
    Q_PROPERTY(bool filterDisconnected READ filterDisconnected WRITE setFilterDisconnected NOTIFY filterDisconnectedChanged)

public:
    explicit DevicesProxy(QObject *parent = 0);

    QAbstractItemModel *devices() const;
    void setDevices(QAbstractItemModel *devices);

    QString filterTagId() const;
    void setFilterTagId(const QString &filterTag);

    QStringList shownInterfaces() const;
    void setShownInterfaces(const QStringList &shownInterfaces);

    QStringList hiddenInterfaces() const;
    void setHiddenInterfaces(const QStringList &hiddenInterfaces);

    bool filterBatteryCritical() const;
    void setFilterBatteryCritical(bool filterBatteryCritical);

    bool filterDisconnected() const;
    void setFilterDisconnected(bool filterDisconnected);

    Q_INVOKABLE Device *get(int index) const;

signals:
    void devicesChanged();
    void filterTagIdChanged();
    void shownInterfacesChanged();
    void hiddenInterfacesChanged();
    void filterBatteryCriticalChanged();
    void filterDisconnectedChanged();
    void countChanged();

private:
    Device *getInternal(int source_index) const;

    QAbstractItemModel *m_devices = nullptr;
    QString m_filterTagId;
    QStringList m_shownInterfaces;
    QStringList m_hiddenInterfaces;

    bool m_filterBatteryCritical = false;
    bool m_filterDisconnected = false;

protected:
    bool lessThan(const QModelIndex &left, const QModelIndex &right) const Q_DECL_OVERRIDE;
    bool filterAcceptsRow(int source_row, const QModelIndex &source_parent) const override;
};

#endif // DEVICESPROXY_H
