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

#ifndef WIRELESSACCESSPOINTSPROXY_H
#define WIRELESSACCESSPOINTSPROXY_H

#include <QObject>
#include <QSortFilterProxyModel>

class WirelessAccessPoint;
class WirelessAccessPoints;

class WirelessAccessPointsProxy : public QSortFilterProxyModel
{
    Q_OBJECT
    Q_PROPERTY(int count READ rowCount NOTIFY countChanged)
    Q_PROPERTY(WirelessAccessPoints* accessPoints READ accessPoints WRITE setAccessPoints)
    Q_PROPERTY(bool showDuplicates READ showDuplicates WRITE setShowDuplicates NOTIFY showDuplicatesChanged FINAL)

public:
    explicit WirelessAccessPointsProxy(QObject *parent = nullptr);

    WirelessAccessPoints *accessPoints() const;
    void setAccessPoints(WirelessAccessPoints *accessPoints);

    Q_INVOKABLE WirelessAccessPoint* get(int index) const;

    bool showDuplicates() const;
    void setShowDuplicates(bool showDuplicates);

signals:
    void countChanged();
    void accessPointsChanged();
    void showDuplicatesChanged();

protected:
    bool filterAcceptsRow(int source_row, const QModelIndex &source_parent) const override;

private:
    WirelessAccessPoints *m_accessPoints = nullptr;
    bool m_showDuplicates = false;

};

#endif // WIRELESSACCESSPOINTSPROXY_H
