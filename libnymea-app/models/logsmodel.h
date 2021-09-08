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

#ifndef LOGSMODEL_H
#define LOGSMODEL_H

#include <QAbstractListModel>
#include <QQmlParserStatus>

#include "types/logentry.h"

#include <QLoggingCategory>
Q_DECLARE_LOGGING_CATEGORY(dcLogEngine)

class Engine;

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

    bool m_busy = false;
    bool m_live = false;
    int m_blockSize = 1000;

    bool m_busyInternal = false;

    bool m_canFetchMore = true;

    int m_generatedEntries = 0;

};

#endif // LOGSMODEL_H
