/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
*
* Copyright 2013 - 2020, nymea GmbH
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

#ifndef LOGSMODELNG_H
#define LOGSMODELNG_H

#include <QObject>
#include <QAbstractListModel>
#include <QDateTime>
#include <QLineSeries>
#include <QUuid>

class LogEntry;
class Engine;

class LogsModelNg : public QAbstractListModel
{
    Q_OBJECT
    Q_PROPERTY(Engine* engine READ engine WRITE setEngine NOTIFY engineChanged)
    Q_PROPERTY(bool busy READ busy NOTIFY busyChanged)
    Q_PROPERTY(bool live READ live WRITE setLive NOTIFY liveChanged)
    Q_PROPERTY(int count READ rowCount NOTIFY countChanged)
    Q_PROPERTY(QUuid deviceId READ deviceId WRITE setDeviceId NOTIFY deviceIdChanged)
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
        RoleDeviceId,
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

    bool busy() const;

    bool live() const;
    void setLive(bool live);

    QUuid deviceId() const;
    void setDeviceId(const QUuid &deviceId);

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

protected:
    virtual void fetchMore(const QModelIndex &parent = QModelIndex()) override;
    virtual bool canFetchMore(const QModelIndex &parent = QModelIndex()) const override;

signals:
    void busyChanged();
    void liveChanged();
    void deviceIdChanged();
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
    void logsReply(const QVariantMap &data);

private:
    QList<LogEntry*> m_list;

    Engine *m_engine = nullptr;
    bool m_busy = false;
    bool m_live = false;
    QUuid m_deviceId;
    QList<QUuid> m_typeIds;
    QDateTime m_startTime;
    QDateTime m_endTime;
    int m_blockSize = 100;
    bool m_canFetchMore = true;
    QDateTime m_viewStartTime;
    QVariant m_minValue;
    QVariant m_maxValue;

    QtCharts::QXYSeries *m_graphSeries = nullptr;

    QList<QPair<QDateTime, bool> > m_fetchedPeriods;
};


#endif // LOGSMODELNG_H
