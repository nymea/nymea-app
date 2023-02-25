#include "airconditioningmanager.h"
#include "zoneinfo.h"

#include "engine.h"

#include <QJsonDocument>
#include <QMetaEnum>

#include "logging.h"

NYMEA_LOGGING_CATEGORY(dcAirConditioningExperience, "AirConditioningExperience")

AirConditioningManager::AirConditioningManager(QObject *parent)
    : QObject{parent},
      m_zoneInfos(new ZoneInfos(this))
{
    qRegisterMetaType<ZoneInfo::SetpointOverrideMode>();
}

AirConditioningManager::~AirConditioningManager()
{
    if (m_engine) {
        m_engine->jsonRpcClient()->unregisterNotificationHandler(this);
    }
}

Engine *AirConditioningManager::engine() const
{
    return m_engine;
}

void AirConditioningManager::setEngine(Engine *engine)
{
    if (m_engine != engine) {
        if (m_engine) {
            m_engine->jsonRpcClient()->unregisterNotificationHandler(this);
        }

        m_engine = engine;
        emit engineChanged();

        if (m_engine) {
            connect(engine, &Engine::destroyed, this, [engine, this]{ if (m_engine == engine) m_engine = nullptr; });
            m_engine->jsonRpcClient()->registerNotificationHandler(this, "AirConditioning", "notificationReceived");
            m_engine->jsonRpcClient()->sendCommand("AirConditioning.GetZones", QVariantMap(), this, "getZonesResponse");
        }
    }
}

ZoneInfos *AirConditioningManager::zoneInfos() const
{
    return m_zoneInfos;
}

int AirConditioningManager::addZone(const QString &name, const QList<QUuid> &thermostats, const QList<QUuid> &windowSensors, const QList<QUuid> &indoorSensors, const QList<QUuid> &outdoorSensors)
{
    QVariantList thermostatIds, windowSensorIds, indoorSensorIds, outdoorSensorIds;
    foreach (const QUuid &id, thermostats) {
        thermostatIds.append(id);
    }
    foreach (const QUuid &id, windowSensors) {
        windowSensorIds.append(id);
    }
    foreach (const QUuid &id, indoorSensors) {
        indoorSensorIds.append(id);
    }
    foreach (const QUuid &id, outdoorSensors) {
        outdoorSensorIds.append(id);
    }
    QVariantMap params = {
        {"name", name},
        {"thermostats", thermostatIds},
        {"windowSensors", windowSensorIds},
        {"indoorSensors", indoorSensorIds},
        {"outdoorSensors", outdoorSensorIds}
    };
    return m_engine->jsonRpcClient()->sendCommand("AirConditioning.AddZone", params, this, "addZoneResponse");
}

int AirConditioningManager::removeZone(const QUuid &zoneId)
{
    return m_engine->jsonRpcClient()->sendCommand("AirConditioning.RemoveZone", {{"zoneId", zoneId}}, this, "removeZoneResponse");
}

int AirConditioningManager::setZoneName(const QUuid &zoneId, const QString &name)
{
    QVariantMap params = {
        {"zoneId", zoneId},
        {"name", name}
    };
    return m_engine->jsonRpcClient()->sendCommand("AirConditioning.SetZoneName", params, this, "setZoneNameResponse");
}

int AirConditioningManager::setZoneStandbySetpoint(const QUuid &zoneId, double standbySetpoint)
{
    QVariantMap params = {
        {"zoneId", zoneId},
        {"standbySetpoint", standbySetpoint}
    };
    return m_engine->jsonRpcClient()->sendCommand("AirConditioning.SetZoneStandbySetpoint", params, this, "setZoneStandbySetpointResponse");
}

int AirConditioningManager::setZoneSetpointOverride(const QUuid &zoneId, double setpointOverride, ZoneInfo::SetpointOverrideMode mode, uint minutes)
{
    QMetaEnum modeEnum = QMetaEnum::fromType<ZoneInfo::SetpointOverrideMode>();
    QVariantMap params = {
        {"zoneId", zoneId},
        {"setpointOverride", setpointOverride},
        {"mode", modeEnum.valueToKey(mode)},
        {"minutes", minutes}
    };
    return m_engine->jsonRpcClient()->sendCommand("AirConditioning.SetZoneSetpointOverride", params, this, "setZoneSetpointOverrideResponse");
}

