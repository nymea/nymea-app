/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 *                                                                         *
 *  Copyright (C) 2017 Simon Stuerz <simon.stuerz@guh.io>                  *
 *                                                                         *
 *  This file is part of nymea:app.                                      *
 *                                                                         *
 *  nymea:app is free software: you can redistribute it and/or modify    *
 *  it under the terms of the GNU General Public License as published by   *
 *  the Free Software Foundation, version 3 of the License.                *
 *                                                                         *
 *  nymea:app is distributed in the hope that it will be useful,         *
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of         *
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the           *
 *  GNU General Public License for more details.                           *
 *                                                                         *
 *  You should have received a copy of the GNU General Public License      *
 *  along with nymea:app. If not, see <http://www.gnu.org/licenses/>.    *
 *                                                                         *
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

#ifndef JSONTYPES_H
#define JSONTYPES_H

#include <QObject>
#include <QJsonDocument>
#include <QVariant>
#include <QUuid>

#include "types/types.h"
#include "types/deviceclass.h"

class Plugin;
class Vendor;

class StateType;
class EventType;
class ActionType;
class ParamType;

class Device;
class DeviceClasses;
class Param;
class Rule;
class StateEvaluator;
class RuleActions;
class EventDescriptors;
class TimeDescriptor;
class TimeEventItem;
class CalendarItem;
class RepeatingOption;

class JsonTypes : public QObject
{
    Q_OBJECT
public:
    explicit JsonTypes(QObject *parent = nullptr);

    static Vendor *unpackVendor(const QVariantMap &vendorMap);
    static Plugin *unpackPlugin(const QVariantMap &pluginMap, QObject *parent);
    static DeviceClass *unpackDeviceClass(const QVariantMap &deviceClassMap, QObject *parent);
    static void unpackParam(const QVariantMap &paramMap, Param *param);
    static ParamType *unpackParamType(const QVariantMap &paramTypeMap, QObject *parent);
    static StateType *unpackStateType(const QVariantMap &stateTypeMap, QObject *parent);
    static EventType *unpackEventType(const QVariantMap &eventTypeMap, QObject *parent);
    static ActionType *unpackActionType(const QVariantMap &actionTypeMap, QObject *parent);
    static Device *unpackDevice(const QVariantMap &deviceMap, DeviceClasses *deviceClasses, Device *oldDevice = nullptr);

    static QVariantMap packRule(Rule* rule);
    static QVariantList packRuleActions(RuleActions* ruleActions);
    static QVariantList packEventDescriptors(EventDescriptors* eventDescriptors);
    static QVariantMap packParam(Param *param);
    static QVariantMap packStateEvaluator(StateEvaluator* stateEvaluator);
    static QVariantMap packTimeDescriptor(TimeDescriptor* timeDescriptor);
    static QVariantMap packTimeEventItem(TimeEventItem* timeEventItem);
    static QVariantMap packCalendarItem(CalendarItem* calendarItem);
    static QVariantMap packRepeatingOption(RepeatingOption* repeatingOption);

private:
    static DeviceClass::SetupMethod stringToSetupMethod(const QString &setupMethodString);
    static QList<DeviceClass::BasicTag> stringListToBasicTags(const QStringList &basicTagsStringList);
    static QPair<Types::Unit, QString> stringToUnit(const QString &unitString);
    static Types::InputType stringToInputType(const QString &inputTypeString);

};

#endif // JSONTYPES_H
