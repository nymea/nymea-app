#include "interface.h"

#include "eventtypes.h"
#include "statetypes.h"
#include "actiontypes.h"

Interface::Interface(const QString &name, const QString &displayName, QObject *parent) :
    QObject(parent),
    m_name(name),
    m_displayName(displayName),
    m_eventTypes(new EventTypes(this)),
    m_stateTypes(new StateTypes(this)),
    m_actionTypes(new ActionTypes(this))
{

}

QString Interface::name() const
{
    return m_name;
}

QString Interface::displayName() const
{
    return m_displayName;
}

EventTypes* Interface::eventTypes() const
{
    return m_eventTypes;
}

StateTypes* Interface::stateTypes() const
{
    return m_stateTypes;
}

ActionTypes* Interface::actionTypes() const
{
    return m_actionTypes;
}
