#include "interfaces.h"
#include "interface.h"

#include "eventtypes.h"
#include "eventtype.h"
#include "actiontypes.h"
#include "actiontype.h"

Interfaces::Interfaces(QObject *parent) : QAbstractListModel(parent)
{

    Interface* iface = nullptr;
    EventType* et = nullptr;
    ActionType* at = nullptr;
    ParamType* pt = nullptr;
    ParamTypes *pts = nullptr;

    iface = new Interface("battery", "Battery powered devices", this);
    et = new EventType();
    pts = new ParamTypes(et);
    et->setParamTypes(pts);

    et->setName("batteryLevel");
    et->setDisplayName("Battery level changed");
    pt = new ParamType("batteryLevel", QVariant::Int, 50);
    pt->setDisplayName("Battery Level");
    qDebug() << "added param" << pt->type();
    pt->setMinValue(0);
    pt->setMaxValue(100);
    et->paramTypes()->addParamType(pt);
    iface->eventTypes()->addEventType(et);

    et = new EventType();
    pts = new ParamTypes(et);
    et->setParamTypes(pts);
    et->setName("batteryCritical");
    et->setDisplayName("Battery level critical");
    pt = new ParamType("batteryCritical", QVariant::Bool, true);
    pt->setDisplayName("Battery critical");
    et->paramTypes()->addParamType(pt);
    iface->eventTypes()->addEventType(et);

    m_list.append(iface);


    iface = new Interface("notification", "Notification services", this);
    at = new ActionType();
    pts = new ParamTypes(at);
    at->setParamTypes(pts);

    at->setName("notify");
    at->setDisplayName("Send notification");
    pt = new ParamType("title", QVariant::String);
    pt->setDisplayName("Title");
    at->paramTypes()->addParamType(pt);
    pt = new ParamType("body", QVariant::String);
    pt->setDisplayName("Message body");
    at->paramTypes()->addParamType(pt);
    iface->actionTypes()->addActionType(at);

    m_list.append(iface);

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
