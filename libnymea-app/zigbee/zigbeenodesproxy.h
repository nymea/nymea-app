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

#ifndef ZIGBEENODESPROXY_H
#define ZIGBEENODESPROXY_H

#include <QObject>
#include <QSortFilterProxyModel>

#include "zigbeenode.h"
#include "zigbeenodes.h"

class ZigbeeNodesProxy : public QSortFilterProxyModel
{
    Q_OBJECT
    Q_PROPERTY(int count READ rowCount NOTIFY countChanged)
    Q_PROPERTY(ZigbeeNodes *zigbeeNodes READ zigbeeNodes WRITE setZigbeeNodes NOTIFY zigbeeNodesChanged)

    Q_PROPERTY(bool showCoordinator READ showCoordinator WRITE setShowCoordinator NOTIFY showCoordinatorChanged)
    Q_PROPERTY(bool showOnline READ showOnline WRITE setShowOnline NOTIFY showOnlineChanged)
    Q_PROPERTY(bool showOffline READ showOffline WRITE setShowOffline NOTIFY showOfflineChanged)
//    Q_PROPERTY(quint16 filterByParentNeighbor READ filterByParentNeighbor WRITE setFilterByParentNeighbor NOTIFY filterByParentNeighborChanged)

    Q_PROPERTY(bool newOnTop READ newOnTop WRITE setNewOnTop NOTIFY newOnTopChanged)

public:
    explicit ZigbeeNodesProxy(QObject *parent = nullptr);

    ZigbeeNodes *zigbeeNodes() const;
    void setZigbeeNodes(ZigbeeNodes *zigbeeNodes);

    bool showCoordinator() const;
    void setShowCoordinator(bool showCoordinator);

    bool showOnline() const;
    void setShowOnline(bool showOnline);

    bool showOffline() const;
    void setShowOffline(bool showOffline);

    bool newOnTop() const;
    void setNewOnTop(bool newOnTop);

    Q_INVOKABLE ZigbeeNode *get(int index) const;

signals:
    void countChanged();
    void zigbeeNodesChanged(ZigbeeNodes *zigbeeNodes);
    void showCoordinatorChanged();
    void newOnTopChanged();
    void showOnlineChanged();
    void showOfflineChanged();

protected:
    bool filterAcceptsRow(int source_row, const QModelIndex &source_parent) const override;
    bool lessThan(const QModelIndex &source_left, const QModelIndex &source_right) const override;

private:
    ZigbeeNodes *m_zigbeeNodes = nullptr;

    bool m_showCoordinator = true;
    bool m_showOnline = true;
    bool m_showOffline = true;

    bool m_newOnTop = false;
    bool m_sortByRelationship = false;

    QHash<ZigbeeNode*, QDateTime> m_newNodes;
};

#endif // ZIGBEENODESPROXY_H
