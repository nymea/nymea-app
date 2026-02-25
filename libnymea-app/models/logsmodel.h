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

#ifndef LOGSMODEL_H
#define LOGSMODEL_H

#include <QAbstractListModel>
#include <QQmlParserStatus>

#include "types/logentry.h"
#include "engine.h"

#include <QLoggingCategory>
Q_DECLARE_LOGGING_CATEGORY(dcLogEngine)

class LogsModel : public QAbstractListModel, public QQmlParserStatus
{
    Q_OBJECT
    Q_PROPERTY(Engine* engine READ engine WRITE setEngine NOTIFY engineChanged)
    Q_INTERFACES(QQmlParserStatus)

    Q_PROPERTY(int count READ rowCount NOTIFY countChanged)
    Q_PROPERTY(bool busy READ busy NOTIFY busyChanged)
    Q_PROPERTY(bool live READ live WRITE setLive NOTIFY liveChanged)
    Q_PROPERTY(QUuid thingId READ thingId WRITE setThingId NOTIFY thingIdChanged)
    Q_PROPERTY(QStringList typeIds READ typeIds WRITE setTypeIds NOTIFY typeIdsChanged)
    Q_PROPERTY(QDateTime startTime READ startTime WRITE setStartTime NOTIFY startTimeChanged)
    Q_PROPERTY(QDateTime endTime READ endTime WRITE setEndTime NOTIFY endTimeChanged)
    Q_PROPERTY(QDateTime viewStartTime READ viewStartTime WRITE setViewStartTime NOTIFY viewStartTimeChanged)
    Q_PROPERTY(SourceFilters sourceFilter READ sourceFilter WRITE setSourceFilter NOTIFY sourceFilterChanged)
    Q_PROPERTY(int fetchBlockSize READ fetchBlockSize WRITE setFetchBlockSize NOTIFY fetchBlockSizeChanged)

public:
    enum Roles {
        RoleTimestamp,
        RoleValue,
        RoleThingId,
        RoleTypeId,
        RoleSource,
        RoleLoggingEventType,
        RoleErrorCode
    };
    enum SourceFilter {
        SourceNone = 0x00,
        SourceSystem = 0x01,
        SourceRules = 0x02,
        SourceEvents = 0x04,
        SourceStates = 0x08,
        SourceActions = 0x10,
        SourceAll = 0xff
    };
    Q_DECLARE_FLAGS(SourceFilters, SourceFilter)
    Q_FLAG(SourceFilters)

    explicit LogsModel(QObject *parent = nullptr);
    virtual ~LogsModel() = default;

    Engine* engine() const;
    void setEngine(Engine* engine);

    bool busy() const;
    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role) const override;
    QHash<int, QByteArray> roleNames() const override;
    bool canFetchMore(const QModelIndex &parent) const override;
    virtual void fetchMore(const QModelIndex &parent = QModelIndex()) override;
    void classBegin() override;
    void componentComplete() override;

    bool live() const;
    void setLive(bool live);

    QUuid thingId() const;
    void setThingId(const QUuid &thingId);

    QStringList typeIds() const;
    void setTypeIds(const QStringList &typeIds);

    QDateTime startTime() const;
    void setStartTime(const QDateTime &startTime);

    QDateTime endTime() const;
    void setEndTime(const QDateTime &endTime);

    QDateTime viewStartTime() const;
    void setViewStartTime(const QDateTime &viewStartTime);

    SourceFilters sourceFilter() const;
    void setSourceFilter(SourceFilters sourceFilter);

    int fetchBlockSize() const;
    void setFetchBlockSize(int fetchBlockSize);

    Q_INVOKABLE LogEntry* get(int index) const;
    Q_INVOKABLE LogEntry* findClosest(const QDateTime &dateTime);


signals:
    void engineChanged();
    void busyChanged();
    void liveChanged();
    void countChanged();
    void thingIdChanged();
    void typeIdsChanged();
    void startTimeChanged();
    void endTimeChanged();
    void viewStartTimeChanged();
    void sourceFilterChanged();
    void fetchBlockSizeChanged();

    void logEntryAdded(LogEntry *entry);

private slots:
    virtual void logsReply(int commandId, const QVariantMap &data);
    void newLogEntryReceived(const QVariantMap &data);

protected:
    Engine *m_engine = nullptr;
    QList<LogEntry*> m_list;
    QUuid m_thingId;
    QList<QUuid> m_typeIds;
    QDateTime m_startTime;
    QDateTime m_endTime;
    QDateTime m_viewStartTime;
    SourceFilters m_sourceFilter = SourceAll;

    bool m_busy = false;
    bool m_live = false;
    int m_blockSize = 1000;

    bool m_busyInternal = false;

    bool m_canFetchMore = true;

    int m_generatedEntries = 0;

    QDateTime m_fetchStartTime;
};

#endif // LOGSMODEL_H