int AirConditioningManager::setZoneWeekSchedule(const QUuid &zoneId, TemperatureWeekSchedule *weekSchedule)
{
    QVariantList weekList;
    for (int day = 0; day < 7; day++) {
        TemperatureDaySchedule *daySchedule = weekSchedule->get(day);
        QVariantList dayList;
        for (int i = 0; i < daySchedule->rowCount(); i++) {
            TemperatureSchedule *schedule = daySchedule->get(i);
            QVariantMap v = {
                {"startTime", schedule->startTime().toString("hh:mm")},
                {"endTime", schedule->endTime().toString("hh:mm")},
                {"temperature", schedule->temperature()}
            };
            dayList.append(v);
        }
        weekList.append(QVariant::fromValue(dayList));
    }
    QVariantMap params = {
        {"zoneId", zoneId},
        {"weekSchedule", weekList}
    };
    return m_engine->jsonRpcClient()->sendCommand("AirConditioning.SetZoneWeekSchedule", params, this, "setZoneWeekScheduleResponse");
}

int AirConditioningManager::setZoneThings(const QUuid &zoneId, const QList<QUuid> &thermostats, const QList<QUuid> &windowSensors, const QList<QUuid> &indoorSensors, const QList<QUuid> &outdoorSensors, const QList<QUuid> &notifications)
{
    QVariantList thermostatIds, windowSensorIds, indoorSensorIds, outdoorSensorIds, notificationIds;
    foreach (const QUuid &thingId, thermostats) {
        thermostatIds.append(thingId);
    }
    foreach (const QUuid &thingId, windowSensors) {
        windowSensorIds.append(thingId);
    }
    foreach (const QUuid &thingId, indoorSensors) {
        indoorSensorIds.append(thingId);
    }
    foreach (const QUuid &thingId, outdoorSensors) {
        outdoorSensorIds.append(thingId);
    }
    foreach (const QUuid &thingId, notifications) {
        notificationIds.append(thingId);
    }
    QVariantMap params = {
        {"zoneId", zoneId},
        {"thermostats", thermostatIds},
        {"windowSensors", windowSensorIds},
        {"indoorSensors", indoorSensorIds},
        {"outdoorSensors", outdoorSensorIds},
        {"notifications", notificationIds},
    };
    return m_engine->jsonRpcClient()->sendCommand("AirConditioning.SetZoneThings", params, this, "setZoneThingsResponse");
}

int AirConditioningManager::addZoneThermostat(const QUuid &zoneId, const QUuid &thermostat)
{
    ZoneInfo *zoneInfo = m_zoneInfos->getZoneInfo(zoneId);
    if (!zoneInfo) {
        return -1;
    }
    return setZoneThings(zoneId, zoneInfo->thermostats() << thermostat, zoneInfo->windowSensors(), zoneInfo->indoorSensors(), zoneInfo->outdoorSensors(), zoneInfo->notifications());
}

int AirConditioningManager::removeZoneThermostat(const QUuid &zoneId, const QUuid &thermostat)
{
    ZoneInfo *zoneInfo = m_zoneInfos->getZoneInfo(zoneId);
    if (!zoneInfo) {
        return -1;
    }
    QList<QUuid> thermostats = zoneInfo->thermostats();
    thermostats.removeAll(thermostat);
    return setZoneThings(zoneId, thermostats, zoneInfo->windowSensors(), zoneInfo->indoorSensors(), zoneInfo->outdoorSensors(), zoneInfo->notifications());
}

int AirConditioningManager::addZoneWindowSensor(const QUuid &zoneId, const QUuid &windowSensor)
{
    ZoneInfo *zoneInfo = m_zoneInfos->getZoneInfo(zoneId);
    if (!zoneInfo) {
        return -1;
    }
    return setZoneThings(zoneId, zoneInfo->thermostats(), zoneInfo->windowSensors() << windowSensor, zoneInfo->indoorSensors(), zoneInfo->outdoorSensors(), zoneInfo->notifications());
}

