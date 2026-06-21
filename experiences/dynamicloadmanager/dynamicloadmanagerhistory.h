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

#ifndef DYNAMICLOADMANAGERHISTORY_H
#define DYNAMICLOADMANAGERHISTORY_H

#include <QAbstractListModel>
#include <QDateTime>
#include <QQmlParserStatus>
#include <QTimer>
#include <QVector>

#include "dynamicloadmanagermanager.h"

// Per-node time-series of dynamic load manager history samples (DynamicLoadManager.GetNodeHistory).
class DynamicLoadManagerHistory : public QAbstractListModel, public QQmlParserStatus
{
    Q_OBJECT
    Q_INTERFACES(QQmlParserStatus)
    Q_PROPERTY(DynamicLoadManagerManager *manager READ manager WRITE setManager NOTIFY managerChanged)
    Q_PROPERTY(QString nodeId READ nodeId WRITE setNodeId NOTIFY nodeIdChanged)
    Q_PROPERTY(QDateTime from READ from WRITE setFrom NOTIFY fromChanged)
    Q_PROPERTY(QDateTime to READ to WRITE setTo NOTIFY toChanged)
    Q_PROPERTY(SampleRate sampleRate READ sampleRate WRITE setSampleRate NOTIFY sampleRateChanged)
    Q_PROPERTY(bool includeCurrent READ includeCurrent WRITE setIncludeCurrent NOTIFY includeCurrentChanged)
    Q_PROPERTY(bool live READ live WRITE setLive NOTIFY liveChanged)
    Q_PROPERTY(bool busy READ busy NOTIFY busyChanged)
    Q_PROPERTY(int count READ rowCount NOTIFY countChanged)
    Q_PROPERTY(double minValue READ minValue NOTIFY rangeChanged)
    Q_PROPERTY(double maxValue READ maxValue NOTIFY rangeChanged)

public:
    // Mirrors DynamicLoadManagerHistoryLogger::SampleRate on the backend. Values are minutes.
    enum SampleRate {
        SampleRateAny = 0,
        SampleRate1Min = 1,
        SampleRate15Mins = 15,
        SampleRate1Hour = 60,
        SampleRate1Day = 1440
    };
    Q_ENUM(SampleRate)

    enum Roles {
        TimestampRole = Qt::UserRole + 1,
        NodeTypeRole,
        SampleRateRole,
        MeasuredLoadL1Role,
        MeasuredLoadL2Role,
        MeasuredLoadL3Role,
        AllocationL1Role,
        AllocationL2Role,
        AllocationL3Role,
        EffectiveLimitL1Role,
        EffectiveLimitL2Role,
        EffectiveLimitL3Role,
        ReserveL1Role,
        ReserveL2Role,
        ReserveL3Role,
        SumOfChildrenL1Role,
        SumOfChildrenL2Role,
        SumOfChildrenL3Role,
        FaultedRole,
        InputFreshRole
    };
    Q_ENUM(Roles)

    explicit DynamicLoadManagerHistory(QObject *parent = nullptr);

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

    SampleRate sampleRate() const;
    void setSampleRate(SampleRate sampleRate);

    bool includeCurrent() const;
    void setIncludeCurrent(bool includeCurrent);

    bool live() const;
    void setLive(bool live);

    bool busy() const;

    double minValue() const;
    double maxValue() const;

    Q_INVOKABLE QVariantMap get(int index) const;
    Q_INVOKABLE void refresh();

    void classBegin() override;
    void componentComplete() override;

signals:
    void managerChanged();
    void nodeIdChanged();
    void fromChanged();
    void toChanged();
    void sampleRateChanged();
    void includeCurrentChanged();
    void liveChanged();
    void busyChanged();
    void countChanged();
    void rangeChanged();

private slots:
    void historyReply(int commandId, const QVariantMap &params);
    void nodeHistoryEntryAdded(const QVariantMap &entry);

private:
    struct Sample {
        QDateTime timestamp;
        QString nodeType;
        int sampleRate = 0;
        double measuredLoad[3] = {0, 0, 0};
        double allocation[3] = {0, 0, 0};
        double effectiveLimit[3] = {0, 0, 0};
        double reserve[3] = {0, 0, 0};
        double sumOfChildren[3] = {0, 0, 0};
        bool faulted = false;
        bool inputFresh = true;
    };

    static Sample parseSample(const QVariantMap &map);
    void recomputeRange();
    void scheduleRefresh();
    void connectManager();

    DynamicLoadManagerManager *m_manager = nullptr;
    QString m_nodeId;
    QDateTime m_from;
    QDateTime m_to;
    SampleRate m_sampleRate = SampleRate1Min;
    bool m_includeCurrent = false;
    bool m_live = false;
    bool m_busy = false;
    bool m_componentComplete = false;

    QVector<Sample> m_samples;
    double m_minValue = 0;
    double m_maxValue = 0;
    QTimer m_refreshTimer;
};

#endif // DYNAMICLOADMANAGERHISTORY_H
