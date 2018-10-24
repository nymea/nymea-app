#ifndef LOGSMODEL_H
#define LOGSMODEL_H

#include <QAbstractListModel>

#include "jsonrpc/jsonhandler.h"
#include "types/logentry.h"

class Engine;

class LogsModel : public QAbstractListModel
{
    Q_OBJECT
    Q_PROPERTY(Engine* engine READ engine WRITE setEngine NOTIFY engineChanged)

    Q_PROPERTY(bool busy READ busy NOTIFY busyChanged)
    Q_PROPERTY(int count READ rowCount NOTIFY countChanged)
    Q_PROPERTY(QString deviceId READ deviceId WRITE setDeviceId NOTIFY deviceIdChanged)
    Q_PROPERTY(QStringList typeIds READ typeIds WRITE setTypeIds NOTIFY typeIdsChanged)
    Q_PROPERTY(QDateTime startTime READ startTime WRITE setStartTime NOTIFY startTimeChanged)
    Q_PROPERTY(QDateTime endTime READ endTime WRITE setEndTime NOTIFY endTimeChanged)
//    Q_PROPERTY(int paginationCount READ paginationCount WRITE setPaginationCount NOTIFY paginationCountChanged)

    Q_PROPERTY(bool live READ live WRITE setLive NOTIFY liveChanged)

public:
    enum Roles {
        RoleTimestamp,
        RoleValue,
        RoleDeviceId,
        RoleTypeId,
        RoleSource,
        RoleLoggingEventType
    };
    explicit LogsModel(QObject *parent = nullptr);

    Engine* engine() const;
    void setEngine(Engine* engine);

    bool busy() const;
    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role) const override;
    QHash<int, QByteArray> roleNames() const override;

    bool live() const;
    void setLive(bool live);

    QString deviceId() const;
    void setDeviceId(const QString &deviceId);

    QStringList typeIds() const;
    void setTypeIds(const QStringList &typeIds);

    QDateTime startTime() const;
    void setStartTime(const QDateTime &startTime);

    QDateTime endTime() const;
    void setEndTime(const QDateTime &endTime);

//    int paginationCount() const;
//    void setPaginationCount(int paginationCount);

    Q_INVOKABLE LogEntry* get(int index) const;

    Q_INVOKABLE void notificationReceived(const QVariantMap &data);

signals:
    void engineChanged();
    void busyChanged();
    void liveChanged();
    void countChanged();
    void deviceIdChanged();
    void typeIdsChanged();
    void startTimeChanged();
    void endTimeChanged();
//    void paginationCountChanged();

public slots:
    virtual void update();
    virtual void fetchEarlier(int hours);
//    virtual void fetchLater(int hours);

private slots:
    virtual void logsReply(const QVariantMap &data);
    virtual void fetchEarlierReply(const QVariantMap &data);
    void newLogEntryReceived(const QVariantMap &data);

protected:
    Engine *m_engine = nullptr;
    QList<LogEntry*> m_list;
    QString m_deviceId;
    QStringList m_typeIds;
    QDateTime m_startTime = QDateTime::currentDateTime().addDays(-1);
    QDateTime m_endTime = QDateTime::currentDateTime();

    bool m_busy = false;
    bool m_live = false;

};

#endif // LOGSMODEL_H