int AirConditioningManager::removeWindowSensor(const QUuid &zoneId, const QUuid &windowSensor)
{
    ZoneInfo *zoneInfo = m_zoneInfos->getZoneInfo(zoneId);
    if (!zoneInfo) {
        return -1;
    }
    QList<QUuid> windowSensors = zoneInfo->windowSensors();
    windowSensors.removeAll(windowSensor);
    return setZoneThings(zoneId, zoneInfo->thermostats(), windowSensors, zoneInfo->indoorSensors(), zoneInfo->outdoorSensors(), zoneInfo->notifications());
}

int AirConditioningManager::addZoneIndoorSensor(const QUuid &zoneId, const QUuid &indoorSensor)
{
    ZoneInfo *zoneInfo = m_zoneInfos->getZoneInfo(zoneId);
    if (!zoneInfo) {
        return -1;
    }
    return setZoneThings(zoneId, zoneInfo->thermostats(), zoneInfo->windowSensors(), zoneInfo->indoorSensors() << indoorSensor, zoneInfo->outdoorSensors(), zoneInfo->notifications());
}

int AirConditioningManager::removeZoneIndoorSensor(const QUuid &zoneId, const QUuid &indoorSensor)
{
    ZoneInfo *zoneInfo = m_zoneInfos->getZoneInfo(zoneId);
    if (!zoneInfo) {
        return -1;
    }
    QList<QUuid> indoorSensors = zoneInfo->indoorSensors();
    indoorSensors.removeAll(indoorSensor);
    return setZoneThings(zoneId, zoneInfo->thermostats(), zoneInfo->windowSensors(), indoorSensors, zoneInfo->outdoorSensors(), zoneInfo->notifications());

}

int AirConditioningManager::addZoneOutdoorSensor(const QUuid &zoneId, const QUuid &outdoorSensor)
{
    ZoneInfo *zoneInfo = m_zoneInfos->getZoneInfo(zoneId);
    if (!zoneInfo) {
        return -1;
    }
    return setZoneThings(zoneId, zoneInfo->thermostats(), zoneInfo->windowSensors(), zoneInfo->indoorSensors(), zoneInfo->outdoorSensors() << outdoorSensor, zoneInfo->notifications());
}

int AirConditioningManager::removeZoneOutdoorSensor(const QUuid &zoneId, const QUuid &outdoorSensor)
{
    ZoneInfo *zoneInfo = m_zoneInfos->getZoneInfo(zoneId);
    if (!zoneInfo) {
        return -1;
    }
    QList<QUuid> outdoorSensors = zoneInfo->outdoorSensors();
    outdoorSensors.removeAll(outdoorSensor);
    return setZoneThings(zoneId, zoneInfo->thermostats(), zoneInfo->windowSensors(), zoneInfo->indoorSensors(), outdoorSensors, zoneInfo->notifications());
}

int AirConditioningManager::addZoneNotification(const QUuid &zoneId, const QUuid &notification)
{
    ZoneInfo *zoneInfo = m_zoneInfos->getZoneInfo(zoneId);
    if (!zoneInfo) {
        return -1;
    }
    return setZoneThings(zoneId, zoneInfo->thermostats(), zoneInfo->windowSensors(), zoneInfo->indoorSensors(), zoneInfo->outdoorSensors(), zoneInfo->notifications() << notification);
}

int AirConditioningManager::removeZoneNotification(const QUuid &zoneId, const QUuid &notification)
{
    ZoneInfo *zoneInfo = m_zoneInfos->getZoneInfo(zoneId);
    if (!zoneInfo) {
        return -1;
    }
    QList<QUuid> notifications = zoneInfo->notifications();
    notifications.removeAll(notification);
    return setZoneThings(zoneId, zoneInfo->thermostats(), zoneInfo->windowSensors(), zoneInfo->indoorSensors(), zoneInfo->outdoorSensors(), notifications);
}

