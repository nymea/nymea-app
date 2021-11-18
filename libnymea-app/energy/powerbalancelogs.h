#ifndef POWERBALANCELOGS_H
#define POWERBALANCELOGS_H

#include <QObject>
#include <QAbstractListModel>
#include <QDateTime>
#include <QSortFilterProxyModel>

class PowerBalanceLogEntry: public QObject
{
    Q_OBJECT
    Q_PROPERTY(QDateTime timestamp READ timestamp CONSTANT)
    Q_PROPERTY(double consumption READ consumption CONSTANT)
    Q_PROPERTY(double production READ production CONSTANT)
    Q_PROPERTY(double acquisition READ acquisition CONSTANT)
    Q_PROPERTY(double storage READ storage CONSTANT)
public:
    PowerBalanceLogEntry() = default;
    PowerBalanceLogEntry(const QDateTime &timestamp, double consumption, double production, double acquisition, double storage, QObject *parent);

    QDateTime timestamp() const;
    double consumption() const;
    double production() const;
    double acquisition() const;
    double storage() const;
private:
    QDateTime m_timestamp;
    double m_consumption = 0;
    double m_production = 0;
    double m_acquisition = 0;
    double m_storage = 0;
};

class PowerBalanceLogs : public QAbstractListModel
{
    Q_OBJECT
    Q_PROPERTY(int count READ rowCount NOTIFY countChanged)
    Q_PROPERTY(double minValue READ minValue NOTIFY minValueChanged)
    Q_PROPERTY(double maxValue READ maxValue NOTIFY maxValueChanged)
public:
    explicit PowerBalanceLogs(QObject *parent = nullptr);
    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role) const override;
    QHash<int, QByteArray> roleNames() const override;
    double minValue() const;
    double maxValue() const;

    void addEntry(PowerBalanceLogEntry *entry);
signals:
    void countChanged();
    void entryAdded(PowerBalanceLogEntry *entry);
    void minValueChanged();
    void maxValueChanged();
private:
    QList<PowerBalanceLogEntry*> m_list;
    double m_minValue = 0;
    double m_maxValue = 0;
};


class PowerBalanceLogsProxy: public QSortFilterProxyModel
{
    Q_OBJECT
    Q_PROPERTY(PowerBalanceLogs* powerBalanceLogs READ powerBalanceLogs WRITE setPowerBalanceLogs NOTIFY powerBalanceLogsChanged)
    Q_PROPERTY(int count READ rowCount NOTIFY countChanged)


public:
    PowerBalanceLogsProxy(QObject *parent);

    PowerBalanceLogs *powerBalanceLogs() const;
    void setPowerBalanceLogs(PowerBalanceLogs *powerBalanceLogs);

signals:
    void countChanged();
    void powerBalanceLogsChanged();

private:
    PowerBalanceLogs *m_powerBalanceLogs = nullptr;
};

#endif // POWERBALANCELOGS_H
