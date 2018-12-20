#ifndef EVENTDESCRIPTOR_H
#define EVENTDESCRIPTOR_H

#include <QObject>
#include <QUuid>

#include "paramdescriptors.h"

class EventDescriptor : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString deviceId READ deviceId WRITE setDeviceId NOTIFY deviceIdChanged)
    Q_PROPERTY(QString eventTypeId READ eventTypeId WRITE setEventTypeId NOTIFY eventTypeIdChanged)

    Q_PROPERTY(QString interfaceName READ interfaceName WRITE setInterfaceName NOTIFY interfaceNameChanged)
    Q_PROPERTY(QString interfaceEvent READ interfaceEvent WRITE setInterfaceEvent NOTIFY interfaceEventChanged)

    Q_PROPERTY(ParamDescriptors* paramDescriptors READ paramDescriptors CONSTANT)

public:
    explicit EventDescriptor(QObject *parent = nullptr);

    QString deviceId() const;
    void setDeviceId(const QString &deviceId);

    QString eventTypeId() const;
    void setEventTypeId(const QString &eventTypeId);

    QString interfaceName() const;
    void setInterfaceName(const QString &interfaceName);

    QString interfaceEvent() const;
    void setInterfaceEvent(const QString &interfaceEvent);

    ParamDescriptors* paramDescriptors() const;

    EventDescriptor* clone() const;
    bool operator==(EventDescriptor* other) const;

signals:
    void deviceIdChanged();
    void eventTypeIdChanged();
    void interfaceNameChanged();
    void interfaceEventChanged();

private:
    QString m_deviceId;
    QString m_eventTypeId;

    QString m_interfaceName;
    QString m_interfaceEvent;

    ParamDescriptors *m_paramDescriptors;
};

#endif // EVENTDESCRIPTOR_H