void AirConditioningManager::notificationReceived(const QVariantMap &data)
{
    QString notification = data.value("notification").toString();
    QVariantMap params = data.value("params").toMap();
    if (notification == "AirConditioning.ZoneAdded") {
        QVariantMap zoneMap = params.value("zone").toMap();
        m_zoneInfos->addZoneInfo(unpack(zoneMap));

    } else if (notification == "AirConditioning.ZoneRemoved") {
        QUuid zoneId = params.value("zoneId").toUuid();
        m_zoneInfos->removeZoneInfo(zoneId);

    } else if (notification == "AirConditioning.ZoneChanged") {
        QVariantMap zoneMap = params.value("zone").toMap();
        qCDebug(dcAirConditioningExperience()) << "Zone changed:" << qUtf8Printable(QJsonDocument::fromVariant(zoneMap).toJson());
        QUuid zoneId = zoneMap.value("id").toUuid();
        ZoneInfo *zone = m_zoneInfos->getZoneInfo(zoneId);
        if (!zone) {
            qCWarning(dcAirConditioningExperience()) << "Received a zone changed notification for a zone we don't know" << zoneId;
            return;
        }
        unpack(zoneMap, zone);
    } else {
        qCDebug(dcAirConditioningExperience()) << "Unhandled notification received" << data;
    }
}

void AirConditioningManager::addZoneResponse(int commandId, const QVariantMap &params)
{
    Q_UNUSED(commandId)
    qCDebug(dcAirConditioningExperience()) << "Add zone response" << qUtf8Printable(QJsonDocument::fromVariant(params).toJson());
    QMetaEnum metaEnum = QMetaEnum::fromType<AirConditioningError>();
    AirConditioningError error = static_cast<AirConditioningError>(metaEnum.keyToValue(params.value("error").toByteArray().data()));
    emit addZoneReply(commandId, error, params.value("zone").toMap().value("id").toUuid());
}

void AirConditioningManager::removeZoneResponse(int commandId, const QVariantMap &params)
{
    qCDebug(dcAirConditioningExperience()) << "remove zone response" << commandId << params;
    QMetaEnum metaEnum = QMetaEnum::fromType<AirConditioningError>();
    AirConditioningError error = static_cast<AirConditioningError>(metaEnum.keyToValue(params.value("error").toByteArray().data()));
    emit removeZoneReply(commandId, error);
}

void AirConditioningManager::getZonesResponse(int commandId, const QVariantMap &params)
{
    Q_UNUSED(commandId)
    qCDebug(dcAirConditioningExperience()) << "get zones response:" << qUtf8Printable(QJsonDocument::fromVariant(params).toJson());

    foreach (const QVariant &zoneVariant, params.value("zones").toList()) {
        m_zoneInfos->addZoneInfo(unpack(zoneVariant.toMap()));
    }
}

void AirConditioningManager::setZoneNameResponse(int commandId, const QVariantMap &params)
{
    qCDebug(dcAirConditioningExperience()) << "set zone name response" << commandId << params;
    QMetaEnum metaEnum = QMetaEnum::fromType<AirConditioningError>();
    AirConditioningError error = static_cast<AirConditioningError>(metaEnum.keyToValue(params.value("error").toByteArray().data()));
    emit setZoneNameReply(commandId, error);
}

void AirConditioningManager::setZoneStandbySetpointResponse(int commandId, const QVariantMap &params)
{
    QMetaEnum metaEnum = QMetaEnum::fromType<AirConditioningError>();
    AirConditioningError error = static_cast<AirConditioningError>(metaEnum.keyToValue(params.value("error").toByteArray().data()));
    emit setZoneStandbySetpointReply(commandId, error);
}

void AirConditioningManager::setZoneSetpointOverrideResponse(int commandId, const QVariantMap &params)
{
    QMetaEnum metaEnum = QMetaEnum::fromType<AirConditioningError>();
    AirConditioningError error = static_cast<AirConditioningError>(metaEnum.keyToValue(params.value("error").toByteArray().data()));
    emit setZoneSetpointOverrideReply(commandId, error);

}

void AirConditioningManager::setZoneWeekScheduleResponse(int commandId, const QVariantMap &params)
{
    qCDebug(dcAirConditioningExperience()) << "set zone week schedule response" << commandId << params;
    QMetaEnum metaEnum = QMetaEnum::fromType<AirConditioningError>();
    AirConditioningError error = static_cast<AirConditioningError>(metaEnum.keyToValue(params.value("error").toByteArray().data()));
    emit setZoneWeekScheduleReply(commandId, error);

}

