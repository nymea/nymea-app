// SPDX-License-Identifier: LGPL-3.0-or-later

/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
*
* Copyright (C) 2024 - 2026, chargebyte austria GmbH
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


#ifndef NETWORKINTERFACESPROXY_H
#define NETWORKINTERFACESPROXY_H

#include <QSortFilterProxyModel>
#include <QStringList>

#include "networkinterfaces.h"

class NetworkInterfacesProxy : public QSortFilterProxyModel
{
    Q_OBJECT
    Q_PROPERTY(int count READ rowCount NOTIFY countChanged)
    Q_PROPERTY(NetworkInterfaces *networkInterfaces READ networkInterfaces WRITE setNetworkInterfaces NOTIFY networkInterfacesChanged)
    Q_PROPERTY(QStringList hiddenKinds READ hiddenKinds WRITE setHiddenKinds NOTIFY hiddenKindsChanged)

public:
    explicit NetworkInterfacesProxy(QObject *parent = nullptr);

    NetworkInterfaces *networkInterfaces() const;
    void setNetworkInterfaces(NetworkInterfaces *networkInterfaces);

    QStringList hiddenKinds() const;
    void setHiddenKinds(const QStringList &hiddenKinds);

    Q_INVOKABLE QVariantMap get(int row) const;

signals:
    void countChanged();
    void networkInterfacesChanged();
    void hiddenKindsChanged();

protected:
    bool filterAcceptsRow(int sourceRow, const QModelIndex &sourceParent) const override;

private:
    QStringList m_hiddenKinds;
};

#endif // NETWORKINTERFACESPROXY_H
