// SPDX-License-Identifier: GPL-3.0-or-later

/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
*
* Copyright (C) 2013 - 2024, nymea GmbH
* Copyright (C) 2024 - 2025, chargebyte austria GmbH
*
* This file is part of nymea-app.
*
* nymea-app is free software: you can redistribute it and/or modify
* it under the terms of the GNU General Public License as published by
* the Free Software Foundation, either version 3 of the License, or
* (at your option) any later version.
*
* nymea-app is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
* GNU General Public License for more details.
*
* You should have received a copy of the GNU General Public License
* along with nymea-app. If not, see <https://www.gnu.org/licenses/>.
*
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

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