void AirConditioningManager::setZoneThingsResponse(int commandId, const QVariantMap &params)
{
    qCDebug(dcAirConditioningExperience()) << "set zone things response" << commandId << params;
    QMetaEnum metaEnum = QMetaEnum::fromType<AirConditioningError>();
    AirConditioningError error = static_cast<AirConditioningError>(metaEnum.keyToValue(params.value("error").toByteArray().data()));
    emit setZoneThingsReply(commandId, error);
}

ZoneInfo *AirConditioningManager::unpack(const QVariantMap &zoneMap, ZoneInfo *zone)
{
    QUuid id = zoneMap.value("id").toUuid();

    if (!zone) {
        zone = new ZoneInfo(id);
    }
    zone->setName(zoneMap.value("name").toString());

    QMetaEnum zoneStatusEnum = QMetaEnum::fromType<ZoneInfo::ZoneStatus>();
    ZoneInfo::ZoneStatus zoneStatus = ZoneInfo::ZoneStatusFlagNone;
    foreach (const QVariant &flag, zoneMap.value("zoneStatus").toList()) {
        zoneStatus.setFlag(static_cast<ZoneInfo::ZoneStatusFlag>(zoneStatusEnum.keyToValue(flag.toByteArray())), true);
    }
    qCDebug(dcAirConditioningExperience()) << "Zone status:" << zoneStatus;
    zone->setZoneStatus(zoneStatus);
    zone->setTemperature(zoneMap.value("temperature").toDouble());
    zone->setHumidity(zoneMap.value("humidity").toDouble());
    zone->setVoc(zoneMap.value("voc").toUInt());
    zone->setPm25(zoneMap.value("pm25").toDouble());
    zone->setCurrentSetpoint(zoneMap.value("currentSetpoint").toDouble());
    zone->setStandbySetpoint(zoneMap.value("standbySetpoint").toDouble());
    QMetaEnum modeEnum = QMetaEnum::fromType<ZoneInfo::SetpointOverrideMode>();
    ZoneInfo::SetpointOverrideMode mode = static_cast<ZoneInfo::SetpointOverrideMode>(modeEnum.keyToValue(zoneMap.value("setpointOverrideMode").toByteArray()));
    QDateTime end = QDateTime::fromSecsSinceEpoch(zoneMap.value("setpointOverrideEnd").toULongLong());
    zone->setSetpointOverride(zoneMap.value("setpointOverride").toDouble(), mode, end);

    QVariantList weekScheduleList = zoneMap.value("weekSchedule").toList();
    for (int day = 0; day < qMin(7, weekScheduleList.count()); day++) {
        QVariant dayVariant = weekScheduleList.at(day);
        zone->weekSchedule()->get(day)->clear();
        foreach (const QVariant &scheduleVariant, dayVariant.toList()) {
            QVariantMap scheduleMap = scheduleVariant.toMap();
            zone->weekSchedule()->get(day)->createSchedule(scheduleMap.value("startTime").toTime(), scheduleMap.value("endTime").toTime(), scheduleMap.value("temperature").toDouble());
        }
    }
    QList<QUuid> thermostats, windowSensors, indoorSensors, outdoorSensors, notifications;
    foreach (const QVariant &variant, zoneMap.value("thermostats").toList()) {
        thermostats.append(variant.toUuid());
    }
    foreach (const QVariant &variant, zoneMap.value("windowSensors").toList()) {
        windowSensors.append(variant.toUuid());
    }
    foreach (const QVariant &variant, zoneMap.value("indoorSensors").toList()) {
        indoorSensors.append(variant.toUuid());
    }
    foreach (const QVariant &variant, zoneMap.value("outdoorSensors").toList()) {
        outdoorSensors.append(variant.toUuid());
    }
    foreach (const QVariant &variant, zoneMap.value("notifications").toList()) {
        notifications.append(variant.toUuid());
    }
    zone->setThermostats(thermostats);
    zone->setWindowSensors(windowSensors);
    zone->setIndoorSensors(indoorSensors);
    zone->setOutdoorSensors(outdoorSensors);
    zone->setNotifications(notifications);
    return zone;
}
