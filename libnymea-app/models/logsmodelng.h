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

#ifndef LOGSMODELNG_H
#define LOGSMODELNG_H

#include <QObject>
#include <QAbstractListModel>
#include <QDateTime>
#include <QLineSeries>
#include <QUuid>
#include <QQmlParserStatus>

class LogEntry;
class Engine;

class LogsModelNg : public QAbstractListModel, public QQmlParserStatus
{
    Q_OBJECT
    Q_INTERFACES(QQmlParserStatus)
    Q_PROPERTY(Engine* engine READ engine WRITE setEngine NOTIFY engineChanged)
    Q_PROPERTY(bool busy READ busy NOTIFY busyChanged)
    Q_PROPERTY(bool live READ live WRITE setLive NOTIFY liveChanged)
    Q_PROPERTY(int count READ rowCount NOTIFY countChanged)
    Q_PROPERTY(QUuid thingId READ thingId WRITE setThingId NOTIFY thingIdChanged)
    Q_PROPERTY(QStringList typeIds READ typeIds WRITE setTypeIds NOTIFY typeIdsChanged)
    Q_PROPERTY(QDateTime startTime READ startTime WRITE setStartTime NOTIFY startTimeChanged)
    Q_PROPERTY(QDateTime endTime READ endTime WRITE setEndTime NOTIFY endTimeChanged)
    Q_PROPERTY(QVariant minValue READ minValue NOTIFY minValueChanged)
    Q_PROPERTY(QVariant maxValue READ maxValue NOTIFY maxValueChanged)

    Q_PROPERTY(QtCharts::QXYSeries *graphSeries READ graphSeries WRITE setGraphSeries NOTIFY graphSeriesChanged)
    Q_PROPERTY(QDateTime viewStartTime READ viewStartTime WRITE setViewStartTime NOTIFY viewStartTimeChanged)

public:
    enum Roles {
        RoleTimestamp,
        RoleValue,
        RoleThingId,
        RoleTypeId,
        RoleSource,
        RoleLoggingEventType
    };

    explicit LogsModelNg(QObject *parent = nullptr);

    Engine *engine() const;
    void setEngine(Engine* jsonRpcClient);

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role) const override;
    QHash<int, QByteArray> roleNames() const override;
    void classBegin() override;
    void componentComplete() override;

    bool busy() const;

    bool live() const;
    void setLive(bool live);

    QUuid thingId() const;
    void setThingId(const QUuid &thingId);

    QStringList typeIds() const;
    void setTypeIds(const QStringList &typeId);

    QDateTime startTime() const;
    void setStartTime(const QDateTime &startTime);

    QDateTime endTime() const;
    void setEndTime(const QDateTime &endTime);

    QtCharts::QXYSeries *graphSeries() const;
    void setGraphSeries(QtCharts::QXYSeries *lineSeries);

    QDateTime viewStartTime() const;
    void setViewStartTime(const QDateTime &viewStartTime);

    QVariant minValue() const;
    QVariant maxValue() const;

    Q_INVOKABLE LogEntry *get(int index) const;
    Q_INVOKABLE LogEntry *findClosest(const QDateTime &dateTime) const;

protected:
    virtual void fetchMore(const QModelIndex &parent = QModelIndex()) override;
    virtual bool canFetchMore(const QModelIndex &parent = QModelIndex()) const override;

signals:
    void busyChanged();
    void liveChanged();
    void thingIdChanged();
    void typeIdsChanged();
    void countChanged();
    void startTimeChanged();
    void endTimeChanged();
    void engineChanged();
    void graphSeriesChanged();
    void viewStartTimeChanged();
    void minValueChanged();
    void maxValueChanged();

private slots:
    void newLogEntryReceived(const QVariantMap &data);
    void logsReply(int commandId, const QVariantMap &data);

private:
    QList<LogEntry*> m_list;

    Engine *m_engine = nullptr;
    bool m_busy = false;
    bool m_live = false;
    QUuid m_thingId;
    QList<QUuid> m_typeIds;
    QDateTime m_startTime;
    QDateTime m_endTime;
    int m_blockSize = 1000;
    bool m_canFetchMore = true;
    QDateTime m_viewStartTime;
    QVariant m_minValue;
    QVariant m_maxValue;
    bool m_ready = false;

    QtCharts::QXYSeries *m_graphSeries = nullptr;

    QList<QPair<QDateTime, bool> > m_fetchedPeriods;
};


#endif // LOGSMODELNG_H
