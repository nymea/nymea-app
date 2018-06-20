#include "interfacesproxy.h"

#include "types/interface.h"
#include "types/interfaces.h"
#include "types/device.h"

#include "devices.h"
#include "engine.h"

InterfacesProxy::InterfacesProxy(QObject *parent): QSortFilterProxyModel(parent)
{
    m_interfaces = new Interfaces(this);
    setSourceModel(m_interfaces);
}

bool InterfacesProxy::showEvents() const
{
    return m_showEvents;
}

void InterfacesProxy::setShowEvents(bool showEvents)
{
    if (m_showEvents != showEvents) {
        m_showEvents = showEvents;
        emit showEventsChanged();
        invalidateFilter();
    }
}

bool InterfacesProxy::showActions() const
{
    return m_showActions;
}

void InterfacesProxy::setShowActions(bool showActions)
{
    if (m_showActions != showActions) {
        m_showActions = showActions;
        emit showActionsChanged();
        invalidateFilter();
    }
}

bool InterfacesProxy::showStates() const
{
    return m_showStates;
}

void InterfacesProxy::setShowStates(bool showStates)
{
    if (m_showStates != showStates) {
        m_showStates = showStates;
        emit showStatesChanged();
        invalidateFilter();
    }
}

bool InterfacesProxy::filterAcceptsRow(int source_row, const QModelIndex &source_parent) const
{
    Q_UNUSED(source_parent)
    qDebug() << "filterAcceptsRow";
    QString interfaceName = m_interfaces->get(source_row)->name();
    if (!m_shownInterfaces.isEmpty()) {
        if (!m_shownInterfaces.contains(interfaceName)) {
            return false;
        }
    }

    if (m_devicesFilter != nullptr) {
        // TODO: This could be improved *a lot* by caching interfaces in the devices model...
        bool found = false;
        for (int i = 0; i < m_devicesFilter->rowCount(); i++) {
            Device *d = m_devicesFilter->get(i);
            DeviceClass *dc = Engine::instance()->deviceManager()->deviceClasses()->getDeviceClass(d->deviceClassId());
            if (!dc) {
                qWarning() << "Cannot find DeviceClass for device:" << d->id() << d->name();
                return false;
            }
            if (dc->interfaces().contains(interfaceName)) {
                found = true;
                break;
            }
        }
        if (!found) {
            return false;
        }
    }

    Interface* iface = m_interfaces->get(source_row);
    if (m_showEvents) {
        if (iface->eventTypes()->rowCount() > 0) {
            return true;
        }
    }

    if (m_showActions) {
        if (iface->actionTypes()->rowCount() > 0) {
            return true;
        }
    }
    if (m_showStates) {
        if (iface->stateTypes()->rowCount() > 0) {
            return true;
        }
    }

    return false;
}

Interface *InterfacesProxy::get(int index) const
{
    return m_interfaces->get(mapToSource(this->index(index, 0)).row());
}
