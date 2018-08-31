#ifndef LOGSMODELNG_H
#define LOGSMODELNG_H

#include <QObject>
#include <QAbstractListModel>
#include <QDateTime>

class LogEntry;
class JsonRpcClient;

class LogsModelNg : public QAbstractListModel
{
    Q_OBJECT
    Q_PROPERTY(JsonRpcClient* jsonRpcClient READ jsonRpcClient WRITE setJsonRpcClient NOTIFY jsonRpcClientChanged)
    Q_PROPERTY(bool busy READ busy NOTIFY busyChanged)
    Q_PROPERTY(int count READ rowCount NOTIFY countChanged)
    Q_PROPERTY(QString deviceId READ deviceId WRITE setDeviceId NOTIFY deviceIdChanged)
    Q_PROPERTY(QString typeId READ typeId WRITE setTypeId NOTIFY typeIdChanged)
    Q_PROPERTY(QDateTime startTime READ startTime WRITE setStartTime NOTIFY startTimeChanged)
    Q_PROPERTY(QDateTime endTime READ endTime WRITE setEndTime NOTIFY endTimeChanged)

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

    JsonRpcClient *jsonRpcClient() const;
    void setJsonRpcClient(JsonRpcClient* jsonRpcClient);

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role) const override;
    QHash<int, QByteArray> roleNames() const override;

    bool busy() const;

    bool live() const;
    void setLive(bool live);

    QString deviceId() const;
    void setDeviceId(const QString &deviceId);

    QString typeId() const;
    void setTypeId(const QString &typeId);

    QDateTime startTime() const;
    void setStartTime(const QDateTime &startTime);

    QDateTime endTime() const;
    void setEndTime(const QDateTime &endTime);


signals:
    void busyChanged();
    void liveChanged();
    void deviceIdChanged();
    void typeIdChanged();
    void countChanged();
    void startTimeChanged();
    void endTimeChanged();
    void jsonRpcClientChanged();

private:
    QList<LogEntry*> m_list;

    JsonRpcClient *m_jsonRpcClient = nullptr;
    bool m_busy = false;
    bool m_live = false;
    QString m_deviceId;
    QString m_typeId;
    QDateTime m_startTime;
    QDateTime m_endTime;
    QDateTime m_currentFetchStartTime;
    QDateTime m_currentFetchEndTime;

    QList<QPair<QDateTime, bool> > m_fetchedPeriods;

    void update();
    Q_INVOKABLE void logsReply(const QVariantMap &data);
};


#endif // LOGSMODELNG_H
