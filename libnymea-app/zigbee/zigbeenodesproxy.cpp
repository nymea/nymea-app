/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
*
* Copyright 2013 - 2021, nymea GmbH
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

#include "zigbeenodesproxy.h"
#include "zigbeenode.h"
#include "zigbeenodes.h"

#include <QDebug>

ZigbeeNodesProxy::ZigbeeNodesProxy(QObject *parent) :
    QSortFilterProxyModel(parent)
{
    sort(0);
}

ZigbeeNodes *ZigbeeNodesProxy::zigbeeNodes() const
{
    return m_zigbeeNodes;
}

void ZigbeeNodesProxy::setZigbeeNodes(ZigbeeNodes *zigbeeNodes)
{
    if (m_zigbeeNodes == zigbeeNodes)
        return;

    m_zigbeeNodes = zigbeeNodes;
    emit zigbeeNodesChanged(m_zigbeeNodes);

    qWarning() << "Set nodes to proxy" << m_zigbeeNodes->rowCount();

    connect(m_zigbeeNodes, &ZigbeeNodes::countChanged, this, [this](){
        sort(0, Qt::AscendingOrder);
        emit countChanged();
    });
    connect(m_zigbeeNodes, &ZigbeeNodes::rowsInserted, this, [this](const QModelIndex &parent, int first, int last){
        Q_UNUSED(parent)
        for (int i = first; i <= last; i++) {
            m_newNodes.insert(m_zigbeeNodes->get(i), QDateTime::currentDateTime());
        }
        emit countChanged();
    });
    connect(m_zigbeeNodes, &ZigbeeNodes::dataChanged, this, [this](const QModelIndex &/*topLeft*/, const QModelIndex &/*bottomRight*/, const QVector<int> &roles = QVector<int>()){
        if ((roles.contains(ZigbeeNodes::RoleReachable) && (!m_showOffline || !m_showOnline))
                || (roles.contains(ZigbeeNodes::RoleType) && !m_showCoordinator)) {
            invalidateFilter();
            emit countChanged();
        }
    });

    setSourceModel(m_zigbeeNodes);

    // Sort by network address so the coordinator will always be on the top
    setSortRole(ZigbeeNodes::RoleNetworkAddress);
    sort(0, Qt::AscendingOrder);

    emit countChanged();
}

bool ZigbeeNodesProxy::showCoordinator() const
{
    return m_showCoordinator;
}

void ZigbeeNodesProxy::setShowCoordinator(bool showCoordinator)
{
    if (m_showCoordinator != showCoordinator) {
        m_showCoordinator = showCoordinator;
        emit showCoordinatorChanged();

        invalidateFilter();
        emit countChanged();
    }
}

bool ZigbeeNodesProxy::showOnline() const
{
    return m_showOnline;
}

void ZigbeeNodesProxy::setShowOnline(bool showOnline)
{
    if (m_showOnline != showOnline) {
        m_showOnline = showOnline;
        emit showOnlineChanged();
        invalidateFilter();
        emit countChanged();
    }
}

bool ZigbeeNodesProxy::showOffline() const
{
    return m_showOffline;
}

void ZigbeeNodesProxy::setShowOffline(bool showOffline)
{
    if (m_showOffline != showOffline) {
        m_showOffline = showOffline;
        emit showOfflineChanged();
        invalidateFilter();
        emit countChanged();
    }
}

bool ZigbeeNodesProxy::newOnTop() const
{
    return m_newOnTop;
}

void ZigbeeNodesProxy::setNewOnTop(bool newOnTop)
{
    if (m_newOnTop != newOnTop) {
        m_newOnTop = newOnTop;
        emit newOnTopChanged();
        invalidate();
    }
}

ZigbeeNode *ZigbeeNodesProxy::get(int index) const
{
    if (index >= 0 && index < m_zigbeeNodes->rowCount()) {
        return m_zigbeeNodes->get(mapToSource(this->index(index, 0)).row());
    }
    return nullptr;
}

bool ZigbeeNodesProxy::filterAcceptsRow(int source_row, const QModelIndex &source_parent) const
{
    Q_UNUSED(source_parent)
    ZigbeeNode *node = m_zigbeeNodes->get(source_row);
    if (!m_showCoordinator && node->type() == ZigbeeNode::ZigbeeNodeTypeCoordinator) {
        return false;
    }
    if (!m_showOnline && node->reachable()) {
        return false;
    }
    if (!m_showOffline && !node->reachable()) {
        return false;
    }
    return true;
}

bool ZigbeeNodesProxy::lessThan(const QModelIndex &source_left, const QModelIndex &source_right) const
{
    if (m_newOnTop) {
        ZigbeeNode *left = m_zigbeeNodes->get(source_left.row());
        ZigbeeNode *right = m_zigbeeNodes->get(source_right.row());
        if (m_newNodes.contains(left) && !m_newNodes.contains(right)) {
            return true;
        }
        if (!m_newNodes.contains(left) && !m_newNodes.contains(right)) {
            return false;
        }
        if (m_newNodes.contains(left) && m_newNodes.contains(right)) {
            return m_newNodes.value(left) > m_newNodes.value(right);
        }
    }
    return QSortFilterProxyModel::lessThan(source_left, source_right);
}
