#ifndef AIRCONDITIONINGMANAGER_H
#define AIRCONDITIONINGMANAGER_H

#include <QObject>

#include "zoneinfo.h"

class Engine;

class AirConditioningManager : public QObject
{
    Q_OBJECT
    Q_PROPERTY(Engine* engine READ engine WRITE setEngine NOTIFY engineChanged)
    Q_PROPERTY(ZoneInfos* zoneInfos READ zoneInfos CONSTANT)

public:
    enum AirConditioningError {
        AirConditioningErrorNoError,
        AirConditioningErrorZoneNotFound,
        AirConditioningErrorInvalidTimeSpec,
        AirConditioningErrorThingNotFound,
        AirConditioningErrorInvalidThingType
    };
    Q_ENUM(AirConditioningError)

    explicit AirConditioningManager(QObject *parent = nullptr);
    ~AirConditioningManager();

    Engine* engine() const;
    void setEngine(Engine *engine);

    ZoneInfos *zoneInfos() const;

    Q_INVOKABLE int addZone(const QString &name, const QList<QUuid> &thermostats, const QList<QUuid> &windowSensors, const QList<QUuid> &indoorSensors, const QList<QUuid> &outdoorSensors);
    Q_INVOKABLE int removeZone(const QUuid &zoneId);
    Q_INVOKABLE int setZoneName(const QUuid &zoneId, const QString &name);
    Q_INVOKABLE int setZoneStandbySetpoint(const QUuid &zoneId, double standbySetpoint);
    Q_INVOKABLE int setZoneSetpointOverride(const QUuid &zoneId, double setpointOverride, ZoneInfo::SetpointOverrideMode mode, uint minutes);
    Q_INVOKABLE int setZoneWeekSchedule(const QUuid &zoneId, TemperatureWeekSchedule *weekSchedule);
    Q_INVOKABLE int setZoneThings(const QUuid &zoneId, const QList<QUuid> &thermostats, const QList<QUuid> &windowSensors, const QList<QUuid> &indoorSensors, const QList<QUuid> &outdoorSensors, const QList<QUuid> &notificationIds);

    Q_INVOKABLE int addZoneThermostat(const QUuid &zoneId, const QUuid &thermostat);
    Q_INVOKABLE int removeZoneThermostat(const QUuid &zoneId, const QUuid &thermostat);
    Q_INVOKABLE int addZoneWindowSensor(const QUuid &zoneId, const QUuid &windowSensor);
    Q_INVOKABLE int removeZoneWindowSensor(const QUuid &zoneId, const QUuid &windowSensor);
    Q_INVOKABLE int addZoneIndoorSensor(const QUuid &zoneId, const QUuid &indoorSensor);
    Q_INVOKABLE int removeZoneIndoorSensor(const QUuid &zoneId, const QUuid &indoorSensor);
    Q_INVOKABLE int addZoneOutdoorSensor(const QUuid &zoneId, const QUuid &outdoorSensor);
    Q_INVOKABLE int removeZoneOutdoorSensor(const QUuid &zoneId, const QUuid &outdoorSensor);
    Q_INVOKABLE int addZoneNotification(const QUuid &zoneId, const QUuid &notification);
    Q_INVOKABLE int removeZoneNotification(const QUuid &zoneId, const QUuid &notification);

signals:
    void engineChanged();
    void addZoneReply(int commandId, AirConditioningError error, const QUuid &zoneId);
    void removeZoneReply(int commandId, AirConditioningError error);
    void setZoneNameReply(int commandId, AirConditioningError error);
    void setZoneStandbySetpointReply(int commandId, AirConditioningError error);
    void setZoneSetpointOverrideReply(int commandId, AirConditioningError error);
    void setZoneThingsReply(int commandId, AirConditioningError error);
    void setZoneWeekScheduleReply(int commandId, AirConditioningError error);

private slots:
    void notificationReceived(const QVariantMap &data);

    void addZoneResponse(int commandId, const QVariantMap &params);
    void removeZoneResponse(int commandId, const QVariantMap &params);
    void getZonesResponse(int commandId, const QVariantMap &params);
    void setZoneNameResponse(int commandId, const QVariantMap &params);
    void setZoneStandbySetpointResponse(int commandId, const QVariantMap &params);
    void setZoneSetpointOverrideResponse(int commandId, const QVariantMap &params);
    void setZoneWeekScheduleResponse(int commandId, const QVariantMap &params);
    void setZoneThingsResponse(int commandId, const QVariantMap &params);

private:
    ZoneInfo *unpack(const QVariantMap &zoneMap, ZoneInfo *zone = nullptr);

private:
    Engine *m_engine = nullptr;
    ZoneInfos *m_zoneInfos = nullptr;
};

#endif // AIRCONDITIONINGMANAGER_H
