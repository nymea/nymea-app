#include "interfaces.h"
#include "interface.h"

#include "eventtypes.h"
#include "eventtype.h"
#include "actiontypes.h"
#include "actiontype.h"
#include "statetype.h"
#include "statetypes.h"

#include "device.h"

#include "paramtypes.h"

Interfaces::Interfaces(QObject *parent) : QAbstractListModel(parent)
{
    ParamTypes *pts = nullptr;

    addInterface("battery", tr("Battery powered devices"));
    addStateType("battery", "batteryCritical", QVariant::Bool, false,
                 tr("Battery level is critical"),
                 tr("Battery level entered critical state"));


    addInterface("notifications", tr("Notification services"));
    pts = createParamTypes("title", tr("Title"), QVariant::String);
    addParamType(pts, "body", tr("Message body"), QVariant::String);
    addActionType("notifications", "notify", tr("Send notification"), pts);


    addInterface("light", tr("Lights"));
    addStateType("light", "power", QVariant::Bool, true,
                 tr("Light is turned on"),
                 tr("A light is turned on or off"),
                 tr("Turn lights on or off"));

    addInterface("temperaturesensor", tr("Temperature sensors"));
    addStateType("temperaturesensor", "temperature", QVariant::Double, false,
                 tr("Temperature"),
                 tr("Temperature has changed"));
}

int Interfaces::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent)
    return m_list.count();
}

QVariant Interfaces::data(const QModelIndex &index, int role) const
{
    switch (role) {
    case RoleName:
        return m_list.at(index.row())->name();
    case RoleDisplayName:
        return m_list.at(index.row())->displayName();
    }
    return QVariant();
}

QHash<int, QByteArray> Interfaces::roleNames() const
{
    QHash<int, QByteArray> roles;
    roles.insert(RoleName, "name");
    roles.insert(RoleDisplayName, "displayName");
    return roles;
}

Interface *Interfaces::get(int index) const
{
    return m_list.at(index);
}

Interface *Interfaces::findByName(const QString &name) const
{
    foreach (Interface* iface, m_list) {
        if (iface->name() == name) {
            return iface;
        }
    }
    return nullptr;
}

void Interfaces::addInterface(const QString &name, const QString &displayName)
{
    Interface *iface = new Interface(name, displayName, this);
    m_list.append(iface);
}

void Interfaces::addEventType(const QString &interfaceName, const QString &name, const QString &displayName, ParamTypes *paramTypes)
{
    Interface *iface = nullptr;
    foreach (Interface* i, m_list) {
        if (i->name() == interfaceName) {
            iface = i;
            break;
        }
    }
    Q_ASSERT_X(iface != nullptr, "Interfaces", "Interface not found");
    EventType *et = new EventType();
    et->setName(name);
    et->setDisplayName(displayName);
    et->setParamTypes(paramTypes);
    iface->eventTypes()->addEventType(et);
}

void Interfaces::addActionType(const QString &interfaceName, const QString &name, const QString &displayName, ParamTypes *paramTypes)
{
    Interface *iface = nullptr;
    foreach (Interface* i, m_list) {
        if (i->name() == interfaceName) {
            iface = i;
            break;
        }
    }
    Q_ASSERT_X(iface != nullptr, "Interfaces", "Interface not found");
    ActionType *at = new ActionType();
    at->setName(name);
    at->setDisplayName(displayName);
    at->setParamTypes(paramTypes);
    iface->actionTypes()->addActionType(at);
}

void Interfaces::addStateType(const QString &interfaceName, const QString &name, QVariant::Type type, bool writable, const QString &displayName, const QString &displayNameEvent, const QString &displayNameAction)
{
    Interface *iface = nullptr;
    foreach (Interface* i, m_list) {
        if (i->name() == interfaceName) {
            iface = i;
            break;
        }
    }
    Q_ASSERT_X(iface != nullptr, "Interfaces", "Interface not found");
    StateType *st = new StateType();
    st->setName(name);
    st->setDisplayName(displayName);
    st->setType(type);
    iface->stateTypes()->addStateType(st);
    ParamTypes *pts = createParamTypes(name, displayName, type);
    addEventType(interfaceName, name, displayNameEvent, pts);
    if (writable) {
        addActionType(interfaceName, name, displayNameAction, pts);
    }
}

ParamTypes *Interfaces::createParamTypes(const QString &name, const QString &displayName, QVariant::Type type, const QVariant &defaultValue, const QVariant &minValue, const QVariant &maxValue)
{
    ParamTypes *pts = new ParamTypes();
    ParamType *pt = new ParamType(name, type, defaultValue);
    pt->setDisplayName(displayName);
    pt->setMinValue(minValue);
    pt->setMaxValue(maxValue);
    pts->addParamType(pt);
    return pts;
}

void Interfaces::addParamType(ParamTypes *paramTypes, const QString &name, const QString &displayName, QVariant::Type type, const QVariant &defaultValue, const QVariant &minValue, const QVariant &maxValue)
{
    ParamType *pt = new ParamType(name, type, defaultValue);
    pt->setDisplayName(displayName);
    pt->setMinValue(minValue);
    pt->setMaxValue(maxValue);
    paramTypes->addParamType(pt);
}
