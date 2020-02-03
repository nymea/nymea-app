/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
*
* Copyright 2013 - 2020, nymea GmbH
* Contact: contact@nymea.io
*
* This file is part of nymea.
* This project including source code and documentation is protected by
* copyright law, and remains the property of nymea GmbH. All rights, including
* reproduction, publication, editing and translation, are reserved. The use of
* this project is subject to the terms of a license agreement to be concluded
* with nymea GmbH in accordance with the terms of use of nymea GmbH, available
* under https://nymea.io/license
*
* GNU General Public License Usage
* Alternatively, this project may be redistributed and/or modified under the
* terms of the GNU General Public License as published by the Free Software
* Foundation, GNU version 3. This project is distributed in the hope that it
* will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty
* of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General
* Public License for more details.
*
* You should have received a copy of the GNU General Public License along with
* this project. If not, see <https://www.gnu.org/licenses/>.
*
* For any further details and any questions please contact us under
* contact@nymea.io or see our FAQ/Licensing Information on
* https://nymea.io/license/faq
*
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

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
    static QPair<Types::Unit, QString> stringToUnit(const QString &unitString);
    static Types::InputType stringToInputType(const QString &inputTypeString);

};

#endif // JSONTYPES_H
