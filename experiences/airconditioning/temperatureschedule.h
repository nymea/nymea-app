#ifndef TEMPERATURESCHEDULE_H
#define TEMPERATURESCHEDULE_H

#include <QObject>
#include <QTime>
#include <QAbstractListModel>

class TemperatureSchedule: public QObject
{
    Q_OBJECT
    Q_PROPERTY(QTime startTime READ startTime WRITE setStartTime NOTIFY startTimeChanged)
    Q_PROPERTY(QTime endTime READ endTime WRITE setEndTime NOTIFY endTimeChanged)
    Q_PROPERTY(double temperature READ temperature WRITE setTemperature NOTIFY temperatureChanged)

public:
    explicit TemperatureSchedule(QObject *parent = nullptr);
    ~TemperatureSchedule();

    QTime startTime() const;
    void setStartTime(const QTime &startTime);

    QTime endTime() const;
    void setEndTime(const QTime &endTime);

    double temperature() const;
    void setTemperature(double temperature);

    TemperatureSchedule *clone() const;
signals:
    void startTimeChanged();
    void endTimeChanged();
    void temperatureChanged();

private:
    QTime m_startTime;
    QTime m_endTime;
    double m_temperature = 0;

};

class TemperatureDaySchedule: public QAbstractListModel
{
    Q_OBJECT
    Q_PROPERTY(int count READ rowCount NOTIFY countChanged)
public:
    enum Roles {
        RoleStartTime,
        RoleEndTime,
        RoleTemperature
    };
    TemperatureDaySchedule(QObject *parent = nullptr);
    ~TemperatureDaySchedule();

    int rowCount(const QModelIndex & = QModelIndex()) const override { return m_list.count(); }
    QVariant data(const QModelIndex &index, int role) const override;
    QHash<int, QByteArray> roleNames() const override;

    void addSchedule(TemperatureSchedule *schedule);
    Q_INVOKABLE TemperatureSchedule* get(int index) const;

    Q_INVOKABLE TemperatureDaySchedule *clone() const; // Passes ownership to caller
    Q_INVOKABLE TemperatureSchedule* createSchedule(const QTime &startTime, const QTime &endTime, double temperature);
    Q_INVOKABLE void removeSchedule(TemperatureSchedule *schedule);
    Q_INVOKABLE void clear();
signals:
    void countChanged();

private:
    QList<TemperatureSchedule*> m_list;
};

class TemperatureWeekSchedule: public QAbstractListModel
{
    Q_OBJECT
    Q_PROPERTY(int count READ rowCount CONSTANT)
public:
    TemperatureWeekSchedule(QObject *parent = nullptr);
    ~TemperatureWeekSchedule();

    int rowCount(const QModelIndex & = QModelIndex()) const override { return m_list.count(); }
    QVariant data(const QModelIndex &, int) const override { return QVariant(); }
    QHash<int, QByteArray> roleNames() const override { return QHash<int, QByteArray>(); }

    Q_INVOKABLE TemperatureDaySchedule* get(int index) const;

    Q_INVOKABLE TemperatureWeekSchedule *clone() const; // Passes ownership to caller

private:
    QList<TemperatureDaySchedule*> m_list;
};

#endif // TEMPERATURESCHEDULE_H
