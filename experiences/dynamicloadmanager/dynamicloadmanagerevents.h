// SPDX-License-Identifier: GPL-3.0-or-later

/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
*
* Copyright (C) 2013 - 2024, nymea GmbH
* Copyright (C) 2024 - 2025, chargebyte austria GmbH
*
* This file is part of nymea-app.
*
* nymea-app is free software: you can redistribute it and/or modify
* it under the terms of the GNU General Public License as published by
* the Free Software Foundation, either version 3 of the License, or
* (at your option) any later version.
*
* nymea-app is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
* GNU General Public License for more details.
*
* You should have received a copy of the GNU General Public License
* along with nymea-app. If not, see <https://www.gnu.org/licenses/>.
*
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

#ifndef DYNAMICLOADMANAGEREVENTS_H
#define DYNAMICLOADMANAGEREVENTS_H

#include <QAbstractListModel>
#include <QDateTime>
#include <QQmlParserStatus>
#include <QSet>
#include <QTimer>
#include <QVector>

#include "dynamicloadmanagermanager.h"

// Per-node chronological list of dynamic load manager events (DynamicLoadManager.GetNodeEvents).
class DynamicLoadManagerEvents : public QAbstractListModel, public QQmlParserStatus
{
    Q_OBJECT
    Q_INTERFACES(QQmlParserStatus)
    Q_PROPERTY(DynamicLoadManagerManager *manager READ manager WRITE setManager NOTIFY managerChanged)
    Q_PROPERTY(QString nodeId READ nodeId WRITE setNodeId NOTIFY nodeIdChanged)
    Q_PROPERTY(QDateTime from READ from WRITE setFrom NOTIFY fromChanged)
    Q_PROPERTY(QDateTime to READ to WRITE setTo NOTIFY toChanged)
    Q_PROPERTY(bool includeDescendants READ includeDescendants WRITE setIncludeDescendants NOTIFY includeDescendantsChanged)
    Q_PROPERTY(bool live READ live WRITE setLive NOTIFY liveChanged)
    Q_PROPERTY(bool busy READ busy NOTIFY busyChanged)
    Q_PROPERTY(int count READ rowCount NOTIFY countChanged)

public:
    enum Roles {
        TimestampRole = Qt::UserRole + 1,
        NodeIdRole,
        EventTypeRole,
        SeverityRole,
        ReasonRole,
        DetailsRole
    };
    Q_ENUM(Roles)

    explicit DynamicLoadManagerEvents(QObject *parent = nullptr);

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    QHash<int, QByteArray> roleNames() const override;

    DynamicLoadManagerManager *manager() const;
    void setManager(DynamicLoadManagerManager *manager);

    QString nodeId() const;
    void setNodeId(const QString &nodeId);

    QDateTime from() const;
    void setFrom(const QDateTime &from);

    QDateTime to() const;
    void setTo(const QDateTime &to);

    bool includeDescendants() const;
    void setIncludeDescendants(bool includeDescendants);

    bool live() const;
    void setLive(bool live);

    bool busy() const;

    Q_INVOKABLE QVariantMap get(int index) const;
    Q_INVOKABLE void refresh();

    void classBegin() override;
    void componentComplete() override;

signals:
    void managerChanged();
    void nodeIdChanged();
    void fromChanged();
    void toChanged();
    void includeDescendantsChanged();
    void liveChanged();
    void busyChanged();
    void countChanged();

private slots:
    void eventsReply(int commandId, const QVariantMap &params);
    void nodeHistoryEventAdded(const QVariantMap &event);

private:
    struct Event {
        QDateTime timestamp;
        QString nodeId;
        QString eventType;
        QString severity;
        QString reason;
        QVariantMap details;
    };

    static Event parseEvent(const QVariantMap &map);
    void scheduleRefresh();
    void connectManager();
    void rebuildNodeFilter();
    void collectDescendants(const QVariantMap &node, bool collecting, QSet<QString> &ids) const;

    DynamicLoadManagerManager *m_manager = nullptr;
    QString m_nodeId;
    QDateTime m_from;
    QDateTime m_to;
    bool m_includeDescendants = false;
    bool m_live = false;
    bool m_busy = false;
    bool m_componentComplete = false;

    QVector<Event> m_events;
    QSet<QString> m_nodeFilter;
    QTimer m_refreshTimer;
};

#endif // DYNAMICLOADMANAGEREVENTS_H
