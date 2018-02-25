#include "interfaces.h"
#include "interface.h"

#include "eventtypes.h"
#include "eventtype.h"

Interfaces::Interfaces(QObject *parent) : QAbstractListModel(parent)
{

    Interface* iface = nullptr;
    EventType* ev = nullptr;
    ParamType* pt = nullptr;
    ParamTypes *pts = nullptr;

    iface = new Interface("battery", "Battery powered devices");
    ev = new EventType();
    pts = new ParamTypes(ev);
    ev->setParamTypes(pts);

    ev->setName("batteryLevel");
    ev->setDisplayName("Battery level changed");
    pt = new ParamType("batteryLevel", QVariant::Int, 50);
    pt->setDisplayName("Battery Level");
    qDebug() << "added param" << pt->type();
    pt->setMinValue(0);
    pt->setMaxValue(100);
    ev->paramTypes()->addParamType(pt);
    iface->eventTypes()->addEventType(ev);

    ev = new EventType();
    pts = new ParamTypes(ev);
    ev->setParamTypes(pts);
    ev->setName("batteryCritical");
    ev->setDisplayName("Battery level critical");
    pt = new ParamType("batteryCritical", QVariant::Bool, true);
    pt->setDisplayName("Battery critical");
    ev->paramTypes()->addParamType(pt);
    iface->eventTypes()->addEventType(ev);

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
