#ifndef NEWLOGSMODEL_H
#define NEWLOGSMODEL_H

#include <QObject>
#include <QQmlParserStatus>
#include <QAbstractListModel>

#include "engine.h"
#include "newlogentry.h"

class NewLogsModel : public QAbstractListModel, public QQmlParserStatus
{
    Q_OBJECT
    Q_INTERFACES(QQmlParserStatus)
    Q_PROPERTY(Engine* engine READ engine WRITE setEngine NOTIFY engineChanged)
    Q_PROPERTY(QString source READ source WRITE setSource NOTIFY sourcesChanged)
    Q_PROPERTY(QStringList sources READ sources WRITE setSources NOTIFY sourcesChanged)
    Q_PROPERTY(QStringList columns READ columns WRITE setColumns NOTIFY columnsChanged)
    Q_PROPERTY(QVariantMap filter READ filter WRITE setFilter NOTIFY filterChanged)
    Q_PROPERTY(QDateTime startTime READ startTime WRITE setStartTime NOTIFY startTimeChanged)
    Q_PROPERTY(QDateTime endTime READ endTime WRITE setEndTime NOTIFY endTimeChanged)
    Q_PROPERTY(SampleRate sampleRate READ sampleRate WRITE setSampleRate NOTIFY sampleRateChanged)
    Q_PROPERTY(Qt::SortOrder sortOrder READ sortOrder WRITE setSortOrder NOTIFY sortOrderChanged)

    Q_PROPERTY(int fetchBlockSize READ fetchBlockSize WRITE setFetchBlockSize NOTIFY fetchBlockSizeChanged)
    Q_PROPERTY(bool live READ live WRITE setLive NOTIFY liveChanged)

    Q_PROPERTY(int count READ rowCount NOTIFY countChanged)
    Q_PROPERTY(bool busy READ busy NOTIFY busyChanged)

public:
    enum Role {
        RoleSource,
        RoleTimestamp,
        RoleValues
    };
    Q_ENUM(Role)

    enum SampleRate {
        SampleRateAny = 0,
        SampleRate1Min = 1,
        SampleRate15Mins = 15,
        SampleRate1Hour = 60,
        SampleRate3Hours = 180,
        SampleRate1Day = 1440,
        SampleRate1Week = 10080,
        SampleRate1Month = 43200,
        SampleRate1Year = 525600
    };
    Q_ENUM(SampleRate)

    explicit NewLogsModel(QObject *parent = nullptr);

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role) const override;
    QHash<int, QByteArray> roleNames() const override;
    void classBegin() override;
    void componentComplete() override;
    bool canFetchMore(const QModelIndex &parent) const override;
    void fetchMore(const QModelIndex &parent = QModelIndex()) override;

    Engine *engine() const;
    void setEngine(Engine *engine);

    QString source() const;
    void setSource(const QString &source);

    QStringList sources() const;
    void setSources(const QStringList &sources);

    QStringList columns() const;
    void setColumns(const QStringList &columns);

    QVariantMap filter() const;
    void setFilter(const QVariantMap &filter);

    QDateTime startTime() const;
    void setStartTime(const QDateTime &startTime);

    QDateTime endTime() const;
    void setEndTime(const QDateTime &endTime);

    SampleRate sampleRate() const;
    void setSampleRate(SampleRate sampleRate);

    Qt::SortOrder sortOrder() const;
    void setSortOrder(Qt::SortOrder sortOrder);

    bool busy() const;

    bool live() const;
    void setLive(bool live);

    int fetchBlockSize() const;
    void setFetchBlockSize(int fetchBlockSize);

    Q_INVOKABLE NewLogEntry *get(int index) const;
    Q_INVOKABLE NewLogEntry *find(const QDateTime &timestamp) const;

//    bool live() const;
//    void setLive(bool live);

public slots:
    void clear();
    void fetchLogs();

signals:
    void engineChanged();
    void sourcesChanged();
    void columnsChanged();
    void filterChanged();
    void busyChanged();
    void countChanged();
    void startTimeChanged();
    void endTimeChanged();
    void sampleRateChanged();
    void sortOrderChanged();

    void liveChanged();
    void fetchBlockSizeChanged();

    void entriesAdded(int index, const QList<NewLogEntry*> &entries);
    void entriesAddedIdx(int index, int count);
    void entriesRemoved(int index, int count);

private slots:
    void logsReply(int commandId, const QVariantMap &data);
    void newLogEntryReceived(const QVariantMap &map);

private:
    Engine *m_engine = nullptr;
    QStringList m_sources;
    QStringList m_columns;
    QVariantMap m_filter;
    Qt::SortOrder m_sortOrder = Qt::AscendingOrder;

    bool m_busy = false;

    bool m_live = true;

    // For time based sampling
    QDateTime m_startTime;
    QDateTime m_endTime;
    SampleRate m_sampleRate = SampleRateAny;

    // For continuous scrolling lists
    bool m_completed = false;
    bool m_canFetchMore = true;
    int m_blockSize = 50;
    int m_lastOffset = 0;
    QDateTime m_currentNewest;

    QList<NewLogEntry*> m_list;
};

#endif // NEWLOGSMODEL_H
