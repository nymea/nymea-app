#include "airconditioning_plugin.h"

#include "airconditioningmanager.h"
#include "airconditioningmanager.h"
#include "zoneinfo.h"

#include <qqml.h>
#include <QDebug>

void AirconditioningPlugin::registerTypes(const char *uri)
{

    qCritical() << "################# loading plugin";
    // @uri Nymea.AirConditioning
    qmlRegisterType<AirConditioningManager>(uri, 1, 0, "AirConditioningManager");
    qmlRegisterUncreatableType<ZoneInfos>(uri, 1, 0, "ZoneInfos", "Get it from AirConditioningManager");
    qmlRegisterUncreatableType<ZoneInfo>(uri, 1, 0, "ZoneInfo", "Get it from AirConditioningManager");
    qmlRegisterUncreatableType<TemperatureSchedule>(uri, 1, 0, "TemperatureSchedule", "Get it from AirConditioningManager");
    qmlRegisterUncreatableType<TemperatureDaySchedule>(uri, 1, 0, "TemperatureDaySchedule", "Get it from AirConditioningManager");
    qmlRegisterUncreatableType<TemperatureWeekSchedule>(uri, 1, 0, "TemperatureWeekSchedule", "Get it from AirConditioningManager");

}

