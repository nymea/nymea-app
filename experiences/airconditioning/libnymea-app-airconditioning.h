#ifndef LIBNYMEAAPPAIRCONDITIONING_H
#define LIBNYMEAAPPAIRCONDITIONING_H

#include "airconditioningmanager.h"
#include "zoneinfo.h"

#include <qqml.h>

namespace Nymea
{
namespace AirConditioning
{

void registerQmlTypes() {

    const char uri[] = "Nymea.AirConditioning";
    // @uri Nymea.AirConditioning
    qmlRegisterType<AirConditioningManager>(uri, 1, 0, "AirConditioningManager");
    qmlRegisterUncreatableType<ZoneInfos>(uri, 1, 0, "ZoneInfos", "Get it from AirConditioningManager");
    qmlRegisterUncreatableType<ZoneInfo>(uri, 1, 0, "ZoneInfo", "Get it from AirConditioningManager");
    qmlRegisterUncreatableType<TemperatureSchedule>(uri, 1, 0, "TemperatureSchedule", "Get it from AirConditioningManager");
    qmlRegisterUncreatableType<TemperatureDaySchedule>(uri, 1, 0, "TemperatureDaySchedule", "Get it from AirConditioningManager");
    qmlRegisterUncreatableType<TemperatureWeekSchedule>(uri, 1, 0, "TemperatureWeekSchedule", "Get it from AirConditioningManager");

}

}
}
#endif // LIBNYMEAAPPAIRCONDITIONING_H
