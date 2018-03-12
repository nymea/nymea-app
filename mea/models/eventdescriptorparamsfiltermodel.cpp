#include "eventdescriptorparamsfiltermodel.h"

#include "types/eventdescriptor.h"
#include "engine.h"

EventDescriptorParamsFilterModel::EventDescriptorParamsFilterModel(QObject *parent) : QSortFilterProxyModel(parent)
{

}

//int EventDescriptorParamsFilterModel::rowCount(const QModelIndex &parent) const
//{
//    Q_UNUSED(parent)
//    if (!m_eventDescriptor) {
//        return 0;
//    }
//    foreach (const Param &param, m_eventDescriptor->paramDescriptors()->rowCount())
//}

EventDescriptor *EventDescriptorParamsFilterModel::eventDescriptor() const
{
    return m_eventDescriptor;
}

void EventDescriptorParamsFilterModel::setEventDescriptor(EventDescriptor *eventDescriptor)
{
    if (m_eventDescriptor != eventDescriptor) {
        m_eventDescriptor = eventDescriptor;
        emit eventDescriptorChanged();
        Device *d = Engine::instance()->deviceManager()->devices()->getDevice(eventDescriptor->deviceId());
        if (!d) {
            qDebug() << "Can't find a device for this descriptor...";
            return;
        }
        DeviceClass* dc = Engine::instance()->deviceManager()->deviceClasses()->getDeviceClass(d->deviceClassId());
        if (!dc) {
            qDebug() << "Uh oh... No deviceClass for a device!?!11";
            return;
        }
        EventType* et = dc->eventTypes()->getEventType(eventDescriptor->eventTypeId());
        if (!et) {
            qDebug() << "Couldn't find eventtype";
            return;
        }
        setSourceModel(et->paramTypes());
        qDebug() << "have set source model" << et->paramTypes()->rowCount();
    }
}

QVariant::Type EventDescriptorParamsFilterModel::type() const
{
    return m_type;
}

void EventDescriptorParamsFilterModel::setType(QVariant::Type type)
{
    if (type != m_type) {
        m_type = type;
        emit typeChanged();
        invalidateFilter();
    }
}

ParamDescriptor *EventDescriptorParamsFilterModel::get(int idx) const
{
//    qDebug() << "...." << m_eventDescriptor->paramDescriptors()->get(mapToSource(index(idx, 0)).row())->paramTypeId()
    return m_eventDescriptor->paramDescriptors()->get(mapToSource(index(idx, 0)).row());
}

bool EventDescriptorParamsFilterModel::filterAcceptsRow(int source_row, const QModelIndex &source_parent) const
{
    Q_UNUSED(source_parent)
    ParamType *pd = dynamic_cast<ParamTypes*>(sourceModel())->get(source_row);

    Device *device = Engine::instance()->deviceManager()->devices()->getDevice(m_eventDescriptor->deviceId());
    if (!device) {
        qDebug() << "rejecting entry" << pd->id();
        return false;
    }
    qDebug() << "accepting entty:" << pd->id();
//    DeviceClass dc = Engine::instance()->deviceManager()->deviceClasses()->getDeviceClass(device->deviceClassId());
//    if (dc.paramTypes()->getParamType(pd->paramTypeId())->type() == m_type) {
        return true;
//    }
//    return false;
}
